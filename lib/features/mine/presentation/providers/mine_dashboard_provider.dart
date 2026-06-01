import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:luminous/features/mine/data/repositories/lucent_mine_repository.dart';
import 'package:luminous/features/mine/data/repositories/mock_mine_repository.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/mine_repository.dart';

final mineRepositoryProvider = Provider<MineRepository>((ref) {
  return LucentMineRepository(ref: ref);
});

final mineDashboardProvider = FutureProvider<MineDashboard>((ref) {
  final authSession = ref.watch(authSessionProvider);
  if (!authSession.isAuthenticated) {
    return Future.value(MockMineRepository.signedOutDashboard);
  }

  return ref
      .watch(mineRepositoryProvider)
      .fetchDashboard()
      .timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException("请求超时，请检查网络后重试。"),
      );
});
