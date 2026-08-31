# lib/core/ai — 实验性 AI 运行时 seam

只有一个开关读取层:从环境变量解析实验性 AI runtime(enabled / provider / genUi)并
暴露 Riverpod provider。默认全关,不接任何 shipping 流程。

## 职责与边界
- 管:runtime_config.dart(`AiRuntimeProviderKind`、`AiRuntimeEnvironment.fromPlatform`、
  `AiRuntimeConfig`)、runtime_providers.dart(`aiRuntimeEnvironmentProvider` /
  `aiRuntimeConfigProvider`)。
- 不管:线上助手、今日 AI 摘要、报告 AI(Lucent 后端 + 各 feature data 层承担);
  本层不持有模型调用、prompt 或网络代码。

## 对外契约
- 导出:`AiRuntimeConfig`(含 `exposesLocalRuntime`)、`AiRuntimeEnvironment`、
  `AiRuntimeProviderKind` 与上述两个 provider。
- 被依赖:core/config/feature_flags.dart(实验开关透出)、settings 的实验开关页
  (features/settings/presentation/pages/feature_flags.dart);无其他 feature 消费。

## 不变量
- 两个源文件首行注释均为 "Experimental dev seam — not part of the shipping
  assistant path";enabled / genUi 默认 false,未知 provider 值回落 `none`
  (test/core/ai/runtime_config_test.dart、runtime_providers_test.dart)。
- 仅 `enabled && provider != none` 时 `exposesLocalRuntime` 为真;shipping 路径不得
  读取本层改变行为。
- 配置只读自 EnvKey(luminousExperimentalAiRuntime 等),无任何写入路径。

## 依赖禁区
- 不 import `features/**`,不依赖 network / database;只依赖 core/config 的 EnvReader。
- feature 代码不得借本层绕过 Lucent 后端 AI 流程(仓库 AGENTS.md 的实验 seam 边界)。

## 陷阱与决策
- `parse` 宽容匹配别名(`toolkit` / `aitoolkit` / `genui` 等),未知值静默回落
  `none`:新增 provider kind 必须同步 parse 与测试。
- seam 存在的意义:为未来本地 AI runtime(gen_ui 等)预留挂载点,避免届时倒灌
  core/network 或 feature 层;这也是 AGENTS.md 把本目录定为"实验 seam"的原因。
