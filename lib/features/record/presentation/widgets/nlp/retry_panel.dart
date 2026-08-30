import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
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

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            Icon(
              SemanticIcons.statusError,
              color: context.theme.colors.primary,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                l10n.recordNlpFailedCandidatesHint(failedCount),
                style: context.theme.typography.body.xs.copyWith(
                  color: colors.foreground,
                ),
              ),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              variant: FButtonVariant.outline,
              key: const Key('record-nlp-retry-failed-action'),
              onPress: enabled ? onRetry : null,
              child: Text(l10n.recordNlpRetryFailedAction),
            ),
          ],
        ),
      ),
    );
  }
}
