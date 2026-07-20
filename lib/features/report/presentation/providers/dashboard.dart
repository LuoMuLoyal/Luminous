import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/report/data/providers/repository.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard.g.dart';

const _reportDashboardTimeout = Duration(seconds: 5);

/// Caches the last successfully loaded [ReportDashboard] so that switching
/// time ranges can show stale data instead of a full skeleton.
class ReportLastDashboardNotifier extends Notifier<ReportDashboard?> {
  @override
  ReportDashboard? build() => null;

  void set(ReportDashboard dashboard) {
    state = dashboard;
  }
}

final reportLastDashboardProvider =
    NotifierProvider<ReportLastDashboardNotifier, ReportDashboard?>(
      ReportLastDashboardNotifier.new,
    );

@Riverpod(keepAlive: true)
Future<ReportDashboard> reportDashboard(
  Ref ref,
  ReportDashboardQuery query,
) async {
  // Watch cross-feature data change topics.
  ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));

  return authGuarded(
    ref: ref,
    fetch: () => ref
        .watch(reportRepositoryProvider)
        .fetchDashboard(query)
        .timeout(
          _reportDashboardTimeout,
          onTimeout: () => throw TimeoutException('report_dashboard_timeout'),
        ),
    signedOutFallback: () async {
      final repo = ref.watch(reportRepositoryProvider);
      final base = await repo.signedOutDashboard;
      return base.copyWith(
        range: query.range,
        startDate: _dateOnly(
          query.startDate ?? clock.now().subtract(const Duration(days: 7)),
        ),
        endDate: _dateOnly(query.endDate ?? clock.now()),
      );
    },
  );
}

String _dateOnly(DateTime date) {
  final local = date.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

class ReportDashboardSelectedQueryNotifier
    extends Notifier<ReportDashboardQuery> {
  @override
  ReportDashboardQuery build() =>
      const ReportDashboardQuery(range: ReportDashboardRange.last7Days);

  void setQuery(ReportDashboardQuery query) {
    state = query;
  }

  void setRange(ReportDashboardRange range) {
    state = ReportDashboardQuery(range: range);
  }

  void setCustomRange(DateTime startDate, DateTime endDate) {
    state = ReportDashboardQuery(
      range: ReportDashboardRange.custom,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

final reportDashboardSelectedQueryProvider =
    NotifierProvider<
      ReportDashboardSelectedQueryNotifier,
      ReportDashboardQuery
    >(ReportDashboardSelectedQueryNotifier.new);
