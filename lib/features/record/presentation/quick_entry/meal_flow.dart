import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/utils/image_compressor.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/application/usecases/water_quick_entry.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/pages/create.dart';

typedef PickMealQuickImage =
    Future<MealQuickImage?> Function(MealQuickImageSource source);
typedef UploadMealQuickImage =
    Future<DailyRecordAttachmentInput> Function(
      DailyRecordImageUploadInput input,
    );

final mealQuickImagePickerProvider = Provider<PickMealQuickImage>((ref) {
  final picker = ImagePicker();
  return (source) async {
    final image = await picker.pickImage(
      source: switch (source) {
        MealQuickImageSource.camera => ImageSource.camera,
        MealQuickImageSource.gallery => ImageSource.gallery,
      },
      requestFullMetadata: false,
    );
    if (image == null) return null;

    final contentType = RecordCreatePage.resolveImageContentType(image);
    if (contentType == null) {
      throw const MealQuickImageUnsupportedException();
    }

    final rawBytes = await image.readAsBytes();
    final compressedBytes = await ImageCompressor.compressForUpload(rawBytes);
    return MealQuickImage(
      bytes: compressedBytes,
      fileName: image.name,
      contentType: 'image/jpeg',
    );
  };
});

enum MealQuickImageSource { camera, gallery }

class MealQuickImageUnsupportedException implements Exception {
  const MealQuickImageUnsupportedException();
}

class MealQuickImage {
  const MealQuickImage({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
}

class MealQuickEntryContext extends QuickEntryRecordContext {
  const MealQuickEntryContext({
    required super.occurredAt,
    required super.occurredTime,
    this.defaultTitle,
  });

  final String? defaultTitle;
}

class MealQuickEntryDraft {
  const MealQuickEntryDraft({
    required this.occurredAt,
    required this.occurredTime,
    this.title,
    this.value,
    this.note,
    this.image,
  });

  final String occurredAt;
  final String occurredTime;
  final String? title;
  final String? value;
  final String? note;
  final MealQuickImage? image;

  MealQuickEntryDraft copyWith({
    String? title,
    String? value,
    String? note,
    MealQuickImage? image,
  }) {
    return MealQuickEntryDraft(
      occurredAt: occurredAt,
      occurredTime: occurredTime,
      title: title ?? this.title,
      value: value ?? this.value,
      note: note ?? this.note,
      image: image ?? this.image,
    );
  }
}

enum MealQuickEntryOutcomeType { cancelled, needsConfirmation }

class MealQuickEntryOutcome {
  const MealQuickEntryOutcome._({required this.type, this.draft});

  const MealQuickEntryOutcome.cancelled()
    : this._(type: MealQuickEntryOutcomeType.cancelled);

  const MealQuickEntryOutcome.needsConfirmation(MealQuickEntryDraft draft)
    : this._(type: MealQuickEntryOutcomeType.needsConfirmation, draft: draft);

  final MealQuickEntryOutcomeType type;
  final MealQuickEntryDraft? draft;
}

class MealQuickEntryFlow {
  const MealQuickEntryFlow({
    required this.pickImage,
    required this.uploadImage,
    required this.createRecord,
    required this.emitDataChange,
  });

  final PickMealQuickImage pickImage;
  final UploadMealQuickImage uploadImage;
  final CreateDailyRecord createRecord;
  final EmitDataChange emitDataChange;

  Future<MealQuickEntryOutcome> startWithCamera(
    MealQuickEntryContext context,
  ) async {
    final image = await pickImage(MealQuickImageSource.camera);
    if (image == null) return const MealQuickEntryOutcome.cancelled();
    return MealQuickEntryOutcome.needsConfirmation(
      MealQuickEntryDraft(
        occurredAt: context.occurredAt,
        occurredTime: context.occurredTime,
        title: context.defaultTitle,
        image: image,
      ),
    );
  }

  MealQuickEntryDraft buildManualDraft(MealQuickEntryContext context) {
    return MealQuickEntryDraft(
      occurredAt: context.occurredAt,
      occurredTime: context.occurredTime,
      title: context.defaultTitle,
    );
  }

  Future<DailyRecordItem> saveDraft(MealQuickEntryDraft draft) async {
    final attachments = <DailyRecordAttachmentInput>[];
    final image = draft.image;
    if (image != null) {
      attachments.add(
        await uploadImage(
          DailyRecordImageUploadInput(
            bytes: image.bytes,
            contentType: image.contentType,
            sizeBytes: image.bytes.length,
            fileName: image.fileName,
          ),
        ),
      );
    }

    final item = await createRecord(
      DailyRecordCreateInput(
        kind: DailyRecordKind.meal,
        occurredAt: draft.occurredAt,
        occurredTime: draft.occurredTime,
        title: _optional(draft.title),
        value: _optional(draft.value),
        note: _optional(draft.note),
        attachments: attachments,
      ),
    );
    emitDataChange(DataChangeTopic.dailyRecords);
    return item;
  }

  String? _optional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
