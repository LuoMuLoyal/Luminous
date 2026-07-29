import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/database/daos/today_suggestion_dao.dart';
import 'package:luminous/core/database/database_providers.dart';
import 'package:luminous/features/today/data/datasources/suggestion_remote.dart';
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

TodaySuggestionBundle _bundle({String? primaryId}) {
  return TodaySuggestionBundle(
    generatedAt: '2026-07-12T10:00:00Z',
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
      ).thenAnswer((_) async => bundle);
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
      ).thenThrow(Exception('Network error'));
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
        ).thenThrow(Exception('Network error'));
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
      ).thenAnswer((_) async => bundle1);
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
      ).thenAnswer((_) async => bundle2);

      await c.read(todaySuggestionProvider.notifier).dismiss('s1');

      final state = c.read(todaySuggestionProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.primary?.id, 's2');
    });

    test('submitFeedback with suppress adds id to excluded list', () async {
      final bundle1 = _bundle(primaryId: 's1');
      final bundle2 = _bundle(primaryId: 's2');

      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) async => bundle1);
      when(
        () => mockDataSource.submitFeedback(
          id: any(named: 'id'),
          feedback: any(named: 'feedback'),
        ),
      ).thenAnswer(
        (_) async => const TodaySuggestionFeedbackResult(
          suggestionId: 's1',
          feedback: TodaySuggestionFeedback.suppress,
          appliedEffect: TodaySuggestionFeedbackEffect.suppressedType,
        ),
      );
      stubDaoSuccess();

      final c = buildContainer();
      await c.read(todaySuggestionProvider.future);

      // Next fetch should exclude 's1'
      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) async => bundle2);

      await c
          .read(todaySuggestionProvider.notifier)
          .submitFeedback(
            suggestionId: 's1',
            feedback: TodaySuggestionFeedback.suppress,
          );

      final state = c.read(todaySuggestionProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.primary?.id, 's2');
    });

    test('refresh re-fetches suggestions', () async {
      final bundle1 = _bundle(primaryId: 's1');
      final bundle2 = _bundle(primaryId: 's2');

      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) async => bundle1);
      stubDaoSuccess();

      final c = buildContainer();
      await c.read(todaySuggestionProvider.future);

      when(
        () => mockDataSource.fetchSuggestions(
          language: any(named: 'language'),
          date: any(named: 'date'),
          excludeIds: any(named: 'excludeIds'),
        ),
      ).thenAnswer((_) async => bundle2);

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
      ).thenAnswer((_) async => bundle);
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
  });
}
