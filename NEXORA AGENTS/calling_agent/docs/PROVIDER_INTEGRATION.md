# Phone Provider Integration

## Overview

The calling agent supports multiple phone providers for making and receiving calls. Each provider integrates through a common interface with provider-specific webhook handling.

## Twilio

### Setup

1. Create a Twilio account at https://www.twilio.com
2. Navigate to Console > Account Info and note your Account SID and Auth Token
3. Purchase a phone number (Console > Phone Numbers > Buy a Number)
4. Configure environment variables:
```env
CA_TWILIO_ACCOUNT_SID=your_account_sid
CA_TWILIO_AUTH_TOKEN=your_auth_token
CA_TWILIO_PHONE_NUMBER=+15551234567
CA_WEBHOOK_BASE_URL=https://your-domain.com
```

### TwiML Configuration

In your Twilio Console, configure your phone number's voice settings:
- **Voice URL**: `https://your-domain.com/api/v1/webhooks/twilio/voice`
- **Status Callback**: `https://your-domain.com/api/v1/webhooks/twilio/status`

### Call Flow

```
1. Twilio receives incoming call
2. Twilio sends POST to /webhooks/twilio/voice with Call data
3. Application responds with TwiML (say, gather, dial, etc.)
4. Twilio executes TwiML instructions
5. For outbound calls, application uses Twilio REST API:
   POST https://api.twilio.com/2010-04-01/Accounts/{SID}/Calls.json
6. Twilio sends status callbacks as call progresses
7. On call completion, Twilio sends final status callback
```

### Webhook Handling

**Incoming Voice Webhook:**
```json
{
  "CallSid": "CA123...",
  "From": "+15551234567",
  "To": "+15559876543",
  "CallStatus": "ringing",
  "Direction": "inbound",
  "AccountSid": "AC...",
  "ApiVersion": "2010-04-01"
}
```

**Status Callback:**
```json
{
  "CallSid": "CA123...",
  "CallStatus": "completed",
  "Duration": 120,
  "From": "+15551234567",
  "To": "+15559876543",
  "Direction": "outbound-api",
  "StartTime": "2024-01-01T00:00:00Z",
  "EndTime": "2024-01-01T00:02:00Z"
}
```

### TwiML Response Examples

**Simple greeting:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="alice">Hello, this is an AI calling agent.</Say>
</Response>
```

**With speech input:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather input="speech" language="en-US" timeout="5">
    <Say voice="alice">How can I help you today?</Say>
  </Gather>
</Response>
```

**Dialing a number:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Dial callerId="+15551234567">
    +15559876543
  </Dial>
</Response>
```

## Exotel

### Setup

1. Create an Exotel account at https://exotel.com
2. Get your API Key and API Token from the dashboard
3. Note your Exotel SID
4. Configure environment variables:
```env
CA_EXOTEL_API_KEY=your_api_key
CA_EXOTEL_API_TOKEN=your_api_token
CA_EXOTEL_SID=your_exotel_sid
CA_WEBHOOK_BASE_URL=https://your-domain.com
```

### Call Flow

```
1. Exotel receives incoming call at your Exotel number
2. Exotel sends POST to application webhook with call details
3. Application responds with call instructions (via Applet/API response)
4. For outbound, use Exotel API:
   POST https://api.exotel.com/v1/Accounts/{SID}/Calls/connect
5. Exotel sends call status updates
```

### Webhook Payload

```json
{
  "CallSid": "e3b0c442...",
  "From": "+15551234567",
  "To": "+15559876543",
  "CallStatus": "in-progress",
  "CallType": "incoming",
  "CallDuration": 0
}
```

## Plivo

### Setup

1. Create a Plivo account at https://www.plivo.com
2. Get Auth ID and Auth Token from the console
3. Purchase a phone number
4. Configure environment variables:
```env
CA_PLIVO_AUTH_ID=your_auth_id
CA_PLIVO_AUTH_TOKEN=your_auth_token
CA_PLIVO_PHONE_NUMBER=+15551234567
CA_WEBHOOK_BASE_URL=https://your-domain.com
```

### Call Flow

```
1. Plivo receives incoming call
2. Plivo sends POST to answer URL with call data
3. Application responds with Plivo XML
4. Plivo executes XML instructions
5. For outbound, use Plivo API:
   POST https://api.plivo.com/v1/Account/{AuthID}/Call/
6. Plivo sends status callbacks
```

### Plivo XML Response

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Speak>Hello, this is an AI calling agent.</Speak>
</Response>
```

## SIP/PBX

### Setup

1. Configure your SIP server or PBX
2. Set up SIP credentials
3. Configure environment variables:
```env
CA_SIP_USERNAME=your_sip_username
CA_SIP_PASSWORD=your_sip_password
CA_SIP_SERVER=sip.example.com:5060
```

### Integration

SIP/PBX integration uses standard SIP protocol for:
- Registration with SIP server
- Making outbound calls via SIP INVITE
- Receiving inbound calls
- RTP audio streaming

Configuration is done through the PhoneProviderConfig with provider_type="sip" or provider_type="pbx".

## Custom Provider

To add a custom phone provider, implement the provider interface:

```python
from backend.infrastructure.phone.base import PhoneProvider

class CustomPhoneProvider(PhoneProvider):
    async def make_call(self, to: str, from_: str, **kwargs) -> dict:
        # Implement outbound call
        pass

    async def end_call(self, call_id: str) -> dict:
        # Implement call termination
        pass

    async def handle_webhook(self, data: dict) -> dict:
        # Implement webhook handling
        pass

    async def get_call_status(self, call_id: str) -> dict:
        # Implement status check
        pass
```

Then register it in the phone provider factory and manage it through the PhoneProviderConfig entity and API endpoints.
