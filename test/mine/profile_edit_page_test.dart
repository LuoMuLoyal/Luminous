import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

class _SignedOut extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

void main() {
  testWidgets('ProfileEditPage renders (signed out)', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authSessionProvider.overrideWith(() => _SignedOut())],
        child: const TestForuiApp(home: ProfileEditPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProfileEditPage), findsOneWidget);
  });
}
