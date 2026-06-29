import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/utils/record_date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/forms/daily_record_form_fields.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordFastEntryDialog extends ConsumerStatefulWidget {
  const RecordFastEntryDialog({
    super.key,
    required this.kind,
    required this.occurredAt,
    required this.currentDateTime,
    required this.moreRoute,
  });

  final DailyRecordKind kind;
  final String occurredAt;
  final DateTime currentDateTime;
  final String moreRoute;

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
    final choices = _choicesFor(widget.kind, l10n);

    return AlertDialog(
      key: Key('record-fast-entry-${widget.kind.name}'),
      title: Text(l10n.recordFastEntryTitle(typeLabel)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recordFastEntryDateHint(widget.occurredAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColorTokens.mute),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Wrap(
            spacing: AppSpacingTokens.sm,
            runSpacing: AppSpacingTokens.sm,
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
        ],
      ),
      actions: [
        TextButton(
          key: const Key('record-fast-entry-more-action'),
          onPressed: _saving ? null : _openMore,
          child: Text(l10n.recordFastEntryMoreAction),
        ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
    );
  }

  Future<void> _openMore() async {
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(context.push(widget.moreRoute));
  }

  Future<void> _saveChoice(_QuickChoice choice) async {
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

      ref.invalidate(recordDashboardProvider);
      ref.invalidate(todayDashboardProvider);
      ref.invalidate(reportDashboardProvider);

      if (!mounted) return;
      unawaited(
        AppToast.show(
          context,
          AppLocalizations.of(context)!.mineEditSavedToast,
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
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
    return ActionChip(
      avatar: prefix,
      label: Text(label),
      onPressed: enabled ? onTap : null,
    );
  }
}

class _QuickChoice {
  const _QuickChoice({
    required this.label,
    this.prefix,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.payload,
  });

  final String label;
  final Widget? prefix;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
  final Map<String, dynamic>? payload;
}

List<_QuickChoice> _choicesFor(DailyRecordKind kind, AppLocalizations l10n) {
  return switch (kind) {
    DailyRecordKind.water => const [
      _QuickChoice(label: '250 ml', value: '250', unit: 'ml'),
      _QuickChoice(label: '500 ml', value: '500', unit: 'ml'),
      _QuickChoice(label: '1 cup', value: '1', unit: 'cup'),
      _QuickChoice(label: '1 time', value: '1', unit: 'times'),
    ],
    DailyRecordKind.meal => [
      _QuickChoice(
        label: l10n.recordFastChoiceMealBreakfast,
        title: l10n.recordFastChoiceMealBreakfast,
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceMealLunch,
        title: l10n.recordFastChoiceMealLunch,
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceMealDinner,
        title: l10n.recordFastChoiceMealDinner,
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceMealSnack,
        title: l10n.recordFastChoiceMealSnack,
      ),
    ],
    DailyRecordKind.symptom => [
      _QuickChoice(
        label: l10n.recordFastChoiceSymptomHeadache,
        title: l10n.recordFastChoiceSymptomHeadache,
        value: l10n.recordFastChoiceSeverityMild,
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceSymptomStomachache,
        title: l10n.recordFastChoiceSymptomStomachache,
        value: l10n.recordFastChoiceSeverityMild,
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceSymptomDizzy,
        title: l10n.recordFastChoiceSymptomDizzy,
        value: l10n.recordFastChoiceSeverityMild,
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceSymptomFever,
        title: l10n.recordFastChoiceSymptomFever,
        value: l10n.recordFastChoiceSeverityMild,
      ),
    ],
    DailyRecordKind.note => [
      _QuickChoice(
        label: l10n.recordFastChoiceNoteStable,
        title: l10n.recordFastChoiceNoteStable,
        note: l10n.recordFastChoiceNoteStable,
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceNoteTired,
        title: l10n.recordFastChoiceNoteTired,
        note: l10n.recordFastChoiceNoteTired,
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceNoteBusy,
        title: l10n.recordFastChoiceNoteBusy,
        note: l10n.recordFastChoiceNoteBusy,
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceNoteRecovered,
        title: l10n.recordFastChoiceNoteRecovered,
        note: l10n.recordFastChoiceNoteRecovered,
      ),
    ],
    DailyRecordKind.sleep => [
      _QuickChoice(
        label: '6h',
        payload: <String, dynamic>{'durationMinutes': 360},
      ),
      _QuickChoice(
        label: '7h',
        payload: <String, dynamic>{'durationMinutes': 420},
      ),
      _QuickChoice(
        label: '8h',
        payload: <String, dynamic>{'durationMinutes': 480},
      ),
      _QuickChoice(
        label: '9h',
        payload: <String, dynamic>{'durationMinutes': 540},
      ),
    ],
    DailyRecordKind.mood => [
      _QuickChoice(
        label: l10n.recordFastChoiceMoodGreat,
        prefix: const Text('😄'),
        payload: <String, dynamic>{'moodLevel': 5, 'moodLabel': 'great'},
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceMoodGood,
        prefix: const Text('🙂'),
        payload: <String, dynamic>{'moodLevel': 4, 'moodLabel': 'good'},
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceMoodOkay,
        prefix: const Text('😐'),
        payload: <String, dynamic>{'moodLevel': 3, 'moodLabel': 'okay'},
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceMoodBad,
        prefix: const Text('😟'),
        payload: <String, dynamic>{'moodLevel': 2, 'moodLabel': 'bad'},
      ),
      _QuickChoice(
        label: l10n.recordFastChoiceMoodTerrible,
        prefix: const Text('😫'),
        payload: <String, dynamic>{'moodLevel': 1, 'moodLabel': 'terrible'},
      ),
    ],
    _ => const [],
  };
}
