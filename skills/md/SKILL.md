---
name: md
description: Export the current chat/session to a Markdown (.md) file and send it back to the user. Use when the user asks to save, archive, or share the current conversation in Markdown (e.g., "save this chat as md", "/md", "export session").
---

# md

## Overview
Export the current conversation to a Markdown file, then send the file to the user in the same chat.

## Workflow
1) **Collect session messages**
   - Prefer using `sessions_history` for the current session if you can resolve its sessionKey.
   - If the sessionKey is unknown, use `sessions_list` to locate the active main session, then `sessions_history`.
   - If you still can’t resolve it, fall back to the visible conversation context and note that the export may be partial.

2) **Build Markdown**
   - Format with a simple structure:
     - Title: `# Chat Export`
     - Optional metadata (date/time, channel)
     - Each message: `**Role** (timestamp):` then content
   - Keep code blocks intact. Preserve ordering.

3) **Write file**
   - Save to: `/home/icewm/.openclaw/workspace/exports/chat-YYYYMMDD-HHMM.md`
   - Use `write` to create/overwrite as needed.

4) **Send to user**
   - Use `message` tool with `action=send` and `filePath`/`path` to send the .md file in the current chat.
   - If sending fails, provide the file path and offer to retry.
