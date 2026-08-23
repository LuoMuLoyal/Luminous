import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/mine/data/providers/mine.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard.g.dart';

@Riverpod(keepAlive: true)
Future<MineDashboard> mineDashboard(Ref ref) {
  // Watch cross-feature data change topics.
  ref.watch(dataChangeVersionProvider(DataChangeTopic.healthContext));

  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref
          .watch(mineRepositoryProvider)
          .fetchDashboard()
          .run();
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      return result.fold((failure) => throw failure, (dashboard) => dashboard);
    },
    signedOutFallback: () =>
        ref.watch(mineRepositoryProvider).signedOutDashboard,
  );
}
