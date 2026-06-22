import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart'
    show
        DailyRecordAttachmentInput,
        DailyRecordImageUploadInput,
        DailyRecordUpdateInput,
        dailyRecordNoChange;
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/utils/record_date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_image_attachment_field.dart';
import 'package:luminous/features/record/presentation/widgets/record_occurred_at_fields.dart';
import 'package:luminous/features/record/presentation/widgets/sleep_structured_fields.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordEditPage extends ConsumerStatefulWidget {
  const RecordEditPage({super.key, required this.recordId});

  final String recordId;

  @override
  ConsumerState<RecordEditPage> createState() => _RecordEditPageState();
}

class _RecordEditPageState extends ConsumerState<RecordEditPage> {
  DailyRecordKind _kind = DailyRecordKind.water;
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _saving = false;
  bool _deleting = false;
  bool _loaded = false;
  bool _loadingRecord = false;
  DailyRecordAttachment? _existingImageAttachment;
  Map<String, dynamic>? _existingSleepPayload;
  _PendingDailyRecordImage? _selectedImage;
  bool _attachmentsChanged = false;
  DateTime? _recordOccurredAt;
  String? _recordOccurredTime;

  TimeOfDay? _sleepBedtime;
  TimeOfDay? _sleepWakeTime;
  String? _sleepQuality;
  int? _sleepDeepMinutes;
  int? _sleepLightMinutes;
  int? _sleepRemMinutes;

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadRecord() async {
    if (_loaded || _loadingRecord) {
      return;
    }
    setState(() => _loadingRecord = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      final record = await repo.get(widget.recordId);
      if (!mounted) return;
      setState(() {
        _kind = record.kind;
        _valueController.text = record.value ?? '';
        _unitController.text =
            record.unit ?? _defaultUnitTextForKind(record.kind);
        _noteController.text = record.note ?? '';
        _titleController.text = record.title ?? '';
        _existingImageAttachment = record.attachments
            .where(
              (attachment) =>
                  attachment.kind == DailyRecordAttachmentKind.image,
            )
            .firstOrNull;
        _existingSleepPayload = record.payload == null
            ? null
            : Map<String, dynamic>.from(record.payload!);
        _selectedImage = null;
        _attachmentsChanged = false;
        _loadSleepPayload(record.payload);
        _recordOccurredAt = parseRecordDate(record.occurredAt);
        _recordOccurredTime = record.occurredTime?.trim();
        _loaded = true;
        _loadingRecord = false;
      });
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          AppLocalizations.of(context)!.recordCreateFailedToast,
        );
        context.pop();
      }
    } finally {
      if (mounted && !_loaded) {
        setState(() => _loadingRecord = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    if (session.canAccessProtectedData && !_loaded && !_loadingRecord) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadRecord();
        }
      });
    }

    if (!session.canAccessProtectedData) {
      return PageScaffoldShell(
        title: l10n.recordEditAction,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          session.isLoading
              ? const _RecordEditLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    if (!_loaded) {
      return PageScaffoldShell(
        title: l10n.recordEditAction,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: const [_RecordEditLoading()],
      );
    }

    return PageScaffoldShell(
      title: l10n.recordEditAction,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RecordOccurredAtFields(
                date: _recordOccurredAt ?? DateTime.now(),
                time: _recordOccurredTime,
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
              const SizedBox(height: 12),
              DailyRecordImageAttachmentField(
                l10n: l10n,
                selectedBytes: _selectedImage?.bytes,
                selectedFileName: _selectedImage?.fileName,
                existingAttachment: _attachmentsChanged
                    ? null
                    : _existingImageAttachment,
                onPick: _onPickImage,
                onRemove: _onRemoveImage,
                enabled: !_saving && !_deleting,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('record-edit-save-action'),
                onPressed: _saving ? null : _onSave,
                child: Text(l10n.mineEditSaveAction),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('record-edit-delete-action'),
                onPressed: _deleting || _saving ? null : _onDelete,
                icon: _deleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(l10n.recordDeleteAction),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onSave() async {
    if (_kind == DailyRecordKind.sleep && !_isValidSleepValue()) {
      AppToast.show(
        context,
        AppLocalizations.of(context)!.recordSleepInvalidValueToast,
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      final attachmentPatch = await _buildAttachmentPatch();
      final rules = dailyRecordFormRules(_kind);
      await repo.update(
        widget.recordId,
        DailyRecordUpdateInput(
          kind: _kind,
          occurredAt: formatRecordDate(_recordOccurredAt ?? DateTime.now()),
          occurredTime: _recordOccurredTime,
          title: rules.showTitle ? _optionalText(_titleController) : null,
          value: rules.showValue ? _normalizedValueForKind(_kind) : null,
          unit: rules.showUnit ? _unitTextForKind(_kind) : null,
          note: _optionalText(_noteController),
          payload: _buildSleepPayload(_kind),
          attachments: attachmentPatch,
        ),
      );
      _invalidateProviders();
      if (mounted) {
        await AppToast.show(
          context,
          AppLocalizations.of(context)!.mineEditSavedToast,
        );
        if (!mounted) return;
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        await AppToast.show(
          context,
          AppLocalizations.of(context)!.recordCreateFailedToast,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.authIdentityUnlinkConfirmTitle),
        content: Text(l10n.recordDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.authCancelAction),
          ),
          FilledButton(
            key: const Key('record-delete-confirm-action'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.recordDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      await repo.delete(widget.recordId);
      _invalidateProviders();
      if (mounted) {
        await AppToast.show(context, l10n.mineEditSavedToast);
        if (!mounted) return;
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        await AppToast.show(context, l10n.recordCreateFailedToast);
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _invalidateProviders() {
    ref.invalidate(dailyRecordDetailProvider(widget.recordId));
    ref.invalidate(recordDashboardProvider);
    ref.invalidate(todayDashboardProvider);
    ref.invalidate(reportDashboardProvider);
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
      if (kind == DailyRecordKind.water &&
          _unitController.text.trim().isEmpty) {
        _unitController.text = dailyRecordWaterDefaultUnit;
      }
      if (kind != DailyRecordKind.sleep) {
        _sleepBedtime = null;
        _sleepWakeTime = null;
        _sleepQuality = null;
        _sleepDeepMinutes = null;
        _sleepLightMinutes = null;
        _sleepRemMinutes = null;
      }
    });
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _normalizedValueForKind(DailyRecordKind kind) {
    if (kind == DailyRecordKind.sleep) return null;
    return _optionalText(_valueController);
  }

  String _defaultUnitTextForKind(DailyRecordKind kind) {
    if (kind == DailyRecordKind.water) return dailyRecordWaterDefaultUnit;
    return '';
  }

  String? _unitTextForKind(DailyRecordKind kind) {
    final value = _unitController.text.trim();
    if (value.isNotEmpty) return value;
    if (kind == DailyRecordKind.water) return dailyRecordWaterDefaultUnit;
    return null;
  }

  Map<String, dynamic>? _buildSleepPayload(DailyRecordKind kind) {
    if (kind != DailyRecordKind.sleep) return null;
    final minutes = _resolvedSleepDurationMinutes();
    if (minutes == null || minutes <= 0) return null;
    final payload = <String, dynamic>{'durationMinutes': minutes};
    if (_sleepBedtime != null && _sleepWakeTime != null) {
      // Sleep date convention: occurredAt is the wake date.
      // endAt falls on the wake date; startAt is the evening before
      // (or the same day for short naps that don't cross midnight).
      final occurredAt = _recordOccurredAt ?? DateTime.now();
      final wake = DateTime(
        occurredAt.year,
        occurredAt.month,
        occurredAt.day,
        _sleepWakeTime!.hour,
        _sleepWakeTime!.minute,
      );
      var bed = DateTime(
        occurredAt.year,
        occurredAt.month,
        occurredAt.day,
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
    final minutes = _resolvedSleepDurationMinutes();
    return minutes != null && minutes > 0;
  }

  int? _resolvedSleepDurationMinutes() {
    final computed = computeSleepDurationMinutes(_sleepBedtime, _sleepWakeTime);
    if (computed != null && computed > 0) {
      return computed;
    }

    final existing = _existingSleepPayload?['durationMinutes'];
    if (existing is num && existing > 0) {
      return existing.round();
    }

    return null;
  }

  Future<void> _pickRecordDate() async {
    final initialDate = _recordOccurredAt ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _recordOccurredAt = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _pickRecordTime() async {
    final parsed = parseRecordTime(_recordOccurredTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: parsed?.hour ?? DateTime.now().hour,
        minute: parsed?.minute ?? DateTime.now().minute,
      ),
    );
    if (picked == null) return;
    setState(() {
      _recordOccurredTime = formatRecordTimeValue(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    });
  }

  void _loadSleepPayload(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final startAt = payload['startAt'] as String?;
    if (startAt != null) {
      final dt = DateTime.tryParse(startAt);
      if (dt != null) {
        final local = dt.toLocal();
        _sleepBedtime = TimeOfDay(hour: local.hour, minute: local.minute);
      }
    }
    final endAt = payload['endAt'] as String?;
    if (endAt != null) {
      final dt = DateTime.tryParse(endAt);
      if (dt != null) {
        final local = dt.toLocal();
        _sleepWakeTime = TimeOfDay(hour: local.hour, minute: local.minute);
      }
    }
    _sleepQuality = payload['quality'] as String?;
    final deep = payload['deepMinutes'];
    if (deep is num && deep > 0) _sleepDeepMinutes = deep.round();
    final light = payload['lightMinutes'];
    if (light is num && light > 0) _sleepLightMinutes = light.round();
    final rem = payload['remMinutes'];
    if (rem is num && rem > 0) _sleepRemMinutes = rem.round();
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
          await AppToast.show(context, l10nSafe.recordImageUnsupportedToast);
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
        _attachmentsChanged = true;
      });
    } catch (_) {
      if (mounted) {
        await AppToast.show(context, l10nSafe.recordImagePickFailedToast);
      }
    }
  }

  void _onRemoveImage() {
    setState(() {
      _selectedImage = null;
      _attachmentsChanged = true;
    });
  }

  Future<Object> _buildAttachmentPatch() async {
    if (!_attachmentsChanged) return dailyRecordNoChange;

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

  AppLocalizations get l10nSafe => AppLocalizations.of(context)!;

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

class _RecordEditLoading extends StatelessWidget {
  const _RecordEditLoading();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 96),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 44),
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
