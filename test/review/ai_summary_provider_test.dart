import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/review/data/repositories/lucent_ai_summary.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/repositories/ai_summary.dart';
import 'package:luminous/features/review/presentation/providers/ai_summary.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';

import '../helpers/test_helpers.dart';
import '../today/test_helpers.dart';

void main() {
  group('ReviewAiSummaryController – build', () {
    test('idle when signed out', () {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(
        reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
      );
      expect(state.status, ReviewAiSummaryCardStatus.idle);
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

      final state = container.read(
        reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
      );
      expect(state.status, ReviewAiSummaryCardStatus.disabled);
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

      final state = container.read(
        reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
      );
      expect(state.status, ReviewAiSummaryCardStatus.idle);
    });
  });

  group('ReviewAiSummaryController – generate', () {
    test('returns idle when signed out (no network call)', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(
            reviewAiSummaryControllerProvider(
              ReviewAiSummaryRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewAiSummaryCardStatus.idle);
      expect(
        container
            .read(
              reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
            )
            .status,
        ReviewAiSummaryCardStatus.idle,
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
          .read(
            reviewAiSummaryControllerProvider(
              ReviewAiSummaryRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewAiSummaryCardStatus.disabled);
      expect(
        container
            .read(
              reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
            )
            .isDisabled,
        isTrue,
      );
    });

    test('loading → success path', () async {
      final fakeRepo = _FakeReviewAiSummaryRepository(
        response: _testSummary(range: ReviewAiSummaryRange.last7Days),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          reviewAiSummaryRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      // Listen to capture loading state.
      final states = <ReviewAiSummaryCardState>[];
      container.listen(
        reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
        (prev, next) {
          states.add(next);
        },
        fireImmediately: true,
      );

      final result = await container
          .read(
            reviewAiSummaryControllerProvider(
              ReviewAiSummaryRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewAiSummaryCardStatus.success);
      expect(result.summary?.summary, '测试周总结');

      // Should have seen loading at some point.
      expect(
        states.any((s) => s.status == ReviewAiSummaryCardStatus.loading),
        isTrue,
      );
      // Final state is success.
      expect(
        container
            .read(
              reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
            )
            .status,
        ReviewAiSummaryCardStatus.success,
      );
    });

    test(
      'loading state carries streaming summary before final result',
      () async {
        final fakeRepo = _FakeReviewAiSummaryRepository(
          streamEvents: [
            const ReviewAiGenerationSummaryEvent('近 7 天总结正在生成中。'),
            ReviewAiGenerationResultEvent(
              _testSummary(range: ReviewAiSummaryRange.last7Days),
            ),
          ],
        );

        final container = ProviderContainer(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            userSettingsControllerProvider.overrideWith(
              EnabledUserSettingsController.new,
            ),
            reviewAiSummaryRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userSettingsControllerProvider.future);

        final states = <ReviewAiSummaryCardState>[];
        container.listen(
          reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
          (prev, next) {
            states.add(next);
          },
          fireImmediately: true,
        );

        final result = await container
            .read(
              reviewAiSummaryControllerProvider(
                ReviewAiSummaryRange.last7Days,
              ).notifier,
            )
            .generate();

        expect(result.status, ReviewAiSummaryCardStatus.success);
        expect(
          states.any(
            (state) =>
                state.status == ReviewAiSummaryCardStatus.loading &&
                state.streamingSummary == '近 7 天总结正在生成中。',
          ),
          isTrue,
        );
      },
    );

    test('backend 403 → disabled state', () async {
      final fakeRepo = _FakeReviewAiSummaryRepository(
        error: DioException(
          requestOptions: RequestOptions(
            path: '/api/v1/user/reports/summary/generate',
          ),
          type: DioExceptionType.badResponse,
          error: const LucentFailure(
            kind: LucentFailureKind.business,
            code: '403001',
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
          reviewAiSummaryRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final result = await container
          .read(
            reviewAiSummaryControllerProvider(
              ReviewAiSummaryRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewAiSummaryCardStatus.disabled);
      expect(
        container
            .read(
              reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
            )
            .status,
        ReviewAiSummaryCardStatus.disabled,
      );
    });

    test(
      'backend failure → error state with previous summary retention',
      () async {
        final fakeRepo = _FakeReviewAiSummaryRepository(
          error: DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/user/reports/summary/generate',
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
            reviewAiSummaryRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userSettingsControllerProvider.future);

        final result = await container
            .read(
              reviewAiSummaryControllerProvider(
                ReviewAiSummaryRange.last7Days,
              ).notifier,
            )
            .generate();

        expect(result.status, ReviewAiSummaryCardStatus.error);
        expect(result.errorMessage, isNotEmpty);
        // No previous summary to retain on first failure.
        expect(result.summary, isNull);
      },
    );

    test('backend failure retains previous summary on retry', () async {
      final successRepo = _FakeReviewAiSummaryRepository(
        response: _testSummary(range: ReviewAiSummaryRange.last7Days),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          reviewAiSummaryRepositoryProvider.overrideWithValue(successRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      // First call succeeds.
      await container
          .read(
            reviewAiSummaryControllerProvider(
              ReviewAiSummaryRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(
        container
            .read(
              reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
            )
            .status,
        ReviewAiSummaryCardStatus.success,
      );
      expect(
        container
            .read(
              reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
            )
            .summary
            ?.summary,
        '测试周总结',
      );

      // Swap to a failing repo.
      successRepo.error = DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/user/reports/summary/generate',
        ),
        type: DioExceptionType.connectionTimeout,
      );
      successRepo.response = null;

      final result = await container
          .read(
            reviewAiSummaryControllerProvider(
              ReviewAiSummaryRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewAiSummaryCardStatus.error);
      // Previous summary should be retained.
      expect(result.summary?.summary, '测试周总结');
      expect(
        container
            .read(
              reviewAiSummaryControllerProvider(ReviewAiSummaryRange.last7Days),
            )
            .summary
            ?.summary,
        '测试周总结',
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ReviewAiSummary _testSummary({required ReviewAiSummaryRange range}) {
  return ReviewAiSummary(
    range: range,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    generatedAt: DateTime.parse('2026-06-12T10:00:00.000Z'),
    summary: '测试周总结',
    coverage: const ReviewAiSummaryCoverage(
      medication: ReviewAiSummaryCoverageDimension(
        trackedDays: 5,
        totalDays: 7,
      ),
      water: ReviewAiSummaryCoverageDimension(trackedDays: 3, totalDays: 7),
      sleep: ReviewAiSummaryCoverageDimension(trackedDays: 0, totalDays: 7),
    ),
    observedPattern: null,
    lowRiskAction: null,
    disclaimer: '仅基于近 7 天数据。',
  );
}

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeReviewAiSummaryRepository implements ReviewAiSummaryRepository {
  _FakeReviewAiSummaryRepository({
    this.response,
    this.error,
    this.streamEvents,
  });

  ReviewAiSummary? response;
  Object? error;
  List<ReviewAiGenerationEvent>? streamEvents;

  @override
  Stream<ReviewAiGenerationEvent> generateStream(
    ReviewAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    if (streamEvents != null) {
      for (final event in streamEvents!) {
        yield event;
      }
      return;
    }
    yield ReviewAiGenerationResultEvent(response!);
  }
}
