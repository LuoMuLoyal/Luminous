/// 可组合表面的组件 id 常量（纯值）。
///
/// 组件 id 是**编排层**的身份，不是某个 feature 的私产：同一份 id 会被多个
/// 表面的目录引用（`auth.preview_banner` 同时挂在 today 与 review 上），谁渲染
/// 它由注册表决定。把常量留在某个 feature 的 `presentation/` 里，另一个
/// feature 就只能 import 它的组件目录——那是跨 feature 的 presentation 依赖。
///
/// 只放 `ComponentId` 常量：不带 builder、不带默认布局（那些属于各 feature 的
/// `presentation/components/catalog.dart`）。
library;

import 'package:luminous/shared/domain/composition/id.dart';

/// 未登录预览横幅（全局登录提示，today 与 review 共用同一个组件）。
const authPreviewBannerId = ComponentId('auth.preview_banner');
