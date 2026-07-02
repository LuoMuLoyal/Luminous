import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/app_design.dart';

class AppDialogShell extends StatelessWidget {
  const AppDialogShell({
    super.key,
    required this.builder,
    this.animation,
    this.maxWidth = 560,
    this.maxHeight,
    this.padding = const EdgeInsets.all(AppSpacingTokens.level5),
    this.scrollable = true,
  });

  final WidgetBuilder builder;
  final Animation<double>? animation;
  final double maxWidth;
  final double? maxHeight;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding.copyWith(
      bottom: padding.bottom + MediaQuery.viewInsetsOf(context).bottom,
    );

    return FDialog.raw(
      constraints: BoxConstraints(
        minWidth: 0,
        maxWidth: maxWidth,
        maxHeight: maxHeight ?? double.infinity,
      ),
      animation: animation,
      builder: (context, style) {
        Widget child = Padding(
          padding: effectivePadding,
          child: builder(context),
        );

        if (scrollable) {
          child = SingleChildScrollView(child: child);
        }

        return Material(color: Colors.transparent, child: child);
      },
    );
  }
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxWidth = 560,
  double? maxHeight,
  EdgeInsets padding = const EdgeInsets.all(AppSpacingTokens.level5),
  bool scrollable = true,
}) {
  return showFDialog<T>(
    context: context,
    builder: (context, style, animation) => AppDialogShell(
      animation: animation,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      padding: padding,
      scrollable: scrollable,
      builder: builder,
    ),
  );
}
