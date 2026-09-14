import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
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
///
/// `mainAxisMaxRatio: null` 是 Forui 对「主轴上含可滚动子节点」的建议值，也是配合
/// body 里 `DraggableScrollableSheet` 往上拖展开的前提：有上限时 sheet 长不到整屏，
/// 手势只能往下拖。
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
    mainAxisMaxRatio: null,
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

/// 单一类型下的时段草稿。
@immutable
class _SleepDraft {
  const _SleepDraft({required this.bedtime, required this.wakeTime});

  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;

  _SleepDraft copyWith({TimeOfDay? bedtime, TimeOfDay? wakeTime}) {
    return _SleepDraft(
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
    );
  }
}

class _SleepQuickEntrySheetBodyState extends State<SleepQuickEntrySheetBody> {
  /// sheet 的初始/最小高度（占可用高度比例）；往上拖可展开到整屏。
  static const _initialSize = 0.75;
  static const _minSize = 0.55;

  static const _nightBedtime = TimeOfDay(hour: 23, minute: 0);
  static const _nightWakeTime = TimeOfDay(hour: 7, minute: 0);
  static const _napBedtime = TimeOfDay(hour: 13, minute: 0);
  static const _napWakeTime = TimeOfDay(hour: 13, minute: 30);

  static const _kinds = [SleepEntryKind.nightSleep, SleepEntryKind.nap];

  late SleepEntryKind _kind = widget.initialKind;

  /// 每种类型各存一份时段草稿：来回切换类型时两边的时间互不覆盖
  /// （夜间 23:00–07:00 不会因为切去小睡再切回来就变成 13:00–13:30）。
  late final Map<SleepEntryKind, _SleepDraft> _drafts = {
    for (final kind in _kinds)
      kind: kind == widget.initialKind
          ? _SleepDraft(
              bedtime: widget.initialBedtime,
              wakeTime: widget.initialWakeTime,
            )
          : _defaultDraft(kind),
  };

  final TextEditingController _noteController = TextEditingController();
  String? _quality;

  static _SleepDraft _defaultDraft(SleepEntryKind kind) => switch (kind) {
    SleepEntryKind.nightSleep => const _SleepDraft(
      bedtime: _nightBedtime,
      wakeTime: _nightWakeTime,
    ),
    SleepEntryKind.nap => const _SleepDraft(
      bedtime: _napBedtime,
      wakeTime: _napWakeTime,
    ),
  };

  _SleepDraft get _draft => _drafts[_kind]!;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectKind(int index) => setState(() => _kind = _kinds[index]);

  void _setBedtime(TimeOfDay? value) {
    if (value == null) return;
    setState(() => _drafts[_kind] = _draft.copyWith(bedtime: value));
  }

  void _setWakeTime(TimeOfDay? value) {
    if (value == null) return;
    setState(() => _drafts[_kind] = _draft.copyWith(wakeTime: value));
  }

  /// 质量可空：再点一次已选项即清除。
  void _toggleQuality(String key) {
    setState(() => _quality = _quality == key ? null : key);
  }

  void _submit() {
    Navigator.of(context).pop(
      SleepQuickEntryResult(
        kind: _kind,
        bedtime: _draft.bedtime,
        wakeTime: _draft.wakeTime,
        quality: _quality,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final bedtime = _draft.bedtime;
    final wakeTime = _draft.wakeTime;
    final error = validateSleepEntry(
      bedtime: bedtime,
      wakeTime: wakeTime,
      kind: _kind,
    );
    final durationMinutes = computeSleepDurationMinutes(bedtime, wakeTime);
    final errorText = error == null ? null : sleepEntryErrorText(l10n, error);

    return SheetSurface(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: _initialSize,
        minChildSize: _minSize,
        maxChildSize: 1,
        snap: true,
        builder: (context, scrollController) => ScrollConfiguration(
          // 让鼠标/触控板也能拖动（桌面与 Web）。
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: const {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              Spacing.xl,
              0,
              Spacing.xl,
              Spacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetDragHandle(),
                Text(
                  l10n.recordQuickSleepSheetTitle,
                  textAlign: TextAlign.center,
                  style: typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                FTabs(
                  key: const Key('sleep-quick-entry-type'),
                  control: FTabControl.lifted(
                    index: _kinds.indexOf(_kind),
                    onChange: _selectKind,
                  ),
                  children: [
                    for (final kind in _kinds)
                      FTabEntry(
                        label: Text(sleepEntryKindLabel(l10n, kind)),
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
                          time: bedtime.toFTime(),
                          onChange: (value) =>
                              _setBedtime(value?.toTimeOfDay()),
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.lg),
                    Expanded(
                      child: FTimeField.picker(
                        key: const Key('sleep-quick-entry-waketime'),
                        label: Text(l10n.recordSleepWakeTimeLabel),
                        control: FTimeFieldControl.lifted(
                          time: wakeTime.toFTime(),
                          onChange: (value) =>
                              _setWakeTime(value?.toTimeOfDay()),
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
                Text(
                  l10n.recordSleepQualityLabel,
                  style: typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                // 内联 chip 行：选项全部可见且随 sheet 一起拖动/滚动，不用弹出层。
                Wrap(
                  key: const Key('sleep-quick-entry-quality'),
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: [
                    for (final option in sleepQualityOptions(l10n))
                      _QualityChip(
                        label: option.label,
                        selected: _quality == option.key,
                        onPress: () => _toggleQuality(option.key),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
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
        ),
      ),
    );
  }
}

/// 单个睡眠质量 pill chip。
class _QualityChip extends StatelessWidget {
  const _QualityChip({
    required this.label,
    required this.selected,
    required this.onPress,
  });

  final String label;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final tone = selected ? SemanticColor.primary : SemanticColor.neutral;
    return Semantics(
      selected: selected,
      button: true,
      child: FTappable(
        onPress: onPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tone.muted(context),
            borderRadius: context.theme.style.borderRadius.pill,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Text(
              label,
              style: context.theme.typography.body.sm.copyWith(
                color: tone.solid(context),
                fontWeight: FontWeight.w600,
              ),
            ),
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
