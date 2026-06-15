import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/core/network/lucent_result_code.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/report/data/repositories/lucent_report_ai_summary_repository.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';

class ReportAiSummaryController extends Notifier<ReportAiSummaryCardState> {
  static const String _defaultStreamingSummary = 'AI 正在整理本阶段的报告摘要...';

  ReportAiSummaryController(this.range);

  final ReportAiSummaryRange range;

  @override
  ReportAiSummaryCardState build() {
    final session = ref.watch(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const ReportAiSummaryCardState.idle();
    }

    final settings = ref.watch(userSettingsControllerProvider).asData?.value;
    if (settings?.aiSummariesEnabled == false) {
      return const ReportAiSummaryCardState.disabled();
    }

    return const ReportAiSummaryCardState.idle();
  }

  Future<ReportAiSummaryCardState> generate() async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return state;
    }

    final settings = ref.read(userSettingsControllerProvider).asData?.value;
    if (settings?.aiSummariesEnabled == false) {
      state = const ReportAiSummaryCardState.disabled();
      return state;
    }

    final previousSummary = state.summary;
    state = ReportAiSummaryCardState.loading(
      previousSummary: previousSummary,
      streamingSummary: _defaultStreamingSummary,
    );

    try {
      await for (final event in ref
          .read(reportAiSummaryRepositoryProvider)
          .generateStream(range)) {
        switch (event) {
          case ReportAiGenerationSummaryEvent():
            state = ReportAiSummaryCardState.loading(
              previousSummary: previousSummary,
              streamingSummary: event.summary,
            );
          case ReportAiGenerationResultEvent():
            state = ReportAiSummaryCardState.success(event.summary);
            return state;
        }
      }

      throw StateError('Report AI stream ended without a final result.');
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      if (apiError.code == LucentResultCode.forbidden) {
        state = const ReportAiSummaryCardState.disabled();
        return state;
      }

      state = ReportAiSummaryCardState.error(
        message: apiError.message,
        previousSummary: previousSummary,
      );
      return state;
    }
  }
}

final reportAiSummaryControllerProvider = NotifierProvider.family<
  ReportAiSummaryController,
  ReportAiSummaryCardState,
  ReportAiSummaryRange
>((range) => ReportAiSummaryController(range));

class ReportAiSummarySelectedRangeNotifier
    extends Notifier<ReportAiSummaryRange> {
  @override
  ReportAiSummaryRange build() => ReportAiSummaryRange.last7Days;

  void setRange(ReportAiSummaryRange range) {
    state = range;
  }
}

final reportAiSummarySelectedRangeProvider = NotifierProvider<
  ReportAiSummarySelectedRangeNotifier,
  ReportAiSummaryRange
>(ReportAiSummarySelectedRangeNotifier.new);
