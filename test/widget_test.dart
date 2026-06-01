import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/app.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';

void main() {
  testWidgets('App should render', (tester) async {
    final mockSnapshot = HealthContextSnapshot(
      summary: const HealthSummary(
        age: 27,
        onboardingCompleted: true,
        activeAllergyCount: 2,
        conditionCount: 1,
        currentMedicineCount: 3,
        missingCoreProfileFields: [],
      ),
      profile: const HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        pregnancyState: null,
        lactationState: null,
        bloodType: null,
        locale: null,
        timezone: null,
        unitSystem: null,
        onboardingCompletedAt: null,
        extras: {},
      ),
      allergies: const [],
      conditions: const [],
      currentMedicines: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthContextSnapshotProvider
              .overrideWith((ref) => Future.value(mockSnapshot)),
        ],
        child: const LuminousApp(),
      ),
    );
    expect(find.byType(LuminousApp), findsOneWidget);
  });
}
