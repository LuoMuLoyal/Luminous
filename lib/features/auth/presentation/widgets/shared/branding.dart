import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({super.key, this.size = 64});

  final double size;

  static const String _assetPath = 'assets/icon/app_icon.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        SemanticIcons.safetyCaution,
        color: SemanticColor.primary.solid(context),
        size: size,
      ),
    );
  }
}

/// Terms notice at the bottom of the register page. Currently uses a toast
/// placeholder; can be replaced with real navigation in the future.
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
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    final linkStyle = typography.body.xs.copyWith(
      color: SemanticColor.primary.solid(context),
      fontWeight: FontWeight.w600,
    );
    final String leadText = l10n.authTermsAgreement('', '');
    final String connector = l10n.localeName.startsWith('zh') ? '与' : ' and ';
    final String termsLabel = l10n.authTermsOfService;
    final String privacyLabel = l10n.authPrivacyPolicy;

    final String trimmedLead = leadText.trimRight().replaceAll(
      RegExp(r'\s+(and|与)\s*$'),
      '',
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.level2),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            Text(
              trimmedLead,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            FButton(
              variant: FButtonVariant.ghost,
              onPress: onTerms,
              child: Text(termsLabel, style: linkStyle),
            ),
            Text(
              connector,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            FButton(
              variant: FButtonVariant.ghost,
              onPress: onPrivacy,
              child: Text(privacyLabel, style: linkStyle),
            ),
          ],
        ),
      ),
    );
  }
}
