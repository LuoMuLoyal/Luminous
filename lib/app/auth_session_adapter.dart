import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:fpdart/fpdart.dart';
import 'package:luminous/app/composition/auth/auth.dart';
import 'package:luminous/app/push_handlers.dart';
import 'package:luminous/app/settings_adapters.dart';
import 'package:luminous/app/sync_handlers.dart';
import 'package:luminous/core/auth/session_gateway.dart';
import 'package:luminous/core/auth/session_snapshot.dart';
import 'package:luminous/core/database/sync/handlers.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/repositories/auth.dart';
import 'package:luminous/shared/domain/failure.dart';

export 'package:luminous/app/auth_session_adapter.dart';
export 'package:luminous/core/auth/session_provider.dart';

// The app-side auth API (gateway override, snapshot adapters, and the typed
// `AuthSessionState.user` accessor) is re-exported so feature code has a single
// import and never needs to know which side of the core/feature seam a piece
// lives on.

/// Composition-root adapter between feature-owned auth entities and the
/// feature-free `SessionSnapshot` value types that `lib/core/auth` consumes.
extension AuthUserSnapshotX on AuthUser {
  SessionUserSnapshot toSessionSnapshot() => SessionUserSnapshot(
    id: id,
    email: email,
    nickname: nickname,
    avatar: avatar,
    emailVerifiedAt: emailVerifiedAt,
    hasPassword: hasPassword,
    lastLoginAt: lastLoginAt,
    linkedIdentities: linkedIdentities
        .map(
          (identity) => SessionLinkedIdentity(
            id: identity.id,
            provider: identity.provider,
            email: identity.email,
            emailVerifiedAt: identity.emailVerifiedAt,
            linkedAt: identity.linkedAt,
          ),
        )
        .toList(growable: false),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension AuthSessionSnapshotX on AuthSession {
  SessionSnapshot toSessionSnapshot() =>
      SessionSnapshot(user: user.toSessionSnapshot());
}

/// [AuthSessionGateway] backed by the feature auth repository.
///
/// Only `lib/app/` may see both sides; `lib/core/auth` talks to the interface,
/// so `core_not_import_features` stays clean without touching feature code.
class FeatureAuthSessionGateway implements AuthSessionGateway {
  const FeatureAuthSessionGateway(this._repository);

  final AuthRepository _repository;

  @override
  TaskEither<LucentFailure, SessionUserSnapshot> fetchAccount() =>
      _repository.fetchAccount().map((user) => user.toSessionSnapshot());

  @override
  TaskEither<LucentFailure, SessionSnapshot> refreshSession({
    required String refreshToken,
  }) => _repository
      .refreshSession(refreshToken: refreshToken)
      .map((session) => session.toSessionSnapshot());

  @override
  TaskEither<LucentFailure, void> logout() => _repository.logout();
}

/// Overrides for the root [ProviderScope]: binds the feature-backed adapter to
/// every feature-free core seam.
///
/// `lib/app/` is the composition root, so it is the only layer allowed to see
/// both `lib/core` interfaces and their `lib/features` implementations.
List<Override> appProviderOverrides(ProviderContainer container) => [
  authSessionGatewayProvider.overrideWithValue(
    FeatureAuthSessionGateway(container.read(authRepositoryProvider)),
  ),
  syncHandlerRegistrarsProvider.overrideWithValue(appSyncHandlerRegistrars),
  ...pushProviderOverrides(container),
  ...settingsProviderOverrides(container),
];
