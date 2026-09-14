import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/services/sleep_entry.dart';
import 'package:luminous/features/record/presentation/utils/sleep_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 一次性睡眠录入的结果。
class SleepQuickEntryResult {
  const SleepQuickEntryResult({
    required this.kind,
    required this.bedtime,
    required this.wakeTime,
    this.quality,
    this.note,
  });

  final SleepEntryKind kind;
  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;
  final String? quality;
  final String? note;
}

/// 打开睡眠一次性录入 sheet。
///
/// [recordDate] 是**归属日**（即起床日）。用户下滑或点外部关闭时返回 null，
/// 不产生任何记录。
Future<SleepQuickEntryResult?> showSleepQuickEntrySheet(
  BuildContext context, {
  required DateTime recordDate,
  required SleepEntryKind initialKind,
  required TimeOfDay initialBedtime,
  required TimeOfDay initialWakeTime,
}) {
  return showFSheet<SleepQuickEntryResult>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
    mainAxisMaxRatio: 0.85,
    builder: (context) => SleepQuickEntrySheetBody(
      recordDate: recordDate,
      initialKind: initialKind,
      initialBedtime: initialBedtime,
      initialWakeTime: initialWakeTime,
    ),
  );
}

/// Sheet body: type / bedtime / wake time / duration / record date / quality /
/// note.
class SleepQuickEntrySheetBody extends StatefulWidget {
  const SleepQuickEntrySheetBody({
    super.key,
    required this.recordDate,
    required this.initialKind,
    required this.initialBedtime,
    required this.initialWakeTime,
  });

  final DateTime recordDate;
  final SleepEntryKind initialKind;
  final TimeOfDay initialBedtime;
  final TimeOfDay initialWakeTime;

  @override
  State<SleepQuickEntrySheetBody> createState() =>
      _SleepQuickEntrySheetBodyState();
}

class _SleepQuickEntrySheetBodyState extends State<SleepQuickEntrySheetBody> {
  /// 切到小睡时若当前时段不适合小睡，回落到这个默认时段。
  static const _napBedtime = TimeOfDay(hour: 13, minute: 0);
  static const _napWakeTime = TimeOfDay(hour: 13, minute: 30);

  static const _kinds = [SleepEntryKind.nightSleep, SleepEntryKind.nap];

  late SleepEntryKind _kind = widget.initialKind;
  late TimeOfDay _bedtime = widget.initialBedtime;
  late TimeOfDay _wakeTime = widget.initialWakeTime;
  final TextEditingController _noteController = TextEditingController();
  String? _quality;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectKind(int index) {
    final kind = _kinds[index];
    setState(() {
      _kind = kind;
      // 小睡不能跨天、也不能超过 3 小时；沿用夜间时段时回落到小睡默认值。
      if (kind == SleepEntryKind.nap &&
          validateSleepEntry(
                bedtime: _bedtime,
                wakeTime: _wakeTime,
                kind: SleepEntryKind.nap,
              ) !=
              null) {
        _bedtime = _napBedtime;
        _wakeTime = _napWakeTime;
      }
    });
  }

  void _submit() {
    Navigator.of(context).pop(
      SleepQuickEntryResult(
        kind: _kind,
        bedtime: _bedtime,
        wakeTime: _wakeTime,
        quality: _quality,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  String? _errorText(AppLocalizations l10n, SleepEntryValidationError? error) {
    return switch (error) {
      null => null,
      SleepEntryValidationError.missingTimes =>
        l10n.recordQuickSleepMissingTimesError,
      SleepEntryValidationError.wakeNotAfterBedtime =>
        l10n.recordQuickSleepInvalidDurationToast,
      SleepEntryValidationError.napCrossesMidnight =>
        l10n.recordQuickSleepNapCrossesMidnightError,
      SleepEntryValidationError.napTooLong =>
        l10n.recordQuickSleepNapTooLongError,
      SleepEntryValidationError.nightSleepTooLong =>
        l10n.recordQuickSleepNightTooLongError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final error = validateSleepEntry(
      bedtime: _bedtime,
      wakeTime: _wakeTime,
      kind: _kind,
    );
    final durationMinutes = computeSleepDurationMinutes(_bedtime, _wakeTime);
    final errorText = _errorText(l10n, error);

    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(color: context.theme.colors.background),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: Spacing.sm),
                  child: Container(
                    width: Spacing.xl3,
                    height: Spacing.xs,
                    decoration: BoxDecoration(
                      color: SemanticColor.neutral.solid(context),
                      borderRadius: context.theme.style.borderRadius.pill,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.md,
                  Spacing.lg,
                  Spacing.sm,
                ),
                child: Text(
                  l10n.recordQuickSleepSheetTitle,
                  style: typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FTabs(
                      key: const Key('sleep-quick-entry-type'),
                      control: FTabControl.lifted(
                        index: _kinds.indexOf(_kind),
                        onChange: _selectKind,
                      ),
                      children: [
                        FTabEntry(
                          label: Text(l10n.recordQuickSleepNightAction),
                          child: const SizedBox.shrink(),
                        ),
                        FTabEntry(
                          label: Text(l10n.recordQuickSleepNapAction),
                          child: const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: FTimeField.picker(
                            key: const Key('sleep-quick-entry-bedtime'),
                            label: Text(l10n.recordSleepBedtimeLabel),
                            control: FTimeFieldControl.lifted(
                              time: _bedtime.toFTime(),
                              onChange: (value) {
                                final time = value?.toTimeOfDay();
                                if (time != null) {
                                  setState(() => _bedtime = time);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.lg),
                        Expanded(
                          child: FTimeField.picker(
                            key: const Key('sleep-quick-entry-waketime'),
                            label: Text(l10n.recordSleepWakeTimeLabel),
                            control: FTimeFieldControl.lifted(
                              time: _wakeTime.toFTime(),
                              onChange: (value) {
                                final time = value?.toTimeOfDay();
                                if (time != null) {
                                  setState(() => _wakeTime = time);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      '${l10n.recordSleepDurationLabel}: '
                      '${formatSleepDurationLabel(durationMinutes ?? 0, l10n)}',
                      style: typography.body.sm,
                    ),
                    const SizedBox(height: Spacing.xs),
                    // 归属日（起床日）必须显式写出来，用户不必猜这条记到哪天。
                    Text(
                      l10n.recordQuickSleepRecordedOn(
                        widget.recordDate.month,
                        widget.recordDate.day,
                      ),
                      key: const Key('sleep-quick-entry-recorded-on'),
                      style: typography.body.sm.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: Spacing.sm),
                      Text(
                        errorText,
                        key: const Key('sleep-quick-entry-error'),
                        style: typography.body.sm.copyWith(
                          color: SemanticColor.destructive.solid(context),
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.lg),
                    FSelect<String>.rich(
                      key: const Key('sleep-quick-entry-quality'),
                      label: Text(l10n.recordSleepQualityLabel),
                      hint: l10n.recordSleepQualityLabel,
                      format: (value) => sleepQualityOptions(
                        l10n,
                      ).firstWhere((option) => option.key == value).label,
                      control: FSelectControl.lifted(
                        value: _quality,
                        onChange: (value) => setState(() => _quality = value),
                      ),
                      children: sleepQualityOptions(l10n)
                          .map(
                            (option) => FSelectItem.item(
                              title: Text(option.label),
                              value: option.key,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: Spacing.md),
                    FTextField(
                      key: const Key('sleep-quick-entry-note'),
                      control: FTextFieldControl.managed(
                        controller: _noteController,
                      ),
                      label: Text(l10n.recordCreateFieldNote),
                    ),
                    const SizedBox(height: Spacing.xl),
                    FButton(
                      key: const Key('sleep-quick-entry-save'),
                      onPress: error == null ? _submit : null,
                      child: Text(l10n.mineEditSaveAction),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

extension _SleepQuickEntryTimeOfDay on TimeOfDay {
  FTime toFTime() => FTime(hour, minute);
}

extension _SleepQuickEntryFTime on FTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
