/// Domain-safe enum for daily record kinds (mirrors Lucent DailyRecordKind).
enum DailyRecordKind {
  water,
  meal,
  vital,
  mood,
  symptom,
  activity,
  note;
}

class DailyRecordItem {
  const DailyRecordItem({
    required this.id,
    required this.kind,
    required this.occurredAt,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DailyRecordKind kind;
  final String occurredAt;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
  final String? source;
  final String createdAt;
  final String updatedAt;
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
  const DailyRecordListData({
    required this.items,
    required this.total,
  });

  final List<DailyRecordItem> items;
  final num total;
}

class DailyRecordSummaryData {
  const DailyRecordSummaryData({required this.summaries});

  final List<DailyRecordSummary> summaries;
}
