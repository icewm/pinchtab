# pinchtab

**English** | [中文](docs/README.zh.md)

**Description:** A lightweight HTTP browser bridge for AI automation and visible debugging.

- 12MB Go binary, zero config
- Control Chrome via HTTP
- Headed/headless modes with persistent sessions

## Features

- **HTTP API** for any language or script
- **Headed mode** for login/debugging
- **Persistent profile** keeps auth across restarts
- **Basic interactions**: click, type, screenshot, extract text

## Installation

### Docker (recommended)
```bash
docker run -d -p 9867:9867 --security-opt seccomp=unconfined pinchtab/pinchtab
curl http://127.0.0.1:9867/health
```

### Build from source
```bash
go build -o pinchtab .
```

## Run

### Headed (default)
```bash
./pinchtab
```

### Headless
```bash
BRIDGE_HEADLESS=true ./pinchtab
```

### GUI environments (WSL/remote)
Ensure `DISPLAY` is set:
```bash
export DISPLAY=:0
./pinchtab
```

## Quick Start

Health check:
```bash
curl http://127.0.0.1:9867/health
```

Open a page:
```bash
curl -X POST http://127.0.0.1:9867/navigate \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://github.com"}'
```

Extract text:
```bash
curl http://127.0.0.1:9867/text
```

Interactive snapshot:
```bash
curl http://127.0.0.1:9867/snapshot?filter=interactive
```

Screenshot:
```bash
curl http://127.0.0.1:9867/screenshot
```

## OpenClaw Skill (pinch)

This repo includes **pinch.skill** so OpenClaw agents can use Pinchtab directly.

### Usage

1. Download `pinch.skill`
2. Install into your OpenClaw Skills directory
3. Use in chat:
   - `/pinch <URL>`
   - “Use pinchtab to open <URL>”
   - “Use pinchtab to search <keywords>” (defaults to Bing)

### Behavior

- Checks `/health` and starts Pinchtab if needed
- Navigates via HTTP API
- Uses persistent profile `~/.pinchtab/chrome-profile`

For Chinese docs, see: **docs/README.zh.md**

## Login & Persistence

- Default profile: `~/.pinchtab/chrome-profile`
- Log in once in headed mode; cookies persist
- Custom profile: `BRIDGE_PROFILE=/path/to/profile`

## FAQ

**Q: Missing X server / $DISPLAY**
- You need a GUI environment, or run headless.

**Q: Can’t access port 9867**
- Ensure the service is running and the port is open.

## License

MIT
