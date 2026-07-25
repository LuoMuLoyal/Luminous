import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:luminous/core/design/design.dart';

/// Defers building [child] until after the current frame.
///
/// Use this to wrap heavy tab content so that the initial tab switch animation
/// isn't blocked by building charts, lists and other expensive widgets. The
/// first time the widget is mounted a lightweight [placeholder] is shown; on
/// the next frame the real content is built.
class ShellDeferredContent extends StatefulWidget {
  const ShellDeferredContent({
    super.key,
    this.placeholder,
    required this.child,
  });

  final Widget? placeholder;
  final Widget child;

  @override
  State<ShellDeferredContent> createState() => _ShellDeferredContentState();
}

class _ShellDeferredContentState extends State<ShellDeferredContent> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _ready = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return widget.child;
    }

    return widget.placeholder ??
        ColoredBox(
          color: SemanticColor.neutral.shimmerBase(context),
          child: const SizedBox.expand(),
        );
  }
}
