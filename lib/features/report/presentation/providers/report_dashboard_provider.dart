import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';

const _reportDashboardTimeout = Duration(seconds: 5);

final reportDashboardProvider =
    FutureProvider.family<ReportDashboard, ReportDashboardQuery>((ref, query) {
      final session = ref.watch(authSessionProvider);
      if (session.isConfirmedSignedOut) {
        return Future.value(
          MockReportRepository.signedOutDashboard.copyWith(
            range: query.range,
            startDate: _dateOnly(query.startDate ?? DateTime(2026, 6, 6)),
            endDate: _dateOnly(query.endDate ?? DateTime(2026, 6, 12)),
          ),
        );
      }
      if (session.isLoading) {
        return pendingAuthSessionResolution<ReportDashboard>();
      }
      if (!session.canAccessProtectedData) {
        return pendingAuthSessionResolution<ReportDashboard>();
      }

      return ref
          .watch(reportRepositoryProvider)
          .fetchDashboard(query)
          .timeout(
            _reportDashboardTimeout,
            onTimeout: () => throw TimeoutException('report_dashboard_timeout'),
          );
    });

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
