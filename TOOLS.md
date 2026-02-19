# TOOLS.md - 本地配置与工具记录

## 浏览器（2026-02-11）

### ✅ Pinchtab（首选，有头）启动脚本（2026-02-19）
```bash
/home/icewm/.openclaw/workspace/tools/pinchtab-start.sh
```

**脚本内容要点：**
- 预设 `DISPLAY=:0`
- 启动命令：`/usr/local/bin/pinchtab`
- 日志：`/tmp/pinchtab.log`
- 健康检查：`http://127.0.0.1:9867/health`
- 默认 profile：`~/.pinchtab/chrome-profile`（持久化登录）

---

**独立有头模式 Chrome 启动命令（备用）：**
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
