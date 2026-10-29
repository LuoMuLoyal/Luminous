import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

/// Builds the presentation-shaped sections of the record dashboard.
///
/// Those sections (summary tiles, timeline entries, quick actions, filters,
/// calendar days) carry design tokens (`IconData`, `SemanticColor`) and copy
/// keys, so they are view models owned by the application layer
/// (`application/mappers/`). The data layer only fetches the wire data and
/// receives a builder through this seam — see
/// `recordDashboardViewAssemblerProvider`.
abstract interface class RecordDashboardViewAssembler {
  List<RecordCalendarDay> monthDays(DateTime selectedDate);

  List<RecordQuickAction> quickActions();

  List<RecordFilter> filters(RecordEntryType? filterType);

  List<RecordTrend> trends();

  RecordDaySummary daySummary(
    DailyRecordSummaryData data,
    List<DailyRecordItem> records,
  );

  RecordTimelineEntry timelineEntry(DailyRecordItem record);
}
