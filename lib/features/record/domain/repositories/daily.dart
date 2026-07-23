import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

abstract class DailyRecordRepository {
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  });
  Future<DailyRecordSummaryData> fetchSummary(String date);
  Future<DailyRecordItem> get(String id);
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  );
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  });
  Future<DailyRecordItem> create(DailyRecordCreateInput input);
  Future<DailyRecordItem> update(String id, DailyRecordUpdateInput input);
  Future<void> delete(String id);
}
