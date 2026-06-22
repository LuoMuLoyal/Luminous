import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';

part 'daily_record_candidates.freezed.dart';

@freezed
abstract class DailyRecordCandidateResult with _$DailyRecordCandidateResult {
  const factory DailyRecordCandidateResult({
    required String locale,
    required String generatedAt,
    required String confirmationHint,
    required List<DailyRecordCandidateItem> items,
  }) = _DailyRecordCandidateResult;
}

@freezed
abstract class DailyRecordCandidateItem with _$DailyRecordCandidateItem {
  const factory DailyRecordCandidateItem({
    required DailyRecordKind kind,
    required String occurredAt,
    String? title,
    String? value,
    String? unit,
    String? note,
    Map<String, dynamic>? payload,
    required String rationale,
  }) = _DailyRecordCandidateItem;
}
