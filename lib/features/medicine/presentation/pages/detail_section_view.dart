import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/core/widgets/common/feedback/state_message.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/pages/detail_sections.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart';
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
    this.shouldLoad = false,
    this.medicineId,
    this.source = 'drugbank',
  });

  final MedicineDetailSection section;
  final AppLocalizations l10n;

  /// Whether a section that fetches its own data on demand (currently only
  /// sequences) may fire that request.
  ///
  /// The accordion builds collapsed children eagerly, so "was built" is not the
  /// same as "the user opened it" — the page lifts the accordion's expanded set
  /// and flips this instead.
  final bool shouldLoad;

  final String? medicineId;
  final String source;

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
      SequencesSectionBody(:final summary) => MedicineSequencesSection(
        summary: summary,
        l10n: l10n,
        shouldLoad: shouldLoad,
        medicineId: medicineId,
        source: source,
      ),
      StructureSectionBody(:final structure) => MedicineStructureView(
        structure: structure,
        l10n: l10n,
      ),
    };
  }
}

/// Computed structure descriptors, grouped so 30-odd numbers stay readable.
///
/// Identifiers get a copy affordance because they are the values people
/// actually paste elsewhere; the rest are label/value rows.
class MedicineStructureView extends StatelessWidget {
  const MedicineStructureView({
    super.key,
    required this.structure,
    required this.l10n,
  });

  final MedicineStructure structure;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StructureRows(
          rows: <(String, String?)>[
            (l10n.medicineDetailStructureFormula, structure.formula),
            (
              l10n.medicineDetailStructureWeight,
              _number(structure.molecularWeight),
            ),
            (
              l10n.medicineDetailStructureExactMass,
              _number(structure.exactMass, digits: 4),
            ),
            (l10n.medicineDetailStructureSmiles, structure.smiles),
            (l10n.medicineDetailStructureInchiKey, structure.inchiKey),
            (l10n.medicineDetailStructureInchi, structure.inchiIdentifier),
            (l10n.medicineDetailStructureIupac, structure.iupacName),
          ].where((row) => row.$2 != null).toList(growable: false),
          l10n: l10n,
          copyable: true,
        ),
        _group(l10n.medicineDetailStructureSurfaceGroup, [
          (l10n.medicineDetailStructureAtoms, _int(structure.atomCount)),
          (l10n.medicineDetailStructureRings, _int(structure.ringCount)),
          (
            l10n.medicineDetailStructureRotatable,
            _int(structure.rotatableBondCount),
          ),
          (
            l10n.medicineDetailStructureAcceptors,
            _int(structure.acceptorCount),
          ),
          (l10n.medicineDetailStructureDonors, _int(structure.donorCount)),
          (
            l10n.medicineDetailStructureTpsa,
            _number(structure.polarSurfaceArea),
          ),
          (
            l10n.medicineDetailStructurePolarizability,
            _number(structure.polarizability, digits: 1),
          ),
          (
            l10n.medicineDetailStructureRefractivity,
            _number(structure.refractivity, digits: 1),
          ),
        ]),
        _group(l10n.medicineDetailStructureLogpGroup, [
          (l10n.medicineDetailStructureLogp, _number(structure.logP)),
          (
            l10n.medicineDetailStructureAlogpsLogp,
            _number(structure.alogpsLogP),
          ),
          (
            l10n.medicineDetailStructureAlogpsLogs,
            _number(structure.alogpsLogS),
          ),
          (l10n.medicineDetailStructureSolubility, structure.alogpsSolubility),
        ]),
        _group(l10n.medicineDetailStructureChargeGroup, [
          (
            l10n.medicineDetailStructureFormalCharge,
            _signedInt(structure.formalCharge),
          ),
          (
            l10n.medicineDetailStructurePhysiologicalCharge,
            _signedInt(structure.physiologicalCharge),
          ),
          (
            l10n.medicineDetailStructurePkaAcidic,
            _number(structure.pkaStrongestAcidic),
          ),
          (
            l10n.medicineDetailStructurePkaBasic,
            _number(structure.pkaStrongestBasic),
          ),
        ]),
        _group(l10n.medicineDetailStructureRulesGroup, [
          (
            l10n.medicineDetailStructureRuleOfFive,
            _verdict(structure.ruleOfFive),
          ),
          (l10n.medicineDetailStructureVeber, _verdict(structure.veberRule)),
          (l10n.medicineDetailStructureGhose, _verdict(structure.ghoseFilter)),
          (l10n.medicineDetailStructureMddr, _verdict(structure.mddrLikeRule)),
        ]),
        if (structure.salts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.xs),
                  child: Text(
                    l10n.medicineDetailStructureSalts,
                    style: context.theme.typography.body.xs.copyWith(
                      fontWeight: FontWeight.w700,
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ),
                _ChipFlow(values: structure.salts),
              ],
            ),
          ),
      ],
    );
  }

  Widget _group(String title, List<(String, String?)> rows) {
    final filled = rows.where((row) => row.$2 != null).toList(growable: false);
    if (filled.isEmpty) return const SizedBox.shrink();
    return _StructureRows(rows: filled, l10n: l10n, heading: title);
  }

  String? _int(int? value) => value?.toString();

  String? _signedInt(int? value) =>
      value == null ? null : (value > 0 ? '+$value' : '$value');

  String? _number(double? value, {int digits = 2}) {
    if (value == null) return null;
    return value.toStringAsFixed(digits);
  }

  /// The source stores rule verdicts as 0/1 flags.
  String? _verdict(int? value) => switch (value) {
    1 => l10n.medicineDetailStructurePass,
    0 => l10n.medicineDetailStructureFail,
    _ => null,
  };
}

/// A group of label/value rows, optionally with a heading and copy buttons.
class _StructureRows extends StatelessWidget {
  const _StructureRows({
    required this.rows,
    required this.l10n,
    this.heading,
    this.copyable = false,
  });

  final List<(String, String?)> rows;
  final AppLocalizations l10n;
  final String? heading;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (heading != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Text(
                heading!,
                style: typography.body.xs.copyWith(
                  fontWeight: FontWeight.w700,
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      label,
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    flex: 5,
                    child: Text(value!, style: typography.body.sm),
                  ),
                  if (copyable) ...[
                    const SizedBox(width: Spacing.xs),
                    FTappable(
                      onPress: () async {
                        await Clipboard.setData(ClipboardData(text: value));
                        if (context.mounted) {
                          await Toast.show(
                            context,
                            l10n.medicineDetailReferenceCopied,
                          );
                        }
                      },
                      child: Icon(
                        FLucideIcons.copy,
                        size: IconSizeTokens.sm,
                        color: SemanticColor.primary.solid(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Sequences of the drug itself and of its targets.
///
/// Fetches nothing until [shouldLoad] turns true, then shows a skeleton while
/// the (potentially tens-of-thousands-of-characters) payload is in flight.
class MedicineSequencesSection extends ConsumerWidget {
  const MedicineSequencesSection({
    super.key,
    required this.summary,
    required this.l10n,
    required this.shouldLoad,
    this.medicineId,
    this.source = 'drugbank',
    this.sequencesOverride,
  });

  final MedicineDetailSequenceSummary summary;
  final AppLocalizations l10n;
  final bool shouldLoad;
  final String? medicineId;
  final String source;

  /// Test seam: supplies the payload without hitting the network.
  final AsyncValue<MedicineSequences>? sequencesOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryLine = _summaryLine();

    if (!shouldLoad || (medicineId == null && sequencesOverride == null)) {
      // Not opened yet: say what is waiting without paying for it.
      return Text(summaryLine, style: context.theme.typography.body.sm);
    }

    final AsyncValue<MedicineSequences> sequences =
        sequencesOverride ??
        ref.watch(medicineSequencesProvider(source, medicineId!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          summaryLine,
          style: context.theme.typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        sequences.when(
          loading: () => const _SequenceSkeleton(),
          error: (error, stackTrace) => StateMessageView(
            title: l10n.medicineDetailSequencesError,
            icon: SemanticIcons.statusError,
            tone: StateTone.danger,
            actionLabel: l10n.todayRetryAction,
            onAction: () =>
                ref.invalidate(medicineSequencesProvider(source, medicineId!)),
          ),
          data: (data) => _SequenceLists(data: data, l10n: l10n),
        ),
      ],
    );
  }

  String _summaryLine() {
    final parts = <String>[
      if (summary.drugChainCount > 0)
        l10n.medicineDetailSequencesDrugChains(summary.drugChainCount),
      if (summary.targetSequenceCount > 0)
        l10n.medicineDetailSequencesTargets(summary.targetSequenceCount),
    ];
    return parts.join(' · ');
  }
}

class _SequenceSkeleton extends StatelessWidget {
  const _SequenceSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InlineSkeletonBlock(height: 16),
        SizedBox(height: Spacing.xs),
        InlineSkeletonBlock(height: 16),
        SizedBox(height: Spacing.xs),
        InlineSkeletonBlock(height: 16),
      ],
    );
  }
}

class _SequenceLists extends StatelessWidget {
  const _SequenceLists({required this.data, required this.l10n});

  final MedicineSequences data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    if (data.isEmpty) {
      return Text(l10n.medicineDetailSequencesEmpty, style: typography.body.sm);
    }

    final grouped = data.targetsByUniprotId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.drug.isNotEmpty) ...[
          _Heading(l10n.medicineDetailSequencesDrugHeading),
          for (final chain in data.drug)
            _SequenceCard(
              title: chain.description,
              meta: l10n.medicineDetailSequenceResidues(chain.length),
              sequence: chain.sequence,
              l10n: l10n,
            ),
        ],
        if (grouped.isNotEmpty) ...[
          _Heading(l10n.medicineDetailSequencesTargetsHeading),
          for (final entry in grouped.entries)
            _SequenceCard(
              title: entry.value.first.targetName ?? entry.key,
              meta: [
                entry.key,
                for (final sequence in entry.value)
                  '${_datasetLabel(sequence)} · ${_lengthLabel(sequence)}',
              ].join(' · '),
              // A target's protein and coding sequence are two readings of the
              // same gene; the protein is what the drug actually binds.
              sequence: entry.value
                  .firstWhere(
                    (sequence) => !sequence.isGene,
                    orElse: () => entry.value.first,
                  )
                  .sequence,
              l10n: l10n,
            ),
        ],
      ],
    );
  }

  String _datasetLabel(MedicineTargetSequence sequence) => sequence.isGene
      ? l10n.medicineDetailSequenceGene
      : l10n.medicineDetailSequenceProtein;

  String _lengthLabel(MedicineTargetSequence sequence) => sequence.isGene
      ? l10n.medicineDetailSequenceBases(sequence.length)
      : l10n.medicineDetailSequenceResidues(sequence.length);
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.xs),
      child: Text(
        text,
        style: context.theme.typography.body.xs.copyWith(
          fontWeight: FontWeight.w700,
          color: SemanticColor.neutral.solid(context),
        ),
      ),
    );
  }
}

/// One sequence: a header with its length, then the residues in a monospaced
/// block that can be selected or copied.
class _SequenceCard extends StatelessWidget {
  const _SequenceCard({
    required this.title,
    required this.meta,
    required this.sequence,
    required this.l10n,
  });

  final String title;
  final String meta;
  final String sequence;
  final AppLocalizations l10n;

  /// Residues per rendered line. A single unbroken line of protein is
  /// unreadable and impossible to compare against a reference.
  static const _lineWidth = 60;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: typography.body.sm.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          meta,
                          style: typography.body.xs.copyWith(
                            color: SemanticColor.neutral.solid(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FTappable(
                    onPress: () async {
                      await Clipboard.setData(ClipboardData(text: sequence));
                      if (context.mounted) {
                        await Toast.show(
                          context,
                          l10n.medicineDetailReferenceCopied,
                        );
                      }
                    },
                    child: Icon(
                      FLucideIcons.copy,
                      size: IconSizeTokens.sm,
                      color: SemanticColor.primary.solid(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              SelectableText(
                _wrap(sequence, _lineWidth),
                style: typography.body.xs.copyWith(
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _wrap(String sequence, int width) {
    final buffer = StringBuffer();
    for (var index = 0; index < sequence.length; index += width) {
      if (index > 0) buffer.write('\n');
      final end = index + width > sequence.length
          ? sequence.length
          : index + width;
      buffer.write(sequence.substring(index, end));
    }
    return buffer.toString();
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
