import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/brand_icon.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return BrandIcon(size: size);
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
    final String leadText = l10n.authTermsAgreementPrefix;
    final String connector = l10n.authTermsConjunction;
    final String termsLabel = l10n.authTermsOfService;
    final String privacyLabel = l10n.authPrivacyPolicy;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            Text(
              leadText,
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
