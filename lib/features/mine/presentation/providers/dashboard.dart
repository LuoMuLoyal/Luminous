import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/mine/data/repositories/lucent_repository.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard.g.dart';

@riverpod
MineRepository mineRepository(Ref ref) {
  return LucentMineRepository(ref);
}

final mineDashboardProvider = FutureProvider<MineDashboard>((ref) {
  return authGuarded(
    ref: ref,
    fetch: () => ref.watch(mineRepositoryProvider).fetchDashboard(),
    signedOutFallback: () =>
        ref.watch(mineRepositoryProvider).signedOutDashboard,
  );
});
