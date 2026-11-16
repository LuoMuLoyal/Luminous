import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:fpdart/fpdart.dart';
import 'package:luminous/app/composition/auth/auth.dart';
import 'package:luminous/app/composition/components/registry.dart';
import 'package:luminous/app/push_handlers.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/app/settings_adapters.dart';
import 'package:luminous/app/sync_handlers.dart';
import 'package:luminous/core/auth/session_gateway.dart';
import 'package:luminous/core/auth/session_mapping.dart';
import 'package:luminous/core/auth/session_snapshot.dart';
import 'package:luminous/core/database/sync/handlers.dart';
import 'package:luminous/core/push/message_handler.dart'
    show pushNavigateProvider;
import 'package:luminous/features/auth/domain/repositories/auth.dart';
import 'package:luminous/shared/domain/failure.dart';

export 'package:luminous/core/auth/session_mapping.dart';
export 'package:luminous/core/auth/session_provider.dart';

// The app-side auth API (gateway override, snapshot adapters, and the typed
// `AuthSessionState.user` accessor) is re-exported so feature code has a single
// import and never needs to know which side of the core/feature seam a piece
// lives on.

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
///
/// **Must be passed to `ProviderContainer(overrides: ...)`**, not applied to an
/// already-created container: Riverpod 3's `updateOverrides` may only *replace*
/// the overrides a container was built with (adding one trips
/// `_debugOverridesLength == overrides.length`), so a container created bare
/// can never receive them afterwards.
List<Override> appProviderOverrides(ProviderContainer container) => [
  authSessionGatewayProvider.overrideWithValue(
    FeatureAuthSessionGateway(container.read(authRepositoryProvider)),
  ),
  syncHandlerRegistrarsProvider.overrideWithValue(appSyncHandlerRegistrars),
  ...pushProviderOverrides(container),
  // `core/push` 声明一个空的跳转动作，真正的路由跳转在这里接上。
  pushNavigateProvider.overrideWithValue(
    (route) => container.read(appRouterProvider).go(route),
  ),
  ...settingsProviderOverrides(container),
  ...compositionProviderOverrides(),
];

/// Builds the root container with [appProviderOverrides] already installed.
///
/// The container is needed to assemble the overrides (`container.read(A)` feeds
/// an override of `B`) while the overrides must exist at construction time.
/// The resolution: a bare throw-away container supplies the read side, and the
/// real one is created with the resulting list. Both see the same code, so the
/// only state that matters — the provider instances — is identical.
ProviderContainer buildRootContainer() {
  final probe = ProviderContainer();
  final overrides = appProviderOverrides(probe);
  probe.dispose();
  return ProviderContainer(overrides: overrides);
}
