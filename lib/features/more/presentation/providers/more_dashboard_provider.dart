import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:luminous/features/more/data/repositories/mock_more_repository.dart';
import 'package:luminous/features/more/domain/entities/more_dashboard.dart';

// TODO(environment): replace the static environment section with Lucent's
// GET /api/v1/environment/snapshot once the backend module exists.
final moreDashboardProvider = FutureProvider<MoreDashboard>((ref) {
  return ref.watch(moreRepositoryProvider).fetchDashboard().timeout(const Duration(seconds: 5), onTimeout: () => throw TimeoutException("请求超时，请检查网络后重试。"));
});

