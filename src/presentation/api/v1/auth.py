import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.application.services.auth_service import AuthService
from src.application.services.audit_service import AuditService
from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import User, Organization, Agent
from src.infrastructure.logging.logger import get_logger
from src.presentation.schemas.auth import UserRegister, UserLogin, TokenResponse, RefreshTokenRequest

logger = get_logger(__name__)

router = APIRouter()


@router.post("/signup", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def signup(data: UserRegister, db: AsyncSession = Depends(get_db_session)) -> TokenResponse:
    """
    Registers a new user and automatically spins up a dedicated multi-tenant Organization container
    along with a default Receptionist Agent.
    """
    # Verify user does not already exist
    stmt = select(User).where(User.email == data.email)
    result = await db.execute(stmt)
    existing_user = result.scalar_one_or_none()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email address already exists."
        )

    # 1. Create Organization
    org = Organization(id=uuid.uuid4(), name=data.organization_name)
    db.add(org)

    # 2. Create User
    hashed_pwd = AuthService.hash_password(data.password)
    user = User(
        id=uuid.uuid4(),
        org_id=org.id,
        email=data.email,
        password_hash=hashed_pwd,
        role="admin"
    )
    db.add(user)

    # 3. Create Default Agent
    default_agent = Agent(
        id=uuid.uuid4(),
        org_id=org.id,
        name="Nexora Receptionist",
        platform_type="web",
        system_prompt="You are Nexora, a helpful receptionist. Assist the user with services and policies.",
        llm_model="llama3",
        temperature=0.7
    )
    db.add(default_agent)

    await db.commit()
    await db.refresh(user)

    await AuditService.log(
        db=db,
        action="CREATE",
        resource="user",
        org_id=org.id,
        user_email=user.email,
        detail=f"User signup for organization '{data.organization_name}'",
    )
    await db.commit()

    # Create tokens
    token_claims = {"sub": user.email, "org_id": str(org.id), "role": user.role}
    access_token = AuthService.create_access_token(token_claims)
    refresh_token = AuthService.create_refresh_token(token_claims)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        org_id=org.id,
        email=user.email,
        role=user.role
    )


@router.post("/login", response_model=TokenResponse)
async def login(data: UserLogin, db: AsyncSession = Depends(get_db_session)) -> TokenResponse:
    """
    Exchanges valid email & password credentials for a secure multi-tenant JWT claim token.
    """
    user = await AuthService.authenticate_user(db, data.email, data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    await AuditService.log(
        db=db,
        action="LOGIN",
        resource="user",
        org_id=user.org_id,
        user_email=user.email,
        detail="User login",
    )
    await db.commit()

    token_claims = {"sub": user.email, "org_id": str(user.org_id), "role": user.role}
    access_token = AuthService.create_access_token(token_claims)
    refresh_token = AuthService.create_refresh_token(token_claims)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        org_id=user.org_id,
        email=user.email,
        role=user.role
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    data: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db_session),
) -> TokenResponse:
    """
    Exchanges a valid refresh token for a new access/refresh token pair.
    """
    payload = AuthService.decode_refresh_token(data.refresh_token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    email = payload.get("sub")
    if not email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token claims.",
        )

    stmt = select(User).where(User.email == email)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User no longer exists.",
        )

    token_claims = {"sub": user.email, "org_id": str(user.org_id), "role": user.role}
    new_access = AuthService.create_access_token(token_claims)
    new_refresh = AuthService.create_refresh_token(token_claims)

    return TokenResponse(
        access_token=new_access,
        refresh_token=new_refresh,
        org_id=user.org_id,
        email=user.email,
        role=user.role
    )
