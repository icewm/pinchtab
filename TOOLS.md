# TOOLS.md - 本地配置与工具记录

## 浏览器（2026-02-11）

**独立有头模式 Chrome 启动命令：**
```bash
PIDFILE=/tmp/openclaw-chrome.pid
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "chrome already running"
else
  export DISPLAY=:0
  /opt/google/chrome/chrome \
    --remote-debugging-port=18800 \
    --user-data-dir=/tmp/openclaw-chrome \
    2>&1 &
  echo $! > "$PIDFILE"
  echo "started chrome pid=$(cat $PIDFILE)"
fi
```

**用途：**
- 本地 OpenClaw 网页搜索（有头模式）
- 调试端口：`http://127.0.0.1:18800`
- 用户数据目录：`/tmp/openclaw-chrome`（独立隔离）

**验证方式：**
```bash
curl -s http://127.0.0.1:18800/json/version | head -c 200
```

---

## TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod

---

Add whatever helps you do your job. This is your cheat sheet.
