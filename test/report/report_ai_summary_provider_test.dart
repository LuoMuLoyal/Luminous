import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/report/data/repositories/lucent_report_ai_summary_repository.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/report/presentation/providers/report_ai_summary_provider.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';

import '../today/today_test_helpers.dart';

void main() {
  group('ReportAiSummaryController – build', () {
    test('idle when signed out', () {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(reportAiSummaryControllerProvider);
      expect(state.status, ReportAiSummaryCardStatus.idle);
      expect(state.summary, isNull);
    });

    test('disabled when aiSummariesEnabled is false', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            DisabledUserSettingsController.new,
          ),
        ],
      );
      addTearDown(container.dispose);

      // Wait for settings to load.
      await container.read(userSettingsControllerProvider.future);

      final state = container.read(reportAiSummaryControllerProvider);
      expect(state.status, ReportAiSummaryCardStatus.disabled);
    });

    test('idle when signed in and aiSummariesEnabled is true', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final state = container.read(reportAiSummaryControllerProvider);
      expect(state.status, ReportAiSummaryCardStatus.idle);
    });
  });

  group('ReportAiSummaryController – generate', () {
    test('returns idle when signed out (no network call)', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(reportAiSummaryControllerProvider.notifier)
          .generate();

      expect(result.status, ReportAiSummaryCardStatus.idle);
      expect(
        container.read(reportAiSummaryControllerProvider).status,
        ReportAiSummaryCardStatus.idle,
      );
    });

    test('sets disabled when aiSummariesEnabled is false', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            DisabledUserSettingsController.new,
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final result = await container
          .read(reportAiSummaryControllerProvider.notifier)
          .generate();

      expect(result.status, ReportAiSummaryCardStatus.disabled);
      expect(
        container.read(reportAiSummaryControllerProvider).isDisabled,
        isTrue,
      );
    });

    test('loading → success path', () async {
      final fakeRepo = _FakeReportAiSummaryRepository(
        response: _testSummary(range: 'last_7_days'),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          reportAiSummaryRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      // Listen to capture loading state.
      final states = <ReportAiSummaryCardState>[];
      container.listen(reportAiSummaryControllerProvider, (prev, next) {
        states.add(next);
      }, fireImmediately: true);

      final result = await container
          .read(reportAiSummaryControllerProvider.notifier)
          .generate();

      expect(result.status, ReportAiSummaryCardStatus.success);
      expect(result.summary?.summary, '测试周总结');

      // Should have seen loading at some point.
      expect(
        states.any((s) => s.status == ReportAiSummaryCardStatus.loading),
        isTrue,
      );
      // Final state is success.
      expect(
        container.read(reportAiSummaryControllerProvider).status,
        ReportAiSummaryCardStatus.success,
      );
    });

    test('backend 403 → disabled state', () async {
      final fakeRepo = _FakeReportAiSummaryRepository(
        error: DioException(
          requestOptions: RequestOptions(
            path: '/api/v1/user/reports/weekly-summary/generate',
          ),
          type: DioExceptionType.badResponse,
          error: const LucentApiException(
            code: 403001,
            message: 'AI summaries are disabled.',
            statusCode: 403,
          ),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          reportAiSummaryRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final result = await container
          .read(reportAiSummaryControllerProvider.notifier)
          .generate();

      expect(result.status, ReportAiSummaryCardStatus.disabled);
      expect(
        container.read(reportAiSummaryControllerProvider).status,
        ReportAiSummaryCardStatus.disabled,
      );
    });

    test(
      'backend failure → error state with previous summary retention',
      () async {
        final fakeRepo = _FakeReportAiSummaryRepository(
          error: DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/user/reports/weekly-summary/generate',
            ),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            userSettingsControllerProvider.overrideWith(
              EnabledUserSettingsController.new,
            ),
            reportAiSummaryRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userSettingsControllerProvider.future);

        final result = await container
            .read(reportAiSummaryControllerProvider.notifier)
            .generate();

        expect(result.status, ReportAiSummaryCardStatus.error);
        expect(result.errorMessage, isNotEmpty);
        // No previous summary to retain on first failure.
        expect(result.summary, isNull);
      },
    );

    test('backend failure retains previous summary on retry', () async {
      final successRepo = _FakeReportAiSummaryRepository(
        response: _testSummary(range: 'last_7_days'),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          reportAiSummaryRepositoryProvider.overrideWithValue(successRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      // First call succeeds.
      await container
          .read(reportAiSummaryControllerProvider.notifier)
          .generate();

      expect(
        container.read(reportAiSummaryControllerProvider).status,
        ReportAiSummaryCardStatus.success,
      );
      expect(
        container.read(reportAiSummaryControllerProvider).summary?.summary,
        '测试周总结',
      );

      // Swap to a failing repo.
      successRepo.error = DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/user/reports/weekly-summary/generate',
        ),
        type: DioExceptionType.connectionTimeout,
      );
      successRepo.response = null;

      final result = await container
          .read(reportAiSummaryControllerProvider.notifier)
          .generate();

      expect(result.status, ReportAiSummaryCardStatus.error);
      // Previous summary should be retained.
      expect(result.summary?.summary, '测试周总结');
      expect(
        container.read(reportAiSummaryControllerProvider).summary?.summary,
        '测试周总结',
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ReportAiSummary _testSummary({required String range}) {
  return ReportAiSummary(
    range: range,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    generatedAt: DateTime.parse('2026-06-12T10:00:00.000Z'),
    summary: '测试周总结',
    bullets: const [
      ReportAiSummaryBullet(
        kind: ReportAiSummaryBulletKind.medication,
        text: '用药记录良好。',
        color: Colors.blue,
        icon: Icons.medication,
      ),
    ],
    actionLabel: '查看报告',
    confidenceNote: '仅基于近 7 天数据。',
  );
}

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeReportAiSummaryRepository implements ReportAiSummaryRepository {
  _FakeReportAiSummaryRepository({this.response, this.error});

  ReportAiSummary? response;
  Object? error;

  @override
  Future<ReportAiSummary> generate() async {
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    return response!;
  }
}
