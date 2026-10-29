import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/dashboard_view_assembler.dart';
import 'package:luminous/features/record/presentation/mappers/dashboard_static_data.dart';
import 'package:luminous/features/record/presentation/mappers/record_view_mappers.dart';

/// Application-layer implementation of [RecordDashboardViewAssembler].
///
/// Owns the view-model mapping (design tokens + copy keys) so the data layer
/// can build the dashboard without importing `application/` or `core/design`.
final class RecordDashboardAssembler implements RecordDashboardViewAssembler {
  const RecordDashboardAssembler();

  @override
  List<RecordCalendarDay> monthDays(DateTime selectedDate) =>
      staticMonthDays(selectedDate);

  @override
  List<RecordQuickAction> quickActions() => filteredQuickActions();

  @override
  List<RecordFilter> filters(RecordEntryType? filterType) =>
      filteredFilters(filterType);

  @override
  List<RecordTrend> trends() => staticTrends;

  @override
  RecordDaySummary daySummary(
    DailyRecordSummaryData data,
    List<DailyRecordItem> records,
  ) => toDaySummary(data, records);

  @override
  RecordTimelineEntry timelineEntry(DailyRecordItem record) =>
      toTimelineEntry(record);
}
