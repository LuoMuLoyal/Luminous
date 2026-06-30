import 'dart:async';

import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/today/data/repositories/lucent_today_ai_repository.dart';
import 'package:luminous/features/today/domain/entities/today_ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/domain/repositories/today_repository.dart';

class StaticTodayRepository implements TodayRepository {
  const StaticTodayRepository(this.dashboard);

  final TodayDashboard dashboard;

  @override
  Future<TodayDashboard> fetchDashboard() async {
    return dashboard;
  }
}

class EnabledUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettingsDataDto> build() async {
    return userSettings(aiSummariesEnabled: true);
  }
}

class DisabledUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettingsDataDto> build() async {
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

UserSettingsDataDto userSettings({required bool aiSummariesEnabled}) {
  return UserSettingsDataDto(
    aiSummariesEnabled: aiSummariesEnabled,
    dataSharingConsent: false,
    assistantEnabled: true,
    assistantMemoryEnabled: false,
    assistantContext: AssistantContextSettingsDto(
      healthProfile: true,
      dailyRecords: true,
      sleepRecords: true,
      currentMedicines: true,
    ),
    updatedAt: '2026-06-12T00:00:00.000Z',
  );
}

final DateTime generatedAt = DateTime.utc(2026, 6, 12, 10, 23, 45);
