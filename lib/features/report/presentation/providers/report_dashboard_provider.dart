import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';

final reportDashboardProvider = FutureProvider<ReportDashboard>((ref) {
  return ref
      .watch(reportRepositoryProvider)
      .fetchDashboard()
      .timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('report_dashboard_timeout'),
      );
});
