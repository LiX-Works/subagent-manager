# subagent-manager

**English** | [简体中文](README.zh-CN.md)

A Codex Skill for deciding when to delegate, choosing models and reasoning effort, and planning handoffs and reviews.

This repository collects a workflow I have refined through everyday use. It is intended for anyone using Codex for research, writing, data extraction, or programming who wants a clearer division of labor. The core is a [Skill](skills/subagent-manager/SKILL.md)—a set of working rules Codex reads during a task—accompanied by model recommendations, external CLI notes, and handoff guidelines.

The homepage is bilingual. The Skill and its detailed reference documents are currently written in Chinese.

## When delegation helps

A capable main agent, such as 6.1 Sol Ultra, can handle much of the work directly. Delegate when a separate task or context helps; account for the time needed to prepare materials and review the result.

Delegation offers three common benefits:

1. **Context isolation**: Keeping extensive reading, data extraction, or intermediate logs in a separate context helps the main agent remain focused on core analysis.
2. **Parallel progress**: Self-contained tasks with clear boundaries can proceed alongside the main train of thought.
3. **Independent review**: Reviewing a proposed plan in a separate context can reveal unstated assumptions, edge cases, and omissions. It does not remove bias or replace evidence.

Short tasks can be worth delegating if the deliverable is clear. Conversely, tasks that depend heavily on the ongoing dialogue or require frequent back-and-forth are usually better handled directly by the main agent.

## A practical example

Consider checking a technical plan alongside 20 downloaded reference documents. One practical division of labor is:

| Role | Responsibility | Deliverable |
|---|---|---|
| Main agent *(e.g., 6.1 Sol Ultra)* | Clarify goals and constraints, guide core analysis, coordinate tasks, and assemble the final result | Final assessment and integrated findings |
| Luna Max | Read the 20 documents, extract specified fields, and verify citations against the text | Structured data table, source references, questions, and unresolved items |
| 6.1 Sol Xhigh *(if helpful)* | Review the plan in a separate context using background materials and requirements | Audit of key assumptions, concrete concerns, and suggested checks |

When handing off work, the main agent should provide the objective, necessary materials, constraints, and acceptance criteria. Returned work should be checked against original sources or tests; agreement between models is not proof of fact.

## Model roles and parameters

These default candidates reflect practical tradeoffs between task requirements and tool availability. Model and effort availability depends on your Codex setup and account tier.

| Candidate | Primary use | Selection considerations |
|---|---|---|
| **GPT-6 Luna Max** | Routine extraction, locating code, small edits, and checks | Tasks with clear criteria and straightforward verification, especially when relying on Codex Skills, MCP tools, search, or project tools |
| **Gemini 3.8 Flash High** *(via optional AGY CLI)* | Batch reading, classification, extraction, and analysis with materials ready | Tasks with prepared inputs that need little support from the main agent. AGY has its own tools and MCP support, but does not automatically share the Skills, MCP integrations, or search tools configured in Codex |
| **GPT-6.1 Sol** | Complex independent tasks, plan review, and separate-context analysis | Usually High for complex tasks; default to Xhigh when difficulty is hard to assess; other levels as needed |
| **GPT-6 Astra** | Occasional specialized comparisons or fallbacks | Not selected by default; use when there is a concrete reason to expect added value, mainly Max with Xhigh as needed. Advisor is a role, not bound to Astra |
| **Grok CLI** *(optional)* | Research on X posts and threads, plus useful web research and verification | Strongly encouraged whenever search enhancement helps the task. Daily use above 30% of the weekly allowance triggers a reminder that does not pause research or restrict further dispatch |

### Explicit model and reasoning parameters

**Every new subagent must have both its model and reasoning effort explicitly set in the actual invocation parameters.** Mentioning a model name inside prompt text is not enough, and you should not rely on implicit inheritance from the main agent.

Ultra remains an option for subagents but is not selected by default. It does not guarantee more proactive delegation or stronger single-agent capabilities. The main agent usually coordinates the first level of subagents. Max can also delegate if the tools allow it. If a subagent must coordinate a further tier, state that responsibility clearly and specify explicit models and effort levels for each tier.

See [model selection rules](skills/subagent-manager/references/native-models.md) for full reasoning tiers, older-model fallbacks, and the limits of benchmark evidence.

## Getting started

You can start with Codex's built-in subagents if your environment supports them:

1. Copy the `skills/subagent-manager/` folder into your personal `$HOME/.agents/skills/` directory or your project's `.agents/skills/` directory. Choose one location. If a Skill with the same name already exists, review your customized rules before replacing it.
2. Mention `$subagent-manager` in a task, or let Codex select it based on context. If the Skill does not appear, restart Codex. See the [official installation guide](https://learn.chatgpt.com/docs/build-skills).
3. Try an initial task and let Codex determine what is worth delegating:

```text
Use $subagent-manager to help review this technical plan.

The background materials are in ./materials/.
Extract the required fields and verify their source locations.
Determine which parts are worth delegating to subagents, and specify the
model and reasoning effort parameters for each call.
The main agent should continue the core analysis and handle final review.
```

## Optional integrations

The Skill provides working rules, rather than installing tools or granting model access. If a model or interface is unavailable, Codex should report the limitation and choose a workable path.

Add the following integrations as needed:

| Extension | Purpose | Requirements |
|---|---|---|
| [AGY / Gemini](skills/subagent-manager/references/google.md) | Hand off tasks with prepared materials to an external CLI | AGY CLI installed and logged in; PowerShell 7 for the wrapper script |
| [Grok](skills/subagent-manager/references/grok.md) | Investigate original posts, discussions, and web sources | Grok CLI installed and logged in, with applicable free or subscription usage allowances; this workflow uses only authorized included usage |
| [Grok quota rules](skills/subagent-manager/references/grok-budget.md) | Check usage after grouped research units; notify above 30% daily consumption of the weekly allowance | Default: 5 substantive research units per check; Python 3 for the snapshot ledger |
| [Windows proxy module](extras/windows-proxy/README.md) | Set a process-level proxy for a single CLI invocation | Direct connections do not need this; if needed, supply your client's HTTP(S) or Mixed port |

Keep these Grok usage metrics distinct:

- `/usage` in interactive mode shows weekly account usage and reset time.
- `grok usage <SESSION_ID>` shows token counts and costs for a specific session.
- The included ledger script saves account snapshots and records daily usage. The main agent can query usage and pass snapshots to the ledger, but the script itself does not query the account.

## Adapting the workflow and documentation

Adjust model tiers, effort levels, and Grok query budgets according to your actual account permissions, tools, and schedule. Public benchmarks are a reference, not a direct predictor of your available task volume.

| Topic | Reference |
|---|---|
| Delegation decisions, handoffs, and review rules | [SKILL.md](skills/subagent-manager/SKILL.md) |
| Model candidate details, effort levels, and benchmark limits | [Model selection](skills/subagent-manager/references/native-models.md) |
| Advisors, worker agents, independent review, and nesting | [Task handoffs](skills/subagent-manager/references/delegation.md) |
| Environment verification and custom defaults | [Custom rules](docs/自定义规则.md) |
| Practical notes and background on revisions | [Experience notes](skills/subagent-manager/references/experience.md) |

This Skill can be used alone or alongside [agent-search-booster](https://github.com/LiX-Works/agent-search-booster) for multi-channel research. See [Releases](https://github.com/LiX-Works/subagent-manager/releases) for updates. Released under the [MIT license](LICENSE).
