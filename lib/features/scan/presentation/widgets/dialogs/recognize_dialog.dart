import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/scan/domain/services/text_matcher.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineRecognizeDialog extends StatefulWidget {
  const MedicineRecognizeDialog({
    super.key,
    required this.imagePath,
    required this.methodLabel,
    required this.results,
    required this.onRetake,
    this.onClose,
  });

  final String imagePath;
  final String methodLabel;
  final List<MedicineMatchResult> results;
  final VoidCallback onRetake;
  final VoidCallback? onClose;

  @override
  State<MedicineRecognizeDialog> createState() =>
      _MedicineRecognizeDialogState();
}

class _MedicineRecognizeDialogState extends State<MedicineRecognizeDialog> {
  bool _showCandidateList = false;
  int? _selectedIndex;

  MedicineMatchResult? get _topResult =>
      widget.results.isNotEmpty ? widget.results.first : null;

  List<MedicineMatchResult> get _sortedResults {
    final seen = <String>{};
    return widget.results.where((r) => seen.add(r.name)).toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final l10n = AppLocalizations.of(context)!;
    final top = _topResult;
    final sorted = _sortedResults;

    final dialogStyle = context.theme.dialogStyle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.scanResultTitle,
          style: dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level2),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: LayoutScaleResolver.dialogMaxWidthFor(
              MediaQuery.sizeOf(context).width,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(RadiusTokens.level2),
                    child: Image.file(
                      File(widget.imagePath),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: colors.muted,
                        child: Icon(
                          FLucideIcons.imageOff,
                          size: Spacing.level5,
                          color: colors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.level4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.scanResultTitle,
                          style: typography.body.md,
                        ),
                        Text(
                          l10n.scanResultSourceLabel(widget.methodLabel),
                          style: typography.body.sm.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level5),

              if (top != null) ...[
                // Top result card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Spacing.level4),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(RadiusTokens.level3),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(l10n.scanResultMedicineLabel, top.name),
                      if (top.approvalNumber != null)
                        _infoRow(
                          l10n.scanResultApprovalNumberLabel,
                          top.approvalNumber!,
                        ),
                      const SizedBox(height: Spacing.level2),
                      FTooltip(
                        tipBuilder: (context, controller) =>
                            Text(l10n.scanResultConfidenceExplanation),
                        child: Text(
                          l10n.scanResultConfidenceLabel(
                            (top.confidence * 100).toInt(),
                          ),
                          style: typography.body.sm.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  AppLocalizations.of(context)!.scanNoResultTitle,
                  style: typography.body.md,
                ),
              ],

              const SizedBox(height: Spacing.level4),

              // Candidate list expander
              if (sorted.length > 1)
                FTappable(
                  onPress: () =>
                      setState(() => _showCandidateList = !_showCandidateList),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.level3,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showCandidateList
                              ? FLucideIcons.chevronUp
                              : FLucideIcons.chevronDown,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.scanResultOtherMatches(sorted.length),
                          style: typography.body.md.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_showCandidateList && sorted.length > 1)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sorted.length,
                    itemBuilder: (_, i) {
                      final r = sorted[i];
                      return FTappable(
                        onPress: () => setState(() => _selectedIndex = i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.level2,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedIndex == i
                                    ? FLucideIcons.checkCircle2
                                    : FLucideIcons.circle,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: Spacing.level3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.name, style: typography.body.md),
                                    Text(
                                      '${_matchTypeLabel(r.matchType, l10n)} · ${(r.confidence * 100).toInt()}%',
                                      style: typography.body.sm.copyWith(
                                        color: colors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: widget.onClose ?? () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.scanCloseAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              variant: FButtonVariant.outline,
              onPress: widget.onRetake,
              child: Text(AppLocalizations.of(context)!.scanRetakeAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              onPress: top != null || _selectedIndex != null
                  ? () {
                      final res = _selectedIndex != null
                          ? sorted[_selectedIndex!]
                          : top;
                      final id = res?.id;
                      if (id != null) {
                        Navigator.of(context).pop();
                        MedicineReminderDetailRoute(
                          medicineId: id,
                        ).push(context);
                      }
                    }
                  : null,
              child: Text(
                AppLocalizations.of(context)!.scanConfirmDetailAction,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: typography.body.sm.copyWith(color: colors.mutedForeground),
            ),
          ),
          Expanded(child: Text(value, style: typography.body.md)),
        ],
      ),
    );
  }
}

/// Maps a [MedicineMatchType] to its localized label.
String _matchTypeLabel(MedicineMatchType type, AppLocalizations l10n) {
  switch (type) {
    case MedicineMatchType.approvalNumber:
      return l10n.scanMatchTypeApprovalNumber;
    case MedicineMatchType.barcode:
      return l10n.scanMatchTypeBarcode;
    case MedicineMatchType.nameFuzzy:
      return l10n.scanMatchTypeNameFuzzy;
  }
}
