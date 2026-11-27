import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/providers/channel.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/features/review/domain/entities/digest.dart';
import 'package:luminous/features/review/domain/repositories/digest.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/data_access.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/shared/domain/failure.dart';

class ReviewDigestController extends Notifier<ReviewDigestCardState> {
  ReviewDigestController(this.range);

  final ReviewDigestRange range;

  @override
  ReviewDigestCardState build() {
    final session = ref.watch(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const ReviewDigestCardState.idle();
    }

    final settings = ref.watch(userSettingsControllerProvider).asData?.value;
    if (settings?.digestEnabled == false) {
      return const ReviewDigestCardState.disabled();
    }

    return const ReviewDigestCardState.idle();
  }

  Future<ReviewDigestCardState> generate() async {
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return state;
    }

    final settings = ref.read(userSettingsControllerProvider).asData?.value;
    if (settings?.digestEnabled == false) {
      state = const ReviewDigestCardState.disabled();
      return state;
    }

    final previousSummary = state.summary;
    state = ReviewDigestCardState.loading(previousSummary: previousSummary);

    String? startDate;
    String? endDate;
    if (range == ReviewDigestRange.custom) {
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
              .read(reviewDigestRepositoryProvider)
              .generateStream(range, startDate: startDate, endDate: endDate)) {
        switch (event) {
          case ReviewDigestSummaryEvent():
            state = ReviewDigestCardState.loading(
              previousSummary: previousSummary,
              streamingSummary: event.summary,
            );
          case ReviewDigestResultEvent():
            state = ReviewDigestCardState.success(event.summary);
            return state;
        }
      }

      // 流结束却没有 result 事件：把「服务端没给出结果」记成与请求失败同形的
      // failure，交给下面统一的 catch 收口（日志 → 403 处理 → error 态）。
      throw const LucentFailureException(
        LucentFailure(
          kind: LucentFailureKind.business,
          code: 'AI_EMPTY_RESULT',
          message: 'Report AI stream ended without a final result.',
        ),
      );
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('ReviewDigestController.generate: failed: $error');
      final apiError = LucentErrorMapper.fromObject(error);
      if (apiError.statusCode == 403) {
        state = const ReviewDigestCardState.disabled();
        return state;
      }

      state = ReviewDigestCardState.error(
        // 保留失败对象：卡片渲染时才拿得到 l10n，在这里取 message 会把
        // 英文诊断串固化进 entity。
        error: apiError,
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

final reviewDigestControllerProvider =
    NotifierProvider.family<
      ReviewDigestController,
      ReviewDigestCardState,
      ReviewDigestRange
    >((range) => ReviewDigestController(range));

class ReviewDigestRangeNotifier extends Notifier<ReviewDigestRange> {
  @override
  ReviewDigestRange build() => ReviewDigestRange.last7Days;

  void setRange(ReviewDigestRange range) {
    state = range;
  }
}

final reviewDigestSummarySelectedRangeProvider =
    NotifierProvider<ReviewDigestRangeNotifier, ReviewDigestRange>(
      ReviewDigestRangeNotifier.new,
    );
