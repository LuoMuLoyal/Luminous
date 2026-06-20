import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_form_fields.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordFastEntrySheet extends ConsumerStatefulWidget {
  const RecordFastEntrySheet({
    super.key,
    required this.kind,
    required this.occurredAt,
    required this.moreRoute,
  });

  final DailyRecordKind kind;
  final String occurredAt;
  final String moreRoute;

  @override
  ConsumerState<RecordFastEntrySheet> createState() =>
      _RecordFastEntrySheetState();
}

class _RecordFastEntrySheetState extends ConsumerState<RecordFastEntrySheet> {
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.kind == DailyRecordKind.water) {
      _unitController.text = dailyRecordWaterDefaultUnit;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = dailyRecordKindLabel(l10n, widget.kind);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacingTokens.md,
          right: AppSpacingTokens.md,
          top: AppSpacingTokens.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom +
              AppSpacingTokens.md,
        ),
        child: Column(
          key: Key('record-fast-entry-${widget.kind.name}'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.recordFastEntryTitle(typeLabel),
              key: const Key('record-fast-entry-title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              l10n.recordFastEntryDateHint(widget.occurredAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            DailyRecordFormFields(
              kind: widget.kind,
              onKindChanged: (_) {},
              valueController: _valueController,
              unitController: _unitController,
              titleController: _titleController,
              noteController: _noteController,
              showKindField: false,
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('record-fast-entry-more-action'),
                    onPressed: _saving ? null : _openMore,
                    child: Text(l10n.recordFastEntryMoreAction),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: FilledButton(
                    key: const Key('record-fast-entry-save-action'),
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.mineEditSaveAction),
                  ),
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
    context.push(widget.moreRoute);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      final rules = dailyRecordFormRules(widget.kind);
      await repo.create(
        DailyRecordCreateInput(
          kind: widget.kind,
          occurredAt: widget.occurredAt,
          title: rules.showTitle ? _optionalText(_titleController) : null,
          value: rules.showValue ? _optionalText(_valueController) : null,
          unit: rules.showUnit ? _unitValue() : null,
          note: _optionalText(_noteController),
        ),
      );

      ref.invalidate(recordDashboardProvider);
      ref.invalidate(todayDashboardProvider);
      ref.invalidate(reportDashboardProvider);

      if (!mounted) return;
      AppToast.show(context, AppLocalizations.of(context)!.mineEditSavedToast);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        context,
        AppLocalizations.of(context)!.recordCreateFailedToast,
      );
      setState(() => _saving = false);
    }
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _unitValue() {
    final value = _unitController.text.trim();
    if (value.isNotEmpty) return value;
    if (widget.kind == DailyRecordKind.water) {
      return dailyRecordWaterDefaultUnit;
    }
    return null;
  }
}
