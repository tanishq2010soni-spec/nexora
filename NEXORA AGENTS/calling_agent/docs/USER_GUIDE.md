# User Guide

## Dashboard

The dashboard provides an at-a-glance overview of your call center operations.

### Key Metrics

- **Total Calls Today**: Number of calls handled today
- **Active Calls**: Currently active calls
- **Answer Rate**: Percentage of answered calls
- **Conversion Rate**: Percentage of calls resulting in conversions
- **Average Duration**: Average call length
- **Agent Performance**: Per-agent metrics

### Charts

- **Call Volume Trend**: Hourly/daily call volume
- **Disposition Breakdown**: Distribution of call outcomes
- **Campaign Performance**: Metrics per campaign
- **Agent Comparison**: Side-by-side agent performance

## Live Calls

Monitor active calls in real-time.

### Call Details

- **Participant Info**: Caller/callee numbers and names
- **Duration**: Elapsed and total call time
- **Status**: Current call state (ringing, in-progress, hold, etc.)
- **Transcript**: Live transcription of conversation
- **Sentiment**: Real-time sentiment analysis
- **AI Handling**: Whether AI is handling the call

### Actions

- **Monitor**: Listen to active calls (supervisor permission required)
- **Whisper**: Speak to agent without caller hearing
- **Barge**: Join the call (3-way conversation)
- **Handoff**: Transfer from AI to human agent
- **Hold**: Put caller on hold
- **Transfer**: Transfer to another number
- **Conference**: Add additional participants

## Queue

View and manage the call queue.

### Queue View

- **Position**: Current position in queue
- **Wait Time**: Time spent waiting
- **Lead Info**: Contact details
- **Priority**: Queue priority level

### Queue Management

- **Reorder**: Change queue priority
- **Assign**: Assign to specific agent
- **Remove**: Remove from queue
- **Schedule**: Set callback time

## Campaigns

Create and manage outbound calling campaigns.

### Creating a Campaign

1. Navigate to Campaigns > Create Campaign
2. Enter campaign details:
   - Name
   - Type (cold calling, warm calling, follow-up, etc.)
   - Script selection
   - Phone provider
   - Caller ID
3. Configure schedule:
   - Call window (start/end time)
   - Working days
   - Timezone
   - Max calls per day
4. Configure retry logic:
   - Max attempts per lead
   - Retry delay
5. Add leads manually or import from file

### Campaign Statuses

- **Draft**: Campaign is being configured but not running
- **Active**: Campaign is actively processing leads
- **Paused**: Campaign is temporarily stopped
- **Completed**: Campaign has finished processing all leads
- **Cancelled**: Campaign was cancelled before completion

### Campaign Actions

- **Start**: Begin processing leads
- **Pause**: Temporarily stop processing
- **Resume**: Continue processing after pause
- **Stop**: Complete the campaign

### Campaign Monitoring

- **Progress**: Calls made vs total scheduled
- **Answer Rate**: Percentage of calls answered
- **Conversion Rate**: Percentage of conversions
- **Cost Tracking**: Total and per-call costs
- **Lead Status**: Breakdown of lead outcomes

## Leads

Manage your lead database.

### Lead Properties

- **Contact Info**: Name, phone, email, company, position
- **Status**: new, contacted, qualified, disqualified, converted, lost
- **Score**: Lead score (0-100)
- **Source**: How lead was acquired
- **Tags**: Custom labels for categorization
- **Custom Fields**: Extended lead data
- **Call History**: Previous calls and dispositions

### Lead Management

- **Add**: Create new leads individually
- **Import**: Bulk import leads from CSV
- **Assign**: Assign leads to campaigns
- **Filter**: Filter by status, score, source, tags
- **Search**: Search by name, phone, email, company
- **Export**: Export lead data

### Lead Scoring

Leads are automatically scored based on:
- Company size and industry
- Engagement history
- Custom field values
- Source quality
- Previous call outcomes

## CRM

Contact relationship management.

### Contacts

- **Contact Details**: Name, phone, email, company, position
- **Call History**: All calls with this contact
- **Total Spend**: Total call cost for this contact
- **Lifetime Value**: Estimated customer value
- **Last Contact**: Date of last interaction

### Appointments

- **Schedule**: Create appointments from calls
- **Calendar View**: Visual appointment calendar
- **Reminders**: Automated appointment reminders
- **Status**: scheduled, confirmed, completed, cancelled, no-show

## Scripts

Create and manage call scripts.

### Script Editor

- **Rich Text**: Formatted script content
- **Variables**: Dynamic placeholders ({{name}}, {{company}}, etc.)
- **Sections**: Organized script structure
- **Versioning**: Track script changes

### Script Types

- **Cold Calling**: Initial outreach
- **Follow-up**: Re-engagement
- **Objection Handling**: Common objections
- **Closing**: Sales closing
- **Voicemail**: Voicemail messages
- **Appointment**: Appointment scheduling
- **Support**: Customer support
- **Welcome**: Welcome calls

## Recordings

Access and manage call recordings.

### Recording Features

- **Playback**: Listen to recordings
- **Download**: Download audio files
- **Transcript**: View auto-generated transcripts
- **Search**: Search by caller, date, duration
- **Archive**: Long-term storage

## Monitoring

Real-time system monitoring.

### Monitoring Features

- **Active Calls**: Currently active calls with details
- **System Health**: Server status, database status
- **Performance Metrics**: Response times, error rates
- **Resource Usage**: CPU, memory, disk usage
- **Provider Health**: Phone provider status

### Supervisor Features

- **Listen**: Monitor calls without participants knowing
- **Whisper**: Give instructions to agent privately
- **Barge**: Join call as third participant
- **Coach**: Provide real-time coaching
- **Takeover**: Take over call from agent

## Settings

Configure system settings.

### General Settings

- **Organization Profile**: Name, brand color, logo
- **Business Hours**: Operating hours and days
- **Timezone**: Default timezone
- **Phone Number**: Default outbound caller ID

### Voice Settings

- **STT Provider**: Whisper or Deepgram
- **TTS Provider**: pyttsx3 or ElevenLabs
- **TTS Voice**: Voice selection
- **VAD Provider**: WebRTC or Silero
- **Noise Suppression**: Enable/disable
- **Interruption Detection**: Enable/disable
- **Silence Timeout**: Silence duration before end of turn

### Phone Providers

- **Twilio**: Account SID, Auth Token, phone numbers
- **Exotel**: API Key, API Token, SID
- **Plivo**: Auth ID, Auth Token, phone numbers
- **SIP/PBX**: Server, credentials

### Team Management

- **Users**: Add/edit/remove users
- **Roles**: admin, supervisor, agent, viewer
- **Permissions**: Granular permission control
- **Extensions**: Phone extensions and SIP URIs

### Billing & Usage

- **Call Costs**: Per-provider cost tracking
- **Usage Reports**: Daily/weekly/monthly usage
- **Spending Limits**: Configure budget caps
