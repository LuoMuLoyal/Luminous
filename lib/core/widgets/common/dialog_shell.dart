import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AppDialogShell extends StatelessWidget {
  const AppDialogShell({
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
  double maxWidth = 560,
  double? maxHeight,
  EdgeInsets padding = const EdgeInsets.all(Spacing.level5),
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
  final result = await showAppDialog<bool>(
    context: context,
    maxWidth: 440,
    scrollable: false,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TypographyToken.level6.body(context)),
        const SizedBox(height: Spacing.level3),
        Text(message, style: TypographyToken.level4.body(context)),
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
