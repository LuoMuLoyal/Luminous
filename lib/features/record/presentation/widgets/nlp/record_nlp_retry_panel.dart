import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            const Icon(
              FLucideIcons.circleAlert,
              color: AppColorTokens.warningDeep,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Text(
                l10n.recordNlpFailedCandidatesHint(failedCount),
                style: textTheme.bodySmall?.copyWith(color: colors.foreground),
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
