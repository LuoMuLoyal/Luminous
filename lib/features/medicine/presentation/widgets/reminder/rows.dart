import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SelectedMedicineRow extends StatelessWidget {
  const SelectedMedicineRow({super.key, required this.medicine});

  final CurrentMedicineItem medicine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.all(Spacing.level4),
      child: Row(
        children: [
          FAvatar.raw(
            child: Icon(
              FLucideIcons.pill,
              color: SemanticColor.primary.solid(context),
            ),
          ),
          const SizedBox(width: Spacing.level4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.displayName,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  medicineDoseText(l10n, medicine),
                  style: typography.body.sm.copyWith(
                    color: colors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
