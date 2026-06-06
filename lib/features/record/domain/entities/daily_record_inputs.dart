import 'package:luminous/features/record/domain/entities/daily_record.dart';

/// Sentinel for optional update fields — omit to leave unchanged.
const Object dailyRecordNoChange = Object();

class DailyRecordCreateInput {
  const DailyRecordCreateInput({
    required this.kind,
    required this.occurredAt,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.attachments = const <DailyRecordAttachmentInput>[],
  });

  final DailyRecordKind kind;
  final String occurredAt;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
  final List<DailyRecordAttachmentInput> attachments;
}

class DailyRecordUpdateInput {
  const DailyRecordUpdateInput({
    this.kind = dailyRecordNoChange,
    this.occurredAt = dailyRecordNoChange,
    this.title = dailyRecordNoChange,
    this.value = dailyRecordNoChange,
    this.unit = dailyRecordNoChange,
    this.note = dailyRecordNoChange,
    this.attachments = dailyRecordNoChange,
  });

  final Object? kind;
  final Object? occurredAt;
  final Object? title;
  final Object? value;
  final Object? unit;
  final Object? note;

  /// Attachment PATCH semantics:
  /// - [dailyRecordNoChange]: omit field and keep existing attachments.
  /// - empty list: send [] and clear attachments.
  /// - non-empty list: replace attachments with the given metadata list.
  final Object? attachments;
}

class DailyRecordAttachmentInput {
  const DailyRecordAttachmentInput({
    required this.objectKey,
    this.bucket,
    this.provider,
    this.fileName,
    this.contentType,
    this.sizeBytes,
    this.width,
    this.height,
    this.publicUrl,
  });

  final String objectKey;
  final String? bucket;
  final String? provider;
  final String? fileName;
  final String? contentType;
  final int? sizeBytes;
  final int? width;
  final int? height;
  final String? publicUrl;
}

class DailyRecordImageUploadInput {
  const DailyRecordImageUploadInput({
    required this.bytes,
    required this.contentType,
    required this.sizeBytes,
    this.fileName,
  });

  final List<int> bytes;
  final String contentType;
  final int sizeBytes;
  final String? fileName;
}
