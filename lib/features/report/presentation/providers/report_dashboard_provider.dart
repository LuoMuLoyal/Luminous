import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';

class ReportDashboardNotifier extends Notifier<AsyncValue<ReportDashboard>> {
  @override
  AsyncValue<ReportDashboard> build() {
    return const AsyncData(MockReportRepository.dashboard);
  }

  Future<void> sync() async {
    state = const AsyncLoading<ReportDashboard>();
    state = await AsyncValue.guard(
      () => ref
          .read(reportRepositoryProvider)
          .fetchDashboard()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException(
              'report_dashboard_timeout',
            ),
          ),
    );
  }
}

final reportDashboardProvider =
    NotifierProvider<
      ReportDashboardNotifier,
      AsyncValue<ReportDashboard>
    >(ReportDashboardNotifier.new);
