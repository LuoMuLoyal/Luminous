import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/dashboard.dart';

import '../helpers/feature_mocks.dart';

class _CountingTodayRepository implements TodayRepository {
  _CountingTodayRepository({required this.dashboard});

  final Future<TodayDashboard> dashboard;
  int fetchDashboardCallCount = 0;

  @override
  Future<TodayDashboard> get signedOutDashboard => dashboard;

  @override
  TaskEither<LucentFailure, TodayDashboard> fetchDashboard() {
    fetchDashboardCallCount += 1;
    return TaskEither(
      () => dashboard.then(
        (value) => Right<LucentFailure, TodayDashboard>(value),
      ),
    );
  }
}

class _AuthenticatedSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() =>
      const AuthSessionState(isLoading: false, isAuthenticated: true);
}

void main() {
  test('returns placeholderDashboard when signed out', () async {
    final c = ProviderContainer(
      overrides: [
        todayRepositoryProvider.overrideWithValue(const MockTodayRepository()),
      ],
    );
    addTearDown(c.dispose);
    c.read(authSessionProvider.notifier).state = const AuthSessionState(
      isAuthenticated: false,
      isLoading: false,
    );
    final d = await c.read(todayDashboardProvider.future);
    expect(d, MockTodayRepository.placeholderDashboard);
  });

  test('rebuilds when healthEvents topic changes', () async {
    final repo = _CountingTodayRepository(
      dashboard: Future.value(MockTodayRepository.previewDashboard),
    );
    final c = ProviderContainer(
      overrides: [
        todayRepositoryProvider.overrideWithValue(repo),
        authSessionProvider.overrideWith(() => _AuthenticatedSessionNotifier()),
      ],
    );
    addTearDown(c.dispose);

    await c.read(todayDashboardProvider.future);
    final callCountBefore = repo.fetchDashboardCallCount;

    c.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.healthEvents);
    // Riverpod 调度器在事件循环末尾执行刷新，等几拍让依赖链重建完成。
    for (var i = 0; i < 5; i += 1) {
      await Future<void>.delayed(Duration.zero);
    }

    // 依赖变化后 provider 进入 loading，需要再次读取 .future 才会真正触发 fetch。
    await c.read(todayDashboardProvider.future);

    expect(repo.fetchDashboardCallCount, greaterThan(callCountBefore));
  });
}
