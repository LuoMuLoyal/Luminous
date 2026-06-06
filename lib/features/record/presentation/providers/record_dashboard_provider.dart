import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

final recordDashboardProvider = FutureProvider<RecordDashboard>((ref) {
  final session = ref.watch(authSessionProvider);
  if (!session.isAuthenticated) {
    return const MockRecordRepository().fetchDashboard();
  }

  return ref
      .watch(recordRepositoryProvider)
      .fetchDashboard()
      .timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException("请求超时，请检查网络后重试。"),
      );
});
