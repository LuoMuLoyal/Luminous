import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';

/// Hero avatar for the record detail header.
///
/// Uses the kind's quick-action accent colors and resolves the user-customized
/// icon (same source as the quick-entry panel), so the same record reads
/// consistently across surfaces. Falls back to the neutral primary style for
/// kinds without a quick action (vitals / activity).
class KindHeroAvatar extends ConsumerWidget {
  const KindHeroAvatar({super.key, required this.kind});

  final DailyRecordKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final entryType = recordEntryTypeForDailyRecordKind(kind);
    final action = RecordDashboard.quickActionFor(entryType);
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();

    final accent =
        action?.accent.solid(context) ?? SemanticColor.primary.solid(context);
    final soft = action?.softColor.subtle(context) ?? colors.secondary;
    final icon = action == null
        ? kindIconFallback(kind)
        : resolveQuickActionIcon(action, prefs);

    return FAvatar.raw(
      size: 52,
      style: .delta(backgroundColor: soft),
      child: Icon(icon, color: accent, size: 24),
    );
  }
}

/// Fallback icon for kinds without a quick action (vitals / activity).
IconData kindIconFallback(DailyRecordKind kind) {
  return switch (kind) {
    DailyRecordKind.water => SemanticIcons.recordWater,
    DailyRecordKind.meal => SemanticIcons.recordMeal,
    DailyRecordKind.vital => SemanticIcons.profileCondition,
    DailyRecordKind.mood => SemanticIcons.recordMood,
    DailyRecordKind.symptom => SemanticIcons.safetyDanger,
    DailyRecordKind.activity => SemanticIcons.recordActivity,
    DailyRecordKind.note => SemanticIcons.tabRecord,
    DailyRecordKind.sleep => SemanticIcons.recordSleep,
  };
}
