import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/mine/data/providers/repository.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';

final mineDashboardProvider = FutureProvider<MineDashboard>((ref) {
  return authGuarded(
    ref: ref,
    fetch: () => ref.watch(mineRepositoryProvider).fetchDashboard(),
    signedOutFallback: () =>
        ref.watch(mineRepositoryProvider).signedOutDashboard,
  );
});
