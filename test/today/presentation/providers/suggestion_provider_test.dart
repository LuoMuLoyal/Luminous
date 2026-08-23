import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/today_suggestion_dao.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/today/data/datasources/suggestion_remote.dart';
import 'package:luminous/features/today/data/providers/suggestion.dart';
import 'package:luminous/features/today/data/utils/suggestion_json_codec.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDataSource extends Mock
    implements TodaySuggestionRemoteDataSource {}

class _MockDao extends Mock implements TodaySuggestionDao {}

class _AuthenticatedSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() =>
      const AuthSessionState(isLoading: false, isAuthenticated: true);
}

class _SignedOutSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();
}

TodaySuggestionBundle _bundle({
  String? primaryId,
  TodaySuggestionMaterializationStatus materializationStatus =
      TodaySuggestionMaterializationStatus.ready,
  int sourceVersion = 0,
}) {
  return TodaySuggestionBundle(
    generatedAt: '2026-07-12T10:00:00Z',
    materializationStatus: materializationStatus,
    sourceVersion: sourceVersion,
    primary: primaryId != null
        ? TodaySuggestionCard(
            id: primaryId,
            type: TodaySuggestionType.compliance,
            cardTone: TodaySuggestionCardTone.soft,
            icon: 'pill',
            title: 'Title $primaryId',
            reason: 'Reason',
            evidence: const [],
            boundary: 'Boundary',
            primaryAction: const TodaySuggestionAction(
              actionId: 'a1',
              label: 'View',
              route: '/record',
              authRequired: true,
            ),
            confidence: TodaySuggestionConfidence.high,
            ruleId: 'rule-1',
            ruleVersion: 'v1',
            triggerType: TodaySuggestionTriggerType.timer,
            lifecycleState: TodaySuggestionLifecycleState.active,
          )
        : null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRemoteDataSource mockDataSource;
  late _MockDao mockDao;

  ProviderContainer buildContainer({bool authenticated = true}) {
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(
          () => authenticated
              ? _AuthenticatedSessionNotifier()
              : _SignedOutSessionNotifier(),
        ),
        todaySuggestionRemoteDataSourceProvider.overrideWithValue(
          mockDataSource,
        ),
        todaySuggestionDaoProvider.overrideWithValue(mockDao),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Stub the DAO methods that are always called during a successful fetch.
  void stubDaoSuccess() {
    when(() => mockDao.replace(any())).thenAnswer((_) async {});
    when(() => mockDao.fetch()).thenAnswer((_) async => null);
  }

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(TodaySuggestionFeedback.later);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockDataSource = _MockRemoteDataSource();
    mockDao = _MockDao();
  });

  group('TodaySuggestionNotifier', () {
    test('build fetches suggestions and caches them', () async {
      final bundle = _bundle(primaryId: 's1');
      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(bundle));
      stubDaoSuccess();

      final c = buildContainer();
      final result = await c.read(todaySuggestionProvider.future);

      expect(result, isNotNull);
      expect(result!.primary?.id, 's1');

      verify(() => mockDao.replace(any())).called(1);
    });

    test('returns null when signed out', () async {
      final c = buildContainer(authenticated: false);
      final result = await c.read(todaySuggestionProvider.future);

      expect(result, isNull);
      verifyNever(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      );
    });

    test('falls back to cache when network fails', () async {
      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer(
        (_) => TaskEither.left(LucentFailure.unknown(message: 'Network error')),
      );
      when(() => mockDao.fetch()).thenAnswer((_) async => null);
      final c = buildContainer();

      // The provider will try network first, fail, then try cache.
      // Since cache is null, it will rethrow the network error.
      c.read(todaySuggestionProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the DAO was consulted as fallback
      verify(() => mockDao.fetch()).called(1);
    });

    test(
      'clears stale cache when deserialization fails and rethrows',
      () async {
        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer(
          (_) =>
              TaskEither.left(LucentFailure.unknown(message: 'Network error')),
        );
        // Return corrupt JSON that will fail deserialization
        when(() => mockDao.fetch()).thenAnswer((_) async => '{corrupt json}');
        when(() => mockDao.clear()).thenAnswer((_) async {});

        final c = buildContainer();

        // The provider will try network first, fail, then try cache.
        // Cache deserialization will fail, so it should clear the stale cache
        // and rethrow the original network error.
        c.read(todaySuggestionProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify the DAO was consulted as fallback
        verify(() => mockDao.fetch()).called(1);
        // Verify the stale cache was cleared
        verify(() => mockDao.clear()).called(1);
      },
    );

    test('dismiss adds id to excluded list and re-fetches', () async {
      final bundle1 = _bundle(primaryId: 's1');
      final bundle2 = _bundle(primaryId: 's2');

      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(bundle1));
      stubDaoSuccess();

      final c = buildContainer();
      await c.read(todaySuggestionProvider.future);

      // Now stub the next call to return bundle2
      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(bundle2));

      await c.read(todaySuggestionProvider.notifier).dismiss('s1');

      final state = c.read(todaySuggestionProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.primary?.id, 's2');
    });

    test(
      'submitFeedback keeps old bundle while submission is in flight',
      () async {
        final bundle1 = _bundle(primaryId: 's1');
        final bundle2 = _bundle(primaryId: 's2');
        final submitCompleter = Completer<TodaySuggestionFeedbackResult>();

        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(bundle1));
        when(
          () => mockDataSource.submitFeedback(
            id: any(named: 'id'),
            feedback: any(named: 'feedback'),
          ),
        ).thenAnswer(
          (_) => TaskEither<LucentFailure, TodaySuggestionFeedbackResult>(
            () => submitCompleter.future.then(
              (value) =>
                  Right<LucentFailure, TodaySuggestionFeedbackResult>(value),
            ),
          ),
        );
        stubDaoSuccess();

        final c = buildContainer();
        await c.read(todaySuggestionProvider.future);

        // Next fetch after feedback returns bundle2.
        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(bundle2));

        final submitFuture = c
            .read(todaySuggestionProvider.notifier)
            .submitFeedback(
              suggestionId: 's1',
              feedback: TodaySuggestionFeedback.suppress,
            );

        // Yield so the async method reaches ds.submitFeedback.
        await Future<void>.delayed(Duration.zero);
        expect(c.read(todaySuggestionProvider).isLoading, isFalse);
        expect(c.read(todaySuggestionProvider).value!.primary!.id, 's1');

        submitCompleter.complete(
          const TodaySuggestionFeedbackResult(
            suggestionId: 's1',
            feedback: TodaySuggestionFeedback.suppress,
            appliedEffect: TodaySuggestionFeedbackEffect.suppressedType,
          ),
        );
        await submitFuture;

        // After submission the provider silently refreshes and replaces state.
        expect(c.read(todaySuggestionProvider).isLoading, isFalse);
        expect(c.read(todaySuggestionProvider).value!.primary!.id, 's2');

        verify(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: ['s1'],
          ),
        ).called(1);
      },
    );

    test(
      'submitFeedback silently refreshes and replaces state on success',
      () async {
        final bundle1 = _bundle(primaryId: 's1');
        final bundle2 = _bundle(primaryId: 's2');

        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(bundle1));
        when(
          () => mockDataSource.submitFeedback(
            id: any(named: 'id'),
            feedback: any(named: 'feedback'),
          ),
        ).thenAnswer(
          (_) => TaskEither.right(
            const TodaySuggestionFeedbackResult(
              suggestionId: 's1',
              feedback: TodaySuggestionFeedback.accepted,
              appliedEffect: TodaySuggestionFeedbackEffect.noted,
            ),
          ),
        );
        stubDaoSuccess();

        final c = buildContainer();
        await c.read(todaySuggestionProvider.future);

        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(bundle2));

        await c
            .read(todaySuggestionProvider.notifier)
            .submitFeedback(
              suggestionId: 's1',
              feedback: TodaySuggestionFeedback.accepted,
            );

        final state = c.read(todaySuggestionProvider);
        expect(state.isLoading, isFalse);
        expect(state.hasValue, isTrue);
        expect(state.value!.primary!.id, 's2');
      },
    );

    test('submitFeedback keeps old bundle when the refresh fails', () async {
      final bundle1 = _bundle(primaryId: 's1');

      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(bundle1));
      when(
        () => mockDataSource.submitFeedback(
          id: any(named: 'id'),
          feedback: any(named: 'feedback'),
        ),
      ).thenAnswer(
        (_) => TaskEither.right(
          const TodaySuggestionFeedbackResult(
            suggestionId: 's1',
            feedback: TodaySuggestionFeedback.accepted,
            appliedEffect: TodaySuggestionFeedbackEffect.noted,
          ),
        ),
      );
      stubDaoSuccess();

      final c = buildContainer();
      await c.read(todaySuggestionProvider.future);

      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer(
        (_) => TaskEither.left(LucentFailure.unknown(message: 'Network error')),
      );

      await c
          .read(todaySuggestionProvider.notifier)
          .submitFeedback(
            suggestionId: 's1',
            feedback: TodaySuggestionFeedback.accepted,
          );

      final state = c.read(todaySuggestionProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasValue, isTrue);
      expect(state.value!.primary!.id, 's1');
    });

    test(
      'submitFeedback throws when submission fails and keeps old bundle',
      () async {
        final bundle1 = _bundle(primaryId: 's1');

        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(bundle1));
        when(
          () => mockDataSource.submitFeedback(
            id: any(named: 'id'),
            feedback: any(named: 'feedback'),
          ),
        ).thenAnswer(
          (_) =>
              TaskEither.left(LucentFailure.unknown(message: 'Submit failed')),
        );
        stubDaoSuccess();

        final c = buildContainer();
        await c.read(todaySuggestionProvider.future);

        await expectLater(
          () => c
              .read(todaySuggestionProvider.notifier)
              .submitFeedback(
                suggestionId: 's1',
                feedback: TodaySuggestionFeedback.accepted,
              ),
          throwsA(isA<LucentFailure>()),
        );

        final state = c.read(todaySuggestionProvider);
        expect(state.isLoading, isFalse);
        expect(state.hasValue, isTrue);
        expect(state.value!.primary!.id, 's1');
      },
    );

    test('refresh re-fetches suggestions', () async {
      final bundle1 = _bundle(primaryId: 's1');
      final bundle2 = _bundle(primaryId: 's2');

      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(bundle1));
      stubDaoSuccess();

      final c = buildContainer();
      await c.read(todaySuggestionProvider.future);

      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(bundle2));

      await c.read(todaySuggestionProvider.notifier).refresh();

      final state = c.read(todaySuggestionProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.primary?.id, 's2');
    });

    test('state transitions to loading during refresh', () async {
      final bundle = _bundle(primaryId: 's1');
      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(bundle));
      stubDaoSuccess();

      final c = buildContainer();
      await c.read(todaySuggestionProvider.future);

      // Start refresh — don't await yet
      final refreshFuture = c.read(todaySuggestionProvider.notifier).refresh();

      // Should be loading
      expect(c.read(todaySuggestionProvider).isLoading, isTrue);

      await refreshFuture;

      // Should have data
      expect(c.read(todaySuggestionProvider).hasValue, isTrue);
    });

    test(
      'keeps the previous primary while materialization is pending',
      () async {
        final oldBundle = _bundle(primaryId: 'old', sourceVersion: 1);
        final pendingBundle = _bundle(
          materializationStatus: TodaySuggestionMaterializationStatus.pending,
          sourceVersion: 2,
        );
        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(oldBundle));
        stubDaoSuccess();

        final c = buildContainer();
        await c.read(todaySuggestionProvider.future);

        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(pendingBundle));

        await c.read(todaySuggestionProvider.notifier).refresh();

        final result = c.read(todaySuggestionProvider).value!;
        expect(
          result.materializationStatus,
          TodaySuggestionMaterializationStatus.pending,
        );
        expect(result.primary?.id, 'old');
      },
    );

    test(
      'restores cached content before a first pending materialization response',
      () async {
        final cachedBundle = _bundle(primaryId: 'cached', sourceVersion: 1);
        final pendingBundle = _bundle(
          materializationStatus: TodaySuggestionMaterializationStatus.pending,
          sourceVersion: 2,
        );
        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(pendingBundle));
        when(() => mockDao.fetch()).thenAnswer(
          (_) async => TodaySuggestionJsonCodec.bundleToJson(cachedBundle),
        );
        when(() => mockDao.replace(any())).thenAnswer((_) async {});

        final c = buildContainer();
        final result = await c.read(todaySuggestionProvider.future);

        expect(
          result?.materializationStatus,
          TodaySuggestionMaterializationStatus.pending,
        );
        expect(result?.primary?.id, 'cached');
      },
    );

    test(
      'debounces data changes into one GET without feedback or generation',
      () async {
        final bundle = _bundle(primaryId: 's1');
        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(bundle));
        stubDaoSuccess();

        final c = buildContainer();
        await c.read(todaySuggestionProvider.future);
        clearInteractions(mockDataSource);

        final bus = c.read(dataChangeBusProvider.notifier);
        bus.emit(DataChangeTopic.dailyRecords);
        bus.emit(DataChangeTopic.doseLogs);
        bus.emit(DataChangeTopic.userSettings);
        await Future<void>.delayed(const Duration(milliseconds: 350));

        verify(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).called(1);
        verifyNever(
          () => mockDataSource.submitFeedback(
            id: any(named: 'id'),
            feedback: any(named: 'feedback'),
          ),
        );
      },
    );

    test('refreshes when healthEvents topic changes', () async {
      final bundle = _bundle(primaryId: 's1');
      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(bundle));
      stubDaoSuccess();

      final c = buildContainer();
      await c.read(todaySuggestionProvider.future);
      clearInteractions(mockDataSource);

      c.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.healthEvents);
      await Future<void>.delayed(const Duration(milliseconds: 350));

      verify(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).called(1);
    });

    test(
      'serializes overlapping refreshes to prevent stale overwrites',
      () async {
        final initialBundle = _bundle(primaryId: 'initial');
        final olderBundle = _bundle(primaryId: 'older', sourceVersion: 2);
        final newerBundle = _bundle(primaryId: 'newer', sourceVersion: 3);
        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) => TaskEither.right(initialBundle));
        stubDaoSuccess();

        final c = buildContainer();
        final notifier = c.read(todaySuggestionProvider.notifier);
        await c.read(todaySuggestionProvider.future);

        var refreshCall = 0;
        when(
          () => mockDataSource.fetchSuggestions(
            language: any(named: 'language'),
            date: any(named: 'date'),
            excludeIds: any(named: 'excludeIds'),
          ),
        ).thenAnswer((_) {
          refreshCall++;
          if (refreshCall == 1) {
            return TaskEither<LucentFailure, TodaySuggestionBundle>(
              () =>
                  Future<TodaySuggestionBundle>.delayed(
                    const Duration(milliseconds: 30),
                    () => olderBundle,
                  ).then(
                    (value) =>
                        Right<LucentFailure, TodaySuggestionBundle>(value),
                  ),
            );
          }
          return TaskEither.right(newerBundle);
        });

        final firstRefresh = notifier.refresh();
        await Future<void>.delayed(Duration.zero);
        final secondRefresh = notifier.refresh();
        await Future.wait([firstRefresh, secondRefresh]);

        expect(c.read(todaySuggestionProvider).value?.primary?.id, 'newer');
      },
    );

    testWidgets('checks sourceVersion again when the app resumes', (
      tester,
    ) async {
      final initialBundle = _bundle(primaryId: 's1', sourceVersion: 1);
      final refreshedBundle = _bundle(primaryId: 's2', sourceVersion: 2);
      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(initialBundle));
      stubDaoSuccess();

      final c = buildContainer();
      await c.read(todaySuggestionProvider.future);
      clearInteractions(mockDataSource);

      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) => TaskEither.right(refreshedBundle));

      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();

      verify(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).called(1);
      expect(c.read(todaySuggestionProvider).value?.sourceVersion, 2);
      expect(c.read(todaySuggestionProvider).value?.primary?.id, 's2');
    });
  });
}
