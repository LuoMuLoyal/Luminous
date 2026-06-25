import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';

const _reportDashboardTimeout = Duration(seconds: 5);

final reportDashboardProvider =
    FutureProvider.family<ReportDashboard, ReportDashboardRange>((ref, range) {
      final session = ref.watch(authSessionProvider);
      if (session.isConfirmedSignedOut) {
        return Future.value(MockReportRepository.signedOutDashboard);
      }
      if (session.isLoading) {
        return pendingAuthSessionResolution<ReportDashboard>();
      }
      if (!session.canAccessProtectedData) {
        return pendingAuthSessionResolution<ReportDashboard>();
      }

      return ref
          .watch(reportRepositoryProvider)
          .fetchDashboard(range)
          .timeout(
            _reportDashboardTimeout,
            onTimeout: () => throw TimeoutException('report_dashboard_timeout'),
          );
    });

class ReportDashboardSelectedRangeNotifier
    extends Notifier<ReportDashboardRange> {
  @override
  ReportDashboardRange build() => ReportDashboardRange.last7Days;

  void setRange(ReportDashboardRange range) {
    state = range;
  }
}

final reportDashboardSelectedRangeProvider =
    NotifierProvider<
      ReportDashboardSelectedRangeNotifier,
      ReportDashboardRange
    >(ReportDashboardSelectedRangeNotifier.new);
