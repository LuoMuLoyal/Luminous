// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/app.dart';
import 'package:luminous/app/router.dart' show router;
import 'package:luminous/core/network/network_providers.dart'
    show lucentBaseUrlProvider, lucentSessionStoreProvider;
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Patrol-based smoke test.
///
/// Run with:
/// ```bash
/// dart pub global run patrol_cli:main test \
///   --target integration_test/patrol/app_smoke_patrol_test.dart \
///   --device emulator-5554
/// ```
///
/// Patrol advantages over plain `integration_test`:
/// - Native system dialog handling (permissions, location, etc.)
/// - `$(Selector)` syntax for more resilient selectors
/// - `$.native` for interacting with native UI outside Flutter
/// - Built-in retry logic for flaky operations
void main() {
  patrolTest('app smoke: renders shell with all five tabs', ($) async {
    // Reset state before launch.
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    router.go('/');

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(_NoopAuthSessionNotifier.new),
        lucentBaseUrlProvider.overrideWithValue('http://localhost'),
        lucentSessionStoreProvider.overrideWithValue(_MemorySessionStore()),
      ],
    );
    addTearDown(container.dispose);

    await $.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LuminousApp(),
      ),
    );
    await $.pumpAndSettle();

    // Verify all five tab keys are visible.
    expect($(const Key('shell-tab-today')).exists, true);
    expect($(const Key('shell-tab-record')).exists, true);
    expect($(const Key('shell-tab-medicine')).exists, true);
    expect($(const Key('shell-tab-report')).exists, true);
    expect($(const Key('shell-tab-mine')).exists, true);

    // Navigate through tabs.
    await $(const Key('shell-tab-record')).tap();
    await $.pumpAndSettle();

    await $(const Key('shell-tab-medicine')).tap();
    await $.pumpAndSettle();

    await $(const Key('shell-tab-report')).tap();
    await $.pumpAndSettle();

    await $(const Key('shell-tab-mine')).tap();
    await $.pumpAndSettle();

    // Return to today.
    await $(const Key('shell-tab-today')).tap();
    await $.pumpAndSettle();

    print('Patrol smoke test passed — all tabs navigable.');
  });
}

class _NoopAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();

  @override
  Future<void> restore() async {}
}

class _MemorySessionStore implements LucentSessionStore {
  LucentSessionTokens? tokens;

  @override
  Future<void> clear() async => tokens = null;

  @override
  Future<LucentSessionTokens?> read() async => tokens;

  @override
  Future<String?> readAccessToken() async => tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => tokens?.refreshToken;

  @override
  Future<void> write(LucentSessionTokens tokens) async => this.tokens = tokens;
}
