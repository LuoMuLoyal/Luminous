import 'dart:typed_data';

import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';
import 'package:luminous/features/record/presentation/quick_entry/flows/water_quick_entry.dart';

typedef PickMealQuickImage =
    Future<MealQuickImage?> Function(MealQuickImageSource source);
typedef UploadMealQuickImage =
    Future<DailyRecordAttachmentInput> Function(
      DailyRecordImageUploadInput input,
    );

enum MealQuickImageSource { camera, gallery }

class MealQuickImageUnsupportedException implements Exception {
  const MealQuickImageUnsupportedException();

  @override
  String toString() => 'MealQuickImageUnsupportedException';
}

/// Thrown by [MealQuickEntryFlow.saveDraft] when the draft carries no content
/// at all (no title / value / note / image): an empty meal record must never be
/// written. Callers surface it as a "fill something in" toast
/// (`recordQuickMealEmptyToast`) — it is a UI guard for a user input problem,
/// not a failure channel, so it stays a dedicated exception the dialog catches
/// instead of a `LucentFailure`.
class MealQuickEntryEmptyException implements Exception {
  const MealQuickEntryEmptyException();

  @override
  String toString() => 'MealQuickEntryEmptyException';
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
  final EmitDataChangeTopic emitDataChange;

  /// Opens the camera and returns the confirmed draft, or a cancelled outcome
  /// when nothing was picked.
  ///
  /// [pickImage] is the platform edge: its implementation belongs to the
  /// picker's caller (`meal_flow.dart`), which reports a content type the
  /// upload cannot take by throwing [MealQuickImageUnsupportedException] — the
  /// picker's `null` means "user cancelled", so the refusal needs its own
  /// value. The page maps it to `recordImageUnsupportedToast`.
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
    final title = _optional(draft.title);
    final value = _optional(draft.value);
    final note = _optional(draft.note);
    // 无任何有意义内容的空餐食记录不允许落库（UI 侧同时禁用提交按钮，
    // 这里是领域侧的第二道闸）。
    if (title == null && value == null && note == null && draft.image == null) {
      throw const MealQuickEntryEmptyException();
    }

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
        title: title,
        value: value,
        note: note,
        attachments: attachments,
      ),
    );
    emitDataChange(QuickEntryDataChange.dailyRecords);
    return item;
  }

  String? _optional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
