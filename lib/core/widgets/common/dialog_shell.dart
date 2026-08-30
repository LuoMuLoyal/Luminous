import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class DialogShell extends StatelessWidget {
  const DialogShell({
    super.key,
    required this.builder,
    this.animation,
    this.maxWidth = 560,
    this.maxHeight,
    this.padding = const EdgeInsets.all(Spacing.level5),
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

    return FDialog(
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

        return child;
      },
    );
  }
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double? maxWidth,
  double? maxHeight,
  EdgeInsets padding = const EdgeInsets.all(Spacing.level5),
  bool scrollable = true,
  bool barrierDismissible = true,
}) {
  // Resolve adaptive dialog width: desktop gets 560px, tablet 480px, mobile
  // falls back to the DialogShell default (560px). When an explicit [maxWidth]
  // is passed (e.g. 440 for confirmation dialogs), it overrides the adaptive
  // resolution but is still clamped to the screen width on very small screens.
  final screenWidth = MediaQuery.sizeOf(context).width;
  final effectiveMaxWidth =
      maxWidth ?? LayoutScaleResolver.dialogMaxWidthFor(screenWidth);

  return showFDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context, style, animation) => DialogShell(
      animation: animation,
      maxWidth: effectiveMaxWidth,
      maxHeight: maxHeight,
      padding: padding,
      scrollable: scrollable,
      builder: builder,
    ),
  );
}

/// A reusable confirmation dialog for dangerous / destructive actions.
///
/// Shows a title, message, cancel button (ghost) and confirm button
/// (destructive). Returns `true` if the user confirmed, `false` otherwise.
Future<bool> showDangerConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final screenWidth = MediaQuery.sizeOf(context).width;
  final result = await showAppDialog<bool>(
    context: context,
    maxWidth: LayoutScaleResolver.wideDialogMaxWidthFor(screenWidth),
    scrollable: false,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.theme.typography.body.lg),
        const SizedBox(height: Spacing.level3),
        Text(message, style: context.theme.typography.body.sm),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel ?? l10n.commonCancel),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              variant: FButtonVariant.destructive,
              onPress: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}
