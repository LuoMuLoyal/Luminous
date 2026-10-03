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
    this.padding = const EdgeInsets.all(Spacing.xl),
    this.scrollable = true,
  }) : assert(
         scrollable || maxHeight != null,
         'DialogShell(scrollable: false) without maxHeight silently overflows '
         'the bottom edge as soon as the content is taller than the FDialog '
         'bound (FDialog insetPadding already eats 40dp per side on a 360dp '
         'screen). Leave scrollable at its default true, or pair '
         'scrollable: false with a bounded maxHeight for short content.',
       );

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
  EdgeInsets padding = const EdgeInsets.all(Spacing.xl),
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
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.theme.typography.body.lg),
        const SizedBox(height: Spacing.md),
        Text(message, style: context.theme.typography.body.sm),
        const SizedBox(height: Spacing.xl),
        DialogActionRow(
          actions: [
            DialogActionButton(
              label: cancelLabel ?? l10n.commonCancel,
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(context).pop(false),
            ),
            DialogActionButton(
              label: confirmLabel,
              variant: FButtonVariant.destructive,
              onPress: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

/// 对话框右下角的按钮行。
///
/// Material/Forui 的按钮都是**固有宽度**:直接放进 `Row` 时它们先占满固有宽度
/// (Row 给非 flex 子节点无界主轴约束),把文字挤到右边溢出——360dp 真机 + 1.3
/// 字缩放时必现(FDialog 的 40dp 横向 inset 让内容只剩 ~240dp)。
/// 这里改用 `Wrap`:空间不够时按钮换行堆叠而不是溢出;宽度上限交给 [DialogActionButton]
/// 的标签省略处理。
class DialogActionRow extends StatelessWidget {
  const DialogActionRow({super.key, required this.actions});

  final List<DialogActionButton> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        alignment: WrapAlignment.end,
        spacing: Spacing.md,
        runSpacing: Spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final action in actions)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: action,
            ),
        ],
      ),
    );
  }
}

/// 对话框里的按钮:标签在窄屏/大字号下省略,而不是把按钮撑到溢出。
///
/// `Flexible` 必须包在标签外——Forui `FButton` 内部是 `Row`,给非 flex 子节点
/// 无界主轴约束,裸 `Text` 会按固有宽度排版并溢出按钮。
class DialogActionButton extends StatelessWidget {
  const DialogActionButton({
    super.key,
    required this.label,
    required this.onPress,
    this.variant = FButtonVariant.primary,
    this.size = FButtonSizeVariant.md,
  });

  final String label;
  final VoidCallback? onPress;
  final FButtonVariant variant;

  /// 按钮尺寸。既有调用点用 [FButtonSizeVariant.sm] 的,迁移时保持一致。
  final FButtonSizeVariant size;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: variant,
      size: size,
      onPress: onPress,
      // Forui FButton 默认 mainAxisSize.max:在有界宽度里会撑满整行,按钮就永远
      // 不会并排(与「右下角按钮行」的语义相反)。min 让它贴合标签宽度,
      // 由 [DialogActionRow] 的 Wrap 决定并排还是换行。
      mainAxisSize: MainAxisSize.min,
      child: Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
