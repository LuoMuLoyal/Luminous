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

  DailyRecordCandidateItem copyWith({
    DailyRecordKind? kind,
    String? occurredAt,
    Object? title = _dailyRecordCandidateNoChange,
    Object? value = _dailyRecordCandidateNoChange,
    Object? unit = _dailyRecordCandidateNoChange,
    Object? note = _dailyRecordCandidateNoChange,
    Object? payload = _dailyRecordCandidateNoChange,
    String? rationale,
  }) {
    return DailyRecordCandidateItem(
      kind: kind ?? this.kind,
      occurredAt: occurredAt ?? this.occurredAt,
      title: identical(title, _dailyRecordCandidateNoChange)
          ? this.title
          : title as String?,
      value: identical(value, _dailyRecordCandidateNoChange)
          ? this.value
          : value as String?,
      unit: identical(unit, _dailyRecordCandidateNoChange)
          ? this.unit
          : unit as String?,
      note: identical(note, _dailyRecordCandidateNoChange)
          ? this.note
          : note as String?,
      payload: identical(payload, _dailyRecordCandidateNoChange)
          ? this.payload
          : payload as Map<String, dynamic>?,
      rationale: rationale ?? this.rationale,
    );
  }
}

const _dailyRecordCandidateNoChange = Object();
