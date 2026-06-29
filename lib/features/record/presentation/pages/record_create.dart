import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/utils/record_date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/forms/daily_record_form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/daily_record_image_attachment_field.dart';
import 'package:luminous/features/record/presentation/widgets/forms/record_occurred_at_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordCreatePage extends ConsumerStatefulWidget {
  const RecordCreatePage({
    super.key,
    this.initialKind,
    this.initialDate,
    this.initialTime,
  });

  final DailyRecordKind? initialKind;
  final DateTime? initialDate;
  final String? initialTime;

  @override
  ConsumerState<RecordCreatePage> createState() => _RecordCreatePageState();
}

class _RecordCreatePageState extends ConsumerState<RecordCreatePage> {
  late DailyRecordKind _kind;
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _saving = false;
  _PendingDailyRecordImage? _selectedImage;
  late DateTime _recordDate;
  String? _recordTime;

  TimeOfDay? _sleepBedtime;
  TimeOfDay? _sleepWakeTime;
  String? _sleepQuality;
  int? _sleepDeepMinutes;
  int? _sleepLightMinutes;
  int? _sleepRemMinutes;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind ?? DailyRecordKind.water;
    final seedDate = widget.initialDate ?? DateTime.now();
    _recordDate = DateTime(seedDate.year, seedDate.month, seedDate.day);
    _recordTime = widget.initialTime?.trim();
    _applyKindDefaults(_kind);
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
    final session = ref.watch(authSessionProvider);

    if (!session.canAccessProtectedData) {
      return PageScaffoldShell(
        title: l10n.recordAddAction,
        centerTitle: true,
        leading: const AppBackButton(),
        children: [
          session.isLoading
              ? const _RecordFormLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    final dateStr = formatRecordDate(_recordDate);

    return PageScaffoldShell(
      title: l10n.recordAddAction,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RecordOccurredAtFields(
                date: _recordDate,
                time: _recordTime,
                onDateTap: _pickRecordDate,
                onTimeTap: _pickRecordTime,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              DailyRecordFormFields(
                kind: _kind,
                onKindChanged: _onKindChanged,
                valueController: _valueController,
                unitController: _unitController,
                titleController: _titleController,
                noteController: _noteController,
              ),
              if (_kind == DailyRecordKind.sleep) ...[
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
              const SizedBox(height: AppSpacingTokens.sm),
              DailyRecordImageAttachmentField(
                l10n: l10n,
                selectedBytes: _selectedImage?.bytes,
                selectedFileName: _selectedImage?.fileName,
                existingAttachment: null,
                onPick: _onPickImage,
                onRemove: _onRemoveImage,
                enabled: !_saving,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              ElevatedButton(
                key: const Key('record-create-save-action'),
                onPressed: _saving ? null : () => _onSave(dateStr),
                child: Text(l10n.mineEditSaveAction),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onSave(String dateStr) async {
    if (_kind == DailyRecordKind.sleep && !_isValidSleepValue()) {
      unawaited(
        AppToast.show(
          context,
          AppLocalizations.of(context)!.recordSleepInvalidValueToast,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      final attachments = await _uploadSelectedImage();
      final rules = dailyRecordFormRules(_kind);
      await repo.create(
        DailyRecordCreateInput(
          kind: _kind,
          occurredAt: dateStr,
          occurredTime: _recordTime,
          title: rules.showTitle ? _optionalText(_titleController) : null,
          value: rules.showValue ? _normalizedValueForKind(_kind) : null,
          unit: rules.showUnit ? _unitTextForKind(_kind) : null,
          note: _optionalText(_noteController),
          payload: _buildSleepPayload(_kind),
          attachments: attachments,
        ),
      );
      ref.invalidate(recordDashboardProvider);
      ref.invalidate(todayDashboardProvider);
      ref.invalidate(reportDashboardProvider);
      if (mounted) {
        unawaited(
          AppToast.show(
            context,
            AppLocalizations.of(context)!.mineEditSavedToast,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        unawaited(
          AppToast.show(
            context,
            AppLocalizations.of(context)!.recordCreateFailedToast,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onKindChanged(DailyRecordKind kind) {
    setState(() {
      final wasWater = _kind == DailyRecordKind.water;
      _kind = kind;
      if (kind != DailyRecordKind.water &&
          wasWater &&
          _unitController.text.trim() == dailyRecordWaterDefaultUnit) {
        _unitController.clear();
      }
      if (kind != DailyRecordKind.sleep) {
        _sleepBedtime = null;
        _sleepWakeTime = null;
        _sleepQuality = null;
        _sleepDeepMinutes = null;
        _sleepLightMinutes = null;
        _sleepRemMinutes = null;
      }
      _applyKindDefaults(kind);
    });
  }

  void _applyKindDefaults(DailyRecordKind kind) {
    if (kind == DailyRecordKind.water && _unitController.text.trim().isEmpty) {
      _unitController.text = dailyRecordWaterDefaultUnit;
    }
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _normalizedValueForKind(DailyRecordKind kind) {
    if (kind == DailyRecordKind.sleep) return null;
    return _optionalText(_valueController);
  }

  String? _unitTextForKind(DailyRecordKind kind) {
    final value = _unitController.text.trim();
    if (value.isNotEmpty) return value;
    if (kind == DailyRecordKind.water) return dailyRecordWaterDefaultUnit;
    return null;
  }

  Map<String, dynamic>? _buildSleepPayload(DailyRecordKind kind) {
    if (kind != DailyRecordKind.sleep) return null;
    final minutes = computeSleepDurationMinutes(_sleepBedtime, _sleepWakeTime);
    if (minutes == null || minutes <= 0) return null;
    final payload = <String, dynamic>{'durationMinutes': minutes};
    if (_sleepBedtime != null && _sleepWakeTime != null) {
      // Sleep date convention: occurredAt is the wake date.
      // endAt falls on the wake date; startAt is the evening before
      // (or the same day for short naps that don't cross midnight).
      final recordDate = _recordDate;
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
      if (!bed.isBefore(wake)) bed = bed.subtract(const Duration(days: 1));
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
    if (_kind != DailyRecordKind.sleep) return true;
    final minutes = computeSleepDurationMinutes(_sleepBedtime, _sleepWakeTime);
    return minutes != null && minutes > 0;
  }

  Future<void> _pickRecordDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _recordDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _pickRecordTime() async {
    final parsed = parseRecordTime(_recordTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: parsed?.hour ?? DateTime.now().hour,
        minute: parsed?.minute ?? DateTime.now().minute,
      ),
    );
    if (picked == null) return;
    setState(() {
      _recordTime = formatRecordTimeValue(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    });
  }

  Future<void> _onPickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      if (image == null) return;

      final contentType = _resolveImageContentType(image);
      if (contentType == null) {
        if (mounted) {
          await AppToast.show(
            context,
            AppLocalizations.of(context)!.recordImageUnsupportedToast,
          );
        }
        return;
      }

      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImage = _PendingDailyRecordImage(
          bytes: bytes,
          fileName: image.name,
          contentType: contentType,
        );
      });
    } catch (_) {
      if (mounted) {
        await AppToast.show(
          context,
          AppLocalizations.of(context)!.recordImagePickFailedToast,
        );
      }
    }
  }

  void _onRemoveImage() {
    setState(() => _selectedImage = null);
  }

  Future<List<DailyRecordAttachmentInput>> _uploadSelectedImage() async {
    final image = _selectedImage;
    if (image == null) return const <DailyRecordAttachmentInput>[];

    final repo = ref.read(dailyRecordRepositoryProvider);
    final attachment = await repo.uploadImage(
      DailyRecordImageUploadInput(
        bytes: image.bytes,
        contentType: image.contentType,
        sizeBytes: image.bytes.length,
        fileName: image.fileName,
      ),
    );
    return <DailyRecordAttachmentInput>[attachment];
  }

  String? _resolveImageContentType(XFile image) {
    final mimeType = image.mimeType?.trim().toLowerCase();
    if (_allowedImageContentTypes.contains(mimeType)) return mimeType;

    final name = image.name.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';
    return null;
  }
}

class _RecordFormLoading extends StatelessWidget {
  const _RecordFormLoading();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 96),
        AppInlineSkeletonBlock(height: 56),
      ],
    );
  }
}

const _allowedImageContentTypes = <String>{
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
};

class _PendingDailyRecordImage {
  const _PendingDailyRecordImage({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
}
