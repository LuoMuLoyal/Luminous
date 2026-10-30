import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/review.dart';

/// The current event review, resolved into the shared page-state machine.
///
/// The review tab has **two** independent data sources that fail independently:
///
/// - the event review ([reviewCurrentProvider]) — the page's backbone;
/// - the period dashboard ([reviewDashboardProvider]) — coverage strip, trend
///   and noteworthy cards.
///
/// They are exposed as two states on purpose. The page must still render the
/// event review when the dashboard read fails (that was an explicit property of
/// the pre-composition page and is covered by a regression test), so a single
/// collapsed state would make one failure take down the other.
PageViewState<ReviewDashboard> _resolveDashboard(Ref ref) {
  final query = ref.watch(reviewDashboardSelectedQueryProvider);
  final async = ref.watch(reviewDashboardProvider(query));

  // Keep the last successful dashboard on screen while a newly selected range
  // loads, instead of flashing the skeleton on every range switch.
  //
  // This provider is a **pure derivation**: it only reads the cache. Writing it
  // from here (via `ref.listen` + `ref.read(...notifier).set`) makes the
  // provider depend on state it mutates itself, and in Riverpod 3 that silent
  // cycle stops the value from ever propagating to listeners — components then
  // keep seeing the initial `PageViewStateLoading` forever. The write lives in
  // the page (`ReviewView`) instead.
  final cached = ref.watch(reviewLastDashboardProvider);
  final effective = async.isLoading && !async.hasValue && cached != null
      ? AsyncValue<ReviewDashboard>.data(cached)
      : async;

  return resolvePageViewState<ReviewDashboard>(
    session: ref.watch(authSessionProvider),
    data: effective,
  );
}

/// Dashboard data for the `review` surface, resolved into the shared page-state
/// machine instead of a bare value.
///
/// Three things this deliberately does **not** do:
///
/// - It does not collapse the `AsyncValue` with `?? ReviewDashboard.empty()`.
///   A failed read rendered as an empty dashboard is indistinguishable from
///   "you recorded nothing this week", which for health data is a real claim.
/// - It does not fall back to a skeleton while refreshing: `isLoading` and
///   `hasValue` are not mutually exclusive, and this provider rebuilds on
///   `DataChangeBus` topics after every record, so "refreshing" is the common
///   case on this page.
/// - It does not re-implement the range switch. The selected query is read here
///   so components stay free of page input.
///
/// Components switch over the returned [PageViewState] via `dataOrNull`, so the
/// state handling lives here once rather than in each component.
final reviewSurfaceStateProvider = Provider<PageViewState<ReviewDashboard>>(
  (ref) => _resolveDashboard(ref),
  name: 'reviewSurfaceState',
);

/// The current event review, resolved into the same page-state machine.
///
/// The last known review is merged in as a fallback, mirroring what the
/// hand-written page did: a failed refresh keeps the previous event on screen
/// instead of dropping the whole section. [dataOrNull] answers `null` for
/// loading and for a first-load failure alike, which is exactly the
/// "component renders nothing, the page owns the state" contract the host wants.
final reviewSurfaceReviewProvider = Provider<PageViewState<EventReview?>>(
  (ref) {
    final async = ref.watch(reviewCurrentProvider);
    final cached = ref.watch(reviewLastCurrentProvider);
    final effective = !async.hasValue && cached != null
        ? AsyncValue<EventReview?>.data(cached)
        : async;
    return resolvePageViewState<EventReview?>(
      session: ref.watch(authSessionProvider),
      data: effective,
    );
  },
  name: 'reviewSurfaceReview',
);

/// Whether the surface is showing the signed-out preview.
///
/// Components that invite the user to sign in decide on their own whether they
/// render at all, so this is a separate axis from [reviewSurfaceStateProvider].
final reviewSurfacePreviewProvider = Provider<bool>(
  (ref) => ref.watch(authSessionProvider).isConfirmedSignedOut,
  name: 'reviewSurfacePreview',
);

/// The range currently selected by the user (week / month / custom).
///
/// Exposed so the trend and period components read the same source as the
/// dashboard query instead of receiving it as a constructor argument.
final reviewSurfaceRangeProvider = Provider<ReviewDashboardRange>(
  (ref) => ref.watch(reviewDashboardSelectedQueryProvider).range,
  name: 'reviewSurfaceRange',
);
/// Whether the event review is showing stale content (a refresh failed but the
/// last success is still on screen).
///
/// The banner is a component, not page chrome, because it belongs to the
/// dashboard/event state rather than to the page's shell.
final reviewSurfaceStaleProvider = Provider<bool>((ref) {
  final async = ref.watch(reviewCurrentProvider);
  return async.hasError && ref.watch(reviewLastCurrentProvider) != null;
}, name: 'reviewSurfaceStale');

/// Whether an event review (current or last known) exists.
///
/// Drives the "no event" branch components: they render only when the user
/// genuinely has no event, never while loading or after a failure.
final reviewSurfaceHasEventProvider = Provider<bool>((ref) {
  return ref.watch(reviewSurfaceReviewProvider).dataOrNull != null ||
      ref.watch(reviewLastCurrentProvider) != null;
}, name: 'reviewSurfaceHasEvent');
