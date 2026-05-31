import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/mine/data/repositories/mock_mine_repository.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';

final mineDashboardProvider = FutureProvider<MineDashboard>((ref) {
  return ref.watch(mineRepositoryProvider).fetchDashboard();
});
