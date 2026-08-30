import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';

/// Bottom-sheet content for the once-per-day health event check-in.
class CheckInSheet extends StatefulWidget {
  const CheckInSheet({
    super.key,
    required this.heading,
    required this.improvedLabel,
    required this.unchangedLabel,
    required this.worsenedLabel,
    required this.cancelLabel,
    required this.submitLabel,
    required this.submittingLabel,
    required this.requiredMessage,
    required this.submitErrorLabel,
    required this.onSubmit,
    this.subtitle,
  });

  final String heading;
  final String improvedLabel;
  final String unchangedLabel;
  final String worsenedLabel;
  final String cancelLabel;
  final String submitLabel;
  final String submittingLabel;
  final String requiredMessage;
  final String submitErrorLabel;
  final Future<void> Function(HealthEventOutcome outcome) onSubmit;
  final String? subtitle;

  @override
  State<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<CheckInSheet> {
  HealthEventOutcome? _selectedOutcome;
  bool _isSubmitting = false;
  String? _validationError;
  String? _submitError;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.heading,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                widget.subtitle!,
                style: context.theme.typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            const SizedBox(height: Spacing.level4),
            Row(
              children: [
                Expanded(
                  child: _OutcomeButton(
                    key: const Key('health-event-check-in-outcome-improved'),
                    label: widget.improvedLabel,
                    selected: _selectedOutcome == HealthEventOutcome.improved,
                    enabled: !_isSubmitting,
                    onPressed: () => _select(HealthEventOutcome.improved),
                  ),
                ),
                const SizedBox(width: Spacing.level2),
                Expanded(
                  child: _OutcomeButton(
                    key: const Key('health-event-check-in-outcome-unchanged'),
                    label: widget.unchangedLabel,
                    selected: _selectedOutcome == HealthEventOutcome.unchanged,
                    enabled: !_isSubmitting,
                    onPressed: () => _select(HealthEventOutcome.unchanged),
                  ),
                ),
                const SizedBox(width: Spacing.level2),
                Expanded(
                  child: _OutcomeButton(
                    key: const Key('health-event-check-in-outcome-worsened'),
                    label: widget.worsenedLabel,
                    selected: _selectedOutcome == HealthEventOutcome.worsened,
                    enabled: !_isSubmitting,
                    onPressed: () => _select(HealthEventOutcome.worsened),
                  ),
                ),
              ],
            ),
            if (_validationError != null) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                _validationError!,
                key: const Key('health-event-check-in-validation-error'),
                style: context.theme.typography.body.xs.copyWith(
                  color: SemanticColor.destructive.solid(context),
                ),
              ),
            ],
            if (_submitError != null) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                _submitError!,
                key: const Key('health-event-check-in-submit-error'),
                style: context.theme.typography.body.xs.copyWith(
                  color: SemanticColor.destructive.solid(context),
                ),
              ),
            ],
            const SizedBox(height: Spacing.level5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  key: const Key('health-event-check-in-cancel'),
                  variant: FButtonVariant.ghost,
                  onPress: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(widget.cancelLabel),
                ),
                const SizedBox(width: Spacing.level3),
                FButton(
                  key: const Key('health-event-check-in-submit'),
                  onPress: _isSubmitting ? null : _submit,
                  child: Text(
                    _isSubmitting ? widget.submittingLabel : widget.submitLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _select(HealthEventOutcome outcome) {
    setState(() {
      _selectedOutcome = outcome;
      _validationError = null;
      _submitError = null;
    });
  }

  Future<void> _submit() async {
    final outcome = _selectedOutcome;
    if (outcome == null) {
      setState(() {
        _validationError = widget.requiredMessage;
        _submitError = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationError = null;
      _submitError = null;
    });

    // 提交失败投影：调用方 onSubmit（ActiveHealthEvent notifier）内部已完成
    // repository 的 run()+fold——Left 以 LucentFailure 抛出、协议异常
    // （FormatException 逃逸 .run()）同样在此被捕获，统一投影到既有
    // submitError state。widget 不导入 fpdart、不读 DioException、不解析
    // code/status。
    try {
      await widget.onSubmit(outcome);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = widget.submitErrorLabel;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }
}

class _OutcomeButton extends StatelessWidget {
  const _OutcomeButton({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: FButton(
        variant: selected ? FButtonVariant.primary : FButtonVariant.outline,
        onPress: enabled ? onPressed : null,
        child: Text(label),
      ),
    );
  }
}
