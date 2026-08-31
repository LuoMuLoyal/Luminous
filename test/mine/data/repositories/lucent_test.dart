import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/mine/data/providers/mine.dart';

import '../../../helpers/task_either.dart';

const _snapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 2,
    conditionCount: 1,
    currentMedicineCount: 3,
    missingCoreProfileFields: ['bloodType'],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-15',
    sexAtBirth: null,
    heightCm: null,
    weightKg: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);

void main() {
  group('LucentMineRepository.fetchDashboard', () {
    test(
      'returns a Right dashboard when the health-context snapshot loads',
      () async {
        final container = ProviderContainer(
          overrides: [
            healthContextSnapshotProvider.overrideWith(
              (ref) => Future.value(_snapshot),
            ),
          ],
        );
        addTearDown(container.dispose);

        final dashboard = await expectTaskRight(
          container.read(mineRepositoryProvider).fetchDashboard(),
        );

        expect(dashboard.account.isAuthenticated, isTrue);
        expect(dashboard.profile.age, 27);
        expect(dashboard.profile.allergyCount, 2);
        expect(dashboard.profile.conditionCount, 1);
        expect(dashboard.profile.currentMedicineCount, 3);
        expect(dashboard.completion.percentLabel, '50%');
        expect(dashboard.archiveEntries, isNotEmpty);
        // Privacy card is always present.
        expect(dashboard.alerts, isNotEmpty);
      },
    );

    test(
      'returns a Left network failure when the snapshot load fails',
      () async {
        // Disable Riverpod's default retry — LucentFailure is not an Error
        // subclass, and a retried provider keeps .future pending, which would
        // time out the assertion (report/health_event suite precedent).
        final container = ProviderContainer(
          retry: (count, error) => null,
          overrides: [
            healthContextSnapshotProvider.overrideWith(
              (ref) => Future<HealthContextSnapshot>.error(
                LucentFailure.network(
                  message: 'offline',
                  networkErrorCode: NetworkErrorCode.connectionError,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final failure = await expectTaskLeft(
          container.read(mineRepositoryProvider).fetchDashboard(),
        );

        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.connectionError);
      },
    );

    test('maps a server business failure to a Left without fabricating a '
        'dashboard', () async {
      final container = ProviderContainer(
        retry: (count, error) => null,
        overrides: [
          healthContextSnapshotProvider.overrideWith(
            (ref) => Future<HealthContextSnapshot>.error(
              const LucentFailure(
                kind: LucentFailureKind.business,
                message: 'profile locked',
                code: 'RESOURCE_CONFLICT',
                statusCode: 409,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final failure = await expectTaskLeft(
        container.read(mineRepositoryProvider).fetchDashboard(),
      );

      expect(failure.kind, LucentFailureKind.business);
      expect(failure.code, 'RESOURCE_CONFLICT');
      expect(failure.statusCode, 409);
    });
  });

  group('LucentMineRepository.signedOutDashboard', () {
    test('returns the signed-out dashboard as a plain Future', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dashboard = await container
          .read(mineRepositoryProvider)
          .signedOutDashboard;

      expect(dashboard.account.isAuthenticated, isFalse);
      expect(dashboard.completion.progress, 0);
    });
  });
}
