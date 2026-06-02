import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/app.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

void main() {
  testWidgets('App restores auth session on startup', (tester) async {
    final notifier = _TrackingAuthSessionNotifier();
    final container = ProviderContainer(
      overrides: [authSessionProvider.overrideWith(() => notifier)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: LuminousApp(routerConfig: _testRouter),
      ),
    );

    await tester.pump();

    expect(notifier.restoreCalled, isTrue);
    expect(find.text('app-home'), findsOneWidget);
  });

  testWidgets('App should render', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _NoopRestoreAuthSessionNotifier(),
          ),
        ],
        child: LuminousApp(routerConfig: _testRouter),
      ),
    );
    await tester.pump();
    expect(find.text('app-home'), findsOneWidget);
  });
}

class _TrackingAuthSessionNotifier extends AuthSessionNotifier {
  bool restoreCalled = false;

  @override
  Future<void> restore() async {
    restoreCalled = true;
  }
}

class _NoopRestoreAuthSessionNotifier extends AuthSessionNotifier {
  @override
  Future<void> restore() async {}
}

final _testRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(body: Text('app-home')),
    ),
  ],
);
