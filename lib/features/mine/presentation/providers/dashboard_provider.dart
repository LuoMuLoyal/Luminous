import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/mine/data/repositories/lucent_repository.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/repository.dart';

final mineRepositoryProvider = Provider<MineRepository>((ref) {
  return LucentMineRepository(ref);
});

final mineDashboardProvider = FutureProvider<MineDashboard>((ref) {
  final authSession = ref.watch(authSessionProvider);
  if (authSession.isConfirmedSignedOut) {
    return ref.watch(mineRepositoryProvider).signedOutDashboard;
  }
  if (!authSession.canAccessProtectedData) {
    return pendingAuthSessionResolution();
  }

  return ref.watch(mineRepositoryProvider).fetchDashboard();
});
