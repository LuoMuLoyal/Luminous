import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/providers/channel.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/core/providers/session/auth_guarded.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/data_access.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard.g.dart';

const _reviewDashboardTimeout = Duration(seconds: 5);

/// Caches the last successfully loaded [ReviewDashboard] so that switching
/// time ranges can show stale data instead of a full skeleton.
class ReviewLastDashboardNotifier extends Notifier<ReviewDashboard?> {
  @override
  ReviewDashboard? build() => null;

  void set(ReviewDashboard dashboard) {
    state = dashboard;
  }
}

final reviewLastDashboardProvider =
    NotifierProvider<ReviewLastDashboardNotifier, ReviewDashboard?>(
      ReviewLastDashboardNotifier.new,
    );

@Riverpod(keepAlive: true)
Future<ReviewDashboard> reviewDashboard(
  Ref ref,
  ReviewDashboardQuery query,
) async {
  // Watch cross-feature data change topics.
  ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));

  return authGuarded(
    ref: ref,
    fetch: () {
      final result = ref
          .watch(reviewDashboardRepositoryProvider)
          .fetchDashboard(query);
      return unwrapFailure(
        result.run().timeout(
          _reviewDashboardTimeout,
          onTimeout: () => Either.left(
            timeoutFailure(
              code: NetworkErrorCode.receiveTimeout,
              message: 'review_dashboard_timeout',
            ),
          ),
        ),
      );
    },
    signedOutFallback: () async {
      final repo = ref.watch(reviewDashboardRepositoryProvider);
      final base = await repo.signedOutDashboard;
      return base.copyWith(
        range: query.range,
        startDate: _dateOnly(
          query.startDate ?? clock.now().subtract(const Duration(days: 7)),
        ),
        endDate: _dateOnly(query.endDate ?? clock.now()),
      );
    },
  );
}

String _dateOnly(DateTime date) {
  final local = date.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

class ReviewDashboardSelectedQueryNotifier
    extends Notifier<ReviewDashboardQuery> {
  @override
  ReviewDashboardQuery build() =>
      const ReviewDashboardQuery(range: ReviewDashboardRange.last7Days);

  void setQuery(ReviewDashboardQuery query) {
    state = query;
  }

  void setRange(ReviewDashboardRange range) {
    state = ReviewDashboardQuery(range: range);
  }

  void setCustomRange(DateTime startDate, DateTime endDate) {
    state = ReviewDashboardQuery(
      range: ReviewDashboardRange.custom,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

final reviewDashboardSelectedQueryProvider =
    NotifierProvider<
      ReviewDashboardSelectedQueryNotifier,
      ReviewDashboardQuery
    >(ReviewDashboardSelectedQueryNotifier.new);

/// Tracks whether a clinic-share request is currently in-flight.
/// Clinic share uses a separate API endpoint (not the data-export pipeline),
/// so it needs its own in-flight state to show a spinner on the export card.
class ClinicShareInFlightNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }
}

final clinicShareInFlightProvider =
    NotifierProvider<ClinicShareInFlightNotifier, bool>(
      ClinicShareInFlightNotifier.new,
    );
