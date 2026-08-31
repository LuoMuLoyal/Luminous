import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/features/review/presentation/widgets/shared/components.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Renders the full content of a [ClinicSummaryResponseDto] — used by both the
/// preview dialog (authenticated) and the public shared page (no auth).
///
/// Pass [onDownloadPdf] / [onShare] to show action buttons at the bottom.
/// When null, no action buttons are rendered (e.g. on the public shared
/// page where only [onDownloadPdf] is wired).
class ClinicSummaryContent extends StatelessWidget {
  const ClinicSummaryContent({
    super.key,
    required this.dto,
    this.onDownloadPdf,
    this.onShare,
    this.isPdfDownloading = false,
    this.isSharing = false,
  });

  final ClinicSummaryResponseDto dto;
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onShare;
  final bool isPdfDownloading;
  final bool isSharing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    // Section data is optional in the contract: deselected sections arrive
    // as null and must render nothing rather than crash.
    final profile = dto.profile;
    final allergies = dto.allergies;
    final conditions = dto.conditions;
    final currentMedicines = dto.currentMedicines;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle (mobile bottom sheet only).
        if (MediaQuery.sizeOf(context).width < Breakpoints.desktop)
          const Center(child: SheetDragHandle()),

        // Meta info.
        MetaRow(
          label: l10n.reviewClinicSummaryGeneratedAt,
          value: formatDateTimeFull(dto.generatedAt, locale),
        ),
        MetaRow(
          label: l10n.reviewClinicSummaryDataRange,
          value: _dataRangeLabel(dto.dataRange, l10n),
        ),

        const SizedBox(height: Spacing.level4),
        const AppDivider(),
        const SizedBox(height: Spacing.level4),

        // Profile section — present only when the event_overview field is
        // selected AND the server included the section (deselected sections
        // are omitted from the response entirely).
        if (profile != null &&
            _sectionSelected(dto.selectedFields, 'profile')) ...[
          _SectionTitle(text: l10n.reviewClinicSummaryProfileSection),
          const SizedBox(height: Spacing.level2),
          MetaRow(
            label: l10n.reviewClinicSummaryProfileNickname,
            value: profile.nickname,
          ),
          MetaRow(
            label: l10n.reviewClinicSummaryProfileAge,
            value: profile.age != null
                ? profile.age!.toInt().toString()
                : l10n.reviewClinicSummaryNotSet,
          ),
          MetaRow(
            label: l10n.reviewClinicSummaryProfileSex,
            value: profile.sexAtBirth ?? l10n.reviewClinicSummaryNotSet,
          ),
          MetaRow(
            label: l10n.reviewClinicSummaryProfileBloodType,
            value: profile.bloodType ?? l10n.reviewClinicSummaryNotSet,
          ),
        ],

        // Allergies — not one of the six selectable fields, so it behaves
        // like findings/coverage metadata: always rendered when present,
        // regardless of the field selection.
        if (allergies != null && allergies.isNotEmpty) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reviewClinicSummaryAllergiesSection),
          const SizedBox(height: Spacing.level2),
          ...allergies.map((e) => _BulletItem(text: e.label)),
        ],

        // Conditions.
        if (conditions != null &&
            conditions.isNotEmpty &&
            _sectionSelected(dto.selectedFields, 'conditions')) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reviewClinicSummaryConditionsSection),
          const SizedBox(height: Spacing.level2),
          ...conditions.map((e) => _BulletItem(text: e.label)),
        ],

        // Current medicines.
        if (currentMedicines != null &&
            currentMedicines.isNotEmpty &&
            _sectionSelected(dto.selectedFields, 'currentMedicines')) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reviewClinicSummaryMedicinesSection),
          const SizedBox(height: Spacing.level2),
          ...currentMedicines.map((e) => _BulletItem(text: e.displayName)),
        ],

        // Key findings — gated by event_overview (R-2): the server only
        // includes findings when event_overview is selected. The
        // _sectionSelected guard ensures consistency with the other
        // selectable fields (profile, conditions, currentMedicines).
        if (dto.findings != null &&
            dto.findings!.isNotEmpty &&
            _sectionSelected(dto.selectedFields, 'findings')) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reviewClinicSummaryFindingsSection),
          const SizedBox(height: Spacing.level2),
          ...dto.findings!.map((e) => _BulletItem(text: e)),
        ],

        // Water entries — gated by the `water` field toggle (R-2).
        if (dto.waterEntries != null &&
            dto.waterEntries!.isNotEmpty &&
            _sectionSelected(dto.selectedFields, 'water')) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reviewClinicSummaryWaterSection),
          const SizedBox(height: Spacing.level2),
          ...dto.waterEntries!.map(
            (e) => _BulletItem(
              text: '${e.date}  ${e.ml}${l10n.reviewClinicSummaryWaterUnit}',
            ),
          ),
        ],

        // Sleep entries — gated by the `sleep` field toggle (R-2).
        if (dto.sleepEntries != null &&
            dto.sleepEntries!.isNotEmpty &&
            _sectionSelected(dto.selectedFields, 'sleep')) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reviewClinicSummarySleepSection),
          const SizedBox(height: Spacing.level2),
          ...dto.sleepEntries!.map(
            (e) => _BulletItem(
              text:
                  '${e.date}  ${e.minutes}${l10n.reviewClinicSummarySleepUnit}',
            ),
          ),
        ],

        // Note entries — gated by the `notes` field toggle (R-2).
        // Defaults to off; the user must explicitly opt in.
        if (dto.noteEntries != null &&
            dto.noteEntries!.isNotEmpty &&
            _sectionSelected(dto.selectedFields, 'notes')) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reviewClinicSummaryNotesSection),
          const SizedBox(height: Spacing.level2),
          ...dto.noteEntries!.map(
            (e) => _BulletItem(text: '${e.date}  (${e.kind})  ${e.text}'),
          ),
        ],

        // Disclaimer.
        const SizedBox(height: Spacing.level4),
        const AppDivider(),
        const SizedBox(height: Spacing.level4),
        _SectionTitle(text: l10n.reviewClinicSummaryDisclaimerSection),
        const SizedBox(height: Spacing.level2),
        Text(
          dto.disclaimer,
          style: context.theme.typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),

        // Action buttons.
        if (onDownloadPdf != null || onShare != null) ...[
          const SizedBox(height: Spacing.level5),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          Row(
            children: [
              if (onDownloadPdf != null)
                Expanded(
                  child: FButton(
                    variant: FButtonVariant.outline,
                    onPress: isPdfDownloading ? null : onDownloadPdf,
                    child: isPdfDownloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: FCircularProgress(),
                          )
                        : Text(l10n.reviewClinicSummaryDownloadPdf),
                  ),
                ),
              if (onDownloadPdf != null && onShare != null)
                const SizedBox(width: Spacing.level3),
              if (onShare != null)
                Expanded(
                  child: FButton(
                    variant: FButtonVariant.primary,
                    onPress: isSharing ? null : onShare,
                    child: isSharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: FCircularProgress(),
                          )
                        : Text(l10n.reviewClinicSummaryShare),
                  ),
                ),
            ],
          ),
        ],

        const SizedBox(height: Spacing.level4),
      ],
    );
  }

  String _dataRangeLabel(String dataRange, AppLocalizations l10n) {
    return switch (dataRange) {
      'last_7_days' => l10n.reviewRangeLast7Days,
      'last_30_days' => l10n.reviewRangeLast30Days,
      _ => dataRange,
    };
  }

  /// Whether [sectionKey] is included in the server-provided effective
  /// section list. An empty list means the legacy "everything included"
  /// semantics (the server echoes all four section keys when no selection is
  /// given), so empty `selectedFields` keeps every section visible.
  bool _sectionSelected(List<String> selectedFields, String sectionKey) {
    return selectedFields.isEmpty || selectedFields.contains(sectionKey);
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: SemanticColor.neutral.solid(context),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(child: Text(text, style: context.theme.typography.body.xs)),
        ],
      ),
    );
  }
}
