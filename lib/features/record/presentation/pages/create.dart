import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/utils/image_compressor.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/forms/form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/image_attachment_field.dart';
import 'package:luminous/features/record/presentation/widgets/forms/kind_icon_field.dart';
import 'package:luminous/features/record/presentation/widgets/forms/occurred_at_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/pending_image.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
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
    final selectedImage = useState<PendingDailyRecordImage?>(null);
    final valueError = useState<String?>(null);
    final titleError = useState<String?>(null);
    final seedDate = initialDate ?? clock.now();
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
    final typography = context.theme.typography;

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
      final bedTime = sleepBedtime.value;
      final wakeTime = sleepWakeTime.value;
      if (bedTime != null && wakeTime != null) {
        final date = recordDate.value;
        final wake = DateTime(
          date.year,
          date.month,
          date.day,
          wakeTime.hour,
          wakeTime.minute,
        );
        var bed = DateTime(
          date.year,
          date.month,
          date.day,
          bedTime.hour,
          bedTime.minute,
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
      final rules = dailyRecordFormRules(newKind);
      kind.value = newKind;
      if (newKind != DailyRecordKind.water &&
          wasWater &&
          unitController.text.trim() == dailyRecordWaterDefaultUnit) {
        unitController.clear();
      }
      // Clear fields that are not applicable to the new kind to avoid
      // stale content silently reappearing when switching back.
      if (!rules.showValue) {
        valueController.clear();
      }
      if (!rules.showTitle) {
        titleController.clear();
      }
      if (!rules.showUnit &&
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

    Future<void> pickAndProcessImage(ImageSource source) async {
      try {
        final image = await imagePicker.pickImage(
          source: source,
          requestFullMetadata: false,
        );
        if (image == null) return;

        final contentType = resolveImageContentType(image);
        if (contentType == null) {
          if (context.mounted) {
            await Toast.show(
              context,
              AppLocalizations.of(context)!.recordImageUnsupportedToast,
            );
          }
          return;
        }

        final rawBytes = await image.readAsBytes();
        if (!context.mounted) return;
        final compressedBytes = await ImageCompressor.compressForUpload(
          rawBytes,
        );
        selectedImage.value = PendingDailyRecordImage(
          bytes: compressedBytes,
          fileName: image.name,
          contentType: 'image/jpeg',
        );
      } catch (e) {
        ref
            .read(talkerProvider)
            .error('RecordCreatePage.pickAndProcessImage: failed: $e');
        if (context.mounted) {
          await Toast.show(
            context,
            AppLocalizations.of(context)!.recordImagePickFailedToast,
          );
        }
      }
    }

    void onPickImage() => pickAndProcessImage(ImageSource.gallery);

    void onPickFromCamera() => pickAndProcessImage(ImageSource.camera);

    void onRemoveImage() {
      selectedImage.value = null;
    }

    Future<List<DailyRecordAttachmentInput>> uploadSelectedImage() async {
      final image = selectedImage.value;
      if (image == null) return const <DailyRecordAttachmentInput>[];

      final repo = ref.read(dailyRecordRepositoryProvider);
      final result = await repo
          .uploadImage(
            DailyRecordImageUploadInput(
              bytes: image.bytes,
              contentType: image.contentType,
              sizeBytes: image.bytes.length,
              fileName: image.fileName,
            ),
          )
          .run();
      final attachment = result.fold(
        (failure) => throw failure,
        (attachment) => attachment,
      );
      return <DailyRecordAttachmentInput>[attachment];
    }

    Future<void> onSave(String dateStr) async {
      if (kind.value == DailyRecordKind.sleep && !isValidSleepValue()) {
        if (!context.mounted) return;
        unawaited(
          Toast.show(
            context,
            AppLocalizations.of(context)!.recordSleepInvalidValueToast,
          ),
        );
        return;
      }

      // ── Front-end validation for required fields ──
      final rules = dailyRecordFormRules(kind.value);
      final l10n = AppLocalizations.of(context)!;

      // Clear previous errors
      valueError.value = null;
      titleError.value = null;

      // Value field: required for water/vital/symptom/meal/activity
      if (rules.showValue) {
        final rawValue = valueController.text.trim();
        if (rawValue.isEmpty) {
          valueError.value = l10n.recordCreateValueRequiredToast;
          return;
        }
        // Numeric validation for water (must be a positive number)
        if (kind.value == DailyRecordKind.water) {
          final parsed = double.tryParse(rawValue);
          if (parsed == null || parsed <= 0) {
            valueError.value = l10n.recordCreateValueInvalidToast;
            return;
          }
        }
      }

      // Title field: required for vital/symptom/meal/note/mood/activity
      if (rules.showTitle) {
        final rawTitle = titleController.text.trim();
        if (rawTitle.isEmpty) {
          titleError.value = l10n.recordCreateTitleRequiredToast;
          return;
        }
      }

      saving.value = true;
      try {
        final repo = ref.read(dailyRecordRepositoryProvider);
        final attachments = await uploadSelectedImage();
        final result = await repo
            .create(
              DailyRecordCreateInput(
                kind: kind.value,
                occurredAt: dateStr,
                occurredTime: recordTime.value,
                title: rules.showTitle ? optionalText(titleController) : null,
                value: rules.showValue
                    ? normalizedValueForKind(kind.value)
                    : null,
                unit: rules.showUnit ? unitTextForKind(kind.value) : null,
                note: optionalText(noteController),
                payload: buildSleepPayload(kind.value),
                attachments: attachments,
              ),
            )
            .run();
        result.fold((failure) => throw failure, (_) {});
        ref
            .read(dataChangeBusProvider.notifier)
            .emit(DataChangeTopic.dailyRecords);
        if (context.mounted) {
          unawaited(
            Toast.show(
              context,
              AppLocalizations.of(context)!.recordCreateSavedToast,
            ),
          );
          context.pop();
        }
      } catch (e) {
        ref.read(talkerProvider).error('RecordCreatePage.onSave: failed: $e');
        if (context.mounted) {
          unawaited(
            Toast.show(
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
    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const InlineSkeletonSection(
                      children: [
                        InlineSkeletonBlock(height: 56),
                        InlineSkeletonBlock(height: 56),
                        InlineSkeletonBlock(height: 56),
                        InlineSkeletonBlock(height: 96),
                        InlineSkeletonBlock(height: 56),
                      ],
                    )
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );
    } else {
      final dateStr = formatRecordDate(recordDate.value);

      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(Spacing.level4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.recordCreateSectionBasicTitle,
                      style: typography.body.md.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.level3),
                    RecordOccurredAtFields(
                      date: recordDate.value,
                      time: recordTime.value,
                      onDateChanged: (date) => recordDate.value = DateTime(
                        date.year,
                        date.month,
                        date.day,
                      ),
                      onTimeChanged: (time) => recordTime.value = time == null
                          ? null
                          : formatHourMinute(time.hour, time.minute),
                    ),
                    const SizedBox(height: Spacing.level5),
                    Text(
                      l10n.recordCreateSectionDetailsTitle,
                      style: typography.body.md.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.level3),
                    DailyRecordFormFields(
                      kind: kind.value,
                      onKindChanged: onKindChanged,
                      valueController: valueController,
                      unitController: unitController,
                      titleController: titleController,
                      noteController: noteController,
                      valueError: valueError.value,
                      titleError: titleError.value,
                      enabled: !saving.value,
                    ),
                    const SizedBox(height: Spacing.level3),
                    RecordKindIconField(kind: kind.value),
                    if (kind.value == DailyRecordKind.sleep) ...[
                      const SizedBox(height: Spacing.level3),
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
                        onLightMinutesChanged: (v) =>
                            sleepLightMinutes.value = v,
                        onRemMinutesChanged: (v) => sleepRemMinutes.value = v,
                      ),
                    ],
                    const SizedBox(height: Spacing.level3),
                    DailyRecordImageAttachmentField(
                      l10n: l10n,
                      selectedBytes: selectedImage.value?.bytes,
                      selectedFileName: selectedImage.value?.fileName,
                      existingAttachment: null,
                      onPick: onPickImage,
                      onCameraPick: onPickFromCamera,
                      onRemove: onRemoveImage,
                      enabled: !saving.value,
                    ),
                    const SizedBox(height: Spacing.level5),
                    FButton(
                      key: const Key('record-create-save-action'),
                      onPress: saving.value ? null : () => onSave(dateStr),
                      prefix: saving.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: FCircularProgress(),
                            )
                          : null,
                      child: Text(l10n.mineEditSaveAction),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PageScaffold(
      title: l10n.recordAddAction,
      child: PopScope(
        canPop: !_isDirty(
          valueController: valueController,
          unitController: unitController,
          noteController: noteController,
          titleController: titleController,
          selectedImage: selectedImage.value,
        ),
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _confirmDiscardChanges(context);
          if (shouldPop && context.mounted) {
            context.pop();
          }
        },
        child: SingleChildScrollView(child: content),
      ),
    );
  }

  static bool _isDirty({
    required TextEditingController valueController,
    required TextEditingController unitController,
    required TextEditingController noteController,
    required TextEditingController titleController,
    required PendingDailyRecordImage? selectedImage,
  }) {
    return valueController.text.trim().isNotEmpty ||
        unitController.text.trim().isNotEmpty ||
        noteController.text.trim().isNotEmpty ||
        titleController.text.trim().isNotEmpty ||
        selectedImage != null;
  }

  static Future<bool> _confirmDiscardChanges(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showAppDialog<bool>(
      context: context,
      scrollable: false,
      builder: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recordDiscardChangesTitle,
            style: dialogContext.theme.dialogStyle.titleTextStyle,
          ),
          const SizedBox(height: Spacing.level2),
          Text(
            l10n.recordDiscardChangesMessage,
            style: dialogContext.theme.dialogStyle.bodyTextStyle,
          ),
          const SizedBox(height: Spacing.level5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.authCancelAction),
              ),
              const SizedBox(width: Spacing.level3),
              FButton(
                variant: FButtonVariant.destructive,
                onPress: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.recordDiscardChangesAction),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static String? resolveImageContentType(XFile image) {
    final mimeType = image.mimeType?.trim().toLowerCase();
    if (allowedImageContentTypes.contains(mimeType)) return mimeType;

    final name = image.name.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';
    return null;
  }
}
