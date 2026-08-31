import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Unified back button.
///
/// Behavior:
/// - If [onPressed] is provided, calls the custom callback directly.
/// - Otherwise tries `GoRouter.of(context).canPop()` first; if poppable, calls `context.pop()`.
/// - Falls back to [fallbackRoute] (default [Routes.home]) when pop is not possible.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.fallbackRoute = Routes.home,
  });

  final VoidCallback? onPressed;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FTooltip(
      tipBuilder: (context, controller) => Text(l10n.commonBack),
      child: FButton.icon(
        onPress: onPressed ?? () => _handleBack(context),
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.sm,
        child: const Icon(SemanticIcons.actionPrev),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute);
    }
  }
}
