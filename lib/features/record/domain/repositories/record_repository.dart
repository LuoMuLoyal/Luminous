import 'package:luminous/features/record/domain/entities/record_dashboard.dart';

abstract interface class RecordRepository {
  Future<RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  });
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  });
}
