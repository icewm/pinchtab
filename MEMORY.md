# 龙虾的记忆库

## Telegram 渠道配置（2026-02-11）⭐
- Telegram 插件与渠道均已启用（`enabled: true`）
- Bot Token 已配置：`8316302894:AAHTtOtZe7eL3P6jdr3seVczyB0_hcZ36w`
- **DM 策略为 `pairing`**（配对模式，需对方确认才能通信）
  - 修改时间：2026-02-11 19:17–19:21
  - Gateway 已重启使配置生效

## 语言偏好（2026-02-11）
- 用户要求：**无特殊情况默认使用中文交流**

## 单位偏好（2026-02-14）
- 用户要求：**单位统一使用公制**（温度℃、风速km/h等）

## 浏览器搜索方式（2026-02-11）⭐
- 用户明确要求：所有网页搜索统一使用 **有头模式本地独立浏览器**
- **全局默认**：凡涉及浏览器/网页搜索，一律使用 TOOLS.md 中记录的本地有头 Chrome 启动方式与 `profile="openclaw"`
- 配置路径：
  - Chrome 可执行文件：`/opt/google/chrome/chrome`
  - 调试端口：`18800`
  - 独立用户数据目录：`/tmp/openclaw-chrome`
- OpenClaw 浏览器配置采用 `profile="openclaw"` 模式（不依赖 Chrome 扩展中继）
- 启动命令：
  ```bash
  export DISPLAY=:0 && /opt/google/chrome/chrome \
    --remote-debugging-port=18800 \
    --user-data-dir=/tmp/openclaw-chrome \
    --profile \
    2>&1 &
  ```
- 测试验证：`openclaw` profile 可正常加载页面并进行 UI 操作

## 已知问题（2026-02-11）
- OpenClaw 系统提示缺少 `openai`、`google`、`voyage` 的 API key（不影响当前任务）
- MCS 连接错误反复出现，Chrome 扩展 GCM 模块连接失败（error -105），但不影响网页搜索功能

## 数据查询能力
- 金融数据类任务（如上证指数）需依赖外部财经网站或 API
- 当前缺少有效的数据源访问方式，建议：
  - 用户手动查看财经平台（新浪财经、东方财富网等）
  - 或配置定时提醒+数据抓取脚本实现自动化

## 大模型推理硬件适配（2026-02-12）⭐
- **Qwen3-32B 运行可行性**：
  - FP16 推理：需 ≥60GB 显存 → ❌ 笔记本无法满足
  - INT8/INT4 量化推理：需 ≈20–24GB 显存 → ✅ Aurora 笔记本（RTX 5060/5070）可运行
- **Aurora 笔记本典型配置**：
  - CPU：Intel Core Ultra 9 275HX（24核）
  - 内存：32GB DDR5
  - 显卡：NVIDIA GeForce RTX 5060 / RTX 5070（8GB GDDR6/GDDR7）
- **建议**：使用 llama.cpp、vLLM 等框架进行量化推理部署
