import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

class RecordCreatePage extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final valueController = useTextEditingController();
    final unitController = useTextEditingController();
    final noteController = useTextEditingController();
    final titleController = useTextEditingController();
    final imagePicker = useMemoized(() => ImagePicker());

    final kind = useState(initialKind ?? DailyRecordKind.water);
    final saving = useState(false);
    final selectedImage = useState<_PendingDailyRecordImage?>(null);
    final seedDate = initialDate ?? DateTime.now();
    final recordDate = useState(
      DateTime(seedDate.year, seedDate.month, seedDate.day),
    );
    final recordTime = useState(initialTime?.trim());
    final sleepBedtime = useState<TimeOfDay?>(null);
    final sleepWakeTime = useState<TimeOfDay?>(null);
    final sleepQuality = useState<String?>(null);
    final sleepDeepMinutes = useState<int?>(null);
    final sleepLightMinutes = useState<int?>(null);
    final sleepRemMinutes = useState<int?>(null);

    // Apply kind defaults (initState equivalent)
    useEffect(() {
      if (kind.value == DailyRecordKind.water &&
          unitController.text.trim().isEmpty) {
        unitController.text = dailyRecordWaterDefaultUnit;
      }
      return null;
    }, []);

    void applyKindDefaults(DailyRecordKind k) {
      if (k == DailyRecordKind.water && unitController.text.trim().isEmpty) {
        unitController.text = dailyRecordWaterDefaultUnit;
      }
    }

    String? optionalText(TextEditingController controller) {
      final value = controller.text.trim();
      return value.isEmpty ? null : value;
    }

    String? normalizedValueForKind(DailyRecordKind k) {
      if (k == DailyRecordKind.sleep) return null;
      return optionalText(valueController);
    }

    String? unitTextForKind(DailyRecordKind k) {
      final value = unitController.text.trim();
      if (value.isNotEmpty) return value;
      if (k == DailyRecordKind.water) return dailyRecordWaterDefaultUnit;
      return null;
    }

    Map<String, dynamic>? buildSleepPayload(DailyRecordKind k) {
      if (k != DailyRecordKind.sleep) return null;
      final minutes = computeSleepDurationMinutes(
        sleepBedtime.value,
        sleepWakeTime.value,
      );
      if (minutes == null || minutes <= 0) return null;
      final payload = <String, dynamic>{'durationMinutes': minutes};
      if (sleepBedtime.value != null && sleepWakeTime.value != null) {
        final date = recordDate.value;
        final wake = DateTime(
          date.year,
          date.month,
          date.day,
          sleepWakeTime.value!.hour,
          sleepWakeTime.value!.minute,
        );
        var bed = DateTime(
          date.year,
          date.month,
          date.day,
          sleepBedtime.value!.hour,
          sleepBedtime.value!.minute,
        );
        if (!bed.isBefore(wake)) bed = bed.subtract(const Duration(days: 1));
        payload['startAt'] = bed.toUtc().toIso8601String();
        payload['endAt'] = wake.toUtc().toIso8601String();
      }
      if (sleepQuality.value != null) payload['quality'] = sleepQuality.value;
      if (sleepDeepMinutes.value != null && sleepDeepMinutes.value! > 0) {
        payload['deepMinutes'] = sleepDeepMinutes.value;
      }
      if (sleepLightMinutes.value != null && sleepLightMinutes.value! > 0) {
        payload['lightMinutes'] = sleepLightMinutes.value;
      }
      if (sleepRemMinutes.value != null && sleepRemMinutes.value! > 0) {
        payload['remMinutes'] = sleepRemMinutes.value;
      }
      return payload;
    }

    bool isValidSleepValue() {
      if (kind.value != DailyRecordKind.sleep) return true;
      final minutes = computeSleepDurationMinutes(
        sleepBedtime.value,
        sleepWakeTime.value,
      );
      return minutes != null && minutes > 0;
    }

    void onKindChanged(DailyRecordKind newKind) {
      final wasWater = kind.value == DailyRecordKind.water;
      kind.value = newKind;
      if (newKind != DailyRecordKind.water &&
          wasWater &&
          unitController.text.trim() == dailyRecordWaterDefaultUnit) {
        unitController.clear();
      }
      if (newKind != DailyRecordKind.sleep) {
        sleepBedtime.value = null;
        sleepWakeTime.value = null;
        sleepQuality.value = null;
        sleepDeepMinutes.value = null;
        sleepLightMinutes.value = null;
        sleepRemMinutes.value = null;
      }
      applyKindDefaults(newKind);
    }

    Future<void> pickRecordDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: recordDate.value,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked == null) return;
      recordDate.value = DateTime(picked.year, picked.month, picked.day);
    }

    Future<void> pickRecordTime() async {
      final parsed = parseRecordTime(recordTime.value);
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: parsed?.hour ?? DateTime.now().hour,
          minute: parsed?.minute ?? DateTime.now().minute,
        ),
      );
      if (picked == null) return;
      recordTime.value = formatRecordTimeValue(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    }

    Future<void> onPickImage() async {
      try {
        final image = await imagePicker.pickImage(
          source: ImageSource.gallery,
          requestFullMetadata: false,
        );
        if (image == null) return;

        final contentType = resolveImageContentType(image);
        if (contentType == null) {
          if (context.mounted) {
            await AppToast.show(
              context,
              AppLocalizations.of(context)!.recordImageUnsupportedToast,
            );
          }
          return;
        }

        final bytes = await image.readAsBytes();
        if (!context.mounted) return;
        selectedImage.value = _PendingDailyRecordImage(
          bytes: bytes,
          fileName: image.name,
          contentType: contentType,
        );
      } catch (_) {
        if (context.mounted) {
          await AppToast.show(
            context,
            AppLocalizations.of(context)!.recordImagePickFailedToast,
          );
        }
      }
    }

    void onRemoveImage() {
      selectedImage.value = null;
    }

    Future<List<DailyRecordAttachmentInput>> uploadSelectedImage() async {
      final image = selectedImage.value;
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

    Future<void> onSave(String dateStr) async {
      if (kind.value == DailyRecordKind.sleep && !isValidSleepValue()) {
        unawaited(
          AppToast.show(
            context,
            AppLocalizations.of(context)!.recordSleepInvalidValueToast,
          ),
        );
        return;
      }

      saving.value = true;
      try {
        final repo = ref.read(dailyRecordRepositoryProvider);
        final attachments = await uploadSelectedImage();
        final rules = dailyRecordFormRules(kind.value);
        await repo.create(
          DailyRecordCreateInput(
            kind: kind.value,
            occurredAt: dateStr,
            occurredTime: recordTime.value,
            title: rules.showTitle ? optionalText(titleController) : null,
            value: rules.showValue ? normalizedValueForKind(kind.value) : null,
            unit: rules.showUnit ? unitTextForKind(kind.value) : null,
            note: optionalText(noteController),
            payload: buildSleepPayload(kind.value),
            attachments: attachments,
          ),
        );
        ref.invalidate(recordDashboardProvider);
        ref.invalidate(todayDashboardProvider);
        ref.invalidate(reportDashboardProvider);
        if (context.mounted) {
          unawaited(
            AppToast.show(
              context,
              AppLocalizations.of(context)!.mineEditSavedToast,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          unawaited(
            AppToast.show(
              context,
              AppLocalizations.of(context)!.recordCreateFailedToast,
            ),
          );
        }
      } finally {
        if (context.mounted) saving.value = false;
      }
    }

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

    final dateStr = formatRecordDate(recordDate.value);

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
                date: recordDate.value,
                time: recordTime.value,
                onDateTap: pickRecordDate,
                onTimeTap: pickRecordTime,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              DailyRecordFormFields(
                kind: kind.value,
                onKindChanged: onKindChanged,
                valueController: valueController,
                unitController: unitController,
                titleController: titleController,
                noteController: noteController,
              ),
              if (kind.value == DailyRecordKind.sleep) ...[
                const SizedBox(height: AppSpacingTokens.sm),
                SleepStructuredFields(
                  l10n: l10n,
                  bedtime: sleepBedtime.value,
                  wakeTime: sleepWakeTime.value,
                  quality: sleepQuality.value,
                  deepMinutes: sleepDeepMinutes.value,
                  lightMinutes: sleepLightMinutes.value,
                  remMinutes: sleepRemMinutes.value,
                  onBedtimeChanged: (v) => sleepBedtime.value = v,
                  onWakeTimeChanged: (v) => sleepWakeTime.value = v,
                  onQualityChanged: (v) => sleepQuality.value = v,
                  onDeepMinutesChanged: (v) => sleepDeepMinutes.value = v,
                  onLightMinutesChanged: (v) => sleepLightMinutes.value = v,
                  onRemMinutesChanged: (v) => sleepRemMinutes.value = v,
                ),
              ],
              const SizedBox(height: AppSpacingTokens.sm),
              DailyRecordImageAttachmentField(
                l10n: l10n,
                selectedBytes: selectedImage.value?.bytes,
                selectedFileName: selectedImage.value?.fileName,
                existingAttachment: null,
                onPick: onPickImage,
                onRemove: onRemoveImage,
                enabled: !saving.value,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              ElevatedButton(
                key: const Key('record-create-save-action'),
                onPressed: saving.value ? null : () => onSave(dateStr),
                child: Text(l10n.mineEditSaveAction),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String? resolveImageContentType(XFile image) {
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
