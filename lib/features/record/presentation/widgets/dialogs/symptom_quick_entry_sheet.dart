import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/pill_chip.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/features/record/domain/constants/fast_entry_choices.dart';
import 'package:luminous/features/record/domain/constants/symptom_catalog.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 症状快速录入的结果：要么带着选中项去落库，要么去完整的创建页。
sealed class SymptomQuickEntryOutcome {
  const SymptomQuickEntryOutcome();
}

/// 用户选好的症状（单选一项，或多选多项）与本次严重度。
class SymptomQuickEntrySelection extends SymptomQuickEntryOutcome {
  const SymptomQuickEntrySelection({
    required this.choices,
    required this.severity,
    this.customLabel,
  });

  final List<RecordFastChoice> choices;
  final String severity;

  /// 仅当选择里含「其它」时给出的自定义症状名。
  final String? customLabel;
}

/// 用户点了「更多」：交给调用方跳创建页（sheet 自己不导航）。
class SymptomQuickEntryMore extends SymptomQuickEntryOutcome {
  const SymptomQuickEntryMore();
}

/// 打开症状快速录入 sheet。
///
/// 选严重度 → 点一个症状即保存；进入多选可一次记录多个。落库与撤销由调用方
/// （application 层）执行，sheet 只负责收集选择——这样撤销 toast 的 action 不会
/// 因为 sheet 已关闭而拿到失活的 context。
Future<SymptomQuickEntryOutcome?> showSymptomQuickEntrySheet(
  BuildContext context, {
  required DateTime recordDate,
  required List<RecordFastChoice> choices,
  required String initialSeverity,
}) {
  return showFSheet<SymptomQuickEntryOutcome>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
    mainAxisMaxRatio: null,
    builder: (context) => SymptomQuickEntrySheetBody(
      recordDate: recordDate,
      choices: choices,
      initialSeverity: initialSeverity,
    ),
  );
}

/// Sheet body: severity row / symptom chips / multi-select actions.
class SymptomQuickEntrySheetBody extends StatefulWidget {
  const SymptomQuickEntrySheetBody({
    super.key,
    required this.recordDate,
    required this.choices,
    required this.initialSeverity,
  });

  final DateTime recordDate;
  final List<RecordFastChoice> choices;
  final String initialSeverity;

  @override
  State<SymptomQuickEntrySheetBody> createState() =>
      _SymptomQuickEntrySheetBodyState();
}

class _SymptomQuickEntrySheetBodyState
    extends State<SymptomQuickEntrySheetBody> {
  static const _initialSize = 0.7;
  static const _minSize = 0.55;

  late String _severity = widget.initialSeverity;
  final Set<int> _selectedIndexes = <int>{};
  final TextEditingController _otherController = TextEditingController();
  bool _multiSelect = false;
  bool _otherInput = false;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _selectSeverity(String severity) => setState(() => _severity = severity);

  void _handleChoiceTap(int index) {
    final choice = widget.choices[index];
    if (!_multiSelect) {
      // 「其它」需要用户补一个名称，先就地展开输入框而不是立即落库。
      if (recordFastChoiceCode(choice) == SymptomCode.other.wireValue) {
        setState(() => _otherInput = true);
        return;
      }
      _submit([choice]);
      return;
    }
    setState(() {
      if (!_selectedIndexes.remove(index)) {
        _selectedIndexes.add(index);
      }
    });
  }

  void _submit(List<RecordFastChoice> choices, {String? customLabel}) {
    Navigator.of(context).pop(
      SymptomQuickEntrySelection(
        choices: choices,
        severity: _severity,
        customLabel: customLabel,
      ),
    );
  }

  void _submitOther() {
    final text = _otherController.text.trim();
    if (text.isEmpty) return;
    final choice = widget.choices.firstWhere(
      (item) => recordFastChoiceCode(item) == SymptomCode.other.wireValue,
    );
    _submit([choice], customLabel: text);
  }

  void _openMore() {
    Navigator.of(context).pop(const SymptomQuickEntryMore());
  }

  void _exitMultiSelect() {
    setState(() {
      _multiSelect = false;
      _selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final selectedChoices = _selectedIndexes
        .map((index) => widget.choices[index])
        .toList(growable: false);

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
                  l10n.recordSymptomSheetTitle,
                  textAlign: TextAlign.center,
                  style: typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  l10n.recordFastEntryDateHint(
                    formatRecordDate(widget.recordDate),
                  ),
                  textAlign: TextAlign.center,
                  style: typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Text(
                  l10n.recordSymptomSeverityLabel,
                  style: typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  key: const Key('symptom-quick-severity'),
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: [
                    for (final severity in SymptomSeverity.ordered)
                      PillChip(
                        key: Key(
                          'symptom-quick-severity-${severity.wireValue}',
                        ),
                        label: symptomSeverityLabel(l10n, severity.wireValue),
                        selected: _severity == severity.wireValue,
                        onPress: () => _selectSeverity(severity.wireValue),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                Text(
                  _multiSelect
                      ? l10n.recordSymptomMultiSelectHint
                      : l10n.recordSymptomSingleSelectHint,
                  style: typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  key: const Key('symptom-quick-choices'),
                  spacing: Spacing.md,
                  runSpacing: Spacing.md,
                  children: [
                    for (
                      var index = 0;
                      index < widget.choices.length;
                      index += 1
                    )
                      FButton(
                        key: Key(
                          'symptom-quick-choice-'
                          '${recordFastChoiceCode(widget.choices[index]) ?? index}',
                        ),
                        variant: _selectedIndexes.contains(index)
                            ? FButtonVariant.primary
                            : FButtonVariant.outline,
                        onPress:
                            _multiSelect &&
                                recordFastChoiceCode(widget.choices[index]) ==
                                    SymptomCode.other.wireValue
                            ? null
                            : () => _handleChoiceTap(index),
                        child: Text(widget.choices[index].label),
                      ),
                  ],
                ),
                if (_otherInput) ...[
                  const SizedBox(height: Spacing.lg),
                  // 「其它」就地展开：输入为空时保存置灰。
                  FTextField(
                    key: const Key('symptom-quick-other-field'),
                    control: FTextFieldControl.managed(
                      controller: _otherController,
                      onChange: (_) => setState(() {}),
                    ),
                    label: Text(l10n.recordSymptomCustomLabel),
                    autofocus: true,
                  ),
                ],
                const SizedBox(height: Spacing.xl),
                if (_multiSelect)
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          variant: FButtonVariant.outline,
                          key: const Key('symptom-quick-back-action'),
                          onPress: _exitMultiSelect,
                          child: Text(l10n.commonBack),
                        ),
                      ),
                      const SizedBox(width: Spacing.lg),
                      Expanded(
                        child: FButton(
                          key: const Key('symptom-quick-confirm-action'),
                          onPress: selectedChoices.isEmpty
                              ? null
                              : () => _submit(selectedChoices),
                          child: Text(
                            l10n.recordSymptomRecordCount(
                              selectedChoices.length,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (_otherInput)
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          variant: FButtonVariant.outline,
                          key: const Key('symptom-quick-other-back-action'),
                          onPress: () => setState(() => _otherInput = false),
                          child: Text(l10n.commonBack),
                        ),
                      ),
                      const SizedBox(width: Spacing.lg),
                      Expanded(
                        child: FButton(
                          key: const Key('symptom-quick-other-save-action'),
                          onPress: _otherController.text.trim().isEmpty
                              ? null
                              : _submitOther,
                          child: Text(l10n.mineEditSaveAction),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FButton(
                        variant: FButtonVariant.ghost,
                        key: const Key('symptom-quick-multi-select-action'),
                        onPress: () => setState(() => _multiSelect = true),
                        child: Text(l10n.recordFastEntryMultiSelectAction),
                      ),
                      const SizedBox(width: Spacing.md),
                      FButton(
                        variant: FButtonVariant.ghost,
                        key: const Key('symptom-quick-more-action'),
                        onPress: _openMore,
                        child: Text(l10n.recordFastEntryMoreAction),
                      ),
                      const SizedBox(width: Spacing.md),
                      FButton(
                        variant: FButtonVariant.ghost,
                        key: const Key('symptom-quick-cancel-action'),
                        onPress: () => Navigator.of(context).pop(),
                        child: Text(l10n.commonCancel),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
