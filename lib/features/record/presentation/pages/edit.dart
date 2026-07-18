import 'dart:async';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/utils/image_compressor.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart'
    show
        DailyRecordAttachmentInput,
        DailyRecordImageUploadInput,
        DailyRecordUpdateInput,
        dailyRecordNoChange;
import 'package:luminous/features/record/presentation/utils/meal_analysis_payload_parser.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/forms/form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/image_attachment_field.dart';
import 'package:luminous/features/record/presentation/widgets/forms/occurred_at_fields.dart';
import 'package:luminous/features/record/presentation/widgets/meal/dish_editor.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordEditPage extends HookConsumerWidget {
  const RecordEditPage({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final valueController = useTextEditingController();
    final unitController = useTextEditingController();
    final noteController = useTextEditingController();
    final titleController = useTextEditingController();
    final imagePicker = useMemoized(() => ImagePicker());

    final kind = useState(DailyRecordKind.water);
    final saving = useState(false);
    final deleting = useState(false);
    final loaded = useState(false);
    final loadingRecord = useState(false);
    final existingImageAttachment = useState<DailyRecordAttachment?>(null);
    final existingSleepPayload = useState<Map<String, dynamic>?>(null);
    final selectedImage = useState<_PendingDailyRecordImage?>(null);
    final attachmentsChanged = useState(false);
    final recordOccurredAt = useState<DateTime?>(null);
    final recordOccurredTime = useState<String?>(null);
    final sleepBedtime = useState<TimeOfDay?>(null);
    final sleepWakeTime = useState<TimeOfDay?>(null);
    final sleepQuality = useState<String?>(null);
    final sleepDeepMinutes = useState<int?>(null);
    final sleepLightMinutes = useState<int?>(null);
    final sleepRemMinutes = useState<int?>(null);
    final mealDishNames = useState<List<String>>(<String>[]);
    final canConfirmMealAnalysis = useState(false);
    final confirmMealAnalysis = useState(false);

    void invalidateProviders() {
      ref.invalidate(dailyRecordDetailProvider(recordId));
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.dailyRecords);
    }

    void loadSleepPayloadData(Map<String, dynamic>? payload) {
      if (payload == null) return;
      final startAt = payload['startAt'] as String?;
      if (startAt != null) {
        final dt = DateTime.tryParse(startAt);
        if (dt != null) {
          final local = dt.toLocal();
          sleepBedtime.value = TimeOfDay(
            hour: local.hour,
            minute: local.minute,
          );
        }
      }
      final endAt = payload['endAt'] as String?;
      if (endAt != null) {
        final dt = DateTime.tryParse(endAt);
        if (dt != null) {
          final local = dt.toLocal();
          sleepWakeTime.value = TimeOfDay(
            hour: local.hour,
            minute: local.minute,
          );
        }
      }
      sleepQuality.value = payload['quality'] as String?;
      final deep = payload['deepMinutes'];
      if (deep is num && deep > 0) sleepDeepMinutes.value = deep.round();
      final light = payload['lightMinutes'];
      if (light is num && light > 0) sleepLightMinutes.value = light.round();
      final rem = payload['remMinutes'];
      if (rem is num && rem > 0) sleepRemMinutes.value = rem.round();
    }

    String defaultUnitTextForKind(DailyRecordKind k) {
      if (k == DailyRecordKind.water) return dailyRecordWaterDefaultUnit;
      return '';
    }

    Future<void> loadRecord() async {
      if (loaded.value || loadingRecord.value) return;
      loadingRecord.value = true;
      try {
        final repo = ref.read(dailyRecordRepositoryProvider);
        final record = await repo.get(recordId);
        if (!context.mounted) return;
        kind.value = record.kind;
        valueController.text = record.value ?? '';
        unitController.text =
            record.unit ?? defaultUnitTextForKind(record.kind);
        noteController.text = record.note ?? '';
        titleController.text = record.title ?? '';
        existingImageAttachment.value = record.attachments
            .where((a) => a.kind == DailyRecordAttachmentKind.image)
            .firstOrNull;
        existingSleepPayload.value = record.payload == null
            ? null
            : Map<String, dynamic>.from(record.payload!);
        selectedImage.value = null;
        attachmentsChanged.value = false;
        loadSleepPayloadData(record.payload);
        mealDishNames.value = parseMealDishDraftNames(record.payload);
        final mealAnalysis = parseMealAnalysisViewData(record.payload);
        canConfirmMealAnalysis.value =
            mealAnalysis != null &&
            (mealAnalysis.status == 'unconfirmed' ||
                mealAnalysis.status == 'confirmed');
        confirmMealAnalysis.value = false;
        recordOccurredAt.value = parseRecordDate(record.occurredAt);
        recordOccurredTime.value = record.occurredTime?.trim();
        loaded.value = true;
        loadingRecord.value = false;
      } catch (e) {
        ref.read(talkerProvider).error('RecordEditPage.loadRecord: failed: $e');
        if (context.mounted) {
          unawaited(AppToast.show(context, l10n.recordCreateFailedToast));
          context.pop();
        }
      } finally {
        if (context.mounted && !loaded.value) {
          loadingRecord.value = false;
        }
      }
    }

    String? optionalText(TextEditingController c) {
      final val = c.text.trim();
      return val.isEmpty ? null : val;
    }

    String? normalizedValueForKind(DailyRecordKind k) {
      if (k == DailyRecordKind.sleep) return null;
      return optionalText(valueController);
    }

    String? unitTextForKind(DailyRecordKind k) {
      final val = unitController.text.trim();
      if (val.isNotEmpty) return val;
      if (k == DailyRecordKind.water) return dailyRecordWaterDefaultUnit;
      return null;
    }

    int? resolvedSleepDurationMinutes() {
      final computed = computeSleepDurationMinutes(
        sleepBedtime.value,
        sleepWakeTime.value,
      );
      if (computed != null && computed > 0) return computed;
      final existing = existingSleepPayload.value?['durationMinutes'];
      if (existing is num && existing > 0) return existing.round();
      return null;
    }

    Map<String, dynamic>? buildSleepPayload(DailyRecordKind k) {
      if (k != DailyRecordKind.sleep) return null;
      final minutes = resolvedSleepDurationMinutes();
      if (minutes == null || minutes <= 0) return null;
      final payload = <String, dynamic>{'durationMinutes': minutes};
      final bedTime = sleepBedtime.value;
      final wakeTime = sleepWakeTime.value;
      if (bedTime != null && wakeTime != null) {
        final occurredAt = recordOccurredAt.value ?? clock.now();
        final wake = DateTime(
          occurredAt.year,
          occurredAt.month,
          occurredAt.day,
          wakeTime.hour,
          wakeTime.minute,
        );
        var bed = DateTime(
          occurredAt.year,
          occurredAt.month,
          occurredAt.day,
          bedTime.hour,
          bedTime.minute,
        );
        if (!bed.isBefore(wake)) bed = bed.subtract(const Duration(days: 1));
        payload['startAt'] = bed.toUtc().toIso8601String();
        payload['endAt'] = wake.toUtc().toIso8601String();
      }
      if (sleepQuality.value != null) payload['quality'] = sleepQuality.value;
      final deep = sleepDeepMinutes.value;
      if (deep != null && deep > 0) {
        payload['deepMinutes'] = deep;
      }
      final light = sleepLightMinutes.value;
      if (light != null && light > 0) {
        payload['lightMinutes'] = light;
      }
      final rem = sleepRemMinutes.value;
      if (rem != null && rem > 0) {
        payload['remMinutes'] = rem;
      }
      return payload;
    }

    Map<String, dynamic>? buildMealPayload(DailyRecordKind k) {
      if (k != DailyRecordKind.meal) return null;
      final dishes = mealDishNames.value
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .map((item) => <String, dynamic>{'rawName': item})
          .toList(growable: false);
      final payload = <String, dynamic>{
        'mealInput': <String, dynamic>{'recognizedDishes': dishes},
      };
      if (confirmMealAnalysis.value) {
        payload['mealAnalysis'] = <String, dynamic>{
          'analysisStatus': 'confirmed',
        };
      }
      return payload;
    }

    Map<String, dynamic>? buildPayload(DailyRecordKind k) {
      return switch (k) {
        DailyRecordKind.sleep => buildSleepPayload(k),
        DailyRecordKind.meal => buildMealPayload(k),
        _ => null,
      };
    }

    bool isValidSleepValue() {
      if (kind.value != DailyRecordKind.sleep) return true;
      final minutes = resolvedSleepDurationMinutes();
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
      if (newKind == DailyRecordKind.water &&
          unitController.text.trim().isEmpty) {
        unitController.text = dailyRecordWaterDefaultUnit;
      }
      if (newKind != DailyRecordKind.sleep) {
        sleepBedtime.value = null;
        sleepWakeTime.value = null;
        sleepQuality.value = null;
        sleepDeepMinutes.value = null;
        sleepLightMinutes.value = null;
        sleepRemMinutes.value = null;
      }
    }

    Future<Object> buildAttachmentPatch() async {
      if (!attachmentsChanged.value) return dailyRecordNoChange;
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

    Future<void> onSave() async {
      if (kind.value == DailyRecordKind.sleep && !isValidSleepValue()) {
        unawaited(AppToast.show(context, l10n.recordSleepInvalidValueToast));
        return;
      }
      saving.value = true;
      try {
        final repo = ref.read(dailyRecordRepositoryProvider);
        final attachmentPatch = await buildAttachmentPatch();
        final rules = dailyRecordFormRules(kind.value);
        await repo.update(
          recordId,
          DailyRecordUpdateInput(
            kind: kind.value,
            occurredAt: formatRecordDate(recordOccurredAt.value ?? clock.now()),
            occurredTime: recordOccurredTime.value,
            title: rules.showTitle ? optionalText(titleController) : null,
            value: rules.showValue ? normalizedValueForKind(kind.value) : null,
            unit: rules.showUnit ? unitTextForKind(kind.value) : null,
            note: optionalText(noteController),
            payload: buildPayload(kind.value),
            attachments: attachmentPatch,
          ),
        );
        invalidateProviders();
        if (context.mounted) {
          await AppToast.show(context, l10n.mineEditSavedToast);
          if (!context.mounted) return;
          context.pop();
        }
      } catch (e) {
        ref.read(talkerProvider).error('RecordEditPage.onSave: failed: $e');
        if (context.mounted) {
          await AppToast.show(context, l10n.recordCreateFailedToast);
        }
      } finally {
        if (context.mounted) saving.value = false;
      }
    }

    Future<void> onDelete() async {
      final confirmed = await showFDialog<bool>(
        context: context,
        builder: (dialogContext, style, animation) => FDialog(
          title: Text(l10n.recordDeleteConfirmTitle),
          body: Text(l10n.recordDeleteConfirmMessage),
          actions: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.authCancelAction),
            ),
            FButton(
              key: const Key('record-delete-confirm-action'),
              variant: FButtonVariant.destructive,
              onPress: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.recordDeleteAction),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      deleting.value = true;
      try {
        final repo = ref.read(dailyRecordRepositoryProvider);
        await repo.delete(recordId);
        invalidateProviders();
        if (context.mounted) {
          await AppToast.show(context, l10n.recordDeletedToast);
          if (!context.mounted) return;
          context.pop();
          context.pop();
        }
      } catch (e) {
        ref.read(talkerProvider).error('RecordEditPage.onDelete: failed: $e');
        if (context.mounted) {
          await AppToast.show(context, l10n.recordDeleteFailedToast);
        }
      } finally {
        if (context.mounted) deleting.value = false;
      }
    }

    Future<void> onPickImage() async {
      try {
        final image = await imagePicker.pickImage(
          source: ImageSource.gallery,
          requestFullMetadata: false,
        );
        if (image == null) return;
        final contentType = RecordEditPage.resolveImageContentType(image);
        if (contentType == null) {
          if (context.mounted) {
            await AppToast.show(context, l10n.recordImageUnsupportedToast);
          }
          return;
        }
        final rawBytes = await image.readAsBytes();
        if (!context.mounted) return;
        final compressedBytes = await AppImageCompressor.compressForUpload(
          rawBytes,
        );
        selectedImage.value = _PendingDailyRecordImage(
          bytes: compressedBytes,
          fileName: image.name,
          contentType: 'image/jpeg',
        );
        attachmentsChanged.value = true;
      } catch (e) {
        ref
            .read(talkerProvider)
            .error('RecordEditPage.onPickImage: failed: $e');
        if (context.mounted) {
          await AppToast.show(context, l10n.recordImagePickFailedToast);
        }
      }
    }

    void onRemoveImage() {
      selectedImage.value = null;
      attachmentsChanged.value = true;
    }

    final session = ref.watch(authSessionProvider);
    final Widget content;

    // Trigger load on first eligible frame
    useEffect(() {
      if (session.canAccessProtectedData &&
          !loaded.value &&
          !loadingRecord.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) loadRecord();
        });
      }
      return null;
    }, [session.canAccessProtectedData]);

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
                  ? const _RecordEditLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );
    } else if (!loaded.value) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_RecordEditLoading()],
          ),
        ),
      );
    } else {
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
                    RecordOccurredAtFields(
                      date: recordOccurredAt.value ?? clock.now(),
                      time: recordOccurredTime.value,
                      onDateChanged: (date) =>
                          recordOccurredAt.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            recordOccurredAt.value?.hour ?? clock.now().hour,
                            recordOccurredAt.value?.minute ??
                                clock.now().minute,
                          ),
                      onTimeChanged: (time) {
                        if (time == null) {
                          recordOccurredTime.value = null;
                          return;
                        }
                        recordOccurredAt.value = DateTime(
                          recordOccurredAt.value?.year ?? clock.now().year,
                          recordOccurredAt.value?.month ?? clock.now().month,
                          recordOccurredAt.value?.day ?? clock.now().day,
                          time.hour,
                          time.minute,
                        );
                        recordOccurredTime.value = formatHourMinute(
                          time.hour,
                          time.minute,
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.level3),
                    DailyRecordFormFields(
                      kind: kind.value,
                      onKindChanged: onKindChanged,
                      valueController: valueController,
                      unitController: unitController,
                      titleController: titleController,
                      noteController: noteController,
                    ),
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
                    if (kind.value == DailyRecordKind.meal) ...[
                      const SizedBox(height: Spacing.level3),
                      MealDishEditorSection(
                        dishNames: mealDishNames.value,
                        enabled: !saving.value && !deleting.value,
                        onDishChanged: (index, value) {
                          final next = [...mealDishNames.value];
                          if (index >= 0 && index < next.length) {
                            next[index] = value;
                            mealDishNames.value = next;
                          }
                        },
                        onDishRemoved: (index) {
                          final next = [...mealDishNames.value]
                            ..removeAt(index);
                          mealDishNames.value = next;
                        },
                        onDishAdded: () {
                          mealDishNames.value = [...mealDishNames.value, ''];
                        },
                      ),
                      if (canConfirmMealAnalysis.value) ...[
                        const SizedBox(height: Spacing.level3),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FButton(
                            variant: FButtonVariant.outline,
                            key: const Key('meal-confirm-action'),
                            onPress: () => confirmMealAnalysis.value = true,
                            child: Text(
                              confirmMealAnalysis.value
                                  ? l10n.recordMealConfirmActionSelected
                                  : l10n.recordMealConfirmAction,
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: Spacing.level3),
                    DailyRecordImageAttachmentField(
                      l10n: l10n,
                      selectedBytes: selectedImage.value?.bytes,
                      selectedFileName: selectedImage.value?.fileName,
                      existingAttachment: attachmentsChanged.value
                          ? null
                          : existingImageAttachment.value,
                      onPick: onPickImage,
                      onRemove: onRemoveImage,
                      enabled: !saving.value && !deleting.value,
                    ),
                    const SizedBox(height: Spacing.level5),
                    FButton(
                      key: const Key('record-edit-save-action'),
                      onPress: saving.value ? null : onSave,
                      child: Text(l10n.mineEditSaveAction),
                    ),
                    const SizedBox(height: Spacing.level3),
                    FButton(
                      key: const Key('record-edit-delete-action'),
                      variant: FButtonVariant.destructive,
                      onPress: deleting.value || saving.value ? null : onDelete,
                      prefix: deleting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: FCircularProgress(),
                            )
                          : const Icon(FLucideIcons.trash2, size: 18),
                      child: Text(l10n.recordDeleteAction),
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
      title: l10n.recordEditAction,
      child: SingleChildScrollView(child: content),
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
