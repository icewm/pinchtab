# pinchtab

轻量级浏览器控制服务（HTTP API），面向 AI 自动化与可视化调试。

- 12MB Go 二进制，零配置
- 通过 HTTP 控制 Chrome
- 可有头/无头运行，支持持久化登录

## 功能特性

- **HTTP API**：任何语言/脚本都能调用
- **可视化有头模式**：适合登录、调试
- **持久化会话**：Chrome profile 保留登录状态
- **基础交互**：点击、输入、截图、读取文本

## 安装

### Docker（推荐）
```bash
docker run -d -p 9867:9867 --security-opt seccomp=unconfined pinchtab/pinchtab
curl http://127.0.0.1:9867/health
```

### 本地编译
```bash
go build -o pinchtab .
```

## 启动

### 有头模式（默认）
```bash
./pinchtab
```

### 无头模式
```bash
BRIDGE_HEADLESS=true ./pinchtab
```

### 需要 GUI 的环境（如 WSL/远程）
确保 `DISPLAY` 可用：
```bash
export DISPLAY=:0
./pinchtab
```

## 快速开始

健康检查：
```bash
curl http://127.0.0.1:9867/health
```

打开页面：
```bash
curl -X POST http://127.0.0.1:9867/navigate \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://github.com"}'
```

获取页面文本：
```bash
curl http://127.0.0.1:9867/text
```

获取可交互元素快照：
```bash
curl http://127.0.0.1:9867/snapshot?filter=interactive
```

截图：
```bash
curl http://127.0.0.1:9867/screenshot
```

## OpenClaw Skill（pinch）

本仓库提供 **pinch.skill**，用于让 OpenClaw 智能体直接学会使用 Pinchtab 打开链接/搜索。

### 使用方式

1. 下载 `pinch.skill`
2. 导入到你的 OpenClaw Skills 目录（或通过 OpenClaw 的 skill 安装方式加载）
3. 在对话中使用以下指令：
   - `/pinch <URL>`：用 Pinchtab 打开链接
   - “用 pinchtab 打开 <URL>”
   - “用 pinchtab 搜索 <关键词>” → 默认 Bing 搜索

### Skill 行为说明

- 自动检查 Pinchtab 是否运行（/health）
- 必要时先启动 Pinchtab（有头模式）
- 使用 HTTP API 导航、抓取快照/文本/截图
- 默认使用持久化 profile：`~/.pinchtab/chrome-profile`

如果需要定制启动脚本（DISPLAY、profile 路径等），可修改你的本地脚本或环境变量。

## 登录与持久化

- 默认 profile：`~/.pinchtab/chrome-profile`
- 有头模式下手动登录后，cookies 会持久化
- 也可用 `BRIDGE_PROFILE=/path/to/profile` 指定自定义目录

## 常见问题

**Q: 启动报错 Missing X server / $DISPLAY**
- 说明没有图形环境，设置 `DISPLAY` 或改用无头模式。

**Q: 端口 9867 访问不了**
- 确认服务已启动，或检查防火墙/端口占用。

## License

MIT
