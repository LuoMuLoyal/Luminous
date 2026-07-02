import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/mine/presentation/pages/current_medicine_edit.dart';
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
  testWidgets('CurrentMedicineEditPage renders (signed out)', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authSessionProvider.overrideWith(() => _SignedOut())],
        child: const TestForuiApp(home: CurrentMedicineEditPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CurrentMedicineEditPage), findsOneWidget);
  });

  testWidgets('CurrentMedicineEditPage renders form when authenticated', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
        child: const TestForuiApp(home: CurrentMedicineEditPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CurrentMedicineEditPage), findsOneWidget);
  });
}
