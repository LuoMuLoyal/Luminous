import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/mine/presentation/pages/condition_edit.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_test_helpers.dart';
import '../helpers/test_forui_app.dart';

class _SignedOut extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

void main() {
  testWidgets('ConditionEditPage renders without crashing when signed out', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authSessionProvider.overrideWith(() => _SignedOut())],
        child: const TestForuiApp(home: ConditionEditPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ConditionEditPage), findsOneWidget);
  });

  testWidgets('ConditionEditPage renders edit form when authenticated', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
        child: const TestForuiApp(home: ConditionEditPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.mineEditConditionNewTitle), findsOneWidget);
  });
}
