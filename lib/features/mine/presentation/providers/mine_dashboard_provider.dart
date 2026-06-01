import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/mine/data/repositories/lucent_mine_repository.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/mine_repository.dart';

final mineRepositoryProvider = Provider<MineRepository>((ref) {
  return LucentMineRepository(ref: ref);
});

final mineDashboardProvider = FutureProvider<MineDashboard>((ref) {
  return ref.watch(mineRepositoryProvider).fetchDashboard();
});
