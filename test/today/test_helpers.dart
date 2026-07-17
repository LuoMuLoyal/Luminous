import 'dart:async';

import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/domain/repositories/ai.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';

class StaticTodayRepository implements TodayRepository {
  const StaticTodayRepository(this.dashboard, {this.delay = Duration.zero});

  final TodayDashboard dashboard;

  /// Simulated network delay for testing loading states.
  final Duration delay;

  @override
  Future<TodayDashboard> fetchDashboard() async {
    if (delay != Duration.zero) await Future.delayed(delay);
    return dashboard;
  }

  @override
  Future<TodayDashboard> get signedOutDashboard =>
      Future.value(TodayDashboard.signedOut());
}

class EnabledUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async {
    return userSettings(aiSummariesEnabled: true);
  }
}

class DisabledUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async {
    return userSettings(aiSummariesEnabled: false);
  }
}

class FakeTodayAiRepository implements TodayAiRepository {
  final Completer<TodayAiAnalysis> _completer = Completer<TodayAiAnalysis>();

  @override
  Future<TodayAiAnalysis> generate({String? date}) {
    return _completer.future;
  }

  @override
  Stream<TodayAiGenerationEvent> generateStream({String? date}) async* {
    final analysis = await _completer.future;
    yield TodayAiGenerationResultEvent(analysis);
  }

  void complete(TodayAiAnalysis analysis) {
    _completer.complete(analysis);
  }
}

UserSettings userSettings({required bool aiSummariesEnabled}) {
  return UserSettings(
    aiSummariesEnabled: aiSummariesEnabled,
    dataSharingConsent: false,
    assistantEnabled: true,
    assistantMemoryEnabled: false,
    waterTargetCount: 8,
    assistantContext: const AssistantContextSettings(
      healthProfile: true,
      dailyRecords: true,
      sleepRecords: true,
      currentMedicines: true,
    ),
    updatedAt: '2026-06-12T00:00:00.000Z',
    securityPin: const SecurityPinSettings(enabled: false, lastChangedAt: null),
  );
}

final DateTime generatedAt = DateTime.utc(2026, 6, 12, 10, 23, 45);

// ── Suggestion test helpers ────────────────────────────────────────────────

/// A static suggestion bundle for testing.
const testSuggestionBundle = TodaySuggestionBundle(
  generatedAt: '2026-07-09T10:00:00.000Z',
  primary: TodaySuggestionCard(
    id: 'sug_test_001',
    type: TodaySuggestionType.compliance,
    cardTone: TodaySuggestionCardTone.urgent,
    icon: 'pill',
    title: '上午的阿托伐他汀尚未确认',
    reason: '计划服药时间为 08:00，当前已超时 4 小时且未标记服用。',
    evidence: [
      TodaySuggestionEvidence(
        kind: TodaySuggestionEvidenceKind.reminder,
        label: '计划时间',
        value: '08:00',
      ),
      TodaySuggestionEvidence(
        kind: TodaySuggestionEvidenceKind.record,
        label: '今日状态',
        value: '未确认',
      ),
    ],
    boundary: '此提醒基于您的用药计划，不能替代医生或药师建议。',
    primaryAction: TodaySuggestionAction(
      actionId: 'go_confirm',
      label: '去确认',
      route: '/medicine',
      authRequired: true,
    ),
    confidence: TodaySuggestionConfidence.high,
    ruleId: 'missed_dose_pending',
    ruleVersion: '1.0.0',
    triggerType: TodaySuggestionTriggerType.event,
    lifecycleState: TodaySuggestionLifecycleState.active,
    feedbackOptions: [
      TodaySuggestionFeedback.accepted,
      TodaySuggestionFeedback.later,
      TodaySuggestionFeedback.notApplicable,
    ],
  ),
  secondary: [
    TodaySuggestionCard(
      id: 'sug_test_002',
      type: TodaySuggestionType.behaviorAdvice,
      cardTone: TodaySuggestionCardTone.soft,
      icon: 'droplets',
      title: '今日饮水还差 2 杯',
      reason: '已完成 6/8，少量多次更好。',
      evidence: [
        TodaySuggestionEvidence(
          kind: TodaySuggestionEvidenceKind.record,
          label: '已饮水量',
          value: '6/8',
        ),
      ],
      boundary: '建议饮水量因人而异，请根据自身情况调整。',
      primaryAction: TodaySuggestionAction(
        actionId: 'go_record',
        label: '去记录',
        route: '/record/create?kind=water',
        authRequired: true,
      ),
      confidence: TodaySuggestionConfidence.medium,
      ruleId: 'water_behind_target',
      ruleVersion: '1.0.0',
      triggerType: TodaySuggestionTriggerType.timer,
      lifecycleState: TodaySuggestionLifecycleState.active,
      feedbackOptions: [
        TodaySuggestionFeedback.accepted,
        TodaySuggestionFeedback.later,
        TodaySuggestionFeedback.notApplicable,
        TodaySuggestionFeedback.suppress,
      ],
      subtype: 'water',
    ),
  ],
  observations: [
    TodaySuggestionCard(
      id: 'sug_test_003',
      type: TodaySuggestionType.coverage,
      cardTone: TodaySuggestionCardTone.neutral,
      icon: 'info',
      title: '睡眠数据不足，暂无法生成睡眠趋势建议',
      reason: '需要至少 3 天连续睡眠记录才能建立基线。',
      evidence: [],
      boundary: '记录越多，建议越精准。',
      primaryAction: TodaySuggestionAction(
        actionId: 'go_record_sleep',
        label: '记录睡眠',
        route: '/record/create?kind=sleep',
        authRequired: true,
      ),
      confidence: TodaySuggestionConfidence.high,
      ruleId: 'coverage_explanation',
      ruleVersion: '1.0.0',
      triggerType: TodaySuggestionTriggerType.timer,
      lifecycleState: TodaySuggestionLifecycleState.active,
    ),
  ],
);

/// A [TodaySuggestionNotifier] that returns a static test bundle.
class StaticTodaySuggestionNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() async => testSuggestionBundle;
}

/// A [TodaySuggestionNotifier] that returns null (empty/no suggestions).
class EmptyTodaySuggestionNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() async => null;
}

/// A [TodaySuggestionNotifier] that never completes (loading state).
class LoadingTodaySuggestionNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() =>
      Completer<TodaySuggestionBundle?>().future;
}
