import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNlpRetryPanel extends StatelessWidget {
  const RecordNlpRetryPanel({
    super.key,
    required this.failedCount,
    required this.enabled,
    required this.onRetry,
  });

  final int failedCount;
  final bool enabled;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.warning.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: surface.warning),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Text(
                l10n.recordNlpFailedCandidatesHint(failedCount),
                style: typography.bodySm.copyWith(color: surface.body),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            OutlinedButton(
              key: const Key('record-nlp-retry-failed-action'),
              onPressed: enabled ? onRetry : null,
              child: Text(l10n.recordNlpRetryFailedAction),
            ),
          ],
        ),
      ),
    );
  }
}
