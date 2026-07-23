import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// 设置页面统一的响应式垂直 padding。
///
/// 窄屏（< [Breakpoints.mobile]）使用 [Spacing.level6]，宽屏使用 [Spacing.level7]。
double settingsPageVerticalPadding(BuildContext context) {
  return MediaQuery.sizeOf(context).width < Breakpoints.mobile
      ? Spacing.level6
      : Spacing.level7;
}
