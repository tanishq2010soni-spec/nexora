# User Guide

## Dashboard

The Dashboard provides a real-time overview of your WhatsApp operations. Key metrics include:

- **Active Conversations** — Number of ongoing conversations
- **Unread Messages** — Messages awaiting response
- **Leads Generated** — New leads created in the period
- **Conversion Rate** — Percentage of leads converted to customers
- **Response Time** — Average time to first response

Filters allow you to view data by date range (7, 30, 90 days) and by department.

## Inbox

The Inbox is the central hub for managing WhatsApp conversations.

### Conversation List

- Shows all active conversations sorted by most recent message
- Each conversation displays customer name/phone, last message preview, and status
- Status indicators: unread (bold), pinned, archived, AI-active
- Filter conversations by status, department, assignee, or search by customer name/phone

### Conversation Detail

Click a conversation to view the full message history. From here you can:

- **View messages** in chronological order with customer/agent labels
- **Send a reply** by typing in the message input and pressing Enter
- **Toggle AI** on/off to enable or disable automatic AI responses
- **Assign conversation** to yourself or another team member
- **Change status** (active, paused, resolved, archived)
- **Pin/Unpin** conversation for quick access
- **Add tags** for categorization
- **Request handoff** to a human agent with an optional note
- **Accept handoff** requests from AI

### Handoff System

When a conversation requires human intervention:

1. **Request** — An agent or the AI requests a handoff
2. **Accept** — A human agent accepts the handoff
3. **Complete** — The human agent marks the handoff as complete

## CRM

The CRM module manages leads and customers throughout the sales pipeline.

### Leads

A lead represents a potential customer identified through WhatsApp conversations.

**Lead Statuses:**
- **New** — Recently identified, not yet contacted
- **Qualified** — Meets qualification criteria (score-based)
- **Disqualified** — Does not meet criteria
- **Converted** — Successfully converted to customer
- **Lost** — Opportunity lost

**Lead Actions:**
- Update pipeline stage (new_lead → contacted → qualified → proposal → negotiation → closed_won/closed_lost)
- Update lead score (0-100)
- Assign to a salesperson
- Add notes
- Tag for categorization
- Convert to customer

**Lead Scoring:**

The system automatically scores leads based on:
- Message frequency (20%)
- Response rate (20%)
- Sentiment analysis (20%)
- Intent detection (25%)
- Response time (20%)
- Custom fields (15%)

Scores range from 0 to 100.

### Customers

Converted leads become customers. The customer record stores:

- Contact information (phone, email, name)
- Tier classification (bronze, silver, gold, platinum)
- Lifetime value tracking
- Conversation history
- Custom fields

### Pipeline Stages

1. **New Lead** — Initial identification
2. **Contacted** — First contact made
3. **Qualified** — Lead meets qualification criteria
4. **Proposal** — Proposal sent to lead
5. **Negotiation** — Price/service negotiation
6. **Closed Won** — Lead converted to customer
7. **Closed Lost** — Opportunity lost

## Knowledge Base

The Knowledge Base stores documents, FAQs, and reference materials that the AI uses to answer customer questions.

### Document Management

- **Upload** documents (PDF, DOCX, XLSX, CSV, Markdown, TXT)
- **Tag** documents for categorization
- **Search** across all document content
- **Index** documents for AI retrieval

### Supported File Types

| Type     | Extensions                    |
|----------|-------------------------------|
| PDF      | .pdf                          |
| Word     | .docx                         |
| Excel    | .xlsx                         |
| CSV      | .csv                          |
| Markdown | .md                           |
| Text     | .txt                          |
| Image    | .png, .jpg, .jpeg (OCR)       |
| Website  | URL (web scraping)            |
| FAQ      | Manual entry                  |

### FAQ Management

Create FAQ entries that the AI can directly reference. FAQ entries are automatically indexed and prioritized in search results.

### Querying

The knowledge base supports full-text search across all indexed documents. Results are ranked by relevance based on term frequency matching.

## Workflows

Workflows automate business processes triggered by events.

### Trigger Types

| Trigger            | Description                          |
|--------------------|--------------------------------------|
| New Lead           | When a new lead is created           |
| New Message        | When a new message arrives           |
| Lead Qualified     | When a lead reaches qualified status |
| Lead Converted     | When a lead is converted             |
| Campaign Completed | When a campaign finishes             |
| Schedule           | Time-based execution                 |
| Webhook            | External webhook trigger             |

### Action Types

| Action              | Description                          |
|---------------------|--------------------------------------|
| Send Message        | Send an automated message            |
| Create Lead         | Create a new lead record             |
| Update Lead         | Update lead status/stage             |
| Assign Salesperson  | Assign lead to a team member         |
| Notify Team         | Send notification to team            |
| Schedule Follow-up  | Schedule a future action             |
| Add Tag             | Add tag to conversation/lead         |
| Send Email          | Send email notification              |
| Webhook             | Call external webhook                |
| Condition           | Conditional branching                |
| Delay               | Wait before next step                |

### Creating a Workflow

1. Go to Workflows in the sidebar
2. Click "Create Workflow"
3. Set a name and description
4. Choose a trigger type and configure it
5. Add steps (actions) in sequence
6. Test the workflow
7. Activate it

## Campaigns

Campaigns allow you to send bulk messages to customers.

### Campaign Types

- **Broadcast** — Send a single message to all recipients at once
- **Drip** — Send a series of messages on a schedule
- **Trigger** — Send messages based on specific events

### Creating a Campaign

1. Go to Campaigns
2. Click "New Campaign"
3. Set campaign name and type
4. Write the message template
5. Define target filter (customer tier, tags, etc.)
6. Schedule or send immediately
7. Monitor delivery, read, and reply rates

### Campaign Statuses

- **Draft** — Being configured, not yet sent
- **Scheduled** — Queued for future delivery
- **Sending** — Currently being delivered
- **Completed** — All messages sent
- **Cancelled** — Stopped before completion

## Analytics

Analytics provides insights into your operations.

### Overview Metrics

- Total conversations, messages, leads
- Qualified and converted leads
- Conversion and qualification rates

### Conversation Analytics

Daily breakdown of new conversations over time.

### Lead Analytics

- Daily lead creation trend
- Lead status distribution

### Response Time

Average time to first human response across conversations.

### Revenue

Track revenue attributed to the platform.

### Customer Satisfaction

Monitor average satisfaction scores from feedback.

### Model Usage

Track AI token usage and associated costs.

## Settings

### Organization Settings

- Brand information (name, color, logo)
- Working hours and days
- Default language
- Rate limits and quotas

### Prompt Templates

Manage AI behavior by customizing system prompts:

- **System Prompt** — Defines the AI's role and behavior
- **Context Prompt** — Additional context for the AI
- **Temperature** — Controls response creativity (0.0-1.0)
- **Max Tokens** — Maximum response length
- **Model** — Which AI model to use

### Model Configuration

- Default AI model
- Available models list
- Max tokens
- Temperature

## Permissions

Role-based access control for team members.

### Roles

| Role       | Permissions                                   |
|------------|-----------------------------------------------|
| Admin      | Full access to all features                   |
| Supervisor | Most features except advanced settings/permissions |
| Agent      | Inbox, CRM, basic analytics                   |
| Viewer     | Read-only access to dashboard, inbox, CRM     |

### Managing Permissions

Admins can assign granular permissions to individual users beyond their role defaults.
