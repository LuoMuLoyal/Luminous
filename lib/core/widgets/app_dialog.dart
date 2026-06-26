import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';

/// Shared dialog shell used across the app.
///
/// Provides the common `Dialog` + `ConstrainedBox(maxWidth)` + `SafeArea` +
/// `Padding` + scrolling layout so individual dialogs only need to supply
/// their content.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.maxHeight,
    this.padding = const EdgeInsets.all(AppSpacingTokens.lg),
    this.insetPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacingTokens.lg,
    ),
    this.scrollable = true,
  });

  final Widget child;
  final double maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry padding;
  final EdgeInsets insetPadding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
    final effectivePadding = padding.add(
      EdgeInsets.only(bottom: bottomPadding),
    );

    Widget content = Padding(padding: effectivePadding, child: child);

    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    return Dialog(
      insetPadding: insetPadding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: SafeArea(child: content),
      ),
    );
  }
}
