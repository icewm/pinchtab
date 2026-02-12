# 对话记录（2026-02-12）

- 用户：你可以使用adb操作安卓手机吗？
- 助手：可以，但要看你这边是否已开启 USB 调试并能通过 ADB 连接到设备。你是想本机直连（USB/Wi‑Fi ADB）操作，还是通过你那边执行 ADB 命令让我指导？请说下目标和当前连接方式。
- 用户：Wsl2下能安装adb吗？
- 助手：可以。WSL2（Ubuntu/Debian）里直接装即可：
  - `sudo apt update`
  - `sudo apt install -y android-tools-adb`
  - `adb version`
  注意：在 WSL2 里连 USB 设备需要 Windows 侧配合（usbipd-win 进行 USB 透传），否则只能用 Wi‑Fi ADB 连接。问用户是否需要 USB 透传或 Wi‑Fi ADB 步骤。
- 用户：Wifi adb的步骤（重复一次）
- 助手：给出两套方案：Android 11+（无线调试/配对）与旧版（USB 先切 TCP），并询问安卓版本。
- 用户：你能通过adb操作安卓手机的屏幕吗？
- 助手：可以，通过 ADB 能发触控/按键指令，也能用工具实现可视化操控（scrcpy）。询问偏脚本化还是可视化操作。
- 用户：scrcpy
- 助手：说明 Windows 侧推荐与 WSL2 侧可用两种方式，询问偏好。
- 用户：WSL2侧
- 助手：给出 WSL2 侧完整流程（安装 adb/scrcpy、检查 WSLg、无线调试配对、连接、启动 scrcpy），询问安卓版本与 DISPLAY 是否有输出。
- 用户：你可以通过scrcpy操作安卓手机吗？
- 助手：可以，只要 WSL2 已连上手机（USB 或 Wi‑Fi ADB），即可通过 scrcpy 操作屏幕；询问具体操作目标与连接方式。
- 用户：把此次对话保存为md文件
