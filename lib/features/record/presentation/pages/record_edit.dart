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
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart'
    show
        DailyRecordAttachmentInput,
        DailyRecordImageUploadInput,
        DailyRecordUpdateInput,
        dailyRecordNoChange;
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_image_attachment_field.dart';
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
  _PendingDailyRecordImage? _selectedImage;
  bool _attachmentsChanged = false;

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
        _unitController.text = record.unit ?? '';
        _noteController.text = record.note ?? '';
        _titleController.text = record.title ?? '';
        _existingImageAttachment = record.attachments
            .where(
              (attachment) =>
                  attachment.kind == DailyRecordAttachmentKind.image,
            )
            .firstOrNull;
        _selectedImage = null;
        _attachmentsChanged = false;
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
              : _RecordAuthRequiredPrompt(
                  onLogin: () => context.push('/login'),
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
                existingAttachment: _attachmentsChanged
                    ? null
                    : _existingImageAttachment,
                onPick: _onPickImage,
                onRemove: _onRemoveImage,
                enabled: !_saving && !_deleting,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _onSave,
                child: Text(_saving ? '...' : l10n.mineEditSaveAction),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _deleting || _saving ? null : _onDelete,
                icon: _deleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(_deleting ? '...' : l10n.recordDeleteAction),
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

  Future<void> _onSave() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(dailyRecordRepositoryProvider);
      final attachmentPatch = await _buildAttachmentPatch();
      await repo.update(
        widget.recordId,
        DailyRecordUpdateInput(
          kind: _kind,
          title: _optionalText(_titleController),
          value: _optionalText(_valueController),
          unit: _optionalText(_unitController),
          note: _optionalText(_noteController),
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
    ref.invalidate(recordDashboardProvider);
    ref.invalidate(todayDashboardProvider);
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
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

class _RecordAuthRequiredPrompt extends StatelessWidget {
  const _RecordAuthRequiredPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.authNotSignedIn),
            const SizedBox(height: AppSpacingTokens.md),
            ElevatedButton(onPressed: onLogin, child: Text(l10n.authGoLogin)),
          ],
        ),
      ),
    );
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
