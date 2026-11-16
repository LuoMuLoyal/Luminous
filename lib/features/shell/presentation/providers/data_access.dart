/// 本 feature 的 `data/` 到 `presentation/` 的**唯一接缝**。
///
/// 仓库约定：`presentation/` 永远不直接 import `data/`（`--clean-layers` 的
/// `presentation_layer` 是 error 级，无白名单）。presentation 需要的 data 层
/// 装配一律从这里再导出。
library;

export 'package:luminous/features/shell/data/repositories/cached_nav_config.dart'
    show navConfigRepositoryProvider;
