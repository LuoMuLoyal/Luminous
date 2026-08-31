import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/tokens/lucide_icon_bridge.dart';
import 'package:luminous/core/widgets/common/dialog/icon_picker_sheet.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Lets the user change the quick-entry icon for the record [kind] being
/// created or edited. Only rendered for kinds that back a quick action
/// (water / meal / mood / symptom / sleep / note).
class RecordKindIconField extends ConsumerWidget {
  const RecordKindIconField({super.key, required this.kind});

  final DailyRecordKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final entryType = recordEntryTypeForDailyRecordKind(kind);
    final action = RecordDashboard.quickActionFor(entryType);
    if (action == null) return const SizedBox.shrink();

    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final icon = resolveQuickActionIcon(action, prefs);

    return FTile(
      key: Key('record-kind-icon-field-${kind.name}'),
      title: Text(l10n.recordQuickIconFieldLabel),
      subtitle: Text(l10n.recordQuickIconChangeAction),
      prefix: FAvatar.raw(
        size: Spacing.level6,
        style: .delta(backgroundColor: action.softColor.subtle(context)),
        child: Icon(
          icon,
          color: action.accent.solid(context),
          size: Spacing.level4,
        ),
      ),
      suffix: const Icon(SemanticIcons.actionNext),
      onPress: () => _pickIcon(context, ref, entryType, icon),
    );
  }

  Future<void> _pickIcon(
    BuildContext context,
    WidgetRef ref,
    RecordEntryType entryType,
    IconData currentIcon,
  ) async {
    final iconData = await showAppIconPicker(context, currentIcon: currentIcon);
    if (iconData == null || !context.mounted) return;
    final iconName = LucideIconBridge.nameOf(iconData);
    if (iconName == null) return;
    await ref
        .read(quickEntryPreferencesProvider.notifier)
        .setCustomIcon(entryType.name, iconName);
  }
}
