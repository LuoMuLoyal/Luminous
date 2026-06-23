import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';

part 'daily_record_inputs.freezed.dart';

/// Sentinel for optional update fields — omit to leave unchanged.
const Object dailyRecordNoChange = Object();

@freezed
abstract class DailyRecordCreateInput with _$DailyRecordCreateInput {
  const factory DailyRecordCreateInput({
    required DailyRecordKind kind,
    required String occurredAt,
    String? occurredTime,
    String? title,
    String? value,
    String? unit,
    String? note,
    Map<String, dynamic>? payload,
    @Default([]) List<DailyRecordAttachmentInput> attachments,
  }) = _DailyRecordCreateInput;
}

@freezed
abstract class DailyRecordUpdateInput with _$DailyRecordUpdateInput {
  const factory DailyRecordUpdateInput({
    @Default(dailyRecordNoChange) Object? kind,
    @Default(dailyRecordNoChange) Object? occurredAt,
    @Default(dailyRecordNoChange) Object? occurredTime,
    @Default(dailyRecordNoChange) Object? title,
    @Default(dailyRecordNoChange) Object? value,
    @Default(dailyRecordNoChange) Object? unit,
    @Default(dailyRecordNoChange) Object? note,
    @Default(dailyRecordNoChange) Object? payload,

    /// Attachment PATCH semantics:
    /// - [dailyRecordNoChange]: omit field and keep existing attachments.
    /// - empty list: send [] and clear attachments.
    /// - non-empty list: replace attachments with the given metadata list.
    @Default(dailyRecordNoChange) Object? attachments,
  }) = _DailyRecordUpdateInput;
}

@freezed
abstract class DailyRecordAttachmentInput with _$DailyRecordAttachmentInput {
  const factory DailyRecordAttachmentInput({
    required String objectKey,
    String? bucket,
    String? provider,
    String? fileName,
    String? contentType,
    int? sizeBytes,
    int? width,
    int? height,
    String? publicUrl,
  }) = _DailyRecordAttachmentInput;
}

@freezed
abstract class DailyRecordImageUploadInput with _$DailyRecordImageUploadInput {
  const factory DailyRecordImageUploadInput({
    required List<int> bytes,
    required String contentType,
    required int sizeBytes,
    String? fileName,
  }) = _DailyRecordImageUploadInput;
}
