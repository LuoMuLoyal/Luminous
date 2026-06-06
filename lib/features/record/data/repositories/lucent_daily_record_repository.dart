import 'package:luminous/features/record/data/datasources/daily_record_remote_data_source.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';

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
