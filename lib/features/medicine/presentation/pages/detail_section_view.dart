import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/pages/detail_sections.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Renders a [MedicineDetailSection] body according to its kind.
///
/// Long prose is clamped with an explicit expand affordance instead of being
/// dumped as one block: source `toxicity` fields run to several thousand
/// characters.
class DetailSectionView extends StatelessWidget {
  const DetailSectionView({
    super.key,
    required this.section,
    required this.l10n,
  });

  final MedicineDetailSection section;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return switch (section.body) {
      TextSectionBody(:final value) => _LongText(value: value, l10n: l10n),
      ChipsSectionBody(:final values) => _ChipFlow(values: values),
      TargetsSectionBody(:final values) => _TargetList(
        targets: values,
        l10n: l10n,
      ),
      ReferencesSectionBody(:final values) => _ReferenceList(
        references: values,
        l10n: l10n,
      ),
    };
  }
}

/// Prose with a "show more" toggle once it exceeds the readable threshold.
class _LongText extends StatefulWidget {
  const _LongText({required this.value, required this.l10n});

  final String value;
  final AppLocalizations l10n;

  @override
  State<_LongText> createState() => _LongTextState();
}

class _LongTextState extends State<_LongText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong =
        widget.value.length > MedicineDetailSections.longTextThreshold;
    final text = Text(widget.value, style: context.theme.typography.body.sm);

    if (!isLong) return text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _expanded ? text : _ClampedText(value: widget.value),
        const SizedBox(height: Spacing.xs),
        FTappable(
          onPress: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded
                ? widget.l10n.medicineDetailCollapseLongText
                : widget.l10n.medicineDetailExpandLongText,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.primary.solid(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ClampedText extends StatelessWidget {
  const _ClampedText({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
      style: context.theme.typography.body.sm,
    );
  }
}

class _ChipFlow extends StatelessWidget {
  const _ChipFlow({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      children: [
        for (final value in values)
          FBadge(variant: FBadgeVariant.outline, child: Text(value)),
      ],
    );
  }
}

/// Targets get a card each: name, gene / UniProt / species, action badges and
/// a bounded PDB preview.
class _TargetList extends StatelessWidget {
  const _TargetList({required this.targets, required this.l10n});

  final List<MedicineDetailTarget> targets;
  final AppLocalizations l10n;

  /// Well-studied kinases carry 80+ PDB entries; showing them all buries the
  /// rest of the page.
  static const _pdbPreviewCount = 6;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final target in targets)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _TargetCard(
              target: target,
              l10n: l10n,
              pdbPreviewCount: _pdbPreviewCount,
            ),
          ),
      ],
    );
  }
}

class _TargetCard extends StatefulWidget {
  const _TargetCard({
    required this.target,
    required this.l10n,
    required this.pdbPreviewCount,
  });

  final MedicineDetailTarget target;
  final AppLocalizations l10n;
  final int pdbPreviewCount;

  @override
  State<_TargetCard> createState() => _TargetCardState();
}

class _TargetCardState extends State<_TargetCard> {
  bool _showAllPdb = false;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final target = widget.target;
    final l10n = widget.l10n;

    final meta = <String>[
      if (target.geneName != null)
        '${l10n.medicineDetailTargetGene} ${target.geneName}',
      if (target.uniprotId != null)
        '${l10n.medicineDetailTargetUniprot} ${target.uniprotId}',
      if (target.species != null) target.species!,
    ];

    final hiddenPdb = target.pdbIds.length - widget.pdbPreviewCount;
    final visiblePdb = _showAllPdb
        ? target.pdbIds
        : target.pdbIds.take(widget.pdbPreviewCount).toList(growable: false);

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    target.name,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (target.relationKind != null) ...[
                  const SizedBox(width: Spacing.xs),
                  _RelationBadge(kind: target.relationKind!, l10n: l10n),
                ],
              ],
            ),
            if (meta.isNotEmpty) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                meta.join(' · '),
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            if (target.actions.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: [
                  for (final action in target.actions)
                    FBadge(variant: FBadgeVariant.primary, child: Text(action)),
                ],
              ),
            ],
            if (visiblePdb.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.medicineDetailTargetPdb,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: [
                  for (final pdbId in visiblePdb)
                    FBadge(variant: FBadgeVariant.outline, child: Text(pdbId)),
                  if (hiddenPdb > 0 && !_showAllPdb)
                    FTappable(
                      onPress: () => setState(() => _showAllPdb = true),
                      child: FBadge(
                        variant: FBadgeVariant.outline,
                        child: Text(
                          l10n.medicineDetailTargetPdbMore(hiddenPdb),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RelationBadge extends StatelessWidget {
  const _RelationBadge({required this.kind, required this.l10n});

  final String kind;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final label = switch (kind) {
      'target' => l10n.medicineDetailRelationTarget,
      'enzyme' => l10n.medicineDetailRelationEnzyme,
      'carrier' => l10n.medicineDetailRelationCarrier,
      'transporter' => l10n.medicineDetailRelationTransporter,
      _ => kind,
    };

    return FBadge(variant: FBadgeVariant.secondary, child: Text(label));
  }
}

/// External identifiers and links: a scrollable label/value list with a copy
/// affordance, since these are short machine identifiers.
class _ReferenceList extends StatelessWidget {
  const _ReferenceList({required this.references, required this.l10n});

  final List<MedicineDetailExternalReference> references;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final reference in references)
          FTappable(
            onPress: () async {
              await Clipboard.setData(ClipboardData(text: reference.value));
              if (context.mounted) {
                await Toast.show(context, l10n.medicineDetailReferenceCopied);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      reference.resource,
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    flex: 5,
                    child: Text(
                      reference.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.sm,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
