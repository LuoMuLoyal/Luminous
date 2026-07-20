import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:lucent_api/api/export.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Renders the full content of a [ClinicSummaryDto] — used by both the
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

  final ClinicSummaryDto dto;
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onShare;
  final bool isPdfDownloading;
  final bool isSharing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle (mobile bottom sheet only).
        if (MediaQuery.sizeOf(context).width < Breakpoints.desktop)
          const Center(child: SheetDragHandle()),

        // Meta info.
        _MetaRow(
          label: l10n.reportClinicSummaryGeneratedAt,
          value: _formatDateTime(context, dto.generatedAt),
        ),
        _MetaRow(
          label: l10n.reportClinicSummaryDataRange,
          value: _dataRangeLabel(dto.dataRange, l10n),
        ),

        const SizedBox(height: Spacing.level4),
        const AppDivider(),
        const SizedBox(height: Spacing.level4),

        // Profile section.
        _SectionTitle(text: l10n.reportClinicSummaryProfileSection),
        const SizedBox(height: Spacing.level2),
        _MetaRow(
          label: l10n.reportClinicSummaryProfileNickname,
          value: dto.profile.nickname,
        ),
        _MetaRow(
          label: l10n.reportClinicSummaryProfileAge,
          value: dto.profile.age != null
              ? dto.profile.age!.toInt().toString()
              : l10n.reportClinicSummaryNotSet,
        ),
        _MetaRow(
          label: l10n.reportClinicSummaryProfileSex,
          value: dto.profile.sexAtBirth ?? l10n.reportClinicSummaryNotSet,
        ),
        _MetaRow(
          label: l10n.reportClinicSummaryProfileBloodType,
          value: dto.profile.bloodType ?? l10n.reportClinicSummaryNotSet,
        ),

        // Allergies.
        if (dto.allergies.isNotEmpty) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reportClinicSummaryAllergiesSection),
          const SizedBox(height: Spacing.level2),
          ...dto.allergies.map((e) => _BulletItem(text: e)),
        ],

        // Conditions.
        if (dto.conditions.isNotEmpty) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reportClinicSummaryConditionsSection),
          const SizedBox(height: Spacing.level2),
          ...dto.conditions.map((e) => _BulletItem(text: e)),
        ],

        // Current medicines.
        if (dto.currentMedicines.isNotEmpty) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reportClinicSummaryMedicinesSection),
          const SizedBox(height: Spacing.level2),
          ...dto.currentMedicines.map((e) => _BulletItem(text: e)),
        ],

        // Key findings.
        if (dto.findings != null && dto.findings!.isNotEmpty) ...[
          const SizedBox(height: Spacing.level4),
          const AppDivider(),
          const SizedBox(height: Spacing.level4),
          _SectionTitle(text: l10n.reportClinicSummaryFindingsSection),
          const SizedBox(height: Spacing.level2),
          ...dto.findings!.map((e) => _BulletItem(text: e)),
        ],

        // Disclaimer.
        const SizedBox(height: Spacing.level4),
        const AppDivider(),
        const SizedBox(height: Spacing.level4),
        _SectionTitle(text: l10n.reportClinicSummaryDisclaimerSection),
        const SizedBox(height: Spacing.level2),
        Text(
          dto.disclaimer,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: context.theme.colors.mutedForeground),
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
                        : Text(l10n.reportClinicSummaryDownloadPdf),
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
                        : Text(l10n.reportClinicSummaryShare),
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
      'last_7_days' => l10n.reportRangeLast7Days,
      'last_30_days' => l10n.reportRangeLast30Days,
      _ => dataRange,
    };
  }

  String _formatDateTime(BuildContext context, String iso8601) {
    final dateTime = DateTime.tryParse(iso8601)?.toLocal();
    if (dateTime == null) return iso8601;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMd(locale).add_Hm().format(dateTime);
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
      style: TypographyToken.level4
          .body(context)
          .copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Text(value, style: TypographyToken.level3.body(context)),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

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
                color: colors.mutedForeground,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Text(text, style: TypographyToken.level3.body(context)),
          ),
        ],
      ),
    );
  }
}
