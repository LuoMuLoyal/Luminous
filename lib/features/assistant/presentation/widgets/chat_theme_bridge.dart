import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Derives the gen_ai (framework `package:flutter/material.dart`) chat theme
/// from the ambient Luminous Forui theme.
///
/// The app root is a `material_ui` `MaterialApp`; its `Theme` is not the one
/// the Flutter framework's `Theme.of` resolves, and the framework `Theme.of`
/// that `material_ui`'s root does expose is the framework Material 3 default
/// (`useMaterial3: true`, `brightness` light, seed `#6750A4`) — neither the
/// app's colours nor its brightness. So gen_ai, which reads the framework
/// `Theme` + its [CustomThemeExtension], has to be handed a framework theme
/// built from the Forui tokens that the rest of the app already uses.
///
/// Brightness is read from **Forui** (`context.theme.colors.brightness`), never
/// from the framework `Theme.of`, for the same reason `flow_theme_bridge.dart`
/// used to do so: the framework value is permanently light under the
/// `material_ui` root, so a dark app would otherwise never reach gen_ai.
ThemeData luminousChatTheme(BuildContext context) {
  final colors = context.theme.colors;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: colors.brightness,
      ).copyWith(
        primary: colors.primary,
        onPrimary: colors.primaryForeground,
        secondary: SemanticColor.primary.solid(context),
        onSecondary: colors.primaryForeground,
        surface: colors.background,
        onSurface: colors.foreground,
        surfaceContainerHigh: colors.card,
        outline: SemanticColor.neutral.border(context),
        error: SemanticColor.destructive.solid(context),
        onError: Colors.white,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: colors.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    extensions: [
      CustomThemeExtension(
        chatBackground: colors.background,
        messageBubbleColor: colors.secondary,
        userBubbleColor: SemanticColor.primary.solid(context),
        messageTextColor: colors.foreground,
        inputBackgroundColor: colors.secondary,
        inputBorderColor: SemanticColor.neutral.border(context),
        inputTextColor: colors.foreground,
        hintTextColor: SemanticColor.neutral.solid(context),
        backToBottomButtonColor: colors.card,
        sendButtonColor: SemanticColor.primary.solid(context),
        sendButtonIconColor: colors.primaryForeground,
      ),
    ],
  );
}

/// Installs [luminousChatTheme] for an assistant subtree only.
///
/// A framework [Theme] is laid down for gen_ai's widgets, plus a transparent
/// framework [Material] ancestor for the ink-based widgets its composer and
/// message chrome rely on. Neither touches the Forui theme outside this
/// subtree — Forui's inherited theme is a separate widget — so the rest of the
/// app keeps resolving its own tokens, and `context.theme` (Forui) still works
/// for the Luminous widgets rendered inside gen_ai's builders.
Widget withLuminousChatTheme(BuildContext context, Widget child) {
  return Theme(
    data: luminousChatTheme(context),
    child: Material(type: MaterialType.transparency, child: child),
  );
}
