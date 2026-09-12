import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';

/// Custom branch container for the stateful shell's five tabs.
///
/// Replaces the default `IndexedStack` container so switching tabs gets a
/// Material 3 "fade-through" transition — the incoming branch fades in with a
/// slight scale-up, the outgoing branch fades out — while preserving the
/// IndexedStack semantics the rest of the app relies on:
///
/// * every branch stays mounted (per-tab state survives switches);
/// * non-current branches stay [Offstage], so finders/tests keep seeing only
///   the active tab (identical to IndexedStack's offstage behavior).
///
/// ## How it keeps both animation and offstage semantics
///
/// A branch is [Offstage] only when it is neither the current branch nor the
/// one currently fading out ([_transitioningFrom]). During a switch the
/// outgoing branch is kept onstage just long enough for its fade-out to be
/// visible, then re-offstaged when the fade completes ([AnimatedOpacity.onEnd]).
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

  /// Branch index that is currently fading out after a switch, or null when no
  /// switch is in flight. Kept onstage until its fade-out completes.
  int? _transitioningFrom;

  @override
  void didUpdateWidget(covariant ShellTabBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.navigationShell.currentIndex;
    if (next != _currentIndex) {
      setState(() {
        _transitioningFrom = _currentIndex;
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
            offstage: i != _currentIndex && i != _transitioningFrom,
            child: AnimatedOpacity(
              opacity: i == _currentIndex ? 1 : 0,
              duration: i == _currentIndex
                  ? DurationTokens.tabFadeThrough
                  : DurationTokens.tabFadeThroughOut,
              curve: MotionTokens.emphasized,
              onEnd: () {
                // The outgoing branch finishes its fade-out: drop it offstage.
                // The incoming branch (i == _currentIndex) never clears.
                if (i != _currentIndex && mounted) {
                  setState(() => _transitioningFrom = null);
                }
              },
              child: TickerMode(
                enabled: i == _currentIndex,
                child: IgnorePointer(
                  ignoring: i != _currentIndex,
                  child: AnimatedScale(
                    scale: i == _currentIndex ? 1 : 0.98,
                    duration: DurationTokens.tabFadeThrough,
                    curve: MotionTokens.emphasized,
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
