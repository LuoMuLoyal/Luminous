import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:luminous/features/more/data/repositories/mock_more_repository.dart';
import 'package:luminous/features/more/domain/entities/more_dashboard.dart';

final moreDashboardProvider = FutureProvider<MoreDashboard>((ref) {
  return ref.watch(moreRepositoryProvider).fetchDashboard().timeout(const Duration(seconds: 5), onTimeout: () => throw TimeoutException("请求超时，请检查网络后重试。"));
});

