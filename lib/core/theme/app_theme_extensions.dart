import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_color_tokens.dart';

@immutable
class AppThemeSurface extends ThemeExtension<AppThemeSurface> {
  const AppThemeSurface({
    required this.canvas,
    required this.canvasSoft,
    required this.canvasSoft2,
    required this.hairline,
    required this.hairlineStrong,
    required this.body,
    required this.mute,
    required this.link,
    required this.linkSoft,
    required this.accent,
    required this.teal,
    required this.tealSoft,
    required this.success,
    required this.error,
    required this.warning,
    required this.warningDeep,
    required this.warningSoft,
    required this.violet,
  });

  final Color canvas;
  final Color canvasSoft;
  final Color canvasSoft2;
  final Color hairline;
  final Color hairlineStrong;
  final Color body;
  final Color mute;
  final Color link;
  final Color linkSoft;
  final Color accent;
  final Color teal;
  final Color tealSoft;
  final Color success;
  final Color error;
  final Color warning;
  final Color warningDeep;
  final Color warningSoft;
  final Color violet;

  static const AppThemeSurface light = AppThemeSurface(
    canvas: AppColorTokens.canvas,
    canvasSoft: AppColorTokens.canvasSoft,
    canvasSoft2: AppColorTokens.canvasSoft2,
    hairline: AppColorTokens.hairline,
    hairlineStrong: AppColorTokens.hairlineStrong,
    body: AppColorTokens.body,
    mute: AppColorTokens.mute,
    link: AppColorTokens.link,
    linkSoft: AppColorTokens.linkSoft,
    accent: AppColorTokens.accent,
    teal: AppColorTokens.cyanDeep,
    tealSoft: AppColorTokens.cyanSoft,
    success: AppColorTokens.success,
    error: AppColorTokens.error,
    warning: AppColorTokens.warning,
    warningDeep: AppColorTokens.warningDeep,
    warningSoft: AppColorTokens.warningSoft,
    violet: AppColorTokens.violet,
  );

  static const AppThemeSurface dark = AppThemeSurface(
    canvas: Color(0xFF111111),
    canvasSoft: Color(0xFF171717),
    canvasSoft2: Color(0xFF1F1F1F),
    hairline: Color(0xFF2A2A2A),
    hairlineStrong: Color(0xFF4A4A4A),
    body: Color(0xFFCECECE),
    mute: Color(0xFF9A9A9A),
    link: AppColorTokens.link,
    linkSoft: Color(0xFF1A2A42),
    accent: AppColorTokens.accent,
    teal: AppColorTokens.cyanDeep,
    tealSoft: Color(0xFF1A3A32),
    success: AppColorTokens.success,
    error: AppColorTokens.errorDark,
    warning: Color(0xFFFFC861),
    warningDeep: Color(0xFFE6A819),
    warningSoft: Color(0xFF3A2E12),
    violet: AppColorTokens.violet,
  );

  @override
  AppThemeSurface copyWith({
    Color? canvas,
    Color? canvasSoft,
    Color? canvasSoft2,
    Color? hairline,
    Color? hairlineStrong,
    Color? body,
    Color? mute,
    Color? link,
    Color? linkSoft,
    Color? accent,
    Color? teal,
    Color? tealSoft,
    Color? success,
    Color? error,
    Color? warning,
    Color? warningDeep,
    Color? warningSoft,
    Color? violet,
  }) {
    return AppThemeSurface(
      canvas: canvas ?? this.canvas,
      canvasSoft: canvasSoft ?? this.canvasSoft,
      canvasSoft2: canvasSoft2 ?? this.canvasSoft2,
      hairline: hairline ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      body: body ?? this.body,
      mute: mute ?? this.mute,
      link: link ?? this.link,
      linkSoft: linkSoft ?? this.linkSoft,
      accent: accent ?? this.accent,
      teal: teal ?? this.teal,
      tealSoft: tealSoft ?? this.tealSoft,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      warningDeep: warningDeep ?? this.warningDeep,
      warningSoft: warningSoft ?? this.warningSoft,
      violet: violet ?? this.violet,
    );
  }

  @override
  ThemeExtension<AppThemeSurface> lerp(
    covariant ThemeExtension<AppThemeSurface>? other,
    double t,
  ) {
    if (other is! AppThemeSurface) return this;
    return AppThemeSurface(
      canvas: Color.lerp(canvas, other.canvas, t) ?? canvas,
      canvasSoft: Color.lerp(canvasSoft, other.canvasSoft, t) ?? canvasSoft,
      canvasSoft2: Color.lerp(canvasSoft2, other.canvasSoft2, t) ?? canvasSoft2,
      hairline: Color.lerp(hairline, other.hairline, t) ?? hairline,
      hairlineStrong:
          Color.lerp(hairlineStrong, other.hairlineStrong, t) ?? hairlineStrong,
      body: Color.lerp(body, other.body, t) ?? body,
      mute: Color.lerp(mute, other.mute, t) ?? mute,
      link: Color.lerp(link, other.link, t) ?? link,
      linkSoft: Color.lerp(linkSoft, other.linkSoft, t) ?? linkSoft,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      teal: Color.lerp(teal, other.teal, t) ?? teal,
      tealSoft: Color.lerp(tealSoft, other.tealSoft, t) ?? tealSoft,
      success: Color.lerp(success, other.success, t) ?? success,
      error: Color.lerp(error, other.error, t) ?? error,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningDeep: Color.lerp(warningDeep, other.warningDeep, t) ?? warningDeep,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t) ?? warningSoft,
      violet: Color.lerp(violet, other.violet, t) ?? violet,
    );
  }

  factory AppThemeSurface.fromForuiColors(FColors colors) {
    return AppThemeSurface(
      canvas: colors.card,
      canvasSoft: colors.background,
      canvasSoft2: colors.secondary,
      hairline: colors.border,
      hairlineStrong: colors.border.withValues(alpha: 0.9),
      body: colors.foreground,
      mute: colors.mutedForeground,
      link: colors.primary,
      linkSoft: colors.secondary,
      accent: colors.primary,
      teal: colors.primary,
      tealSoft: colors.secondary,
      success: AppColorTokens.success,
      error: colors.error,
      warning: AppColorTokens.warning,
      warningDeep: AppColorTokens.warningDeep,
      warningSoft: AppColorTokens.warningSoft,
      violet: AppColorTokens.violet,
    );
  }
}
