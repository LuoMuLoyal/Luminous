import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/health_context/data/datasources/health_context_remote_data_source.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('Profile edit saves domain input with explicit null clears', (
    tester,
  ) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthContextSnapshotProvider.overrideWith(
            (ref) async => _snapshot,
          ),
          healthContextRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => Scaffold(
                  body: TextButton(
                    onPressed: () => context.push('/mine/profile/edit'),
                    child: const Text('open-profile-edit'),
                  ),
                ),
              ),
              GoRoute(
                path: '/mine/profile/edit',
                builder: (context, state) => const ProfileEditPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1999-02-03');
    await tester.enterText(fields.at(1), '170');
    await tester.enterText(fields.at(2), '');
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('完成新手引导'),
      220,
      scrollable: scrollable,
    );
    await tester.pump();
    await tester.tap(find.text('完成新手引导'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('保存'),
      220,
      scrollable: scrollable,
    );
    await tester.pump();
    await tester.tap(find.text('保存'));
    await tester.pump(const Duration(seconds: 2));

    final input = fakeRepo.profileUpdate;
    expect(input, isNotNull);
    expect(
      healthProfileUpdatePayload(input!),
      containsPair('birthDate', '1999-02-03'),
    );
    expect(healthProfileUpdatePayload(input), containsPair('heightCm', 170));
    expect(healthProfileUpdatePayload(input), containsPair('bloodType', null));
    expect(
      healthProfileUpdatePayload(input),
      containsPair('onboardingCompleted', false),
    );
  });
}

class _FakeHealthContextRepository implements HealthContextRepository {
  HealthProfileUpdateInput? profileUpdate;

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    profileUpdate = input;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async => _snapshot;

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async => _snapshot;

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async =>
      _snapshot;
}

const _snapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-01',
    sexAtBirth: 'female',
    heightCm: 168,
    pregnancyState: null,
    lactationState: null,
    bloodType: 'O+',
    locale: null,
    timezone: null,
    unitSystem: 'metric',
    onboardingCompletedAt: '2026-01-01T00:00:00.000Z',
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);
