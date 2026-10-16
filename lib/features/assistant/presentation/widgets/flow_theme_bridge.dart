import 'package:flow_ui/flow_ui.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:material_ui/material_ui.dart';

/// Derives the FlowUI theme from the ambient Luminous Forui theme.
///
/// Reads the ambient brightness through the **Forui** theme
/// (`context.theme.colors.brightness`), not through `Theme.of(context)`:
/// the app root is a `material_ui` `MaterialApp`, whose [Theme] is not the
/// one Flutter's framework `Theme.of` resolves — so
/// `Theme.of(context).brightness` is permanently `Brightness.light` in
/// production and the dark FlowUI preset was unreachable (a one-off probe
/// confirmed `material_ui`'s `Theme.of` and Forui's
/// `context.theme.colors.brightness` both report dark correctly). Every
/// other token here already goes through Forui, so this makes the brightness
/// source consistent with the rest of the function.
///
/// Since 0.3.0 flow_ui depends on `material_ui` rather than
/// `flutter/material.dart`, and each package declares its own
/// [ThemeExtension] / [ThemeData] pair, so a [FlowTheme] only resolves
/// through `context.flowTheme` when it is installed on a `material_ui`
/// [Theme].
FlowTheme luminousFlowTheme(BuildContext context) {
  final colors = context.theme.colors;
  final baseColors = colors.brightness == Brightness.dark
      ? FlowColors.dark
      : FlowColors.light;

  return FlowTheme(
    colors: baseColors.copyWith(
      primary: SemanticColor.primary.solid(context),
      onPrimary: colors.primaryForeground,
      surface: colors.background,
      onSurface: colors.foreground,
      onSurfaceVariant: SemanticColor.neutral.solid(context),
      onSurfaceMuted: SemanticColor.neutral
          .solid(context)
          .withValues(alpha: 0.5),
      onSurfaceDisabled: SemanticColor.neutral
          .solid(context)
          .withValues(alpha: 0.3),
      outline: SemanticColor.neutral.border(context),
      outlineVariant: SemanticColor.neutral
          .border(context)
          .withValues(alpha: 0.5),
      surfaceBright: colors.card,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: colors.secondary,
      surfaceContainer: colors.secondary,
      surfaceContainerHigh: colors.secondary,
      surfaceContainerHighest: colors.secondary,
      error: SemanticColor.destructive.solid(context),
      // Material 桥接层 error 前景：白字红底标准对比，不随主题变化
      onError: Colors.white,
    ),
    typography: FlowTypography.standard.withFontFamily(
      context.theme.typography.body.sm.fontFamily ?? 'Figtree',
    ),
  );
}

/// Installs [luminousFlowTheme] for an assistant subtree only.
///
/// The [Theme] laid down here is `material_ui`'s, not the framework's, and the
/// extension entries stay `material_ui` ones — flow_ui reads its tokens from
/// that type, so a Flutter-framework [ThemeExtension] would never reach it.
/// `material_ui`'s [ThemeData.extensions] is keyed by [ThemeExtension.type], so
/// `copyWith` replaces the previous [FlowTheme] outright and keeps the other
/// extensions — hence no de-duplication here.
///
/// [SemanticColor] tone lookups inside [luminousFlowTheme] still go through the
/// Forui `context.theme` above, which this widget does not touch.
///
/// A `material_ui` [Material] is wrapped around the subtree because flow_ui
/// 0.3.0 renders its composer input with material_ui's `TextField`, which
/// requires a material_ui `Material` ancestor. The app's root is a
/// `material_ui` `MaterialApp`, which does not insert one below its builder, so
/// without this the composer fails with "No Material widget found". It is
/// transparent, so it adds no surface of its own.
Widget withLuminousFlowTheme(BuildContext context, Widget child) {
  final parentTheme = Theme.of(context);

  return Theme(
    data: parentTheme.copyWith(
      extensions: [
        ...parentTheme.extensions.values,
        luminousFlowTheme(context),
      ],
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}
