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
import 'package:luminous/features/record/presentation/widgets/sleep_structured_fields.dart';
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
  TimeOfDay? _sleepBedtime;
  TimeOfDay? _sleepWakeTime;
  String? _sleepQuality;
  int? _sleepDeepMinutes;
  int? _sleepLightMinutes;
  int? _sleepRemMinutes;

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
            if (widget.kind == DailyRecordKind.sleep) ...[
              const SizedBox(height: AppSpacingTokens.sm),
              SleepStructuredFields(
                l10n: l10n,
                bedtime: _sleepBedtime,
                wakeTime: _sleepWakeTime,
                quality: _sleepQuality,
                deepMinutes: _sleepDeepMinutes,
                lightMinutes: _sleepLightMinutes,
                remMinutes: _sleepRemMinutes,
                onBedtimeChanged: (v) => setState(() => _sleepBedtime = v),
                onWakeTimeChanged: (v) => setState(() => _sleepWakeTime = v),
                onQualityChanged: (v) => setState(() => _sleepQuality = v),
                onDeepMinutesChanged: (v) =>
                    setState(() => _sleepDeepMinutes = v),
                onLightMinutesChanged: (v) =>
                    setState(() => _sleepLightMinutes = v),
                onRemMinutesChanged: (v) =>
                    setState(() => _sleepRemMinutes = v),
              ),
            ],
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
    if (widget.kind == DailyRecordKind.sleep && !_isValidSleepValue()) {
      AppToast.show(
        context,
        AppLocalizations.of(context)!.recordSleepInvalidValueToast,
      );
      return;
    }

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
          payload: _buildSleepPayload(),
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

  Map<String, dynamic>? _buildSleepPayload() {
    if (widget.kind != DailyRecordKind.sleep) return null;
    final minutes = computeSleepDurationMinutes(_sleepBedtime, _sleepWakeTime);
    if (minutes == null || minutes <= 0) return null;

    final payload = <String, dynamic>{'durationMinutes': minutes};
    final recordDate = DateTime.parse(widget.occurredAt);

    if (_sleepBedtime != null && _sleepWakeTime != null) {
      final wake = DateTime(
        recordDate.year,
        recordDate.month,
        recordDate.day,
        _sleepWakeTime!.hour,
        _sleepWakeTime!.minute,
      );
      var bed = DateTime(
        recordDate.year,
        recordDate.month,
        recordDate.day,
        _sleepBedtime!.hour,
        _sleepBedtime!.minute,
      );
      if (!bed.isBefore(wake)) {
        bed = bed.subtract(const Duration(days: 1));
      }
      payload['startAt'] = bed.toUtc().toIso8601String();
      payload['endAt'] = wake.toUtc().toIso8601String();
    }
    if (_sleepQuality != null) payload['quality'] = _sleepQuality;
    if (_sleepDeepMinutes != null && _sleepDeepMinutes! > 0) {
      payload['deepMinutes'] = _sleepDeepMinutes;
    }
    if (_sleepLightMinutes != null && _sleepLightMinutes! > 0) {
      payload['lightMinutes'] = _sleepLightMinutes;
    }
    if (_sleepRemMinutes != null && _sleepRemMinutes! > 0) {
      payload['remMinutes'] = _sleepRemMinutes;
    }
    return payload;
  }

  bool _isValidSleepValue() {
    if (widget.kind != DailyRecordKind.sleep) return true;
    final minutes = computeSleepDurationMinutes(_sleepBedtime, _sleepWakeTime);
    return minutes != null && minutes > 0;
  }
}
