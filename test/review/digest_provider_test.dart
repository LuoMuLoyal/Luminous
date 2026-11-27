import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/features/review/data/repositories/lucent_digest.dart';
import 'package:luminous/features/review/domain/entities/digest.dart';
import 'package:luminous/features/review/domain/repositories/digest.dart';
import 'package:luminous/features/review/presentation/providers/digest.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/shared/domain/failure.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_helpers.dart';
import '../today/test_helpers.dart';

void main() {
  setUp(() {
    KvTestStore.install();
  });

  group('ReviewDigestController – build', () {
    test('idle when signed out', () {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(
        reviewDigestControllerProvider(ReviewDigestRange.last7Days),
      );
      expect(state.status, ReviewDigestCardStatus.idle);
      expect(state.summary, isNull);
    });

    test('disabled when digestEnabled is false', () async {
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
        reviewDigestControllerProvider(ReviewDigestRange.last7Days),
      );
      expect(state.status, ReviewDigestCardStatus.disabled);
    });

    test('idle when signed in and digestEnabled is true', () async {
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
        reviewDigestControllerProvider(ReviewDigestRange.last7Days),
      );
      expect(state.status, ReviewDigestCardStatus.idle);
    });
  });

  group('ReviewDigestController – generate', () {
    test('returns idle when signed out (no network call)', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(
            reviewDigestControllerProvider(
              ReviewDigestRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewDigestCardStatus.idle);
      expect(
        container
            .read(reviewDigestControllerProvider(ReviewDigestRange.last7Days))
            .status,
        ReviewDigestCardStatus.idle,
      );
    });

    test('sets disabled when digestEnabled is false', () async {
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
            reviewDigestControllerProvider(
              ReviewDigestRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewDigestCardStatus.disabled);
      expect(
        container
            .read(reviewDigestControllerProvider(ReviewDigestRange.last7Days))
            .isDisabled,
        isTrue,
      );
    });

    test('loading → success path', () async {
      final fakeRepo = _FakeReviewDigestRepository(
        response: _testSummary(range: ReviewDigestRange.last7Days),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          reviewDigestRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      // Listen to capture loading state.
      final states = <ReviewDigestCardState>[];
      container.listen(
        reviewDigestControllerProvider(ReviewDigestRange.last7Days),
        (prev, next) {
          states.add(next);
        },
        fireImmediately: true,
      );

      final result = await container
          .read(
            reviewDigestControllerProvider(
              ReviewDigestRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewDigestCardStatus.success);
      expect(result.summary?.summary, '测试周总结');

      // Should have seen loading at some point.
      expect(
        states.any((s) => s.status == ReviewDigestCardStatus.loading),
        isTrue,
      );
      // Final state is success.
      expect(
        container
            .read(reviewDigestControllerProvider(ReviewDigestRange.last7Days))
            .status,
        ReviewDigestCardStatus.success,
      );
    });

    test(
      'loading state carries streaming summary before final result',
      () async {
        final fakeRepo = _FakeReviewDigestRepository(
          streamEvents: [
            const ReviewDigestSummaryEvent('近 7 天总结正在生成中。'),
            ReviewDigestResultEvent(
              _testSummary(range: ReviewDigestRange.last7Days),
            ),
          ],
        );

        final container = ProviderContainer(
          overrides: [
            authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
            userSettingsControllerProvider.overrideWith(
              EnabledUserSettingsController.new,
            ),
            reviewDigestRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userSettingsControllerProvider.future);

        final states = <ReviewDigestCardState>[];
        container.listen(
          reviewDigestControllerProvider(ReviewDigestRange.last7Days),
          (prev, next) {
            states.add(next);
          },
          fireImmediately: true,
        );

        final result = await container
            .read(
              reviewDigestControllerProvider(
                ReviewDigestRange.last7Days,
              ).notifier,
            )
            .generate();

        expect(result.status, ReviewDigestCardStatus.success);
        expect(
          states.any(
            (state) =>
                state.status == ReviewDigestCardStatus.loading &&
                state.streamingSummary == '近 7 天总结正在生成中。',
          ),
          isTrue,
        );
      },
    );

    test('backend 403 → disabled state', () async {
      final fakeRepo = _FakeReviewDigestRepository(
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
          reviewDigestRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final result = await container
          .read(
            reviewDigestControllerProvider(
              ReviewDigestRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewDigestCardStatus.disabled);
      expect(
        container
            .read(reviewDigestControllerProvider(ReviewDigestRange.last7Days))
            .status,
        ReviewDigestCardStatus.disabled,
      );
    });

    test(
      'backend failure → error state with previous summary retention',
      () async {
        final fakeRepo = _FakeReviewDigestRepository(
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
            reviewDigestRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userSettingsControllerProvider.future);

        final result = await container
            .read(
              reviewDigestControllerProvider(
                ReviewDigestRange.last7Days,
              ).notifier,
            )
            .generate();

        expect(result.status, ReviewDigestCardStatus.error);
        // 失败对象（不是预格式化文案）留在 state 里，卡片渲染时才映射。
        expect(result.error, isNotNull);
        // No previous summary to retain on first failure.
        expect(result.summary, isNull);
      },
    );

    test('backend failure retains previous summary on retry', () async {
      final successRepo = _FakeReviewDigestRepository(
        response: _testSummary(range: ReviewDigestRange.last7Days),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          reviewDigestRepositoryProvider.overrideWithValue(successRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      // First call succeeds.
      await container
          .read(
            reviewDigestControllerProvider(
              ReviewDigestRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(
        container
            .read(reviewDigestControllerProvider(ReviewDigestRange.last7Days))
            .status,
        ReviewDigestCardStatus.success,
      );
      expect(
        container
            .read(reviewDigestControllerProvider(ReviewDigestRange.last7Days))
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
            reviewDigestControllerProvider(
              ReviewDigestRange.last7Days,
            ).notifier,
          )
          .generate();

      expect(result.status, ReviewDigestCardStatus.error);
      // Previous summary should be retained.
      expect(result.summary?.summary, '测试周总结');
      expect(
        container
            .read(reviewDigestControllerProvider(ReviewDigestRange.last7Days))
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

ReviewDigest _testSummary({required ReviewDigestRange range}) {
  return ReviewDigest(
    range: range,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    generatedAt: DateTime.parse('2026-06-12T10:00:00.000Z'),
    summary: '测试周总结',
    coverage: const ReviewDigestCoverage(
      medication: ReviewDigestCoverageDimension(trackedDays: 5, totalDays: 7),
      water: ReviewDigestCoverageDimension(trackedDays: 3, totalDays: 7),
      sleep: ReviewDigestCoverageDimension(trackedDays: 0, totalDays: 7),
    ),
    observedPattern: null,
    lowRiskAction: null,
    disclaimer: '仅基于近 7 天数据。',
  );
}

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeReviewDigestRepository implements ReviewDigestRepository {
  _FakeReviewDigestRepository({this.response, this.error, this.streamEvents});

  ReviewDigest? response;
  Object? error;
  List<ReviewDigestEvent>? streamEvents;

  @override
  Stream<ReviewDigestEvent> generateStream(
    ReviewDigestRange range, {
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
    yield ReviewDigestResultEvent(response!);
  }
}
