import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/core/providers/session/auth_guarded.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_context.g.dart';

/// Health-context snapshot, composed here rather than in
/// `health_context/data/providers/`.
///
/// It needs the cross-feature `dataChangeVersionProvider` and `authGuarded`
/// (session state); the `data/` layer may not import `core/providers`. The data
/// provider file re-exports it so consumers keep their existing imports.
@Riverpod(keepAlive: true)
Future<HealthContextSnapshot> healthContextSnapshot(Ref ref) {
  // Watch cross-feature data change topics.
  ref.watch(dataChangeVersionProvider(DataChangeTopic.healthContext));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.currentMedicines));

  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref
          .watch(healthContextRepositoryProvider)
          .fetchHealthContext()
          .run()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw LucentFailure.network(
              message: NetworkErrorCode.receiveTimeout.name,
              networkErrorCode: NetworkErrorCode.receiveTimeout,
            ),
          );
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      return result.fold((failure) => throw failure, (snapshot) => snapshot);
    },
  );
}
