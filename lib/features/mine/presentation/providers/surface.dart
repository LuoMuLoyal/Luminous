import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/providers/dashboard.dart';

/// Dashboard data for the `mine` surface, resolved into the shared page-state
/// machine instead of a bare value.
///
/// Two things this deliberately does **not** do:
///
/// - It does not collapse the `AsyncValue` with `?? MineDashboard.signedOut()`.
///   That would render a load failure as "you have nothing here yet", which for
///   account readiness and archive data is indistinguishable from a genuinely
///   empty profile.
/// - It does not fall back to a skeleton while refreshing. `isLoading` and
///   `hasValue` can both be true; the dashboard rebuilds on `DataChangeBus`
///   topics, so "refreshing" is a normal state on this page, not an edge case.
///
/// Sections read this provider and render nothing when `dataOrNull` is null;
/// the page-level `PageStateSwitch` owns the skeleton and the fatal-error view,
/// so a failure stays a visible failure instead of degrading to empty content.
final mineSurfaceStateProvider = Provider<PageViewState<MineDashboard>>(
  (ref) {
    return resolvePageViewState<MineDashboard>(
      session: ref.watch(authSessionProvider),
      data: ref.watch(mineDashboardProvider),
    );
  },
  name: 'mineSurfaceState',
);
