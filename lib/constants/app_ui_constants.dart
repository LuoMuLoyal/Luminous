import 'package:flutter/material.dart';

// ignore_for_file: constant_identifier_names

/// 应用内统一 UI 色值。
///
/// 仅存放**不跟随主题切换**的固定色值。
/// 主题相关的主色/辅色在 [AppThemeSpec] 中定义。
class AppUiConstants {
  AppUiConstants._();

  // ── 页面背景 ──

  /// 亮色模式页面背景。
  static const Color PAGE_BACKGROUND = Color(0xFFF5FAF5);

  /// 暗色模式页面背景。
  static const Color PAGE_BACKGROUND_DARK = Color(0xFF0B1A0E);

  // ── 底部导航栏 ──

  /// 底部 Tab 栏背景色。
  static const Color TAB_BAR_BACKGROUND = Color(0xFFFBFDFB);

  /// 底部 Tab 栏顶部描边。
  static const Color TAB_BAR_BORDER = Color(0xFFE2EBE2);

  /// 底部 Tab 未选中图标和文字颜色。
  static const Color TAB_INACTIVE = Color(0xFF7A8B7A);

  // ── 通用文字色 ──

  /// 主要文字（近黑，比纯黑柔和）。
  static const Color TEXT_PRIMARY = Color(0xFF1D1F1D);

  /// 次要文字（中灰）。
  static const Color TEXT_SECONDARY = Color(0xFF6B7B6B);

  /// 辅助/禁用文字（浅灰）。
  static const Color TEXT_MUTED = Color(0xFF94A394);

  /// 暗色模式主要文字。
  static const Color TEXT_PRIMARY_DARK = Color(0xFFF2F6F2);

  // ── 分割线 & 描边 ──

  /// 细分割线。
  static const Color DIVIDER = Color(0xFFE2EBE2);

  /// 卡片描边。
  static const Color BORDER = Color(0xFFE4ECE4);

  /// 暗色模式描边。
  static const Color BORDER_DARK = Color(0xFF324432);

  // ── 语义色 ──

  /// 成功/确认（绿）。
  static const Color SUCCESS = Color(0xFF66BB6A);

  /// 警告（琥珀）。
  static const Color WARNING = Color(0xFFFFA726);

  /// 错误/危险（红）。
  static const Color ERROR = Color(0xFFEF5350);

  /// 信息提示（蓝）。
  static const Color INFO = Color(0xFF42A5F5);
}
