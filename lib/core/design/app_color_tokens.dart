import 'package:flutter/material.dart';

abstract final class AppColorTokens {
  static const Color primary = Color(0xFF15803D);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF111827);
  static const Color body = Color(0xFF1F2937);
  static const Color mute = Color(0xFF6B7280);
  static const Color hairline = Color(0xFFE5E7EB);
  static const Color hairlineStrong = Color(0xFFD1D5DB);
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasSoft = Color(0xFFF8FAFC);
  static const Color canvasSoft2 = Color(0xFFF1F5F9);
  static const Color link = Color(0xFF16A34A);
  static const Color linkDeep = Color(0xFF166534);
  static const Color linkSoft = Color(0xFFDCFCE7);
  static const Color health = Color(0xFF15803D);
  static const Color healthSoft = Color(0xFFDCFCE7);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color errorDeep = Color(0xFF991B1B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color warningDeep = Color(0xFFB45309);
  static const Color violet = Color(0xFF7C3AED);
  static const Color violetSoft = Color(0xFFEDE9FE);
  static const Color violetDeep = Color(0xFF5B21B6);
  static const Color cyan = Color(0xFF2DD4BF);
  static const Color cyanSoft = Color(0xFFCCFBF1);
  static const Color cyanDeep = Color(0xFF0F766E);
  static const Color highlightPink = Color(0xFFF43F5E);
  static const Color highlightMagenta = Color(0xFFE11D48);
  static const Color gradientDevelopStart = Color(0xFF16A34A);
  static const Color gradientDevelopEnd = Color(0xFF14B8A6);
  static const Color gradientPreviewStart = Color(0xFF7C3AED);
  static const Color gradientPreviewEnd = Color(0xFFE11D48);
  static const Color gradientShipStart = Color(0xFFF59E0B);
  static const Color gradientShipEnd = Color(0xFF84CC16);
  static const Color accent = Color(0xFF16A34A);
  static const Color accentSoft = Color(0xFFDCFCE7);
  static const Color errorDark = Color(0xFFF87171);
  static const Color selectionBackground = Color(0xFF166534);
  static const Color selectionForeground = Color(0xFFF9FAFB);

  /// 点击水波纹颜色（叠加在 canvas 之上），用于 [AppInkWell]。
  static const Color inkSplash = Color(0x14000000);

  /// 点击高亮颜色（长按或 hover），用于 [AppInkWell]。
  static const Color inkHighlight = Color(0x0A000000);

  /// 禁用态不透明度，用于 [AppInkWell.onTap] 为 null 时。
  static const double inkDisabledOpacity = 0.5;

  static const seed = primary;
}
