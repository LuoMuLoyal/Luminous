import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/mine/presentation/pages/current_medicine_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/test_helpers.dart';
import '../helpers/test_forui_app.dart';

class _SignedOut extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

final _mockSnapshot = const HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: <String>[],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-15',
    sexAtBirth: null,
    heightCm: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    extras: <String, dynamic>{},
  ),
  allergies: <AllergyItem>[],
  conditions: <ConditionItem>[],
  currentMedicines: <CurrentMedicineItem>[],
);

void main() {
  testWidgets('CurrentMedicineEditPage renders (signed out)', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authSessionProvider.overrideWith(() => _SignedOut())],
        child: const TestForuiApp(home: CurrentMedicineEditPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
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
          healthContextSnapshotProvider.overrideWith(
            (ref) => Future.value(_mockSnapshot),
          ),
        ],
        child: const TestForuiApp(home: CurrentMedicineEditPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CurrentMedicineEditPage), findsOneWidget);
  });
}
