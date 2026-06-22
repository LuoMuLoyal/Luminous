import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';

void main() {
  test('returns placeholderDashboard when signed out', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(authSessionProvider.notifier).state = const AuthSessionState(
      isAuthenticated: false,
      isLoading: false,
    );
    final d = await c.read(todayDashboardProvider.future);
    expect(d, MockTodayRepository.placeholderDashboard);
  });
}
