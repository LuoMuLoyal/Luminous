import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/mine/presentation/pages/allergy_edit.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/auth_test_helpers.dart';

void main() {
  testWidgets('AllergyEditPage renders without crashing when signed out', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authSessionProvider.overrideWith(() => _SignedOut())],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light().copyWith(
            extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
          ),
          home: const AllergyEditPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(AllergyEditPage), findsOneWidget);
  });

  testWidgets('AllergyEditPage renders create form when authenticated', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light().copyWith(
            extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
          ),
          home: const AllergyEditPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should render the form page elements
    expect(find.text(l10n.mineEditAllergyNewTitle), findsOneWidget);
  });
}

class _SignedOut extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}
