import 'package:flutter/material.dart';

// ignore_for_file: constant_identifier_names

/// 应用内统一 UI 色值。
///
/// 仅存放**不跟随主题切换**的固定色值。
/// 主题相关的主色/辅色在 [AppThemeSpec] 中定义。
///
/// 基于 DESIGN.md (Airbnb 设计语言) 更新。
class AppUiConstants {
  AppUiConstants._();

  // ── 页面背景 ──

  /// 亮色模式页面背景（Canvas — #ffffff）。
  static const Color PAGE_BACKGROUND = Color(0xFFFFFFFF);

  /// 暗色模式页面背景。
  static const Color PAGE_BACKGROUND_DARK = Color(0xFF0B1A0E);

  // ── 底部导航栏 ──

  /// 底部 Tab 栏背景色（Canvas）。
  static const Color TAB_BAR_BACKGROUND = Color(0xFFFFFFFF);

  /// 底部 Tab 栏顶部描边（Hairline — #dddddd）。
  static const Color TAB_BAR_BORDER = Color(0xFFDDDDDD);

  /// 底部 Tab 未选中图标和文字颜色（Muted — #6a6a6a）。
  static const Color TAB_INACTIVE = Color(0xFF6A6A6A);

  // ── 通用文字色 ──

  /// 主要文字（Ink — #222222）。
  static const Color TEXT_PRIMARY = Color(0xFF222222);

  /// 次要文字（Body — #3f3f3f）。
  static const Color TEXT_SECONDARY = Color(0xFF3F3F3F);

  /// 辅助/禁用文字（Muted Soft — #929292）。
  static const Color TEXT_MUTED = Color(0xFF929292);

  /// 暗色模式主要文字。
  static const Color TEXT_PRIMARY_DARK = Color(0xFFF2F6F2);

  // ── 分割线 & 描边 ──

  /// 细分割线（Hairline — #dddddd）。
  static const Color DIVIDER = Color(0xFFDDDDDD);

  /// 卡片描边（Hairline — #dddddd）。
  static const Color BORDER = Color(0xFFDDDDDD);

  /// 较柔和描边（Hairline Soft — #ebebeb）。
  static const Color BORDER_SOFT = Color(0xFFEBEBEB);

  /// 较强描边（Border Strong — #c1c1c1）。
  static const Color BORDER_STRONG = Color(0xFFC1C1C1);

  /// 暗色模式描边。
  static const Color BORDER_DARK = Color(0xFF324432);

  // ── 语义色 ──

  /// 成功/确认（绿）。
  static const Color SUCCESS = Color(0xFF66BB6A);

  /// 警告（琥珀）。
  static const Color WARNING = Color(0xFFFFA726);

  /// 错误/危险（Primary Error Text — #c13515）。
  static const Color ERROR = Color(0xFFC13515);

  /// 错误/危险 Hover（Primary Error Text Hover — #b32505）。
  static const Color ERROR_HOVER = Color(0xFFB32505);

  /// 信息提示（Legal Link Blue — #428bff）。
  static const Color INFO = Color(0xFF428BFF);
}
