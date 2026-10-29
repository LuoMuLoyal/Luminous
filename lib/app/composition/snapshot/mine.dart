import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/mine/data/repositories/lucent.dart';
import 'package:luminous/features/mine/domain/entities/account.dart';
import 'package:luminous/features/mine/domain/repositories/profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mine.g.dart';

/// Composition-root glue for the mine feature.
///
/// `LucentMineRepository` aggregates the health-context snapshot and the
/// account header. Both are session-aware, so the wiring lives here; the data
/// layer receives them as plain callbacks and keeps no knowledge of `Ref`,
/// `core/auth` or another feature's `data/`.

@riverpod
MineRepository mineRepository(Ref ref) {
  return LucentMineRepository(
    healthContextSnapshot: () => ref.read(healthContextSnapshotProvider.future),
    currentUser: () {
      final user = ref.read(authSessionProvider).user as AuthUser?;
      if (user == null) return null;
      return AccountIdentity(
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        avatar: user.avatar,
        emailVerifiedAt: user.emailVerifiedAt,
        hasPassword: user.hasPassword,
        linkedIdentityCount: user.linkedIdentities.length,
        lastLoginAt: user.lastLoginAt,
      );
    },
    dao: ref.watch(mineDashboardDaoProvider),
  );
}
