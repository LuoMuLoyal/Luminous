import 'package:luminous/features/record/domain/entities/daily_record.dart';

class DailyRecordCandidateResult {
  const DailyRecordCandidateResult({
    required this.locale,
    required this.generatedAt,
    required this.confirmationHint,
    required this.items,
  });

  final String locale;
  final String generatedAt;
  final String confirmationHint;
  final List<DailyRecordCandidateItem> items;

  DailyRecordCandidateResult copyWith({
    String? locale,
    String? generatedAt,
    String? confirmationHint,
    List<DailyRecordCandidateItem>? items,
  }) {
    return DailyRecordCandidateResult(
      locale: locale ?? this.locale,
      generatedAt: generatedAt ?? this.generatedAt,
      confirmationHint: confirmationHint ?? this.confirmationHint,
      items: items ?? this.items,
    );
  }
}

class DailyRecordCandidateItem {
  const DailyRecordCandidateItem({
    required this.kind,
    required this.occurredAt,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.payload,
    required this.rationale,
  });

  final DailyRecordKind kind;
  final String occurredAt;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
  final Map<String, dynamic>? payload;
  final String rationale;
}
