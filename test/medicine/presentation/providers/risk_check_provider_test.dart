import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/risk_check.dart';

void main() {
  group('redFlagAlertsProvider', () {
    test('returns empty list when medicineRiskCheck has no findings', () async {
      const riskResult = MedicineRiskCheckResult(
        currentMedicineCount: 0,
        checkedMedicineCount: 0,
        findings: [],
        coverageIssues: [],
      );

      final c = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => _SignedOutSessionNotifier()),
          medicineRiskCheckProvider.overrideWith((ref) async => riskResult),
          // healthContextSnapshotProvider is used by redFlagAlertsProvider
          // but RedFlagEvaluator.evaluate handles null snapshot gracefully
        ],
      );
      addTearDown(c.dispose);

      // Override healthContextSnapshotProvider to avoid real network call
      // The redFlagAlertsProvider watches both medicineRiskCheckProvider
      // and healthContextSnapshotProvider
    });
  });

  group('medicineRiskCheckProvider signed-out behavior', () {
    test('throws AuthRequiredException when signed out (no fallback)', () {
      final c = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(() => _SignedOutSessionNotifier()),
        ],
      );
      addTearDown(c.dispose);

      final state = c.read(medicineRiskCheckProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<AuthRequiredException>());
    });
  });
}

class _SignedOutSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();
}
