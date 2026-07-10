import 'dart:convert';

import 'package:luminous/features/record/domain/entities/record.dart';

/// Manual JSON serialization for [DailyRecordItem] and related types.
///
/// These entities use `@freezed` without `json_serializable`, so we
/// provide explicit to/from JSON helpers for the cache layer.
class DailyRecordJsonCodec {
  static String itemToJson(DailyRecordItem item) {
    return jsonEncode({
      'id': item.id,
      'kind': item.kind.name,
      'occurredAt': item.occurredAt,
      'occurredTime': item.occurredTime,
      'title': item.title,
      'value': item.value,
      'unit': item.unit,
      'note': item.note,
      'source': item.source,
      'payload': item.payload,
      'mealAnalysisStatus': item.mealAnalysisStatus,
      'mealAnalysisCoverage': item.mealAnalysisCoverage,
      'mealAnalysisUpdatedAt': item.mealAnalysisUpdatedAt,
      'mealAnalysisFailureReason': item.mealAnalysisFailureReason,
      'mealShortDescription': item.mealShortDescription,
      'mealTopFoods': item.mealTopFoods,
      'attachments': item.attachments.map(_attachmentToJson).toList(),
      'createdAt': item.createdAt,
      'updatedAt': item.updatedAt,
    });
  }

  static DailyRecordItem itemFromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return DailyRecordItem(
      id: map['id'] as String,
      kind: DailyRecordKind.values.firstWhere(
        (k) => k.name == map['kind'],
        orElse: () => DailyRecordKind.note,
      ),
      occurredAt: map['occurredAt'] as String,
      occurredTime: map['occurredTime'] as String?,
      title: map['title'] as String?,
      value: map['value'] as String?,
      unit: map['unit'] as String?,
      note: map['note'] as String?,
      source: map['source'] as String?,
      payload: map['payload'] as Map<String, dynamic>?,
      mealAnalysisStatus: map['mealAnalysisStatus'] as String?,
      mealAnalysisCoverage: map['mealAnalysisCoverage'] as String?,
      mealAnalysisUpdatedAt: map['mealAnalysisUpdatedAt'] as String?,
      mealAnalysisFailureReason: map['mealAnalysisFailureReason'] as String?,
      mealShortDescription: map['mealShortDescription'] as String?,
      mealTopFoods:
          (map['mealTopFoods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      attachments:
          (map['attachments'] as List<dynamic>?)
              ?.map((e) => _attachmentFromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DailyRecordAttachment>[],
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  static Map<String, dynamic> _attachmentToJson(DailyRecordAttachment a) {
    return {
      'id': a.id,
      'kind': a.kind.name,
      'objectKey': a.objectKey,
      'bucket': a.bucket,
      'provider': a.provider,
      'fileName': a.fileName,
      'contentType': a.contentType,
      'sizeBytes': a.sizeBytes,
      'width': a.width,
      'height': a.height,
      'publicUrl': a.publicUrl,
      'createdAt': a.createdAt,
    };
  }

  static DailyRecordAttachment _attachmentFromJson(Map<String, dynamic> map) {
    return DailyRecordAttachment(
      id: map['id'] as String,
      kind: DailyRecordAttachmentKind.values.firstWhere(
        (k) => k.name == map['kind'],
        orElse: () => DailyRecordAttachmentKind.image,
      ),
      objectKey: map['objectKey'] as String,
      bucket: map['bucket'] as String?,
      provider: map['provider'] as String?,
      fileName: map['fileName'] as String?,
      contentType: map['contentType'] as String?,
      sizeBytes: map['sizeBytes'] as int?,
      width: map['width'] as int?,
      height: map['height'] as int?,
      publicUrl: map['publicUrl'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }
}
