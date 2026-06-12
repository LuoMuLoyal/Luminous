import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';

const _reportDashboardTimeout = Duration(seconds: 5);

final reportDashboardProvider = FutureProvider<ReportDashboard>((ref) {
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
      .fetchDashboard()
      .timeout(
        _reportDashboardTimeout,
        onTimeout: () => throw TimeoutException('report_dashboard_timeout'),
      );
});
