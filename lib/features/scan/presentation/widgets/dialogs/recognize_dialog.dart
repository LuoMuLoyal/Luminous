import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/search/presentation/widgets/shared/add_to_box.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineRecognizeDialog extends ConsumerStatefulWidget {
  const MedicineRecognizeDialog({
    super.key,
    required this.imagePath,
    required this.method,
    required this.methodLabel,
    required this.results,
    required this.onRetake,
    this.onClose,
  });

  final String imagePath;

  /// Recognition method used to produce [results] — drives the verify hint
  /// copy on the top card (`scanResultVerifyHintAi` / `scanResultVerifyHintOcr`).
  final MedicineScanMethod method;

  /// Localized method label for the `scanResultSourceLabel` header.
  final String methodLabel;
  final List<MedicineMatchResult> results;
  final VoidCallback onRetake;
  final VoidCallback? onClose;

  @override
  ConsumerState<MedicineRecognizeDialog> createState() =>
      _MedicineRecognizeDialogState();
}

class _MedicineRecognizeDialogState
    extends ConsumerState<MedicineRecognizeDialog> {
  bool _showCandidateList = false;
  int? _selectedIndex;

  /// Top result follows the same ordering as the candidate list: deduplicated
  /// by name, then sorted by confidence (null sorts as 0).
  MedicineMatchResult? get _topResult => _sortedResults.firstOrNull;

  List<MedicineMatchResult> get _sortedResults {
    final seen = <String>{};
    return widget.results.where((r) => seen.add(r.name)).toList()
      ..sort((a, b) => (b.confidence ?? 0).compareTo(a.confidence ?? 0));
  }

  /// Current drugbox lookup by `source:sourceRefId` (F-3 dedup key). Loading /
  /// error states fall back to an empty map (dialog then shows the default
  /// "not added" exit).
  Map<String, CurrentMedicineItem> get _boxByKey => ref
      .watch(healthContextSnapshotProvider)
      .maybeWhen(
        data: (snapshot) => {
          for (final medicine in snapshot.currentMedicines)
            if (medicine.isCurrent && medicine.sourceRefId != null)
              '${medicine.source}:${medicine.sourceRefId}': medicine,
        },
        orElse: () => const <String, CurrentMedicineItem>{},
      );

  Future<void> _addToBox(MedicineMatchResult res, String sourceRefId) {
    return addMedicineToBoxWithPrecheck(
      context,
      ref: ref,
      source: 'cn',
      sourceRefId: sourceRefId,
      displayName: res.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final l10n = AppLocalizations.of(context)!;
    final top = _topResult;
    final sorted = _sortedResults;

    final dialogStyle = context.theme.dialogStyle;

    // The entry the user acts on: the candidate picked from the list, or the
    // top result. Its `cn:<产品id>` presence in the drugbox decides the
    // added state.
    final res = _selectedIndex != null ? sorted[_selectedIndex!] : top;
    final resId = res?.id;
    final boxItem = resId == null ? null : _boxByKey['cn:$resId'];
    final alreadyAdded = boxItem != null;

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
                          SemanticIcons.statusUnavailable,
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
                      // No fabricated confidence percentage: the recognition
                      // path has no trustworthy score, so show a method-aware
                      // verify hint instead (F-6).
                      Text(
                        widget.method == MedicineScanMethod.ai
                            ? l10n.scanResultVerifyHintAi
                            : l10n.scanResultVerifyHintOcr,
                        style: typography.body.sm.copyWith(
                          color: colors.primary,
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
                              ? SemanticIcons.actionCollapse
                              : SemanticIcons.actionExpand,
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
                                    ? SemanticIcons.statusSuccess
                                    : SemanticIcons.statusPending,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: Spacing.level3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.name, style: typography.body.md),
                                    // Match method only — confidence is not
                                    // displayed (AI results carry none).
                                    Text(
                                      _matchTypeLabel(r.matchType, l10n),
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
        Wrap(
          spacing: Spacing.level3,
          runSpacing: Spacing.level3,
          alignment: WrapAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: widget.onClose ?? () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.scanCloseAction),
            ),
            FButton(
              variant: FButtonVariant.outline,
              onPress: widget.onRetake,
              child: Text(AppLocalizations.of(context)!.scanRetakeAction),
            ),
            if (alreadyAdded)
              FButton(
                variant: FButtonVariant.outline,
                onPress: null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      SemanticIcons.statusDone,
                      size: Spacing.level4,
                      color: colors.primary,
                    ),
                    const SizedBox(width: Spacing.level2),
                    Text(l10n.medicineSearchAlreadyAddedLabel),
                  ],
                ),
              ),
            if (res == null)
              FButton(
                onPress: null,
                child: Text(l10n.medicineSearchAddToBoxAction),
              )
            else if (alreadyAdded)
              FButton(
                onPress: () {
                  Navigator.of(context).pop();
                  unawaited(
                    MedicineReminderDetailRoute(
                      medicineId: boxItem.id,
                    ).push(context),
                  );
                },
                child: Text(l10n.scanViewReminderAction),
              )
            else
              FButton(
                onPress: res.id == null
                    ? null
                    : () => unawaited(_addToBox(res, res.id!)),
                child: Text(l10n.medicineSearchAddToBoxAction),
              ),
            if (res != null && res.id != null)
              FButton(
                variant: FButtonVariant.outline,
                onPress: () {
                  Navigator.of(context).pop();
                  unawaited(
                    MedicineDetailRoute(
                      source: 'cn',
                      id: res.id!,
                    ).push(context),
                  );
                },
                child: Text(l10n.scanViewInstructionsAction),
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
    case MedicineMatchType.nameFuzzy:
      return l10n.scanMatchTypeNameFuzzy;
  }
}
