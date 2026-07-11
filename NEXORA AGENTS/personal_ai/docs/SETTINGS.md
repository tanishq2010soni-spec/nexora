# Settings Guide

## Overview

The Settings panel is organized into 8 tabbed sections. All settings are persisted locally and synced to the backend when available.

## General

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Workspace Path | Path | `~/nexora` | Root directory for AI file operations |
| Language | Selector | English | UI language |
| Max Conversation History | Slider (10-200) | 100 | Number of conversations kept in history |

## Model

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Model | Dropdown | gpt-4 | AI model to use for responses |
| Temperature | Slider (0-2) | 0.7 | Controls response randomness (lower = more focused) |
| Context Window | Slider (1K-128K) | 8192 | Maximum tokens for model context |

### Supported Models

- GPT-4, GPT-3.5-Turbo (OpenAI)
- Claude 3 Opus, Claude 3 Sonnet (Anthropic)
- Local (Ollama, llama.cpp)

## Memory

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Memory Limit | Slider (50-5000) | 1000 | Maximum stored memory entries |
| Auto-Prune | Toggle | true | Automatically remove oldest entries when limit reached |
| Summarization | Toggle | true | Auto-summarize related memories into concise entries |

## Tools

Permission toggles for each tool category the AI can use:

| Tool | Default | Risk |
|------|---------|------|
| Mouse | Off | Medium - Can control cursor |
| Keyboard | Off | High - Can type text |
| Files | Off | Medium - Can read/write files |
| Browser | Off | Medium - Can browse web |
| Terminal | Off | High - Can execute commands |
| Camera | Off | High - Can capture images |
| Microphone | Off | High - Can record audio |

Each tool can be independently enabled or disabled.

## Appearance

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Theme | Selector | Dark | Dark theme (only option currently) |
| Font Size | Slider (12-24) | 14 | UI font size in pixels |
| Accent Color | Color Picker | Indigo | Primary accent color for the UI |

### Accent Colors

Choose from: Indigo, Teal, Amber, Pink, Cyan, Lime, Deep Orange, Purple

## Voice

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Voice Enabled | Toggle | false | Enable voice input/output |
| Voice | Dropdown | Default | TTS voice selection |
| Speech Speed | Slider (0.5-2.0) | 1.0 | Voice playback speed |

## Plugins

Manage installed plugins. Each plugin can be individually enabled or disabled. See the PLUGINS.md for details on installing and developing plugins.

## Automation

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Enable Automation | Toggle | false | Allow AI to run automated task sequences |
| Max Concurrent Tasks | Slider (1-20) | 5 | Maximum parallel task execution |
| Default Timeout | Slider (10-300s) | 60 | Default timeout for each task step |

## Saving Settings

- Individual settings auto-save on change
- Use "Save All" button to persist all settings at once
- Settings are stored in `~/.nexora/settings.json`
