import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Auth 页面品牌 Logo。用浅灰圆角渐变容器包裹白色 app icon,
/// 解决白底图标与白色卡片背景融合的问题,并增加层次感。
class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({super.key, this.size = 64});

  final double size;

  static const String _assetPath = 'assets/icons/luminous_app_icon.png';

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[surface.canvasSoft, surface.canvasSoft2],
        ),
        boxShadow: AppShadowTokens.level1,
      ),
      padding: const EdgeInsets.all(AppSpacingTokens.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Image.asset(
          _assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.health_and_safety_rounded,
            color: theme.colorScheme.primary,
            size: size - AppSpacingTokens.sm * 2,
          ),
        ),
      ),
    );
  }
}

/// 注册页底部服务条款提示。当前用 toast 占位,未来可替换为真实跳转。
class AuthTermsNotice extends StatelessWidget {
  const AuthTermsNotice({
    super.key,
    required this.onTerms,
    required this.onPrivacy,
  });

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final l10n = AppLocalizations.of(context);

    final linkStyle = typography.bodySm.copyWith(
      color: surface.link,
      fontWeight: FontWeight.w600,
    );
    final linkButtonStyle = TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 28),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final String leadText =
        l10n?.authTermsAgreement('', '') ??
        'By creating an account, you agree to the ';
    final String connector = l10n?.localeName.startsWith('zh') == true
        ? '与'
        : ' and ';
    final String termsLabel = l10n?.authTermsOfService ?? 'Terms of Service';
    final String privacyLabel = l10n?.authPrivacyPolicy ?? 'Privacy Policy';

    final String trimmedLead = leadText.trimRight().replaceAll(
      RegExp(r'\s+(and|与)\s*$'),
      '',
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xs),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            Text(
              trimmedLead,
              style: typography.bodySm.copyWith(color: surface.body),
            ),
            TextButton(
              onPressed: onTerms,
              style: linkButtonStyle,
              child: Text(termsLabel, style: linkStyle),
            ),
            Text(
              connector,
              style: typography.bodySm.copyWith(color: surface.body),
            ),
            TextButton(
              onPressed: onPrivacy,
              style: linkButtonStyle,
              child: Text(privacyLabel, style: linkStyle),
            ),
          ],
        ),
      ),
    );
  }
}
