import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';

/// Custom branch container for the stateful shell's five tabs.
///
/// Replaces the default `IndexedStack` container so switching tabs gets a
/// cross-fade — the incoming branch fades in with a slight scale-up, the
/// outgoing branch fades out — while preserving the IndexedStack semantics the
/// rest of the app relies on:
///
/// * every branch stays mounted (per-tab state survives switches);
/// * non-current branches stay [Offstage] (plus [IgnorePointer]), so finders
///   and tests keep seeing only the active tab (identical to IndexedStack's
///   offstage behavior). This is locked in by
///   `test/shell/tab_branch_container_test.dart`.
///
/// ## How it keeps both animation and offstage semantics
///
/// A branch is [Offstage] only when it is neither the current branch nor one
/// that is still fading out ([_transitioningFrom]). During a switch each
/// outgoing branch is kept onstage just long enough for its fade-out to be
/// visible, then re-offstaged as *its own* fade completes
/// ([AnimatedOpacity.onEnd]).
///
/// **This container is the only thing animating a tab switch.** Tab root routes
/// are `NoTransitionPage`: a `CustomTransitionPage` there was measured
/// (frame-by-frame, 2026-09-12) never to play on a tab switch — go_router reuses
/// a restored branch's Navigator rather than rebuilding it, and the branch's
/// first mount is added at full opacity — so the route-level
/// `FadeThroughTransition` was dead configuration that still read as if it were
/// the tab transition. Keeping the tab roots transition-free means the
/// cross-fade below is the single owner of the motion and cannot be stacked on.
///
/// Durations and curves come from [DurationTokens] / [MotionTokens] so the
/// whole motion system stays tunable in one place. All animation durations are
/// bounded, so `pumpAndSettle` in tests always converges.
class ShellTabBranchContainer extends StatefulWidget {
  const ShellTabBranchContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;

  /// The branch Navigator widgets, one per tab (order matches [ShellTab]).
  final List<Widget> children;

  @override
  State<ShellTabBranchContainer> createState() =>
      _ShellTabBranchContainerState();
}

class _ShellTabBranchContainerState extends State<ShellTabBranchContainer> {
  late int _currentIndex = widget.navigationShell.currentIndex;

  /// Branch indices that are still fading out after a switch. Each one is kept
  /// onstage until *its own* fade-out completes.
  ///
  /// A set rather than a single index: switching tabs again before the previous
  /// fade finished would otherwise overwrite the earlier entry and drop that
  /// branch to [Offstage] mid-fade, cutting its fade-out off with a visible
  /// snap.
  final Set<int> _transitioningFrom = <int>{};

  @override
  void didUpdateWidget(covariant ShellTabBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.navigationShell.currentIndex;
    if (next != _currentIndex) {
      setState(() {
        _transitioningFrom.add(_currentIndex);
        _currentIndex = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          Offstage(
            offstage: i != _currentIndex && !_transitioningFrom.contains(i),
            child: AnimatedOpacity(
              opacity: i == _currentIndex ? 1 : 0,
              duration: i == _currentIndex
                  ? DurationTokens.tabFadeThrough
                  : DurationTokens.tabFadeThroughOut,
              // A cross-fade has both branches on screen at once, so the curve
              // must fill the middle of the ramp instead of sitting at ~0.5
              // opacity in it. M3's emphasized curve is built the other way
              // round — it covers ~95% of its range in the final quarter and
              // reaches 1.0 at t/T≈0.25 — which for two simultaneously visible
              // branches made both read as washed out mid-switch.
              curve: MotionTokens.snappy,
              onEnd: () {
                // Only an *outgoing* branch finishes at 0; the incoming branch
                // never enters `_transitioningFrom`, so its own onEnd is a
                // no-op here. Clearing one index (not the whole set) keeps a
                // second, still-fading branch onstage.
                if (i != _currentIndex &&
                    _transitioningFrom.contains(i) &&
                    mounted) {
                  setState(() => _transitioningFrom.remove(i));
                }
              },
              child: TickerMode(
                enabled: i == _currentIndex,
                child: IgnorePointer(
                  ignoring: i != _currentIndex,
                  child: AnimatedScale(
                    scale: i == _currentIndex ? 1 : 0.98,
                    duration: DurationTokens.tabFadeThrough,
                    curve: MotionTokens.snappy,
                    child: widget.children[i],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
