# subagent-manager

一份用于**判断何时委派、选择合适代理、交接任务并验收结果**的 Codex Skill。它不规定某个模型永远优先，也不把作者个人的账户额度或平台偏好设为其他人的默认规则。

Skill 位于 [`skills/subagent-manager/SKILL.md`](skills/subagent-manager/SKILL.md)，附属参考文件只说明模型选择因素和外部 CLI 的交接方法。需要本地代理的 Windows 用户可选择仓库的 [`extras/windows-proxy/`](extras/windows-proxy/README.md)；直连使用者无需安装或运行该模块。个人选型、预算和平台排除项应先按[自定义规则说明](docs/自定义规则.md)决定是否加入自己的环境。

## 安装与使用

将 `skills/subagent-manager/` 整个文件夹复制到个人的 `~/.agents/skills/` 下；若目标已有同名 Skill，先比较，不直接覆盖。也可以放入特定项目的 `.agents/skills/`。Codex 通常会发现新 Skill；若当前会话未显示，重新打开任务后再检查。[Codex Skill 文档](https://learn.chatgpt.com/docs/build-skills)

需要时在任务中显式提到 `$subagent-manager`，或让 Codex 根据请求自动选用。先交给它一个边界清楚、结果容易验收的小任务；实际可调用的原生代理、外部 CLI、模型和思考档位，以当前环境为准。此仓库不安装 AGY/Grok，也不提供它们的账号或额度。

本仓库独立于 `multi-source-search`。两者可配合，但任一 Skill 都不要求安装另一份。代理脚本、个人模型偏好和额度策略不是本 Skill 的默认依赖。内容按 [MIT 许可证](LICENSE)开放。
