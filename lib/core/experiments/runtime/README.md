# lib/core/experiments/runtime — 实验性 runtime 开关

只有一个开关读取层：从环境变量解析实验性 runtime（enabled / provider / genUi）并
暴露 Riverpod provider。默认全关，不接任何 shipping 流程。

目录名是 `experiments/runtime` 而不是原来的 `ai`：`ai` 太泛——本层既不持有模型调用，
也不持有 prompt，只回答「这个构建里实验性 runtime 开没开、是哪一种」。精确的名字
让人一眼看出它只是个开关读取层。

## 职责与边界

- 管：`config.dart`（`RuntimeProviderKind`、`RuntimeEnvironment.fromPlatform`、
  `RuntimeConfig`）、`providers.dart`（`runtimeEnvironmentProvider` /
  `runtimeConfigProvider`）。
- 不管：线上助手、今日摘要、报告生成（Lucent 后端 + 各 feature data 层承担）；
  本层不持有模型调用、prompt 或网络代码。

## 对外契约

- 导出：`RuntimeConfig`（含 `exposesLocalRuntime`）、`RuntimeEnvironment`、
  `RuntimeProviderKind` 与上述两个 provider。
- 被依赖：`core/config/feature_flags.dart`（用 `RuntimeEnvironment.fromPlatform` /
  `RuntimeConfig.fromEnvironment` 给实验开关做首启种子）、settings 的实验开关页
  （`features/settings/presentation/pages/advanced/feature_flags.dart`）；无其他
  feature 消费，两个 provider 本身在 feature 侧也未被读取。

## 不变量

- `enabled` / `genUi` 默认 false，未知 provider 值回落 `none`
  （`test/core/experiments/runtime/config_test.dart`、`providers_test.dart`）。
- 仅 `enabled && provider != none` 时 `exposesLocalRuntime` 为真；shipping 路径不得
  读取本层改变行为。
- 配置只读自 `EnvKey`（`luminousExperimentalRuntimeEnabled` 等），无任何写入路径；运行期
  开关值由 settings 的 `FeatureFlagsController` 写 SharedPreferences，不在本层。

## 依赖禁区

- 不 import `features/**`，不依赖 network / database；只依赖 `core/config` 的
  `EnvReader`。
- feature 代码不得借本层绕过 Lucent 后端流程（仓库 `AGENTS.md` 的 seam 边界）。
- **生成式 UI 不走这一层**：`lib/core/composition/genui/` 是渲染引擎接缝，
  与「实验开关」是两件事，不要合并。

## 陷阱与决策

- `parse` 宽容匹配别名（`toolkit` / `aitoolkit` / `genui` 等），未知值静默回落
  `none`：新增 provider kind 必须同步 parse 与测试。
- seam 存在的意义：为未来本地 runtime 预留挂载点，避免届时倒灌 `core/network`
  或 feature 层。
