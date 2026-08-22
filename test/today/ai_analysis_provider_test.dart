import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/data/repositories/lucent_ai.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/repositories/ai.dart';
import 'package:luminous/features/today/presentation/providers/ai_analysis.dart';

import '../helpers/test_helpers.dart';
import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Today AI provider stays idle when signed out', () async {
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      todayAiAnalysisControllerProvider.future,
    );

    expect(state.status, TodayAiAnalysisCardStatus.idle);
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
      todayAiAnalysisControllerProvider.future,
    );

    expect(state.status, TodayAiAnalysisCardStatus.disabled);
  });

  test('Today AI provider maps empty read state', () async {
    final repository = _StaticTodayAiRepository(
      TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: '',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayAiAnalysisMaterializationStatus.empty,
        aiGenerated: false,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayAiRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    final state = await container.read(
      todayAiAnalysisControllerProvider.future,
    );

    expect(state.status, TodayAiAnalysisCardStatus.success);
    expect(
      state.materializationStatus,
      TodayAiAnalysisMaterializationStatus.empty,
    );
    expect(state.analysis, isNull);
  });

  test('Today AI provider maps ready state with aiGenerated true', () async {
    final repository = _StaticTodayAiRepository(
      TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Hydration still needs attention today.',
        bullets: const [
          TodayAiAnalysisBullet(
            kind: TodayAiAnalysisBulletKind.hydration,
            text: 'Two water check-ins are still missing.',
          ),
        ],
        actionLabel: 'View today',
        confidenceNote: 'Generated from today records only.',
        materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
        aiGenerated: true,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayAiRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    final state = await container.read(
      todayAiAnalysisControllerProvider.future,
    );

    expect(state.status, TodayAiAnalysisCardStatus.success);
    expect(
      state.materializationStatus,
      TodayAiAnalysisMaterializationStatus.ready,
    );
    expect(state.analysis?.summary, 'Hydration still needs attention today.');
    expect(state.analysis?.aiGenerated, isTrue);
  });

  test('Today AI provider maps ready state with aiGenerated false', () async {
    final repository = _StaticTodayAiRepository(
      TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Rule-based summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
        aiGenerated: false,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayAiRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    final state = await container.read(
      todayAiAnalysisControllerProvider.future,
    );

    expect(state.analysis?.aiGenerated, isFalse);
  });

  test(
    'Today AI provider preserves previous analysis on pending/stale/failed',
    () async {
      final readyAnalysis = TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Original summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
        aiGenerated: true,
      );
      final repository = _SequenceTodayAiRepository([
        readyAnalysis,
        TodayAiAnalysis(
          date: '2026-06-12',
          generatedAt: generatedAt,
          summary: '',
          bullets: const [],
          actionLabel: '',
          confidenceNote: '',
          materializationStatus: TodayAiAnalysisMaterializationStatus.pending,
          aiGenerated: true,
        ),
      ]);

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final firstState = await container.read(
        todayAiAnalysisControllerProvider.future,
      );
      expect(firstState.analysis?.summary, 'Original summary.');

      await container
          .read(todayAiAnalysisControllerProvider.notifier)
          .refresh();

      final secondState = container
          .read(todayAiAnalysisControllerProvider)
          .asData
          ?.value;
      expect(secondState, isNotNull);
      expect(
        secondState!.materializationStatus,
        TodayAiAnalysisMaterializationStatus.pending,
      );
      expect(secondState.analysis?.summary, 'Original summary.');
    },
  );

  test('Today AI provider refresh action updates state', () async {
    final repository = _SequenceTodayAiRepository([
      TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'First summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
        aiGenerated: true,
      ),
      TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Refreshed summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
        aiGenerated: true,
      ),
    ]);

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayAiRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    await container.read(todayAiAnalysisControllerProvider.future);
    await container.read(todayAiAnalysisControllerProvider.notifier).refresh();

    final state = container
        .read(todayAiAnalysisControllerProvider)
        .asData
        ?.value;
    expect(state?.analysis?.summary, 'Refreshed summary.');
  });

  test('Today AI provider re-reads on relevant DataChangeBus topic', () async {
    final repository = _CallCountingTodayAiRepository(
      TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
        aiGenerated: true,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        userSettingsControllerProvider.overrideWith(
          EnabledUserSettingsController.new,
        ),
        todayAiRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);
    await container.read(todayAiAnalysisControllerProvider.future);

    expect(repository.readCount, 1);

    container
        .read(dataChangeBusProvider.notifier)
        .emit(DataChangeTopic.dailyRecords);

    await Future.delayed(const Duration(milliseconds: 400));

    expect(repository.readCount, greaterThan(1));
  });

  test('Today AI provider maps forbidden error to disabled state', () async {
    const repository = _ThrowingTodayAiRepository(
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
        todayAiRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    await container.read(todayAiAnalysisControllerProvider.notifier).refresh();

    final state = container
        .read(todayAiAnalysisControllerProvider)
        .asData
        ?.value;
    expect(state?.status, TodayAiAnalysisCardStatus.disabled);
  });

  test('Today AI provider maps generic refresh error to error state', () async {
    const repository = _ThrowingTodayAiRepository(
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
        todayAiRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userSettingsControllerProvider.future);

    await container.read(todayAiAnalysisControllerProvider.notifier).refresh();

    final asyncValue = container.read(todayAiAnalysisControllerProvider);
    expect(asyncValue.hasError, isTrue);
  });

  test(
    'Today AI provider maps initial forbidden read to disabled state',
    () async {
      const repository = _ThrowingTodayAiRepository(
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
          todayAiRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);

      final state = await container.read(
        todayAiAnalysisControllerProvider.future,
      );

      expect(state.status, TodayAiAnalysisCardStatus.disabled);
    },
  );

  test(
    'Today AI provider re-reads on healthEvents DataChangeBus topic',
    () async {
      final repository = _CallCountingTodayAiRepository(
        TodayAiAnalysis(
          date: '2026-06-12',
          generatedAt: generatedAt,
          summary: 'Summary.',
          bullets: const [],
          actionLabel: '',
          confidenceNote: '',
          materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
          aiGenerated: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);
      await container.read(todayAiAnalysisControllerProvider.future);

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
      final firstAnalysis = TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'First summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
        aiGenerated: true,
        sourceVersion: 1,
        computedVersion: 1,
      );
      final secondAnalysis = TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt.add(const Duration(seconds: 1)),
        summary: 'Second summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
        aiGenerated: true,
        sourceVersion: 2,
        computedVersion: 2,
      );
      final repository = _SequenceTodayAiRepository([
        firstAnalysis,
        secondAnalysis,
      ]);

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);
      await container.read(todayAiAnalysisControllerProvider.future);

      expect(
        container
            .read(todayAiAnalysisControllerProvider)
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
          .read(todayAiAnalysisControllerProvider)
          .asData
          ?.value;
      expect(state?.analysis?.summary, 'Second summary.');
      expect(state?.sourceVersion, 2);
    },
  );

  testWidgets(
    'resumed diff keeps state when sourceVersion and computedAt are unchanged',
    (tester) async {
      final analysis = TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Stable summary.',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: TodayAiAnalysisMaterializationStatus.ready,
        aiGenerated: true,
        sourceVersion: 1,
        computedVersion: 1,
      );
      final repository = _StaticTodayAiRepository(analysis);

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
          userSettingsControllerProvider.overrideWith(
            EnabledUserSettingsController.new,
          ),
          todayAiRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userSettingsControllerProvider.future);
      await container.read(todayAiAnalysisControllerProvider.future);

      final firstState = container.read(todayAiAnalysisControllerProvider);

      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();

      final secondState = container.read(todayAiAnalysisControllerProvider);
      expect(secondState.asData?.value.analysis?.summary, 'Stable summary.');
      expect(identical(firstState, secondState), isTrue);
    },
  );
}

class _StaticTodayAiRepository implements TodayAiRepository {
  const _StaticTodayAiRepository(this.analysis);

  final TodayAiAnalysis analysis;

  @override
  Future<TodayAiAnalysis> read(DateTime date) async => analysis;

  @override
  Future<TodayAiAnalysis> refresh(DateTime date) async => analysis;

  @override
  Future<TodayAiAnalysis> generate({String? date}) async => analysis;

  @override
  Stream<TodayAiGenerationEvent> generateStream({String? date}) async* {
    yield TodayAiGenerationResultEvent(analysis);
  }
}

class _SequenceTodayAiRepository implements TodayAiRepository {
  _SequenceTodayAiRepository(this.analyses);

  final List<TodayAiAnalysis> analyses;
  var _index = 0;

  TodayAiAnalysis get _next {
    final analysis = analyses[_index];
    if (_index < analyses.length - 1) {
      _index++;
    }
    return analysis;
  }

  @override
  Future<TodayAiAnalysis> read(DateTime date) async => _next;

  @override
  Future<TodayAiAnalysis> refresh(DateTime date) async => _next;

  @override
  Future<TodayAiAnalysis> generate({String? date}) async => _next;

  @override
  Stream<TodayAiGenerationEvent> generateStream({String? date}) async* {
    yield TodayAiGenerationResultEvent(_next);
  }
}

class _CallCountingTodayAiRepository implements TodayAiRepository {
  _CallCountingTodayAiRepository(this.analysis);

  final TodayAiAnalysis analysis;
  int readCount = 0;

  @override
  Future<TodayAiAnalysis> read(DateTime date) async {
    readCount++;
    return analysis;
  }

  @override
  Future<TodayAiAnalysis> refresh(DateTime date) async {
    readCount++;
    return analysis;
  }

  @override
  Future<TodayAiAnalysis> generate({String? date}) async => analysis;

  @override
  Stream<TodayAiGenerationEvent> generateStream({String? date}) async* {
    yield TodayAiGenerationResultEvent(analysis);
  }
}

class _ThrowingTodayAiRepository implements TodayAiRepository {
  const _ThrowingTodayAiRepository(this.error);

  final Object error;

  @override
  Future<TodayAiAnalysis> read(DateTime date) {
    return Future<TodayAiAnalysis>.error(error);
  }

  @override
  Future<TodayAiAnalysis> refresh(DateTime date) {
    return Future<TodayAiAnalysis>.error(error);
  }

  @override
  Future<TodayAiAnalysis> generate({String? date}) {
    return Future<TodayAiAnalysis>.error(error);
  }

  @override
  Stream<TodayAiGenerationEvent> generateStream({String? date}) {
    return Stream<TodayAiGenerationEvent>.error(error);
  }
}
