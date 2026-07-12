import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/medicine/data/repositories/mock_workspace.dart';
import 'package:luminous/features/medicine/presentation/providers/workspace.dart';

void main() {
  group('medicineWorkspaceProvider', () {
    test('returns preview workspace when not authenticated', () async {
      final c = ProviderContainer(
        overrides: [
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
        ],
      );
      addTearDown(c.dispose);

      c.read(authSessionProvider.notifier).state = const AuthSessionState(
        isAuthenticated: false,
        isLoading: false,
      );

      final workspace = await c.read(medicineWorkspaceProvider.future);

      // signedOutFallback returns previewWorkspace, not signedOut()
      expect(workspace, MockMedicineWorkspaceRepository.previewWorkspace);
      expect(workspace.hero.metricDosesToday, '0');
      expect(workspace.plan.items.length, 3);
    });

    test('returns preview workspace when authenticated', () async {
      final c = ProviderContainer(
        overrides: [
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
        ],
      );
      addTearDown(c.dispose);

      c.read(authSessionProvider.notifier).state = const AuthSessionState(
        isAuthenticated: true,
        isLoading: false,
      );

      final workspace = await c.read(medicineWorkspaceProvider.future);

      // MockMedicineWorkspaceRepository.fetchWorkspace returns previewWorkspace
      expect(workspace, MockMedicineWorkspaceRepository.previewWorkspace);
      expect(workspace.plan.items.length, 3);
      expect(workspace.alerts.length, 4);
    });

    test('is in loading state when session is restoring', () {
      final c = ProviderContainer(
        overrides: [
          medicineWorkspaceRepositoryProvider.overrideWithValue(
            const MockMedicineWorkspaceRepository(),
          ),
        ],
      );
      addTearDown(c.dispose);

      // Default state is isLoading: true, isAuthenticated: false
      final state = c.read(medicineWorkspaceProvider);
      expect(state.isLoading, isTrue);
    });
  });
}
