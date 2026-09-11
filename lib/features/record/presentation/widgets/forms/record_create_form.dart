import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/widgets/forms/form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/image_attachment_field.dart';
import 'package:luminous/features/record/presentation/widgets/forms/kind_icon_field.dart';
import 'package:luminous/features/record/presentation/widgets/forms/occurred_at_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The form body for creating a new daily record.
///
/// This widget is stateless — all state lives in the parent [RecordCreatePage]
/// and is passed in as parameters.  The widget is purely a layout + input
/// composition layer.
class RecordCreateForm extends StatelessWidget {
  const RecordCreateForm({
    super.key,
    required this.kind,
    required this.onKindChanged,
    required this.valueController,
    required this.unitController,
    required this.titleController,
    required this.noteController,
    required this.valueError,
    required this.titleError,
    required this.saving,
    required this.recordDate,
    required this.recordTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.sleepBedtime,
    required this.sleepWakeTime,
    required this.sleepQuality,
    required this.sleepDeepMinutes,
    required this.sleepLightMinutes,
    required this.sleepRemMinutes,
    required this.onBedtimeChanged,
    required this.onWakeTimeChanged,
    required this.onQualityChanged,
    required this.onDeepMinutesChanged,
    required this.onLightMinutesChanged,
    required this.onRemMinutesChanged,
    required this.selectedImageBytes,
    required this.selectedImageFileName,
    required this.onPickImage,
    required this.onPickFromCamera,
    required this.onRemoveImage,
    required this.onSave,
  });

  final DailyRecordKind kind;
  final ValueChanged<DailyRecordKind> onKindChanged;
  final TextEditingController valueController;
  final TextEditingController unitController;
  final TextEditingController titleController;
  final TextEditingController noteController;
  final String? valueError;
  final String? titleError;
  final bool saving;
  final DateTime recordDate;
  final String? recordTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<FTime?> onTimeChanged;
  final TimeOfDay? sleepBedtime;
  final TimeOfDay? sleepWakeTime;
  final String? sleepQuality;
  final int? sleepDeepMinutes;
  final int? sleepLightMinutes;
  final int? sleepRemMinutes;
  final ValueChanged<TimeOfDay?> onBedtimeChanged;
  final ValueChanged<TimeOfDay?> onWakeTimeChanged;
  final ValueChanged<String?> onQualityChanged;
  final ValueChanged<int?> onDeepMinutesChanged;
  final ValueChanged<int?> onLightMinutesChanged;
  final ValueChanged<int?> onRemMinutesChanged;
  final Uint8List? selectedImageBytes;
  final String? selectedImageFileName;
  final VoidCallback onPickImage;
  final VoidCallback onPickFromCamera;
  final VoidCallback onRemoveImage;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.recordCreateSectionBasicTitle,
          style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.md),
        RecordOccurredAtFields(
          date: recordDate,
          time: recordTime,
          onDateChanged: onDateChanged,
          onTimeChanged: onTimeChanged,
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          l10n.recordCreateSectionDetailsTitle,
          style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.md),
        DailyRecordFormFields(
          kind: kind,
          onKindChanged: onKindChanged,
          valueController: valueController,
          unitController: unitController,
          titleController: titleController,
          noteController: noteController,
          valueError: valueError,
          titleError: titleError,
          enabled: !saving,
        ),
        const SizedBox(height: Spacing.md),
        RecordKindIconField(kind: kind),
        if (kind == DailyRecordKind.sleep) ...[
          const SizedBox(height: Spacing.md),
          SleepStructuredFields(
            l10n: l10n,
            bedtime: sleepBedtime,
            wakeTime: sleepWakeTime,
            quality: sleepQuality,
            deepMinutes: sleepDeepMinutes,
            lightMinutes: sleepLightMinutes,
            remMinutes: sleepRemMinutes,
            onBedtimeChanged: onBedtimeChanged,
            onWakeTimeChanged: onWakeTimeChanged,
            onQualityChanged: onQualityChanged,
            onDeepMinutesChanged: onDeepMinutesChanged,
            onLightMinutesChanged: onLightMinutesChanged,
            onRemMinutesChanged: onRemMinutesChanged,
          ),
        ],
        const SizedBox(height: Spacing.md),
        DailyRecordImageAttachmentField(
          l10n: l10n,
          selectedBytes: selectedImageBytes,
          selectedFileName: selectedImageFileName,
          existingAttachment: null,
          onPick: onPickImage,
          onCameraPick: onPickFromCamera,
          onRemove: onRemoveImage,
          enabled: !saving,
        ),
        const SizedBox(height: Spacing.xl),
        FButton(
          key: const Key('record-create-save-action'),
          onPress: saving ? null : onSave,
          prefix: saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: FCircularProgress(),
                )
              : null,
          child: Text(l10n.mineEditSaveAction),
        ),
      ],
    );
  }
}
