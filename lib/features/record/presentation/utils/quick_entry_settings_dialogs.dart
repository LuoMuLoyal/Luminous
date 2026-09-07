import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/tokens/lucide_icon_bridge.dart';
import 'package:luminous/core/widgets/common/dialog/icon_picker_sheet.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows a custom-icon picker for the given quick-entry [action] and persists
/// the selection via [QuickEntryPreferencesController].
Future<void> pickQuickEntryIcon(
  BuildContext context,
  WidgetRef ref,
  RecordQuickAction action,
) async {
  final prefs =
      ref.read(quickEntryPreferencesProvider).asData?.value ??
      const QuickEntryPreferences();
  final iconData = await showAppIconPicker(
    context,
    currentIcon: resolveQuickActionIcon(action, prefs),
  );
  if (iconData == null || !context.mounted) return;
  final iconName = LucideIconBridge.nameOf(iconData);
  if (iconName == null) return;
  await ref
      .read(quickEntryPreferencesProvider.notifier)
      .setCustomIcon(action.type.name, iconName);
}

/// Shows a bottom-sheet style dialog for selecting the mood badge display mode.
Future<void> showMoodBadgeSelectDialog(
  BuildContext context, {
  required QuickEntryPreferences prefs,
  required QuickEntryPreferencesController controller,
  required AppLocalizations l10n,
}) async {
  final selected = await showFDialog<QuickEntryMoodBadgeMode>(
    context: context,
    builder: (dialogContext, style, animation) => FDialog(
      animation: animation,
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.recordQuickSettingsMoodBadge,
              style: style.titleTextStyle,
            ),
            const SizedBox(height: Spacing.level4),
            for (final mode in QuickEntryMoodBadgeMode.values)
              FTappable(
                onPress: () => Navigator.of(context).pop(mode),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(switch (mode) {
                          QuickEntryMoodBadgeMode.latest =>
                            l10n.recordQuickSettingsMoodBadgeLatest,
                          QuickEntryMoodBadgeMode.hidden =>
                            l10n.recordQuickSettingsMoodBadgeHidden,
                        }),
                      ),
                      if (mode == prefs.moodBadgeMode)
                        const Icon(SemanticIcons.statusDone),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
  if (selected != null) {
    unawaited(controller.setMoodBadgeMode(selected));
  }
}
