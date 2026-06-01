import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';

final todayDashboardProvider = FutureProvider<TodayDashboard>((ref) {
  return ref.watch(todayRepositoryProvider).fetchDashboard().timeout(const Duration(seconds: 5), onTimeout: () => throw TimeoutException("请求超时，请检查网络后重试。"));
});

