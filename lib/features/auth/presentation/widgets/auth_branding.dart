import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({super.key, this.size = 64});

  final double size;

  static const String _assetPath = 'assets/icons/luminous_app_icon.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        FLucideIcons.shieldPlus,
        color: theme.colorScheme.primary,
        size: size,
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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final linkStyle = textTheme.bodySmall?.copyWith(
      color: colors.primary,
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.level2),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            Text(
              trimmedLead,
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            TextButton(
              onPressed: onTerms,
              style: linkButtonStyle,
              child: Text(termsLabel, style: linkStyle),
            ),
            Text(
              connector,
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
              ),
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
