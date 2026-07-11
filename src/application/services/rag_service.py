import uuid
from typing import Any, Dict, List, Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.application.interfaces.embedding_service import EmbeddingService, VectorDBRepository
from src.application.interfaces.llm_service import LLMService
from src.application.interfaces.customer_repository import CustomerRepository
from src.application.interfaces.lead_repository import LeadRepository
from src.domain.models.customer import Customer
from src.domain.models.lead import Lead
from src.infrastructure.database.models import Agent, BusinessProfile, ChatSession, Message
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)


class RAGService:
    def __init__(
        self,
        embedding_service: EmbeddingService,
        vector_db: VectorDBRepository,
        llm_service: LLMService,
        customer_repo: CustomerRepository,
        lead_repo: LeadRepository,
    ):
        self.embedding_service = embedding_service
        self.vector_db = vector_db
        self.llm_service = llm_service
        self.customer_repo = customer_repo
        self.lead_repo = lead_repo

    async def execute_chat_turn(
        self,
        db: AsyncSession,
        org_id: uuid.UUID,
        session_id: uuid.UUID,
        agent_id: uuid.UUID,
        user_message: str,
        customer_phone: str,
    ) -> Dict[str, Any]:
        """
        Coordinates full RAG query execution, memory retrieval, Llama3 generation,
        lead extraction, and data saving.
        """
        logger.info("Executing chat agent turn", session_id=str(session_id), phone=customer_phone)

        # 1. Fetch Agent configurations
        agent_stmt = select(Agent).where(Agent.id == agent_id, Agent.org_id == org_id)
        agent_result = await db.execute(agent_stmt)
        agent = agent_result.scalar_one_or_none()
        if not agent:
            raise ValueError(f"Agent with ID {agent_id} not found.")

        # 2. Fetch Business Profile
        profile_stmt = select(BusinessProfile).where(BusinessProfile.org_id == org_id)
        profile_result = await db.execute(profile_stmt)
        profile = profile_result.scalar_one_or_none()
        profile_context = ""
        if profile:
            profile_context = (
                f"=== BUSINESS INFORMATION ===\n"
                f"Name: {profile.name}\n"
                f"Type: {profile.business_type}\n"
                f"Address: {profile.address}\n"
                f"Phone: {profile.phone}\n"
                f"Email: {profile.email}\n"
                f"Website: {profile.website or 'N/A'}\n"
                f"Working Hours: {profile.working_hours or 'N/A'}\n"
                f"Services: {profile.services or 'N/A'}\n"
                f"Policies: {profile.policies or 'N/A'}\n"
            )

        # 3. Retrieve Customer Memory
        customer = await self.customer_repo.get_by_phone(org_id, customer_phone)
        customer_context = ""
        if customer:
            customer_context = (
                f"=== CUSTOMER PROFILE ===\n"
                f"Customer Name: {customer.name or 'Unknown'}\n"
                f"Customer Phone: {customer.phone}\n"
                f"Saved Customer Preferences: {customer.preferences or 'None'}\n"
                f"Customer Notes: {customer.notes or 'None'}\n"
            )
        else:
            # Create a basic customer record placeholder if new
            customer = Customer(
                org_id=org_id,
                phone=customer_phone,
                name=None,
                preferences="First interaction"
            )
            await self.customer_repo.create(customer)

        # 4. Query Vector Database for RAG context
        query_vector = await self.embedding_service.generate_embedding(user_message)
        relevant_chunks = await self.vector_db.search(str(org_id), query_vector, limit=4)
        
        chunks_context = ""
        sources = []
        if relevant_chunks:
            chunks_context = "=== RELEVANT DOCUMENTS CONTEXT ===\n"
            for chunk in relevant_chunks:
                chunks_context += f"Source ({chunk['metadata'].get('filename', 'Unknown')}): {chunk['text']}\n\n"
                sources.append(chunk['metadata'].get('filename', 'Unknown'))
            sources = list(set(sources))  # deduplicate

        # 5. Fetch Session History
        history_stmt = select(Message).where(Message.session_id == session_id).order_by(Message.created_at.asc())
        history_result = await db.execute(history_stmt)
        messages_history = history_result.scalars().all()
        
        history_list = []
        for msg in messages_history[-10:]:  # Limit to last 10 turns for context windows
            history_list.append({"role": msg.role, "content": msg.content})

        # 6. Build Prompts
        system_base = (
            "You are Nexora, an AI receptionist for the business.\n"
            "Your behavior must adhere strictly to these rules:\n"
            "1. ONLY use facts described in the BUSINESS INFORMATION or RELEVANT DOCUMENTS CONTEXT.\n"
            "2. Never invent facts, phone numbers, email addresses, or working hours. If information is missing, politely say you don't have that detail and offer to connect them to a human representative.\n"
            "3. Try to capture customer information (Name, Email, Product Interest, Budget) when natural to help create leads.\n"
            "4. Ask clarifying questions if the query is ambiguous.\n"
            "5. Escalate to uncertainty by offering human support if you are not sure about an answer.\n\n"
        )
        
        full_system_prompt = f"{system_base}\n{profile_context}\n{customer_context}\n{chunks_context}"

        # 7. Generate Response via LLM
        assistant_content = await self.llm_service.generate_response(
            prompt=user_message,
            system_prompt=full_system_prompt,
            history=history_list,
            temperature=agent.temperature,
        )

        # 8. Extract Lead Information asynchronously/inline
        lead_schema = {
            "type": "object",
            "properties": {
                "name": {"type": "string", "description": "Customer name, if mentioned"},
                "email": {"type": "string", "description": "Customer email, if mentioned"},
                "intent": {"type": "string", "description": "Reason for interaction, e.g., booking, purchase"},
                "product_interest": {"type": "string", "description": "Product or service they are asking about"},
                "budget": {"type": "number", "description": "Indicated budget figure, if mentioned"}
            },
            "required": []
        }
        
        extraction_prompt = (
            f"Analyze the following conversation segment and extract customer lead details.\n"
            f"User message: '{user_message}'\n"
            f"Assistant response: '{assistant_content}'\n"
        )
        
        extracted_data = await self.llm_service.generate_structured_json(
            prompt=extraction_prompt,
            response_schema=lead_schema,
            system_prompt="Extract lead attributes from the interaction. If a field is missing, return null."
        )

        # Save lead to PostgreSQL if name, email, or product_interest is extracted
        lead_saved = False
        if extracted_data and any(v is not None for v in extracted_data.values()):
            # Deduplication: check if lead already exists for this email or phone
            existing = await self.lead_repo.find_duplicate(
                org_id,
                email=extracted_data.get("email"),
                phone=customer_phone,
            )
            if not existing:
                new_lead = Lead(
                    org_id=org_id,
                    session_id=session_id,
                    name=extracted_data.get("name"),
                    phone=customer_phone,
                    email=extracted_data.get("email"),
                    intent=extracted_data.get("intent"),
                    product_interest=extracted_data.get("product_interest"),
                    budget=extracted_data.get("budget"),
                )
                await self.lead_repo.create(new_lead)
                lead_saved = True
                logger.info("Captured and saved lead details to database", email=new_lead.email)
            else:
                logger.info("Duplicate lead skipped", email=extracted_data.get("email"), phone=customer_phone)

            # Update Customer name in memory if extracted and currently missing
            if extracted_data.get("name") and not customer.name:
                customer.name = extracted_data.get("name")

            # Accumulate preferences or interest notes
            interest = extracted_data.get("product_interest")
            if interest:
                customer.preferences = f"{customer.preferences or ''}; Interested in {interest}".strip("; ")

            await self.customer_repo.update(customer)

        # 9. Record User and Assistant messages to Database
        db_user_msg = Message(
            id=uuid.uuid4(),
            session_id=session_id,
            role="user",
            content=user_message,
        )
        db_assistant_msg = Message(
            id=uuid.uuid4(),
            session_id=session_id,
            role="assistant",
            content=assistant_content,
        )
        db.add(db_user_msg)
        db.add(db_assistant_msg)
        await db.commit()

        return {
            "response": assistant_content,
            "sources": sources,
            "lead_captured": lead_saved,
            "extracted_fields": extracted_data
        }
