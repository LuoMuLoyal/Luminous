import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

/// Domain interface for reading and writing daily records.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a legal empty page / empty summary stays a
/// Right. A non-`problem+json` or malformed HTTP error body keeps the mapper's
/// `FormatException` (protocol invariant) and propagates directly from
/// `.run()`.
abstract class DailyRecordRepository {
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  });
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date);
  TaskEither<LucentFailure, DailyRecordItem> get(String id);
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  );
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  });
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  );
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  );
  TaskEither<LucentFailure, void> delete(String id);
}
