import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Receives the values confirmed by [StartEventSheet].
///
/// The optional associations are supplied by the parent because their
/// selectors belong to the surrounding Today context, not this form.
typedef StartEventSubmitCallback =
    Future<void> Function({
      required String shortTitle,
      String? reasonRecordId,
      required List<String> currentMedicineIds,
    });

class HealthEventAssociationOption {
  const HealthEventAssociationOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// Bottom-sheet content for starting a health event.
///
/// This widget owns only the short-title input and submission state. The
/// parent owns association selection, repository calls, refreshes, and sheet
/// dismissal after a successful submission.
class StartEventSheet extends StatefulWidget {
  const StartEventSheet({
    super.key,
    required this.heading,
    required this.shortTitleLabel,
    required this.cancelLabel,
    required this.submitLabel,
    required this.submittingLabel,
    required this.requiredMessage,
    required this.submitErrorLabel,
    required this.onSubmit,
    this.hint,
    this.reasonRecordId,
    this.currentMedicineIds = const [],
    this.reasonRecordOptions = const [],
    this.currentMedicineOptions = const [],
    this.reasonRecordLabel,
    this.currentMedicineLabel,
    this.currentMedicineOptionsLoadFailed = false,
    this.reasonRecordOptionsLoadFailed = false,
    this.onRetryLoadOptions,
  });

  final String heading;
  final String shortTitleLabel;
  final String cancelLabel;
  final String submitLabel;
  final String submittingLabel;
  final String requiredMessage;
  final String submitErrorLabel;
  final StartEventSubmitCallback onSubmit;
  final String? hint;

  /// Optional parent-selected record associated with the event.
  final String? reasonRecordId;

  /// Optional parent-selected current medicines associated with the event.
  final List<String> currentMedicineIds;

  /// Optional records that the user can associate as the event trigger.
  final List<HealthEventAssociationOption> reasonRecordOptions;

  /// Optional current medicines that the user can associate with the event.
  final List<HealthEventAssociationOption> currentMedicineOptions;

  final String? reasonRecordLabel;
  final String? currentMedicineLabel;

  /// Whether loading [currentMedicineOptions] failed and a retry should be
  /// offered.
  final bool currentMedicineOptionsLoadFailed;

  /// Whether loading [reasonRecordOptions] failed and a retry should be
  /// offered.
  final bool reasonRecordOptionsLoadFailed;

  /// Called when the user taps the retry button in either options section.
  final VoidCallback? onRetryLoadOptions;

  @override
  State<StartEventSheet> createState() => _StartEventSheetState();
}

class _StartEventSheetState extends State<StartEventSheet> {
  late final TextEditingController _titleController;
  bool _isSubmitting = false;
  String? _validationError;
  String? _submitError;
  late final Set<String> _selectedMedicineIds;
  String? _selectedReasonRecordId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _selectedMedicineIds = {...widget.currentMedicineIds};
    _selectedReasonRecordId = widget.reasonRecordId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.heading,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: Spacing.level4),
            FTextField(
              key: const Key('health-event-start-title-field'),
              control: FTextFieldControl.managed(
                controller: _titleController,
                onChange: (_) {
                  if (_validationError == null && _submitError == null) {
                    return;
                  }
                  setState(() {
                    _validationError = null;
                    _submitError = null;
                  });
                },
              ),
              label: Text(widget.shortTitleLabel),
              hint: widget.hint,
              enabled: !_isSubmitting,
            ),
            if (widget.currentMedicineOptions.isNotEmpty ||
                widget.currentMedicineOptionsLoadFailed) ...[
              const SizedBox(height: Spacing.level4),
              _AssociationOptions(
                label: widget.currentMedicineLabel ?? '',
                options: widget.currentMedicineOptions,
                selectedIds: _selectedMedicineIds,
                loadFailed: widget.currentMedicineOptionsLoadFailed,
                onRetry: widget.onRetryLoadOptions,
                retryKey: const Key(
                  'health-event-options-retry-current-medicine',
                ),
                onToggle: (id) => setState(() {
                  if (!_selectedMedicineIds.add(id)) {
                    _selectedMedicineIds.remove(id);
                  }
                }),
              ),
            ],
            if (widget.reasonRecordOptions.isNotEmpty ||
                widget.reasonRecordOptionsLoadFailed) ...[
              const SizedBox(height: Spacing.level4),
              _AssociationOptions(
                label: widget.reasonRecordLabel ?? '',
                options: widget.reasonRecordOptions,
                selectedIds: {
                  if (_selectedReasonRecordId != null) _selectedReasonRecordId!,
                },
                loadFailed: widget.reasonRecordOptionsLoadFailed,
                onRetry: widget.onRetryLoadOptions,
                retryKey: const Key('health-event-options-retry-reason-record'),
                onToggle: (id) => setState(() {
                  _selectedReasonRecordId = _selectedReasonRecordId == id
                      ? null
                      : id;
                }),
              ),
            ],
            if (_validationError != null) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                _validationError!,
                key: const Key('health-event-start-validation-error'),
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.destructive),
              ),
            ],
            if (_submitError != null) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                _submitError!,
                key: const Key('health-event-start-submit-error'),
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.destructive),
              ),
            ],
            const SizedBox(height: Spacing.level5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  key: const Key('health-event-start-cancel'),
                  variant: FButtonVariant.ghost,
                  onPress: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(widget.cancelLabel),
                ),
                const SizedBox(width: Spacing.level3),
                FButton(
                  key: const Key('health-event-start-submit'),
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

  Future<void> _submit() async {
    final shortTitle = _titleController.text.trim();
    if (shortTitle.isEmpty) {
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

    try {
      await widget.onSubmit(
        shortTitle: shortTitle,
        reasonRecordId: _selectedReasonRecordId,
        currentMedicineIds: List<String>.unmodifiable(_selectedMedicineIds),
      );
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

class _AssociationOptions extends StatelessWidget {
  const _AssociationOptions({
    required this.label,
    required this.options,
    required this.selectedIds,
    required this.onToggle,
    this.loadFailed = false,
    this.onRetry,
    this.retryKey,
  });

  final String label;
  final List<HealthEventAssociationOption> options;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final bool loadFailed;
  final VoidCallback? onRetry;
  final Key? retryKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TypographyToken.level3.body(context)),
        if (loadFailed) ...[
          const SizedBox(height: Spacing.level2),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.todayHealthEventOptionsLoadFailed,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.destructive),
                ),
              ),
              FButton(
                key: retryKey,
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.xs,
                onPress: onRetry,
                child: Text(l10n.todayHealthEventOptionsRetryAction),
              ),
            ],
          ),
        ],
        if (options.isNotEmpty) ...[
          const SizedBox(height: Spacing.level2),
          Wrap(
            spacing: Spacing.level2,
            runSpacing: Spacing.level2,
            children: [
              for (final option in options)
                FButton(
                  key: Key('health-event-association-${option.id}'),
                  variant: selectedIds.contains(option.id)
                      ? FButtonVariant.primary
                      : FButtonVariant.outline,
                  onPress: () => onToggle(option.id),
                  child: Text(option.label),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
