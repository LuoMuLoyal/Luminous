import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/data/repositories/lucent_briefing.dart';
import 'package:luminous/features/today/domain/entities/briefing.dart';
import 'package:luminous/features/today/domain/repositories/briefing.dart';
import 'package:luminous/features/today/presentation/providers/briefing.dart';
import 'package:luminous/shared/domain/failure.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_helpers.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    KvTestStore.install();
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  test('Today AI provider stays idle when signed out', () async {
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      todayBriefingAnalysisControllerProvider.future,
    );

    expect(state.status, TodayBriefingCardStatus.idle);
  });

  test('Today AI provider returns disabled when user setting is off', () async {
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

    final state = await container.read(
      todayBriefingAnalysisControllerProvider.future,
    );

    expect(state.status, TodayBriefingCardStatus.disabled);
  });

  test('Today AI provider maps empty read state', () async {
    final repository = _StaticTodayBriefingRepository(
      TodayBriefing(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: '',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayBriefingMaterializationStatus.empty,
        briefingGenerated: false,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayBriefingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    final state = await container.read(
      todayBriefingAnalysisControllerProvider.future,
    );

    expect(state.status, TodayBriefingCardStatus.success);
    expect(
      state.materializationStatus,
      TodayBriefingMaterializationStatus.empty,
    );
    expect(state.analysis, isNull);
  });

  test(
    'Today AI provider maps ready state with briefingGenerated true',
    () async {
      final repository = _StaticTodayBriefingRepository(
        TodayBriefing(
          date: '2026-06-12',
          generatedAt: generatedAt,
          summary: 'Hydration still needs attention today.',
          bullets: const [
            TodayBriefingBullet(
              kind: TodayBriefingBulletKind.hydration,
              text: 'Two water check-ins are still missing.',
            ),
          ],
          actionLabel: 'View today',
          confidenceNote: 'Generated from today records only.',
          materializationStatus: TodayBriefingMaterializationStatus.ready,
          briefingGenerated: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayBriefingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final state = await container.read(
        todayBriefingAnalysisControllerProvider.future,
      );

      expect(state.status, TodayBriefingCardStatus.success);
      expect(
        state.materializationStatus,
        TodayBriefingMaterializationStatus.ready,
      );
      expect(state.analysis?.summary, 'Hydration still needs attention today.');
      expect(state.analysis?.briefingGenerated, isTrue);
    },
  );

  test(
    'Today AI provider maps ready state with briefingGenerated false',
    () async {
      final repository = _StaticTodayBriefingRepository(
        TodayBriefing(
          date: '2026-06-12',
          generatedAt: generatedAt,
          summary: 'Rule-based summary.',
          bullets: const [],
          actionLabel: '',
          confidenceNote: '',
          materializationStatus: TodayBriefingMaterializationStatus.ready,
          briefingGenerated: false,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayBriefingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final state = await container.read(
        todayBriefingAnalysisControllerProvider.future,
      );

      expect(state.analysis?.briefingGenerated, isFalse);
    },
  );

  test(
    'Today AI provider preserves previous analysis on pending/stale/failed',
    () async {
      final readyAnalysis = TodayBriefing(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Original summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayBriefingMaterializationStatus.ready,
        briefingGenerated: true,
      );
      final repository = _SequenceTodayBriefingRepository([
        readyAnalysis,
        TodayBriefing(
          date: '2026-06-12',
          generatedAt: generatedAt,
          summary: '',
          bullets: const [],
          actionLabel: '',
          confidenceNote: '',
          materializationStatus: TodayBriefingMaterializationStatus.pending,
          briefingGenerated: true,
        ),
      ]);

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayBriefingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final firstState = await container.read(
        todayBriefingAnalysisControllerProvider.future,
      );
      expect(firstState.analysis?.summary, 'Original summary.');

      await container
          .read(todayBriefingAnalysisControllerProvider.notifier)
          .refresh();

      final secondState = container
          .read(todayBriefingAnalysisControllerProvider)
          .asData
          ?.value;
      expect(secondState, isNotNull);
      expect(
        secondState!.materializationStatus,
        TodayBriefingMaterializationStatus.pending,
      );
      expect(secondState.analysis?.summary, 'Original summary.');
    },
  );

  test('Today AI provider refresh action updates state', () async {
    final repository = _SequenceTodayBriefingRepository([
      TodayBriefing(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'First summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayBriefingMaterializationStatus.ready,
        briefingGenerated: true,
      ),
      TodayBriefing(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Refreshed summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayBriefingMaterializationStatus.ready,
        briefingGenerated: true,
      ),
    ]);

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayBriefingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    await container.read(todayBriefingAnalysisControllerProvider.future);
    await container
        .read(todayBriefingAnalysisControllerProvider.notifier)
        .refresh();

    final state = container
        .read(todayBriefingAnalysisControllerProvider)
        .asData
        ?.value;
    expect(state?.analysis?.summary, 'Refreshed summary.');
  });

  test('Today AI provider re-reads on relevant DataChangeBus topic', () async {
    final repository = _CallCountingTodayBriefingRepository(
      TodayBriefing(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayBriefingMaterializationStatus.ready,
        briefingGenerated: true,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayBriefingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);
    await container.read(todayBriefingAnalysisControllerProvider.future);

    expect(repository.readCount, 1);

    container
        .read(dataChangeBusProvider.notifier)
        .emit(DataChangeTopic.dailyRecords);

    await Future.delayed(const Duration(milliseconds: 400));

    expect(repository.readCount, greaterThan(1));
  });

  test('Today AI provider maps forbidden error to disabled state', () async {
    const repository = _ThrowingTodayBriefingRepository(
      LucentFailure(
        kind: LucentFailureKind.authentication,
        message: 'AI summaries are disabled for this user',
        code: 'FORBIDDEN',
        statusCode: 403,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayBriefingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    await container
        .read(todayBriefingAnalysisControllerProvider.notifier)
        .refresh();

    final state = container
        .read(todayBriefingAnalysisControllerProvider)
        .asData
        ?.value;
    expect(state?.status, TodayBriefingCardStatus.disabled);
  });

  test('Today AI provider maps generic refresh error to error state', () async {
    const repository = _ThrowingTodayBriefingRepository(
      LucentFailure(
        kind: LucentFailureKind.network,
        message: 'Network request failed.',
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayBriefingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    await container
        .read(todayBriefingAnalysisControllerProvider.notifier)
        .refresh();

    final asyncValue = container.read(todayBriefingAnalysisControllerProvider);
    expect(asyncValue.hasError, isTrue);
  });

  test(
    'Today AI provider projects refresh FormatException to an AsyncError',
    () async {
      final repository = _FormatExceptionTodayBriefingRepository();

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayBriefingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);
      await container.read(todayBriefingAnalysisControllerProvider.future);

      // A malformed (non-problem+json) body surfaces as a FormatException
      // from the repository; refresh() must not rethrow — it projects the
      // failure into an AsyncError state.
      await container
          .read(todayBriefingAnalysisControllerProvider.notifier)
          .refresh();

      final asyncValue = container.read(
        todayBriefingAnalysisControllerProvider,
      );
      expect(asyncValue.hasError, isTrue);
      expect(asyncValue.error, isA<LucentFailure>());
      expect(
        (asyncValue.error as LucentFailure).kind,
        LucentFailureKind.unknown,
      );
    },
  );

  test(
    'Today AI provider maps initial forbidden read to disabled state',
    () async {
      const repository = _ThrowingTodayBriefingRepository(
        LucentFailure(
          kind: LucentFailureKind.authentication,
          message: 'AI summaries are disabled for this user',
          code: 'FORBIDDEN',
          statusCode: 403,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayBriefingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final state = await container.read(
        todayBriefingAnalysisControllerProvider.future,
      );

      expect(state.status, TodayBriefingCardStatus.disabled);
    },
  );

  test(
    'Today AI provider re-reads on healthEvents DataChangeBus topic',
    () async {
      final repository = _CallCountingTodayBriefingRepository(
        TodayBriefing(
          date: '2026-06-12',
          generatedAt: generatedAt,
          summary: 'Summary.',
          bullets: const [],
          actionLabel: '',
          confidenceNote: '',
          materializationStatus: TodayBriefingMaterializationStatus.ready,
          briefingGenerated: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayBriefingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);
      await container.read(todayBriefingAnalysisControllerProvider.future);

      expect(repository.readCount, 1);

      container
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.healthEvents);

      await Future.delayed(const Duration(milliseconds: 400));

      expect(repository.readCount, greaterThan(1));
    },
  );

  testWidgets(
    'resumed diff updates state when sourceVersion or computedAt change',
    (tester) async {
      final firstAnalysis = TodayBriefing(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'First summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayBriefingMaterializationStatus.ready,
        briefingGenerated: true,
        sourceVersion: 1,
        computedVersion: 1,
      );
      final secondAnalysis = TodayBriefing(
        date: '2026-06-12',
        generatedAt: generatedAt.add(const Duration(seconds: 1)),
        summary: 'Second summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayBriefingMaterializationStatus.ready,
        briefingGenerated: true,
        sourceVersion: 2,
        computedVersion: 2,
      );
      final repository = _SequenceTodayBriefingRepository([
        firstAnalysis,
        secondAnalysis,
      ]);

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayBriefingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);
      await container.read(todayBriefingAnalysisControllerProvider.future);

      expect(
        container
            .read(todayBriefingAnalysisControllerProvider)
            .asData
            ?.value
            .analysis
            ?.summary,
        'First summary.',
      );

      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();

      final state = container
          .read(todayBriefingAnalysisControllerProvider)
          .asData
          ?.value;
      expect(state?.analysis?.summary, 'Second summary.');
      expect(state?.sourceVersion, 2);
    },
  );

  testWidgets(
    'resumed diff keeps state when sourceVersion and computedAt are unchanged',
    (tester) async {
      final analysis = TodayBriefing(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Stable summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayBriefingMaterializationStatus.ready,
        briefingGenerated: true,
        sourceVersion: 1,
        computedVersion: 1,
      );
      final repository = _StaticTodayBriefingRepository(analysis);

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayBriefingRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);
      await container.read(todayBriefingAnalysisControllerProvider.future);

      final firstState = container.read(
        todayBriefingAnalysisControllerProvider,
      );

      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();

      final secondState = container.read(
        todayBriefingAnalysisControllerProvider,
      );
      expect(secondState.asData?.value.analysis?.summary, 'Stable summary.');
      expect(identical(firstState, secondState), isTrue);
    },
  );
}

class _StaticTodayBriefingRepository implements TodayBriefingRepository {
  const _StaticTodayBriefingRepository(this.analysis);

  final TodayBriefing analysis;

  @override
  TaskEither<LucentFailure, TodayBriefing> read(DateTime date) =>
      TaskEither.right(analysis);

  @override
  TaskEither<LucentFailure, TodayBriefing> refresh(DateTime date) =>
      TaskEither.right(analysis);

  @override
  TaskEither<LucentFailure, TodayBriefing> generate({String? date}) =>
      TaskEither.right(analysis);

  @override
  Stream<TodayBriefingEvent> generateStream({String? date}) async* {
    yield TodayBriefingResultEvent(analysis);
  }
}

class _SequenceTodayBriefingRepository implements TodayBriefingRepository {
  _SequenceTodayBriefingRepository(this.analyses);

  final List<TodayBriefing> analyses;
  var _index = 0;

  TodayBriefing get _next {
    final analysis = analyses[_index];
    if (_index < analyses.length - 1) {
      _index++;
    }
    return analysis;
  }

  @override
  TaskEither<LucentFailure, TodayBriefing> read(DateTime date) =>
      TaskEither.right(_next);

  @override
  TaskEither<LucentFailure, TodayBriefing> refresh(DateTime date) =>
      TaskEither.right(_next);

  @override
  TaskEither<LucentFailure, TodayBriefing> generate({String? date}) =>
      TaskEither.right(_next);

  @override
  Stream<TodayBriefingEvent> generateStream({String? date}) async* {
    yield TodayBriefingResultEvent(_next);
  }
}

class _CallCountingTodayBriefingRepository implements TodayBriefingRepository {
  _CallCountingTodayBriefingRepository(this.analysis);

  final TodayBriefing analysis;
  int readCount = 0;

  @override
  TaskEither<LucentFailure, TodayBriefing> read(DateTime date) =>
      TaskEither(() async {
        readCount++;
        return Right(analysis);
      });

  @override
  TaskEither<LucentFailure, TodayBriefing> refresh(DateTime date) =>
      TaskEither(() async {
        readCount++;
        return Right(analysis);
      });

  @override
  TaskEither<LucentFailure, TodayBriefing> generate({String? date}) =>
      TaskEither.right(analysis);

  @override
  Stream<TodayBriefingEvent> generateStream({String? date}) async* {
    yield TodayBriefingResultEvent(analysis);
  }
}

class _ThrowingTodayBriefingRepository implements TodayBriefingRepository {
  const _ThrowingTodayBriefingRepository(this.error);

  final LucentFailure error;

  @override
  TaskEither<LucentFailure, TodayBriefing> read(DateTime date) =>
      TaskEither.left(error);

  @override
  TaskEither<LucentFailure, TodayBriefing> refresh(DateTime date) =>
      TaskEither.left(error);

  @override
  TaskEither<LucentFailure, TodayBriefing> generate({String? date}) =>
      TaskEither.left(error);

  @override
  Stream<TodayBriefingEvent> generateStream({String? date}) {
    return Stream<TodayBriefingEvent>.error(error);
  }
}

/// Read succeeds but [refresh] throws a [FormatException] — simulating a
/// malformed (non-problem+json) response body at the HTTP boundary.
class _FormatExceptionTodayBriefingRepository
    implements TodayBriefingRepository {
  TodayBriefing get _analysis => TodayBriefing(
    date: '2026-06-12',
    generatedAt: generatedAt,
    summary: 'Existing summary.',
    bullets: const [],
    actionLabel: '',
    confidenceNote: '',
    materializationStatus: TodayBriefingMaterializationStatus.ready,
    briefingGenerated: true,
  );

  @override
  TaskEither<LucentFailure, TodayBriefing> read(DateTime date) =>
      TaskEither.right(_analysis);

  @override
  TaskEither<LucentFailure, TodayBriefing> refresh(DateTime date) =>
      TaskEither(() async {
        throw const FormatException('malformed response body');
      });

  @override
  TaskEither<LucentFailure, TodayBriefing> generate({String? date}) =>
      TaskEither.right(_analysis);

  @override
  Stream<TodayBriefingEvent> generateStream({String? date}) async* {
    yield TodayBriefingResultEvent(_analysis);
  }
}
