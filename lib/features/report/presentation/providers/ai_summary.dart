import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/report/data/repositories/lucent_ai_summary.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';
import 'package:luminous/features/report/domain/repositories/ai_summary.dart';
import 'package:luminous/features/report/presentation/providers/dashboard.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';

class ReportAiSummaryController extends Notifier<ReportAiSummaryCardState> {
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
    state = ReportAiSummaryCardState.loading(previousSummary: previousSummary);

    String? startDate;
    String? endDate;
    if (range == ReportAiSummaryRange.custom) {
      final query = ref.read(reportDashboardSelectedQueryProvider);
      if (query.isCustom) {
        startDate = _formatDate(query.startDate);
        endDate = _formatDate(query.endDate);
      } else {
        // Dashboard isn't in custom mode — use its actual date range.
        final cached = ref.read(reportLastDashboardProvider);
        if (cached != null) {
          startDate = cached.startDate;
          endDate = cached.endDate;
        } else {
          final now = clock.now();
          startDate = _formatDate(now.subtract(const Duration(days: 7)));
          endDate = _formatDate(now);
        }
      }
    }

    try {
      await for (final event
          in ref
              .read(reportAiSummaryRepositoryProvider)
              .generateStream(range, startDate: startDate, endDate: endDate)) {
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

      throw StateError('报告 AI 流式响应已结束，但没有返回最终结果。');
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('ReportAiSummaryController.generate: failed: $error');
      final apiError = LucentErrorMapper.fromObject(error);
      if (apiError.statusCode == 403) {
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

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}

final reportAiSummaryControllerProvider =
    NotifierProvider.family<
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

final reportAiSummarySelectedRangeProvider =
    NotifierProvider<
      ReportAiSummarySelectedRangeNotifier,
      ReportAiSummaryRange
    >(ReportAiSummarySelectedRangeNotifier.new);
