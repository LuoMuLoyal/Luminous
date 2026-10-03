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
        padding: const EdgeInsets.all(Spacing.lg),
        child: Row(
          children: [
            Icon(
              SemanticIcons.statusError,
              color: SemanticColor.primary.solid(context),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                l10n.recordNlpFailedCandidatesHint(failedCount),
                style: context.theme.typography.body.xs.copyWith(
                  color: colors.foreground,
                ),
              ),
            ),
            const SizedBox(width: Spacing.md),
            // 重试按钮是固有宽度:给宽度上限 + 标签省略,左侧提示文字
            // (Expanded)才不会被挤到多行。
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: FButton(
                variant: FButtonVariant.outline,
                key: const Key('record-nlp-retry-failed-action'),
                mainAxisSize: MainAxisSize.min,
                onPress: enabled ? onRetry : null,
                child: Flexible(
                  child: Text(
                    l10n.recordNlpRetryFailedAction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
