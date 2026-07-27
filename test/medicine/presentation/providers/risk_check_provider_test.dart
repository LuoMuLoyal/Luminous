import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/risk_check.dart';

void main() {
  group('redFlagAlertsProvider', () {
    test('returns empty list when result has no red flags', () async {
      const riskResult = MedicineRiskCheckResult(
        currentMedicineCount: 3,
        checkedMedicineCount: 3,
        findings: [],
        coverageIssues: [],
        redFlags: [],
      );

      final c = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => _SignedOutSessionNotifier()),
          medicineRiskCheckProvider.overrideWith((ref) async => riskResult),
        ],
      );
      addTearDown(c.dispose);

      final result = await c.read(redFlagAlertsProvider.future);
      expect(result, isEmpty);
    });

    test('returns red flags when result has red flags', () async {
      const redFlags = [
        RedFlagAlert(
          rule: RedFlagRule.severeAllergy,
          primaryMedicineName: '阿莫西林',
          relatedLabel: '青霉素',
        ),
        RedFlagAlert(
          rule: RedFlagRule.informationGap,
          primaryMedicineName: '未知药品',
        ),
      ];
      const riskResult = MedicineRiskCheckResult(
        currentMedicineCount: 2,
        checkedMedicineCount: 2,
        redFlags: redFlags,
      );

      final c = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => _SignedOutSessionNotifier()),
          medicineRiskCheckProvider.overrideWith((ref) async => riskResult),
        ],
      );
      addTearDown(c.dispose);

      final result = await c.read(redFlagAlertsProvider.future);
      expect(result, hasLength(2));
      expect(result.first.rule, RedFlagRule.severeAllergy);
      expect(result.first.primaryMedicineName, '阿莫西林');
      expect(result[1].rule, RedFlagRule.informationGap);
    });
  });

  group('medicineRiskCheckProvider signed-out behavior', () {
    test(
      'throws AuthRequiredException when signed out (no fallback)',
      () async {
        final c = ProviderContainer(
          overrides: [
            authSessionProvider.overrideWith(() => _SignedOutSessionNotifier()),
          ],
        );
        addTearDown(c.dispose);

        final state = c.read(medicineRiskCheckRecordsProvider);

        expect(state.hasError, isTrue);
        expect(state.error, isA<AuthRequiredException>());
      },
    );
  });
}

class _SignedOutSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();
}
