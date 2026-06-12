import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/network/lucent_result_code.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/today/data/repositories/lucent_today_ai_repository.dart';
import 'package:luminous/features/today/domain/entities/today_ai_analysis.dart';
import 'package:luminous/features/today/presentation/providers/today_ai_analysis_provider.dart';

import 'today_test_helpers.dart';

void main() {
  test('Today AI provider stays idle when signed out', () async {
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(todayAiAnalysisControllerProvider).status,
      TodayAiAnalysisCardStatus.idle,
    );

    final result = await container
        .read(todayAiAnalysisControllerProvider.notifier)
        .generate();

    expect(result.status, TodayAiAnalysisCardStatus.idle);
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

    final result = await container
        .read(todayAiAnalysisControllerProvider.notifier)
        .generate();

    expect(result.status, TodayAiAnalysisCardStatus.disabled);
    expect(
      container.read(todayAiAnalysisControllerProvider).status,
      TodayAiAnalysisCardStatus.disabled,
    );
  });

  test('Today AI provider stores success result', () async {
    final repository = _ImmediateTodayAiRepository(
      TodayAiAnalysis(
        date: '2026-06-12',
        generatedAt: generatedAt,
        summary: 'Hydration still needs attention today.',
        bullets: const [
          TodayAiAnalysisBullet(
            kind: TodayAiAnalysisBulletKind.hydration,
            text: 'Two water check-ins are still missing.',
          ),
          TodayAiAnalysisBullet(
            kind: TodayAiAnalysisBulletKind.general,
            text: 'Keep logging tonight to complete the day.',
          ),
        ],
        actionLabel: 'View today',
        confidenceNote: 'Generated from today records only.',
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

    final result = await container
        .read(todayAiAnalysisControllerProvider.notifier)
        .generate();

    expect(result.status, TodayAiAnalysisCardStatus.success);
    expect(result.analysis?.summary, 'Hydration still needs attention today.');
    expect(
      container.read(todayAiAnalysisControllerProvider).analysis?.summary,
      'Hydration still needs attention today.',
    );
  });

  test('Today AI provider maps forbidden error to disabled state', () async {
    final repository = _ThrowingTodayAiRepository(
      const LucentApiException(
        message: 'AI summaries are disabled for this user',
        code: LucentResultCode.forbidden,
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

    final result = await container
        .read(todayAiAnalysisControllerProvider.notifier)
        .generate();

    expect(result.status, TodayAiAnalysisCardStatus.disabled);
  });

  test('Today AI provider maps generic error to error state', () async {
    final repository = _ThrowingTodayAiRepository(
      const LucentApiException(message: 'Network request failed.'),
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

    final result = await container
        .read(todayAiAnalysisControllerProvider.notifier)
        .generate();

    expect(result.status, TodayAiAnalysisCardStatus.error);
    expect(result.errorMessage, 'Network request failed.');
  });
}

class _ImmediateTodayAiRepository implements TodayAiRepository {
  const _ImmediateTodayAiRepository(this.analysis);

  final TodayAiAnalysis analysis;

  @override
  Future<TodayAiAnalysis> generate({String? date}) async {
    return analysis;
  }
}

class _ThrowingTodayAiRepository implements TodayAiRepository {
  const _ThrowingTodayAiRepository(this.error);

  final Object error;

  @override
  Future<TodayAiAnalysis> generate({String? date}) {
    return Future<TodayAiAnalysis>.error(error);
  }
}
