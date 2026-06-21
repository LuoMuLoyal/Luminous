/// Domain-safe enum for daily record kinds (mirrors Lucent DailyRecordKind).
enum DailyRecordKind { water, meal, vital, mood, symptom, activity, note, sleep }

class DailyRecordItem {
  const DailyRecordItem({
    required this.id,
    required this.kind,
    required this.occurredAt,
    this.occurredTime,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.source,
    this.payload,
    this.attachments = const <DailyRecordAttachment>[],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DailyRecordKind kind;
  final String occurredAt;
  final String? occurredTime;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
  final String? source;
  final Map<String, dynamic>? payload;
  final List<DailyRecordAttachment> attachments;
  final String createdAt;
  final String updatedAt;
}

enum DailyRecordAttachmentKind { image }

class DailyRecordAttachment {
  const DailyRecordAttachment({
    required this.id,
    required this.kind,
    required this.objectKey,
    this.bucket,
    this.provider,
    this.fileName,
    this.contentType,
    this.sizeBytes,
    this.width,
    this.height,
    this.publicUrl,
    required this.createdAt,
  });

  final String id;
  final DailyRecordAttachmentKind kind;
  final String objectKey;
  final String? bucket;
  final String? provider;
  final String? fileName;
  final String? contentType;
  final int? sizeBytes;
  final int? width;
  final int? height;
  final String? publicUrl;
  final String createdAt;

  String? get displayUrl {
    final url = publicUrl?.trim();
    return url == null || url.isEmpty ? null : url;
  }
}

class DailyRecordSummary {
  const DailyRecordSummary({
    required this.kind,
    required this.count,
    this.latest,
  });

  final DailyRecordKind kind;
  final num count;
  final DailyRecordItem? latest;
}

class DailyRecordListData {
  const DailyRecordListData({required this.items, required this.total});

  final List<DailyRecordItem> items;
  final num total;
}

class DailyRecordSummaryData {
  const DailyRecordSummaryData({required this.summaries});

  final List<DailyRecordSummary> summaries;
}
