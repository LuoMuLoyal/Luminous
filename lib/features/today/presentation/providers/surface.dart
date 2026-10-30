import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/dashboard.dart';

/// Dashboard data for the `today` surface, resolved into the shared page-state
/// machine instead of a bare value.
///
/// Two things this deliberately does **not** do:
///
/// - It does not collapse the `AsyncValue` with `?? TodayDashboard.signedOut()`.
///   That would render a load failure as "you have nothing recorded today",
///   which for medication and symptom data is indistinguishable from a real
///   empty day.
/// - It does not fall back to a skeleton while refreshing. `isLoading` and
///   `hasValue` can both be true; the dashboard rebuilds on six `DataChangeBus`
///   topics, so "refreshing" is the common case on this page, not an edge case.
///
/// Sections switch over the returned [PageViewState], so the state handling
/// lives here once rather than in each of the eight components.
final todaySurfaceDashboardProvider = Provider<PageViewState<TodayDashboard>>(
  (ref) {
    return resolvePageViewState<TodayDashboard>(
      session: ref.watch(authSessionProvider),
      data: ref.watch(todayDashboardProvider),
    );
  },
  name: 'todaySurfaceDashboard',
);

/// Whether the surface is showing the signed-out preview.
///
/// Components that invite the user to sign in (the preview banner) or that need
/// protected data (health event) decide on their own whether they render at all.
final todaySurfacePreviewProvider = Provider<bool>(
  (ref) => ref.watch(authSessionProvider).isConfirmedSignedOut,
  name: 'todaySurfacePreview',
);
