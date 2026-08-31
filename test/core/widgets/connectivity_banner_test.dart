import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/widgets/common/feedback/connectivity_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

/// A fake [AuthSessionNotifier] that starts in a non-timeout state.
class _NormalAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() =>
      const AuthSessionState(isAuthenticated: true, isLoading: false);
}

/// A fake [AuthSessionNotifier] that starts in a timeout state.
class _TimeoutAuthSessionNotifier extends AuthSessionNotifier {
  _TimeoutAuthSessionNotifier({this.restoreCalled = false});

  bool restoreCalled;

  @override
  AuthSessionState build() => const AuthSessionState(
    isAuthenticated: false,
    isLoading: false,
    isTimeout: true,
  );

  @override
  Future<void> restore() async {
    restoreCalled = true;
  }
}

Widget _appShell(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: TestForuiApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('ConnectivityBanner', () {
    testWidgets('renders SizedBox.shrink when session is not timed out', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appShell(const ConnectivityBanner(), [
          authSessionProvider.overrideWith(_NormalAuthSessionNotifier.new),
        ]),
      );
      await tester.pumpAndSettle();

      // The only meaningful assertion: banner content is not visible.
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.authSessionRestoreTimeout), findsNothing);
    });

    testWidgets('renders banner with timeout message when session timed out', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        _appShell(const ConnectivityBanner(), [
          authSessionProvider.overrideWith(_TimeoutAuthSessionNotifier.new),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.authSessionRestoreTimeout), findsOneWidget);
      expect(find.text(l10n.commonRetry), findsOneWidget);
      expect(find.byType(FButton), findsOneWidget);
    });

    testWidgets('tapping Retry calls restore()', (tester) async {
      final notifier = _TimeoutAuthSessionNotifier();

      await tester.pumpWidget(
        _appShell(const ConnectivityBanner(), [
          authSessionProvider.overrideWith(() => notifier),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FButton));
      // FTappable has a tap animation that needs to drain.
      await tester.pumpAndSettle();

      expect(notifier.restoreCalled, isTrue);
    });
  });
}
