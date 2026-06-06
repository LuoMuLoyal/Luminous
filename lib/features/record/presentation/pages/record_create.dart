import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_image_attachment_field.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordCreatePage extends ConsumerStatefulWidget {
  const RecordCreatePage({super.key});

  @override
  ConsumerState<RecordCreatePage> createState() => _RecordCreatePageState();
}

class _RecordCreatePageState extends ConsumerState<RecordCreatePage> {
  DailyRecordKind _kind = DailyRecordKind.water;
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _saving = false;
  _PendingDailyRecordImage? _selectedImage;

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

    // Signed-out users see login prompt
    if (!session.isAuthenticated) {
      return PageScaffoldShell(
        title: l10n.recordAddAction,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.authNotSignedIn),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    child: Text(l10n.authGoLogin),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
              DropdownButtonFormField<DailyRecordKind>(
                initialValue: _kind,
                decoration: InputDecoration(
                  labelText: l10n.recordCreateFieldKind,
                ),
                items: DailyRecordKind.values
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(_kindLabel(l10n, k)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _kind = v);
                },
              ),
              const SizedBox(height: 12),
              if (_kind != DailyRecordKind.mood) ...[
                TextField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: _valueLabel(l10n, _kind),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_kind == DailyRecordKind.vital ||
                  _kind == DailyRecordKind.water) ...[
                TextField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: l10n.recordCreateFieldUnit,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_kind != DailyRecordKind.water) ...[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.recordCreateFieldTitleOptional,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.recordCreateFieldNote,
                ),
                maxLines: 3,
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
                onPressed: _saving ? null : () => _onSave(dateStr),
                child: Text(_saving ? '...' : l10n.mineEditSaveAction),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _kindLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => l10n.recordTypeWater,
      DailyRecordKind.meal => l10n.recordTypeMeal,
      DailyRecordKind.vital => l10n.recordTypeVitals,
      DailyRecordKind.mood => l10n.recordTypeMood,
      DailyRecordKind.symptom => l10n.recordTypeSymptom,
      DailyRecordKind.activity => l10n.recordTypeActivity,
      DailyRecordKind.note => l10n.recordCreateKindNote,
    };
  }

  String _valueLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => l10n.recordCreateValueWater,
      DailyRecordKind.meal => l10n.recordCreateValueMeal,
      DailyRecordKind.vital => l10n.recordCreateValueVital,
      DailyRecordKind.mood => l10n.recordTypeMood,
      DailyRecordKind.symptom => l10n.recordTypeSymptom,
      DailyRecordKind.activity => l10n.recordTypeActivity,
      DailyRecordKind.note => l10n.recordCreateFieldNote,
    };
  }

  Future<void> _onSave(String dateStr) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      final attachments = await _uploadSelectedImage();
      await repo.create(
        DailyRecordCreateInput(
          kind: _kind,
          occurredAt: dateStr,
          title: _titleController.text.isEmpty ? null : _titleController.text,
          value: _valueController.text.isEmpty ? null : _valueController.text,
          unit: _unitController.text.isEmpty ? null : _unitController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          attachments: attachments,
        ),
      );
      ref.invalidate(recordDashboardProvider);
      ref.invalidate(todayDashboardProvider);
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
