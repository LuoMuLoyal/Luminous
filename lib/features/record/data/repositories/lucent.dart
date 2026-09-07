import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/record/data/utils/record_mappers.dart';
import 'package:luminous/features/record/data/utils/record_static_data.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/domain/repositories/record.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';

/// Lucent-backed implementation of [RecordRepository] that maps real daily
/// records into the timeline while keeping other dashboard sections as static
/// mock until their backend APIs exist.
///
/// Repository boundary: the daily-record inputs (timeline records, daily
/// summary) are secondary dashboard signals — their failures degrade to
/// empty and are observed via [appTalker] (product behaviour, same as the
/// today dashboard degrade), never surfaced as a dashboard failure. Only
/// unexpected errors (including a protocol `FormatException` escaping
/// `.run()`) become a Left at this boundary.
class LucentRecordRepository implements RecordRepository {
  LucentRecordRepository({required this.dailyRecordRepo});

  final DailyRecordRepository dailyRecordRepo;

  @override
  TaskEither<LucentFailure, RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) {
    return TaskEither.tryCatch(() async {
      final date = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final dateStr = formatRecordDate(date);
      final selectedKind = filterType == null
          ? null
          : dailyRecordKindForEntryType(filterType);
      final kind = selectedKind?.name;

      // Kick off the records and summary fetches in parallel: create both
      // futures before awaiting either so the requests overlap. Each fetch is
      // independently guarded — a summary failure degrades to an empty grid
      // without affecting the timeline, mirroring the records failure path.
      final recordsFuture = () async {
        if (filterType != null &&
            (selectedKind == null || !isActiveRecordEntryType(filterType))) {
          return <DailyRecordItem>[];
        }
        final result = await dailyRecordRepo
            .fetchRecords(dateStr, kind: kind, pageSize: 100)
            .run();
        return result.fold(
          (failure) {
            appTalker.error(
              'LucentRecordRepository: fetchRecords failed: $failure',
            );
            return <DailyRecordItem>[];
          },
          (data) => data.items
              .where((record) {
                final type = recordEntryTypeForDailyRecordKind(record.kind);
                return isActiveRecordEntryType(type);
              })
              .toList(growable: false),
        );
      }();

      final summaryFuture = () async {
        final result = await dailyRecordRepo.fetchSummary(dateStr).run();
        return result.fold((failure) {
          appTalker.error(
            'LucentRecordRepository: fetchSummary failed: $failure',
          );
          return const DailyRecordSummaryData(summaries: []);
        }, (summary) => summary);
      }();

      final records = await recordsFuture;
      final summaryData = await summaryFuture;

      final sortedRecords = List<DailyRecordItem>.from(records)
        ..sort((a, b) {
          final ta = a.occurredTime ?? a.occurredAt;
          final tb = b.occurredTime ?? b.occurredAt;
          return tb.compareTo(ta);
        });
      final timeline = sortedRecords.map(toTimelineEntry).toList();

      return RecordDashboard(
        selectedDate: date,
        selectedDay: date.day,
        monthDays: staticMonthDays(date),
        quickActions: filteredQuickActions(),
        summary: toDaySummary(summaryData, records),
        filters: filteredFilters(filterType),
        timeline: timeline,
        trends: staticTrends,
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) => Future.value(RecordDashboard.signedOut(selectedDate));
}
