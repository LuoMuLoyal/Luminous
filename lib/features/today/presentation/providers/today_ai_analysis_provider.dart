import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/core/network/lucent_result_code.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/today/data/repositories/lucent_today_ai_repository.dart';
import 'package:luminous/features/today/domain/entities/today_ai_analysis.dart';

class TodayAiAnalysisController extends Notifier<TodayAiAnalysisCardState> {
  @override
  TodayAiAnalysisCardState build() {
    final session = ref.watch(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const TodayAiAnalysisCardState.idle();
    }

    final settings = ref.watch(userSettingsControllerProvider).asData?.value;
    if (settings?.aiSummariesEnabled == false) {
      return const TodayAiAnalysisCardState.disabled();
    }

    return const TodayAiAnalysisCardState.idle();
  }

  Future<TodayAiAnalysisCardState> generate() async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return state;
    }

    final settings = ref.read(userSettingsControllerProvider).asData?.value;
    if (settings?.aiSummariesEnabled == false) {
      state = const TodayAiAnalysisCardState.disabled();
      return state;
    }

    final previousAnalysis = state.analysis;
    state = TodayAiAnalysisCardState.loading(previousAnalysis: previousAnalysis);

    try {
      final analysis = await ref.read(todayAiRepositoryProvider).generate();
      state = TodayAiAnalysisCardState.success(analysis);
      return state;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      if (apiError.code == LucentResultCode.forbidden) {
        state = const TodayAiAnalysisCardState.disabled();
        return state;
      }

      state = TodayAiAnalysisCardState.error(
        message: apiError.message,
        previousAnalysis: previousAnalysis,
      );
      return state;
    }
  }

  void reset() {
    state = const TodayAiAnalysisCardState.idle();
  }
}

final todayAiAnalysisControllerProvider =
    NotifierProvider<TodayAiAnalysisController, TodayAiAnalysisCardState>(
      TodayAiAnalysisController.new,
    );
