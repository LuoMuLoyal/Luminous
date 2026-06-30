import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';

const _todayDashboardTimeout = Duration(seconds: 5);

final todayDashboardProvider = FutureProvider<TodayDashboard>((ref) {
  final session = ref.watch(authSessionProvider);
  if (session.isConfirmedSignedOut) {
    if (kDebugMode) {
      return Future.value(MockTodayRepository.placeholderDashboard);
    }
    return Future.value(TodayDashboard.signedOut());
  }
  if (!session.canAccessProtectedData) {
    return pendingAuthSessionResolution();
  }

  return ref
      .watch(todayRepositoryProvider)
      .fetchDashboard()
      .timeout(
        _todayDashboardTimeout,
        onTimeout: () => throw TimeoutException('today_dashboard_timeout'),
      );
});
