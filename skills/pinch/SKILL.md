---
name: pinch
description: Use Pinchtab (HTTP browser bridge) to open links or run searches when the user says “/pinch URL”, “用pinchtab打开…”, or “用pinchtab搜索…”. This skill starts Pinchtab if needed, checks /health, opens a URL or search results, and can snapshot/text/screenshot via the Pinchtab HTTP API.
---

# Pinch

## Overview
Use Pinchtab’s HTTP API to open a URL or perform a search in a visible (headed) Chrome session, with persistent profile at `~/.pinchtab/chrome-profile`.

## Workflow

### 1) Ensure Pinchtab is running
Prefer the default startup script (headed mode with DISPLAY):

```bash
/home/icewm/.openclaw/workspace/tools/pinchtab-start.sh
```

Health check:
```bash
curl -s http://127.0.0.1:9867/health
```

### 2) Open a URL ("/pinch <url>" or “用pinchtab打开 <url>”)
Use `/navigate` (POST) to open the URL in the current tab:

```bash
curl -s -X POST http://127.0.0.1:9867/navigate \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://github.com"}'
```

If you need a new tab first, create one with `/tab` and then navigate (optional):

```bash
curl -s -X POST http://127.0.0.1:9867/tab \
  -H 'Content-Type: application/json' \
  -d '{"kind":"new"}'
```

### 3) Search ("用pinchtab搜索 <query>")
Default to Bing for search queries:

```bash
curl -s -X POST http://127.0.0.1:9867/navigate \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://www.bing.com/search?q=YOUR_QUERY"}'
```

(Replace `YOUR_QUERY` with URL-encoded text.)

### 4) Read or act on the page (as needed)
- Snapshot:
  ```bash
  curl -s "http://127.0.0.1:9867/snapshot?filter=interactive"
  ```
- Text extraction:
  ```bash
  curl -s "http://127.0.0.1:9867/text"
  ```
- Screenshot:
  ```bash
  curl -s "http://127.0.0.1:9867/screenshot"
  ```

Use `/tabs` to get `tabId` if multiple tabs exist:
```bash
curl -s http://127.0.0.1:9867/tabs
```

## Notes
- Pinchtab headed mode needs `DISPLAY` and a running X server.
- Persistent profile: `~/.pinchtab/chrome-profile`.
- If Pinchtab is down, restart it with the startup script before navigating.
