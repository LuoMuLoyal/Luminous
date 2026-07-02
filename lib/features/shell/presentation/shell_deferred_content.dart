import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';

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

    return widget.placeholder ?? const _DefaultTabPlaceholder();
  }
}

class _DefaultTabPlaceholder extends StatelessWidget {
  const _DefaultTabPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return ColoredBox(
      color: colors.secondary.withValues(alpha: 0.32),
      child: const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(AppSpacingTokens.level5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInlineSkeletonBlock(
                height: AppSpacingTokens.level7,
                widthFactor: 0.45,
                radius: AppRadiusTokens.level4,
              ),
              SizedBox(height: AppSpacingTokens.level4),
              AppInlineSkeletonBlock(
                height: AppSpacingTokens.level9,
                widthFactor: 1,
                radius: AppRadiusTokens.level4,
              ),
              SizedBox(height: AppSpacingTokens.level4),
              AppInlineSkeletonBlock(
                height: AppSpacingTokens.level9,
                widthFactor: 1,
                radius: AppRadiusTokens.level4,
              ),
              SizedBox(height: AppSpacingTokens.level4),
              AppInlineSkeletonBlock(
                height: AppSpacingTokens.level9,
                widthFactor: 0.72,
                radius: AppRadiusTokens.level4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
