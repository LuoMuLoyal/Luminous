import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return ColoredBox(
      color: surface.canvasSoft,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInlineSkeletonBlock(
                height: AppSpacingTokens.x2l,
                widthFactor: 0.45,
                radius: AppRadiusTokens.lg,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              AppInlineSkeletonBlock(
                height: AppSpacingTokens.x4l,
                widthFactor: 1,
                radius: AppRadiusTokens.lg,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              AppInlineSkeletonBlock(
                height: AppSpacingTokens.x4l,
                widthFactor: 1,
                radius: AppRadiusTokens.lg,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              AppInlineSkeletonBlock(
                height: AppSpacingTokens.x4l,
                widthFactor: 0.72,
                radius: AppRadiusTokens.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
