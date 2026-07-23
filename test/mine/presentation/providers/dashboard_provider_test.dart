import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/mine/data/providers/mine.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/providers/dashboard.dart';

import '../../../helpers/feature_mocks.dart';

void main() {
  group('mineDashboardProvider', () {
    test('returns signed-out dashboard when not authenticated', () async {
      final c = ProviderContainer(
        overrides: [
          mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
        ],
      );
      addTearDown(c.dispose);

      c.read(authSessionProvider.notifier).state = const AuthSessionState(
        isAuthenticated: false,
        isLoading: false,
      );

      final dashboard = await c.read(mineDashboardProvider.future);

      expect(dashboard.account.isAuthenticated, isFalse);
      expect(dashboard.completion.progress, 0);
      expect(dashboard.alerts, isNotEmpty);
      expect(dashboard.archiveEntries, isNotEmpty);
    });

    test('returns real dashboard when authenticated', () async {
      final c = ProviderContainer(
        overrides: [
          mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
        ],
      );
      addTearDown(c.dispose);

      c.read(authSessionProvider.notifier).state = const AuthSessionState(
        isAuthenticated: true,
        isLoading: false,
      );

      final dashboard = await c.read(mineDashboardProvider.future);

      expect(dashboard.account.isAuthenticated, isTrue);
      expect(dashboard.account.displayName, '[DEMO] User');
      expect(dashboard.completion.progress, 0.82);
      expect(dashboard.completion.percentLabel, '82%');
    });

    test('is in loading state when session is restoring', () {
      final c = ProviderContainer(
        overrides: [
          mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
        ],
      );
      addTearDown(c.dispose);

      // Default state is isLoading: true, isAuthenticated: false
      final state = c.read(mineDashboardProvider);
      expect(state.isLoading, isTrue);
    });

    test('signed-out dashboard has privacy notice', () async {
      final c = ProviderContainer(
        overrides: [
          mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
        ],
      );
      addTearDown(c.dispose);

      c.read(authSessionProvider.notifier).state = const AuthSessionState(
        isAuthenticated: false,
        isLoading: false,
      );

      final dashboard = await c.read(mineDashboardProvider.future);

      expect(dashboard.privacyNotice.titleKey, MineCopyKey.privacyNoticeTitle);
      expect(
        dashboard.privacyNotice.actionKey,
        MineCopyKey.privacyNoticeAction,
      );
    });
  });
}
