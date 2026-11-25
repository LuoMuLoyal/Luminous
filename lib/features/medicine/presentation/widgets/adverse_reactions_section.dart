import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/core/widgets/common/feedback/state_message.dart';
import 'package:luminous/features/medicine/domain/entities/adverse_reaction.dart';
import 'package:luminous/features/medicine/presentation/providers/adverse_reaction.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Label-stated adverse reactions for one drug, grouped by label section.
///
/// ## What this is not
///
/// Not an incidence chart. The source is the structured product label: each row
/// says "this label states this reaction for this ingredient". `labelCount` is
/// how many labels said so, and the confidence band is how sure the extraction
/// model is that it **read the label correctly** — neither is a probability that
/// a patient will experience the reaction. The section footer states this once
/// rather than repeating a caveat on every row.
///
/// ## Three states, deliberately
///
/// - `null` report → the drug has no RxCUI bridge (91.8% of DrugBank). Renders
///   a quiet "no data" line, no retry: nothing failed, and retrying a coverage
///   gap is pointless.
/// - empty report → bridged, but no statements. Same quiet line, different
///   wording is not worth a separate string.
/// - error → a real transport failure, with retry.
class DrugAdverseReactionsSection extends ConsumerWidget {
  const DrugAdverseReactionsSection({
    super.key,
    required this.drugbankId,
    required this.l10n,
    this.reportOverride,
  });

  final String drugbankId;
  final AppLocalizations l10n;

  /// Test seam: supplies the report without hitting the network.
  final AsyncValue<AdverseReactionReport?>? reportOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AdverseReactionReport?> report =
        reportOverride ?? ref.watch(drugAdverseReactionsProvider(drugbankId));

    return report.when(
      loading: () => const _ReactionSkeleton(),
      error: (error, stackTrace) => StateMessageView(
        title: l10n.medicineReactionError,
        icon: SemanticIcons.statusError,
        tone: StateTone.danger,
        actionLabel: l10n.todayRetryAction,
        onAction: () =>
            ref.invalidate(drugAdverseReactionsProvider(drugbankId)),
      ),
      data: (data) {
        if (data == null || data.isEmpty) {
          return Text(
            l10n.medicineReactionNoBridge,
            style: context.theme.typography.body.sm.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          );
        }
        return _ReactionGroups(report: data, l10n: l10n);
      },
    );
  }
}

class _ReactionGroups extends StatelessWidget {
  const _ReactionGroups({required this.report, required this.l10n});

  final AdverseReactionReport report;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in report.groups)
          _SectionGroup(group: group, l10n: l10n),
        const SizedBox(height: Spacing.xs),
        // The caveat belongs here, once per section, not on every row: HIG's
        // grouped-list footer exists for exactly this kind of qualification.
        Text(
          l10n.medicineReactionFootNote,
          style: context.theme.typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ],
    );
  }
}

/// One section (adverse reactions / boxed warning / warnings / other) as an
/// iOS-style grouped card: rows in a rounded card, first row first.
class _SectionGroup extends StatefulWidget {
  const _SectionGroup({required this.group, required this.l10n});

  final ReactionGroup group;
  final AppLocalizations l10n;

  @override
  State<_SectionGroup> createState() => _SectionGroupState();
}

class _SectionGroupState extends State<_SectionGroup> {
  /// Rows shown before the "show all" affordance. A single label section can
  /// carry hundreds of terms; the card is a preview, not the whole list.
  static const _previewCount = 8;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final reactions = widget.group.reactions;
    final visible = _expanded
        ? reactions
        : reactions.take(_previewCount).toList(growable: false);
    final hidden = reactions.length - visible.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // No label for the adverse-reaction bucket: the accordion header
          // already says "Adverse Reactions", so repeating it is the same phrase
          // twice in a row. The other buckets keep theirs — they are the
          // distinctions that actually need naming.
          if (widget.group.section != ReactionSection.adverseReaction)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Text(
                _sectionLabel(widget.group.section, l10n),
                style: context.theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w700,
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ),
          FCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < visible.length; index += 1) ...[
                    if (index > 0) const FDivider(),
                    _ReactionRow(reaction: visible[index], l10n: l10n),
                  ],
                  if (hidden > 0)
                    FTappable(
                      onPress: () => setState(() => _expanded = true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.sm,
                        ),
                        child: Text(
                          // HIG: an action names the action. The old string was
                          // a bare count, which reads as a label, not a control.
                          l10n.medicineReactionShowAll,
                          style: context.theme.typography.body.xs.copyWith(
                            color: SemanticColor.primary.solid(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sectionLabel(ReactionSection section, AppLocalizations l10n) {
    return switch (section) {
      ReactionSection.adverseReaction => l10n.medicineReactionSectionAr,
      ReactionSection.boxedWarning => l10n.medicineReactionSectionBw,
      ReactionSection.warningPrecautions => l10n.medicineReactionSectionWp,
      ReactionSection.notApplicable => l10n.medicineReactionSectionNa,
    };
  }
}

/// One reaction: the term, plus its confidence band as a trailing badge.
///
/// No secondary text: `labelCount` and the source set are internal evidence, and
/// HIG keeps a cell to one line of content plus at most one trailing value.
class _ReactionRow extends StatelessWidget {
  const _ReactionRow({required this.reaction, required this.l10n});

  final AdverseReaction reaction;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final confidence = _confidenceLabel(reaction.confidence, l10n);
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              reaction.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typography.body.sm,
            ),
          ),
          if (confidence != null) ...[
            const SizedBox(width: Spacing.sm),
            FBadge(
              variant: _badgeVariant(reaction.confidence),
              child: Text(
                confidence,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// An unscored row gets no badge at all rather than a "low" one: the source
  /// omitted a score, which is not the same statement as "scored low".
  String? _confidenceLabel(
    ReactionConfidence confidence,
    AppLocalizations l10n,
  ) {
    return switch (confidence) {
      ReactionConfidence.high => l10n.medicineReactionConfidenceHigh,
      ReactionConfidence.medium => l10n.medicineReactionConfidenceMedium,
      ReactionConfidence.low => l10n.medicineReactionConfidenceLow,
      ReactionConfidence.unscored => null,
    };
  }

  FBadgeVariant _badgeVariant(ReactionConfidence confidence) {
    return switch (confidence) {
      ReactionConfidence.high => FBadgeVariant.primary,
      ReactionConfidence.medium => FBadgeVariant.secondary,
      ReactionConfidence.low ||
      ReactionConfidence.unscored => FBadgeVariant.outline,
    };
  }
}

class _ReactionSkeleton extends StatelessWidget {
  const _ReactionSkeleton();

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
