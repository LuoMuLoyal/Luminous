import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/review/data/repositories/lucent_ai_summary.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/repositories/ai_summary.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';

class ReviewAiSummaryController extends Notifier<ReviewAiSummaryCardState> {
  ReviewAiSummaryController(this.range);

  final ReviewAiSummaryRange range;

  @override
  ReviewAiSummaryCardState build() {
    final session = ref.watch(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const ReviewAiSummaryCardState.idle();
    }

    final settings = ref.watch(userSettingsControllerProvider).asData?.value;
    if (settings?.aiSummariesEnabled == false) {
      return const ReviewAiSummaryCardState.disabled();
    }

    return const ReviewAiSummaryCardState.idle();
  }

  Future<ReviewAiSummaryCardState> generate() async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return state;
    }

    final settings = ref.read(userSettingsControllerProvider).asData?.value;
    if (settings?.aiSummariesEnabled == false) {
      state = const ReviewAiSummaryCardState.disabled();
      return state;
    }

    final previousSummary = state.summary;
    state = ReviewAiSummaryCardState.loading(previousSummary: previousSummary);

    String? startDate;
    String? endDate;
    if (range == ReviewAiSummaryRange.custom) {
      final query = ref.read(reviewDashboardSelectedQueryProvider);
      if (query.isCustom) {
        startDate = _formatDate(query.startDate);
        endDate = _formatDate(query.endDate);
      } else {
        // Dashboard isn't in custom mode — use its actual date range.
        final cached = ref.read(reviewLastDashboardProvider);
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
              .read(reviewAiSummaryRepositoryProvider)
              .generateStream(range, startDate: startDate, endDate: endDate)) {
        switch (event) {
          case ReviewAiGenerationSummaryEvent():
            state = ReviewAiSummaryCardState.loading(
              previousSummary: previousSummary,
              streamingSummary: event.summary,
            );
          case ReviewAiGenerationResultEvent():
            state = ReviewAiSummaryCardState.success(event.summary);
            return state;
        }
      }

      throw const LucentFailure(
        kind: LucentFailureKind.business,
        code: 'AI_EMPTY_RESULT',
        message: 'Report AI stream ended without a final result.',
      );
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('ReviewAiSummaryController.generate: failed: $error');
      final apiError = LucentErrorMapper.fromObject(error);
      if (apiError.statusCode == 403) {
        state = const ReviewAiSummaryCardState.disabled();
        return state;
      }

      state = ReviewAiSummaryCardState.error(
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

final reviewAiSummaryControllerProvider =
    NotifierProvider.family<
      ReviewAiSummaryController,
      ReviewAiSummaryCardState,
      ReviewAiSummaryRange
    >((range) => ReviewAiSummaryController(range));

class ReviewAiSummarySelectedRangeNotifier
    extends Notifier<ReviewAiSummaryRange> {
  @override
  ReviewAiSummaryRange build() => ReviewAiSummaryRange.last7Days;

  void setRange(ReviewAiSummaryRange range) {
    state = range;
  }
}

final reviewAiSummarySelectedRangeProvider =
    NotifierProvider<
      ReviewAiSummarySelectedRangeNotifier,
      ReviewAiSummaryRange
    >(ReviewAiSummarySelectedRangeNotifier.new);
