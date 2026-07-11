# User Guide

## Getting Started

### Launching the App

1. Ensure the backend service is running (see DEVELOPER.md)
2. Launch the desktop application
3. You will see the Dashboard as the main screen

### Dashboard

The Dashboard is your home screen with:

- **Status Indicator** (top-right) - Green dot when connected to backend
- **Recent Conversations** (left) - Last 5 conversations, click to resume
- **System Health** (right) - Model status, memory usage, active tasks, uptime
- **Quick Actions** - New Chat, Search Memory, View Tasks, Open Settings
- **Quick Input** (bottom) - Type a message to start a new chat

## Chat

### Starting a Conversation

1. Click "New Chat" on Dashboard or sidebar
2. Type your message in the input bar
3. Press Enter or click Send

### Chat Interface

- **Left Sidebar**: Conversation list with search
- **Main Area**: Message history with scrolling
- **Message Bubbles**:
  - User messages: Indigo background, right-aligned
  - Assistant messages: Dark card, left-aligned
  - Markdown rendering for formatted responses
  - Code blocks with copy button
  - Tool call indicators when AI uses tools

### Input Bar Features

- **Text Input**: Type your message
- **Attach Button**: Upload files for the AI to process
- **Voice Button**: Voice input (coming soon)
- **Send Button**: Send your message

## Memory

The memory system stores information from your conversations and interactions.

### Browsing Memories

1. Open Memory Screen from Dashboard Quick Actions
2. Use search bar to find specific memories
3. Apply filters: memory type, date range, tags

### Memory Features

- **Type Badges**: Color-coded by type (Conversation, Fact, Preference, etc.)
- **Score Indicators**: Relevance score based on usage
- **Tag Cloud**: Visual tag navigation in the side panel
- **Expand/Collapse**: Click a memory to see full content and metadata
- **Actions**: Edit tags, delete, or summarize selected memories
- **Search Highlighting**: Matching terms are highlighted in results

## Tasks

The task system manages AI-executed multi-step operations.

### Creating Tasks

1. Type a task goal in the input field
2. Press Enter or click the task button
3. Optionally, use "Create Plan" to let AI break down a complex goal

### Task Management

- **Tabs**: Active | Completed | Failed
- **Task Cards**: Show goal, progress bar, status badge, timestamps
- **Expand**: Click a task to see individual steps
- **Step Status**: Each step shows pending/running/completed/failed
- **Actions**: Cancel (running), Delete (completed/failed), Retry (failed)

## Settings

See SETTINGS.md for detailed settings documentation.

## Character

The animated assistant character provides visual feedback.

### Expressions

- **Idle**: Gentle breathing animation
- **Happy**: Smiling eyes and mouth
- **Thinking**: Eyes looking up, head tilted
- **Listening**: Gentle pulse, attentive posture
- **Talking**: Animated mouth movement

### Interacting

- Character shows speech bubbles with typewriter animation
- Manual expression override via buttons
- Mouse tracking: eyes subtly follow cursor
- Settings: name, voice toggle, animation speed

## Permissions

When the AI wants to use a tool, it requests permission:

1. A permission card appears in the Permissions screen
2. Click to open the detail dialog with countdown timer
3. Choose: Allow Once, Allow Always, or Deny
4. History of all decisions is maintained

## Plugins

Extend AI capabilities by installing plugins:

1. Open Plugins screen
2. View installed plugins in grid layout
3. Toggle plugins on/off
4. Click a plugin to see details: capabilities, permissions, hooks
5. Install new plugins via the Install button

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Ctrl+N | New conversation |
| Ctrl+Shift+M | Toggle sidebar |
| Ctrl+, | Open settings |
| Escape | Close current panel |
| Ctrl+Enter | Send message (with newline in input) |

## Tips

- Use the memory system to store facts and preferences for the AI to reference
- Break complex requests into tasks for step-by-step execution
- Review permission history to audit AI actions
- Install plugins to add specialized capabilities
- The character's expressions provide visual cues about AI state
