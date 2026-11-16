/// 生成式组件的 id 约定（纯值）。
///
/// 生成结果按 surface 存（`genui.<surface>.surface`），所以每个 surface 恰好
/// 对应一个组件 id。编排页要据此判断「这一行走的是生成式渲染」，但那属于
/// 组件的**身份**而不是某个目录的实现——放在这里，编排页就不必 import
/// `generative` 的组件目录。
///
/// 注册（builder / 支持尺寸 / 默认配置）仍在
/// `presentation/components/catalog.dart`。
library;

import 'package:luminous/core/composition/composition.dart';

/// `generative.<surface>`：该 surface 的生成式区块组件 id。
///
/// id 是 `generative.<surface>` 而不是 `generative.<domain>.<view>`：生成式 UI
/// 没有「域 + 视图」的细分，它就是「这个格子里的东西由 agent 现拼」，`surface`
/// 是它唯一的区分维度。
ComponentId generativeSurfaceComponentId(SurfaceId surface) =>
    ComponentId('generative.${surface.wireValue}');
