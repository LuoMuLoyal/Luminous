import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal_flow.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MealQuickConfirmationDialog extends StatefulWidget {
  const MealQuickConfirmationDialog({
    super.key,
    required this.flow,
    required this.draft,
  });

  final MealQuickEntryFlow flow;
  final MealQuickEntryDraft draft;

  @override
  State<MealQuickConfirmationDialog> createState() =>
      _MealQuickConfirmationDialogState();
}

class _MealQuickConfirmationDialogState
    extends State<MealQuickConfirmationDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _valueController;
  late final TextEditingController _noteController;
  bool _saving = false;

  /// 上一次重建时确认按钮是否可点。
  ///
  /// 三个输入框都接了下面的监听:只要内容变化就得判断按钮要不要跟着变。但"有内容"
  /// 这个布尔量只在空↔非空时翻转——拼音输入法选词期间每个字符都会通知一次,逐次
  /// 重建整棵对话框(含按钮、图片、底部栏)是纯浪费。这里只在翻转时重建。
  late bool _canSaveAtLastBuild;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title ?? '');
    _valueController = TextEditingController(text: widget.draft.value ?? '');
    _noteController = TextEditingController(text: widget.draft.note ?? '');
    _canSaveAtLastBuild = _canSave;
    _titleController.addListener(_onFieldChanged);
    _valueController.addListener(_onFieldChanged);
    _noteController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _valueController.removeListener(_onFieldChanged);
    _noteController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!mounted) return;
    // 只有按钮可点状态真的变了才重建;其余输入变化不影响任何显示。
    if (_canSave == _canSaveAtLastBuild) return;
    setState(() {
      _canSaveAtLastBuild = _canSave;
    });
  }

  /// An empty meal record carries no information: the photo is the only
  /// content when both the quick fields and every text field are blank.
  bool get _hasContent =>
      widget.draft.image != null ||
      _titleController.text.trim().isNotEmpty ||
      _valueController.text.trim().isNotEmpty ||
      _noteController.text.trim().isNotEmpty;

  bool get _canSave => !_saving && _hasContent;

  /// 切换 `_saving` 并同步 [‏_canSaveAtLastBuild]。
  ///
  /// `_saving` 也是 `_canSave` 的输入之一。`setState` 本身已经重建了这一帧,
  /// 但缓存值必须跟着走:否则下一次输入变化比较的是过期值,「可点状态翻转」会被
  /// 漏判,按钮就停在错误状态。写 `_saving` 的每一处都走这里。
  void _setSaving(bool saving) {
    setState(() {
      _saving = saving;
      _canSaveAtLastBuild = _canSave;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final image = widget.draft.image;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.recordQuickMealConfirmTitle,
          style: context.theme.typography.body.lg,
        ),
        if (image != null) ...[
          const SizedBox(height: Spacing.lg),
          ClipRRect(
            borderRadius: context.theme.style.borderRadius.sm,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.memory(image.bytes, fit: BoxFit.cover),
            ),
          ),
        ],
        const SizedBox(height: Spacing.lg),
        FTextField(
          key: const Key('record-quick-meal-title-field'),
          control: FTextFieldControl.managed(controller: _titleController),
          label: Text(l10n.recordCreateFieldTitle),
          enabled: !_saving,
        ),
        const SizedBox(height: Spacing.md),
        FTextField(
          key: const Key('record-quick-meal-value-field'),
          control: FTextFieldControl.managed(controller: _valueController),
          label: Text(l10n.recordCreateValueMeal),
          enabled: !_saving,
        ),
        const SizedBox(height: Spacing.md),
        FTextField(
          key: const Key('record-quick-meal-note-field'),
          control: FTextFieldControl.managed(controller: _noteController),
          label: Text(l10n.recordCreateFieldNote),
          maxLines: 2,
          enabled: !_saving,
        ),
        if (_saving) ...[
          const SizedBox(height: Spacing.lg),
          const Center(child: FProgress()),
        ],
        const SizedBox(height: Spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: _saving ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            const SizedBox(width: Spacing.md),
            FButton(
              key: const Key('record-quick-meal-confirm-action'),
              onPress: _canSave ? _save : null,
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    // 空输入不允许提交（按钮此时已置灰，这里再挡一次）。
    if (!_canSave) return;
    _setSaving(true);
    try {
      await widget.flow.saveDraft(
        widget.draft.copyWith(
          title: _titleController.text,
          value: _valueController.text,
          note: _noteController.text,
        ),
      );
    } on MealQuickEntryEmptyException {
      // 领域侧的第二道闸：理论上与上面的按钮置灰同构，兜住任何绕过 UI 的调用。
      if (!mounted) return;
      _setSaving(false);
      unawaited(Toast.show(context, l10n.recordQuickMealEmptyToast));
      return;
    } catch (e, st) {
      appTalker.error('MealQuickConfirmation: saveDraft failed: $e', st);
      if (!mounted) return;
      _setSaving(false);
      unawaited(Toast.show(context, l10n.recordCreateFailedToast));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(Toast.show(context, l10n.recordCreateSavedToast));
  }
}
