import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_record.freezed.dart';

/// Domain-safe enum for daily record kinds (mirrors Lucent DailyRecordKind).
enum DailyRecordKind {
  water,
  meal,
  vital,
  mood,
  symptom,
  activity,
  note,
  sleep,
}

@freezed
abstract class DailyRecordItem with _$DailyRecordItem {
  const factory DailyRecordItem({
    required String id,
    required DailyRecordKind kind,
    required String occurredAt,
    String? occurredTime,
    String? title,
    String? value,
    String? unit,
    String? note,
    String? source,
    Map<String, dynamic>? payload,
    @Default([]) List<DailyRecordAttachment> attachments,
    required String createdAt,
    required String updatedAt,
  }) = _DailyRecordItem;
}

enum DailyRecordAttachmentKind { image }

@freezed
abstract class DailyRecordAttachment with _$DailyRecordAttachment {
  const DailyRecordAttachment._();

  const factory DailyRecordAttachment({
    required String id,
    required DailyRecordAttachmentKind kind,
    required String objectKey,
    String? bucket,
    String? provider,
    String? fileName,
    String? contentType,
    int? sizeBytes,
    int? width,
    int? height,
    String? publicUrl,
    required String createdAt,
  }) = _DailyRecordAttachment;

  String? get displayUrl {
    final url = publicUrl?.trim();
    return url == null || url.isEmpty ? null : url;
  }
}

@freezed
abstract class DailyRecordSummary with _$DailyRecordSummary {
  const factory DailyRecordSummary({
    required DailyRecordKind kind,
    required num count,
    DailyRecordItem? latest,
  }) = _DailyRecordSummary;
}

@freezed
abstract class DailyRecordListData with _$DailyRecordListData {
  const factory DailyRecordListData({
    required List<DailyRecordItem> items,
    required num total,
  }) = _DailyRecordListData;
}

@freezed
abstract class DailyRecordSummaryData with _$DailyRecordSummaryData {
  const factory DailyRecordSummaryData({
    required List<DailyRecordSummary> summaries,
  }) = _DailyRecordSummaryData;
}
