# Windows CLI 代理（可选）

两份 Skill 都可以在直连环境下使用，本模块**不是安装或运行前提**。作者使用 Clash/Mihomo 的本地代理端口，因此需要让 Grok、AGY 等 CLI 的某一次启动经过代理。这里给出可改造的进程级做法；不修改系统代理、浏览器设置、Skill 主文件或服务账户。

## 先找到端口

在自己的代理客户端设置或配置文件中查找 **HTTP(S) 代理端口**（Mihomo 的 `port`）或 **Mixed 端口**（`mixed-port`）；不要把 SOCKS 专用端口、控制 API 端口或示例数字直接填入 HTTP 代理地址。Mixed 端口同时接受 HTTP(S) 和 SOCKS 连接。端口由本机实际配置决定，下面的 `PORT` 必须替换成真实数字。[Mihomo 端口文档](https://wiki.metacubex.one/en/config/inbound/port/)

例如在 PowerShell 中先检查本地监听：

```powershell
Test-NetConnection 127.0.0.1 -Port PORT
```

`TcpTestSucceeded=True` 只说明端口在监听，不证明目标网站可达或 CLI 一定支持代理。需要时可再用 `Invoke-WebRequest -Uri 'https://example.com' -Proxy 'http://127.0.0.1:PORT'` 做一次小范围请求；网络策略和目标站点可能影响结果。

## 只为一次 CLI 调用设置代理

从仓库根目录运行附带的 [Invoke-CliWithProxy.ps1](Invoke-CliWithProxy.ps1)，先用 `-DryRun` 检查参数，然后去掉它执行。例如：

```powershell
& './extras/windows-proxy/Invoke-CliWithProxy.ps1' `
  -Executable 'grok' -ProxyUri 'http://127.0.0.1:PORT' `
  -CliArgs @('--version') -DryRun
```

这个示例仅检查 Grok CLI 版本；真正研究任务应按 CLI 当前帮助和 Skill 的授权边界传入参数。若 `grok` 不在 PATH，可将 `-Executable` 改为自己机器上的可执行文件绝对路径。AGY 等其他 CLI 也可使用同一包装脚本，只需将 `-Executable` 换成相应命令；本仓库不捆绑它们的登录或默认模型配置。

脚本只为本次命令临时设置 `HTTP_PROXY`、`HTTPS_PROXY` 和 `NO_PROXY`，结束后恢复当前 PowerShell 进程的原值。`NO_PROXY` 默认排除本机回环地址，避免本地回调也走外部代理。它不启动代理客户端、不修改 Clash/Mihomo 的节点或分流规则、不登录 CLI、不复制凭据，也不改变订阅或计费设置。部分程序可能忽略这些环境变量；那时应查该程序自己的代理文档，不能把“端口可连”直接当成服务已接通。
