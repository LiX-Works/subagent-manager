# Google：AGY CLI辅助代理

默认请求`gemini-3.8-flash-high`与`--effort high`。2026-09-23 AGY1.2.8还列出3.8/3.7/3.6 Flash Low/Medium/High、3.1 Pro Low/High、Claude4.6及GPT-OSS；列表不是调用验收或其他计费路径授权。

2026-09的小样本试用只覆盖已备齐材料的独立题目，未证明联网、多文件、长任务或跨模型质量，也不能折算订阅余额。先在使用者自己的任务上验收。

本方案将Gemini与Luna设为相近优先级、不同适用情景。关键差异是：独立AGY CLI不会自动接用Codex里**已经配置成体系的**Skill、MCP和搜索工具。Gemini适合输入材料已齐备、可独立交接的批量阅读、分类、提取、初稿与分析；需要在任务中反复串联现有搜索、站内读取、文档和项目工具时通常优先Luna。主代理可先取得材料再交Gemini；若必须频繁代跑工具、搬运上下文，则交接成本可能抵消Gemini的模型能力优势。High是本方案的默认试用档，可按实际结果调整。3.1 Pro按具体价值选，不按Pro名称当升级档。

2026-09-23的AGY帮助提供`mcp add/list/enable/disable`、项目目录与编辑/沙箱选项，因此不能宣称它本身不支持工具。它是独立CLI，不自动继承Codex已配置的整套Skill、MCP和搜索工具。帮助列出功能不是该功能在使用者机器上实测通过；接入并验证相应工具链后可更新分工。

## 入口

- 先确认自己的`agy` CLI可用且已登录；脚本默认从PATH解析`agy`，也可用`-Executable`指定可执行文件。AGY及Gemini账号是可选依赖，不由本Skill安装或登录。
- 桌面App与CLI不同；登录由使用者在原客户端完成，不读认证文件。过期/额度错误不自动换号或改API key。
- [invoke-agy.ps1](../scripts/invoke-agy.ps1)统一接收UTF-8提示文件、独立工作目录、输出目录和时限，默认plan+sandbox。

```powershell
pwsh -NoProfile -File '<已安装Skill目录>/scripts/invoke-agy.ps1' -PromptFile '<提示文件>' -Workspace '<已有任务目录>' -OutputDirectory '<新结果目录>' -Model 'gemini-3.8-flash-high' -Effort high -DryRun
```

去掉DryRun执行；默认180秒，按任务调整TimeoutSeconds，不统一硬限长任务。需要在用户已授权的任务工作目录（项目或副本）编辑时可选Mode accept-edits，由主代理安排文件责任和冲突处理，不启用权限绕过。输出目录必须为空或未存在，不覆盖旧结果。保存最终回复和可见用量，不保存原始stderr或内部思考，非完整工具审计。

任务传可写范围、验收条件、缺证据时说明；不要求固定JSON字段。代码返回后先检查再执行。真实联网或工具任务需在当前环境独立验证，不把局部无工具试用当全面代理验收。

脚本不默认启用代理，继承当前进程的网络环境；需要时显式传`-ProxyUri 'http://127.0.0.1:<端口>'`，或参考仓库的可选Windows代理模块。它不改系统代理、PATH或Python。CLI变化先查help，可按同边界直接用原CLI。

上述模型与命令以当前AGY版本的help和实际账户权限为准。
