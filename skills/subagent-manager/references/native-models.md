# 本家子代理：模型与任务优先级

这是一份可调整的个人模型路由示例：按职责细分Astra档位，按工具依赖在Luna与Gemini间选择。只约束子代理选用，不改主模型或`config.toml`。下方2026-09-23评测是历史依据，不代表当前实测或最新定价；运行前核对模型是否仍可用。

## 当前默认优先级（按任务，而非固定排行榜）

| 子任务 | 首选 | 何时提升或更换 |
|---|---|---|
| 常规、可核对的读取/提取、代码定位、小改动与检查，尤其依赖Codex工具环境的任务 | `gpt-6-luna`，通常Max；与Gemini相近优先级，依赖当前Skill/MCP/项目工具时优先Luna；当前不指定Ultra | 材料齐备且工具依赖低时也可选Gemini；实质遗漏或复杂判断需求可换6 Sol，文件数量多本身不强制升级 |
| 普通至较复杂的代码、资料核验与多步分析 | `gpt-6-sol`，High、Xhigh、Max、Ultra可按难度选；难以判断时优先Xhigh | 错误代价高、条件强耦合或反复失败，可直接换6 Astra |
| 方向判断、困难子任务与实质审查 | `gpt-6-astra`，可选Low／Medium／High／Xhigh；具体按下表的职责分档 | 不必先让较弱模型试错；先判断是否值得调用，再按难度与重要性选档 |

Luna Max与Gemini 3.8 Flash High处于相近的常规候选优先级。先判断是否需要Codex当前已配置成体系的工具：任务要连续串联Skill、MCP、搜索、浏览器或项目操作时优先Luna；输入齐备、可一次交接的批量阅读、分析和生成可选Gemini。希望Luna承担较多合适的常规工作，但不设份额或强制分派。两者不要求逐题对照或重复运行。Gemini未直接接入现成工具链不等于模型本身没有工具能力；本家子代理可用入口也以实际暴露为准。研究渠道与Grok见对应参考文件。主代理模型由用户选择，不自动让子代理继承其模型/档位。

6 Sol可在High、Xhigh、Max、Ultra中按需选择，难判时Xhigh；不要因主代理是Sol Ultra就把Sol子代理一律设成Ultra。需要完整多步分析、上下文耦合或更难验收时可直接选Sol，而不是按文件数量或工作量机械升级。6 Luna通常Max，只作子代理候选；当前不指定Ultra，以本轮工具实际支持为准。3.1 Pro保持备用，不能仅凭Pro名称当作Flash的自动升级。旧5.6默认不选。

## Astra：统一可选池与按职责分档

**本方案的统一可选池为Low、Medium、High、Xhigh（含两端）；不自行选Max或Ultra。** 池内以下档位为任务建议，使用者的新指示优先；请求组合还须由实际工具支持。先决定是否调用Astra，再选档，不以“重要”二字自动制造一次调用。

| 实际职责 | 通常选择 | 较难或特别重要时 |
|---|---|---|
| Advisor／Guide：决定方向、方法、架构、核心解释或纠偏 | High | 很难或重要的判断用Xhigh |
| 执行有边界的子任务：实现、推导、分析、产物制作 | Medium | 较难High；很难或重要Xhigh |
| 独立审查 | 整体方向/核心论证按Advisor处理；局部结果核对按执行型任务处理 | 关键、很难或重要的审查可用Xhigh |
| 其他或混合职责 | 按主导工作、判断难度和错误影响选择，不按任务标签硬套 | 以关键部分要求为准；材料不足先补必要材料 |

Low保留在可选池，**默认不使用，也不把它当作Sol Max的默认能力升级**；仅在用户明确指定或有任务特定依据时选用。常规简单工作可由主代理或Luna完成；确需Astra提供局部第二意见或核对时，通常从Medium考虑，方向性Advisor仍通常用High。不要因为任务通过子代理工具启动，就把方向顾问套成执行任务的Medium。进一步原则见[关键判断点咨询](delegation.md)。以上是用户偏好下的试行策略，不声称某个档位在每类任务上最省或最优。

## 5.6旧模型：默认不调用，保留历史硬下限

| 模型ID | 硬要求 | 默认倾向 |
|---|---|---|
| gpt-5.6-luna | xhigh及以上 | 简单、明确、可验收 |
| gpt-5.6-terra | high及以上 | 常规至中等复杂分析/代码 |
| gpt-5.6-sol | 任意支持档位 | 建议high及以上，较复杂任务 |

5.6 Sol的建议不是硬下限；5.6 Luna/Terra的最低档位仍是硬要求。Astra使用上一节的Low至Xhigh可选池。旧5.6模型当前无默认任务分配，仅在用户明确要求、6模型不可用且已说明限制，或有任务特定实测依据时考虑。xhigh、max、ultra只用于实际支持且用户规则允许的型号；不能把“可以使用”误作“每次都用最高”。每次新建本家子代理仍要**在调用参数中同时写出`model`和`reasoning_effort`**；组合不可用时不得以省略字段的方式继承主代理配置。

## 对照证据与旧模型的保留用途（2026-09-23）

官方于2026年9月22日发布6 Sol/Luna；2026-09-23的[Codex信用额度表](https://learn.chatgpt.com/docs/pricing)显示6 Sol相对5.6 Sol约半价，输入与5.6 Terra同价且输出略低；6 Luna低于5.6 Luna。当时[Artificial Analysis](https://artificialanalysis.ai/models/releases/gpt-6-sol)综合指数：6 Sol max 48、5.6 Sol max 47；6 Luna max 37、5.6 Luna max 37。编码Agent指数在各自Codex框架为6 Sol max 57、5.6 Sol max 55；6 Luna max 41、5.6 Luna max 43。[ARC Prize](https://arcprize.org/results/openai-gpt-6-luna)的ARC-AGI-2上，6 Luna max 59.3%、5.6 Luna max 59.5%，未显示全面提升。

同档对照中，6 Sol high的Artificial Analysis综合分43、5.6 Sol high为42、5.6 Terra high为34；最高档6 Sol max 48、5.6 Sol max 47、5.6 Terra max 42。API和Codex信用额度中，6 Sol比5.6 Sol便宜，输出价低于5.6 Terra。这个证据支持优先试6 Sol，但分差不代表任务成功率差异，也不证明每类任务必胜。6 Luna max与5.6 Luna max在同榜均为37，6 Luna的公开价和Codex信用额度更低，适合优先试用。

因此5.6 Sol、Terra、Luna主要作任务特定回退、已验证旧流程或新模型未暴露时使用。特别是知识工作完整性：独立评测观察到6 Sol/Luna在部分任务省略了要求项；重要文档应保留主代理核对，必要时用5.6 Sol作对照。旧模型不因版本号直接禁用。

定价是API/信用额度计量的参照，**不是订阅账户可用Token的承诺**。对同一任务的实际耗额仍受上下文、缓存、思考、工具与重试影响；Google/Grok订阅不能用API价格直接估算。

以上数值是2026-09-23的比较快照；使用前可复查[OpenAI定价](https://learn.chatgpt.com/docs/pricing)、[Artificial Analysis的6 Sol条目](https://artificialanalysis.ai/models/releases/gpt-6-sol)、[6 Luna条目](https://artificialanalysis.ai/models/releases/gpt-6-luna)与[ARC Prize原始结果](https://arcprize.org/results/openai-gpt-6-luna)。这些来源的榜单与价格会更新，不能把本段作为实时排名。

可按难度选、表现不佳换更强模型，说明实际组合。不默认继承主模型/强度。组合不可用或环境不允许显式选择/委派时说明，不谎称已用指定模型，继续可做部分。

按当前spawn工具说明调用；显式覆盖要求fork_turns为none或有限轮数时遵守并传足够任务上下文。是否Ultra不构成额外调用门槛，也不是扩员理由。没有必须先让某个较便宜模型失败的升级流程；常规任务在Luna与Gemini间按工具依赖、材料完整性和交接成本选择。
