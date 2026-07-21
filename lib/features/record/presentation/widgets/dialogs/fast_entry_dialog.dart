import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/constants/fast_entry_choices.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/forms/form_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordFastEntryDialog extends ConsumerStatefulWidget {
  const RecordFastEntryDialog({
    super.key,
    required this.kind,
    required this.occurredAt,
    required this.currentDateTime,
    required this.moreRoute,
    this.animation,
  });

  final DailyRecordKind kind;
  final String occurredAt;
  final DateTime currentDateTime;
  final String moreRoute;
  final Animation<double>? animation;

  @override
  ConsumerState<RecordFastEntryDialog> createState() =>
      _RecordFastEntryDialogState();
}

class _RecordFastEntryDialogState extends ConsumerState<RecordFastEntryDialog> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = dailyRecordKindLabel(l10n, widget.kind);
    final choices = recordFastEntryChoicesFor(widget.kind, l10n);

    return FDialog(
      key: Key('record-fast-entry-${widget.kind.name}'),
      animation: widget.animation,
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordFastEntryTitle(typeLabel),
              style: style.titleTextStyle,
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              l10n.recordFastEntryDateHint(widget.occurredAt),
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              spacing: Spacing.level3,
              runSpacing: Spacing.level3,
              children: [
                for (var index = 0; index < choices.length; index += 1)
                  _QuickChoiceChip(
                    key: Key(
                      'record-fast-entry-choice-${widget.kind.name}-$index',
                    ),
                    label: choices[index].label,
                    prefix: choices[index].prefix,
                    enabled: !_saving,
                    onTap: () => _saveChoice(choices[index]),
                  ),
              ],
            ),
            if (_saving) ...[
              const SizedBox(height: Spacing.level4),
              const Center(child: FProgress()),
            ],
            const SizedBox(height: Spacing.level5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: FButtonVariant.ghost,
                  key: const Key('record-fast-entry-more-action'),
                  onPress: _saving ? null : _openMore,
                  child: Text(l10n.recordFastEntryMoreAction),
                ),
                const SizedBox(width: Spacing.level3),
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: _saving ? null : () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMore() async {
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(context.push(widget.moreRoute));
  }

  Future<void> _saveChoice(RecordFastChoice choice) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(dailyRecordRepositoryProvider)
          .create(
            DailyRecordCreateInput(
              kind: widget.kind,
              occurredAt: widget.occurredAt,
              occurredTime: formatRecordTimeValue(widget.currentDateTime),
              title: choice.title,
              value: choice.value,
              unit: choice.unit,
              note: choice.note,
              payload: choice.payload,
            ),
          );

      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.dailyRecords);

      if (!mounted) return;
      unawaited(
        AppToast.show(
          context,
          AppLocalizations.of(context)!.recordCreateSavedToast,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('RecordFastEntryDialog._saveChoice: failed: $e');
      if (!mounted) return;
      unawaited(
        AppToast.show(
          context,
          AppLocalizations.of(context)!.recordCreateFailedToast,
        ),
      );
      setState(() => _saving = false);
    }
  }
}

class _QuickChoiceChip extends StatelessWidget {
  const _QuickChoiceChip({
    super.key,
    required this.label,
    this.prefix,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final Widget? prefix;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: FButtonVariant.outline,
      onPress: enabled ? onTap : null,
      prefix: prefix,
      child: Text(label),
    );
  }
}
