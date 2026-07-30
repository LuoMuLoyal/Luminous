import 'package:elk_icon_picker/elk_icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/lucide_icon_bridge.dart';

/// Opens the Lucide icon picker sheet, themed with Forui colors.
///
/// Returns the selected icon as [IconData] (resolved from [FLucideIcons]
/// via [LucideIconBridge]), or null if the user dismissed the sheet.
///
/// Note: pre-selection of the current icon is not supported because
/// `elk_icon_picker`'s `LucideIcons` class does not expose a name-based
/// lookup. The picker still works fully without it.
Future<IconData?> showAppIconPicker(
  BuildContext context, {
  IconData? currentIcon,
}) async {
  final colors = context.theme.colors;

  final result = await showElkIconPicker(
    context,
    backgroundColor: colors.background,
    iconColor: colors.mutedForeground,
    selectedColor: colors.primary,
    selectedIconColor: colors.primaryForeground,
    searchBarFillColor: colors.secondary,
    tabIndicatorColor: colors.primary,
  );

  if (result is LucideIconSelection) {
    return LucideIconBridge.resolve(result.name);
  }

  return null;
}
