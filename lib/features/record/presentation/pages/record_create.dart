import 'dart:typed_data';

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
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_image_attachment_field.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordCreatePage extends ConsumerStatefulWidget {
  const RecordCreatePage({super.key, this.initialKind, this.initialDate});

  final DailyRecordKind? initialKind;
  final DateTime? initialDate;

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

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind ?? DailyRecordKind.water;
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
        leading: const SettingsBackButton(),
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

    final selectedRecordDate = ref.watch(selectedRecordDateProvider);
    final recordDate = widget.initialDate ?? selectedRecordDate;
    final dateStr = _formatDate(recordDate);

    return PageScaffoldShell(
      title: l10n.recordAddAction,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DailyRecordFormFields(
                kind: _kind,
                onKindChanged: _onKindChanged,
                valueController: _valueController,
                unitController: _unitController,
                titleController: _titleController,
                noteController: _noteController,
              ),
              const SizedBox(height: 12),
              DailyRecordImageAttachmentField(
                l10n: l10n,
                selectedBytes: _selectedImage?.bytes,
                selectedFileName: _selectedImage?.fileName,
                existingAttachment: null,
                onPick: _onPickImage,
                onRemove: _onRemoveImage,
                enabled: !_saving,
              ),
              const SizedBox(height: 24),
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
      AppToast.show(
        context,
        AppLocalizations.of(context)!.recordSleepInvalidValueToast,
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
          title: rules.showTitle ? _optionalText(_titleController) : null,
          value: rules.showValue ? _normalizedValueForKind(_kind) : null,
          unit: rules.showUnit ? _unitTextForKind(_kind) : null,
          note: _optionalText(_noteController),
          payload: _buildSleepPayload(_kind, _valueController.text),
          attachments: attachments,
        ),
      );
      ref.invalidate(recordDashboardProvider);
      ref.invalidate(todayDashboardProvider);
      ref.invalidate(reportDashboardProvider);
      if (mounted) {
        AppToast.show(
          context,
          AppLocalizations.of(context)!.mineEditSavedToast,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          AppLocalizations.of(context)!.recordCreateFailedToast,
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
    final raw = _optionalText(_valueController);
    if (raw == null) return null;
    if (kind != DailyRecordKind.sleep) return raw;
    final hours = _parseSleepHours(raw);
    return hours == null ? raw : hours.toString();
  }

  String? _unitTextForKind(DailyRecordKind kind) {
    final value = _unitController.text.trim();
    if (value.isNotEmpty) return value;
    if (kind == DailyRecordKind.water) return dailyRecordWaterDefaultUnit;
    if (kind == DailyRecordKind.sleep) return 'h';
    return null;
  }

  double? _parseSleepHours(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final cleaned = trimmed.endsWith('h') || trimmed.endsWith('H')
        ? trimmed.substring(0, trimmed.length - 1).trim()
        : trimmed;
    return double.tryParse(cleaned);
  }

  Map<String, dynamic>? _buildSleepPayload(
    DailyRecordKind kind,
    String rawValue,
  ) {
    if (kind != DailyRecordKind.sleep) return null;
    final hours = _parseSleepHours(rawValue);
    if (hours == null || hours <= 0) return null;
    final minutes = (hours * 60).round();
    return <String, dynamic>{
      'durationMinutes': minutes,
    };
  }

  bool _isValidSleepValue() {
    if (_kind != DailyRecordKind.sleep) return true;
    final hours = _parseSleepHours(_valueController.text);
    return hours != null && hours > 0;
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

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
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
