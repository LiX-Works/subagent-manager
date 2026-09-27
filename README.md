# subagent-manager

一份可改造的 **Codex 子代理工作流 Skill**：判断何时委派、在 Luna／Sol／Astra 间选择模型与思考档位、把难题交给顾问或执行代理，并验收结果。它也包含可选的 Gemini AGY CLI、Grok CLI 路径，以及 Grok 每周额度查询和按日预算的规则。

这里发布的是一套**有具体模型偏好和额度阈值的个人工作流案例**，不是对所有账户的最优配置或克隆后即用的工具包。模型、档位、可用代理工具、订阅和 CLI 版本会变化；先按[适配说明](docs/自定义规则.md)核对自己的环境。历史评测数字有日期，仅作选择依据，不是实时排名。[Codex 定价与用量](https://learn.chatgpt.com/docs/pricing)也提示订阅额度不能直接按公开价格换算。

## 包含什么

- [`skills/subagent-manager/SKILL.md`](skills/subagent-manager/SKILL.md)：委派条件、显式指定子代理模型与强度、交接和验收。
- `references/`：模型选用、关键判断点咨询、AGY／Grok 调用、Grok 日预算和可修订的经验记录。Grok 预算示例在日消耗达到整周额度的 1/7、1.5/7、2/7 时分别检查、提醒和默认停止新派发；每个有边界的 Grok 子任务结束后查一次 `/usage`。
- `scripts/`：可选的 AGY 调用包装和 Grok 快照账本；不安装 CLI、不登录、不读取认证。账本不会主动查询账户。
- [`extras/windows-proxy/`](extras/windows-proxy/README.md)：仅在需要本地网络代理的 Windows 环境使用。直连用户不用配置端口，也不用运行该模块。

## 安装与使用

将 `skills/subagent-manager/` 整个文件夹复制到自己的 `$HOME/.agents/skills/`；也可放进项目的 `.agents/skills/`。已有同名 Skill 时先比较，不直接覆盖。Codex 通常会发现 Skill 变更，若当前任务未显示，可重启 Codex 后检查。[官方 Skill 文档](https://learn.chatgpt.com/docs/build-skills)

在任务中提到 `$subagent-manager`，或让 Codex 按请求自动选用。先用一个范围清楚的任务测试：当前环境是否能在子代理调用参数中显式指定模型和思考强度，以及实际返回的模型是否符合选择。模型或 CLI 不可用时应说明并跳过对应路径，不用提示词假装切换成功。

AGY 和 Grok **均为可选依赖**；只使用本家 Codex 子代理时无需安装它们。若要启用外部 CLI，请自行安装和登录，并先验证当前模型、调用参数、权限与计费方式。AGY 包装脚本默认不指定代理，按进程继承的网络环境运行；需要代理时显式传入实际 HTTP(S) 或 Mixed 端口。Grok `grok usage <SESSION_ID>`查看指定会话的 Token／成本，交互界面 `/usage`查看账户周额度，两者不是同一个统计量。

仅使用脚本时才需要相应运行环境：`quota-ledger.py` 使用 Python 3 标准库，`invoke-agy.ps1` 需要 PowerShell 7 和已安装的 AGY CLI。两者都不应被当作自动安装、自动登录或自动充值工具。

这份仓库可独立使用；多源搜索工作流可以另行搭配，但不是前置依赖。内容按 [MIT 许可证](LICENSE)开放。
