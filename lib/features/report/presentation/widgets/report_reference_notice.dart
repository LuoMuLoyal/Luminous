import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportReferenceNotice extends StatelessWidget {
  const ReportReferenceNotice({
    super.key,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          AppColorTokens.warning.withValues(alpha: 0.1),
          surface.canvas,
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(
          color: AppColorTokens.warning.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColorTokens.warning,
              size: AppSpacingTokens.lg,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Text(
                l10n.reportReferenceNotice,
                style: typography.bodySm.copyWith(
                  color: AppColorTokens.warning,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
