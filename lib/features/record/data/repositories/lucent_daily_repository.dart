import 'package:luminous/features/record/data/datasources/remote_data_source.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/repositories/daily_repository.dart';

class LucentDailyRecordRepository implements DailyRecordRepository {
  LucentDailyRecordRepository({required this.dataSource});

  final DailyRecordRemoteDataSource dataSource;

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) {
    return dataSource.fetchRecords(
      date,
      kind: kind,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) {
    return dataSource.fetchSummary(date);
  }

  @override
  Future<DailyRecordItem> get(String id) {
    return dataSource.get(id);
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) {
    return dataSource.uploadImage(input);
  }

  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) {
    return dataSource.generateCandidates(text: text, occurredAt: occurredAt);
  }

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) {
    return dataSource.create(input);
  }

  @override
  Future<DailyRecordItem> update(String id, DailyRecordUpdateInput input) {
    return dataSource.update(id, input);
  }

  @override
  Future<void> delete(String id) {
    return dataSource.delete(id);
  }
}
