import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/presentation/widgets/shared/components.dart';
import 'package:luminous/l10n/app_localizations.dart';

typedef OpenNlpSheetCallback = void Function(BuildContext context);

/// Builds the header action chips for the record page.
///
/// On mobile, shows quick settings + NLP entry.
/// On desktop, additionally shows date navigation (today/prev/next/pick).
List<Widget> buildRecordHeaderActions({
  required BuildContext context,
  required AppLocalizations l10n,
  required bool isMobileLayout,
  required bool isCompact,
  required DateTime selectedDate,
  required void Function(DateTime) onSetDate,
  required Future<void> Function(BuildContext, DateTime) onPickDate,
  required OpenNlpSheetCallback onOpenNlpSheet,
}) {
  if (isMobileLayout) {
    return [
      RecordHeaderActionChip(
        key: const Key('record-quick-settings-action'),
        label: l10n.recordQuickSettingsTitle,
        icon: SemanticIcons.actionSettings,
        onTap: () => context.push(Routes.recordQuickEntrySettings),
        iconOnly: true,
      ),
      RecordHeaderActionChip(
        key: const Key('record-nlp-action'),
        label: l10n.recordNlpHeaderAction,
        icon: SemanticIcons.aiEntry,
        emphasized: true,
        onTap: () => onOpenNlpSheet(context),
        iconOnly: true,
      ),
    ];
  }

  return [
    RecordHeaderActionChip(
      key: const Key('record-date-today-action'),
      label: l10n.recordTodayAction,
      icon: SemanticIcons.actionCalendar,
      onTap: () => onSetDate(clock.now()),
      iconOnly: isCompact,
    ),
    RecordHeaderActionChip(
      key: const Key('record-date-previous-action'),
      label: l10n.recordPreviousDayAction,
      icon: SemanticIcons.actionPrev,
      onTap: () => onSetDate(selectedDate.subtract(const Duration(days: 1))),
      iconOnly: true,
    ),
    RecordHeaderActionChip(
      key: const Key('record-date-next-action'),
      label: l10n.recordNextDayAction,
      icon: SemanticIcons.actionNext,
      onTap: () => onSetDate(selectedDate.add(const Duration(days: 1))),
      iconOnly: true,
    ),
    RecordHeaderActionChip(
      label: l10n.recordPickDateAction,
      icon: SemanticIcons.actionCalendar,
      onTap: () => onPickDate(context, selectedDate),
      iconOnly: true,
    ),
    RecordHeaderActionChip(
      key: const Key('record-quick-settings-action'),
      label: l10n.recordQuickSettingsTitle,
      icon: SemanticIcons.actionSettings,
      onTap: () => context.push(Routes.recordQuickEntrySettings),
      iconOnly: true,
    ),
    RecordHeaderActionChip(
      key: const Key('record-nlp-action'),
      label: l10n.recordNlpHeaderAction,
      icon: SemanticIcons.aiEntry,
      emphasized: true,
      onTap: () => onOpenNlpSheet(context),
      iconOnly: true,
    ),
  ];
}
