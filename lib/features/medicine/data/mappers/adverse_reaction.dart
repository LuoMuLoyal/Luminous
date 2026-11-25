import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/domain/entities/adverse_reaction.dart';
import 'package:luminous/features/medicine/domain/repositories/adverse_reaction.dart';

/// Maps the OnSIDES resources onto domain entities.
///
/// Two decisions live here, both of which the UI depends on:
///
/// 1. **The raw score never leaves this file.** `confidenceMax` is an
///    unnormalised log-odds; it is banded into [ReactionConfidence] here so no
///    widget can accidentally render the number as if it were a probability.
/// 2. **Grouping is done once, here.** Reactions are bucketed by label section
///    with AR first, and each bucket keeps the backend's ordering
///    (confidence desc, then label count desc) — the widget only renders.
class AdverseReactionMapper {
  const AdverseReactionMapper();

  AdverseReactionReport reportDtoToEntity(IngredientReactionsResponse dto) {
    final reactions = dto.reactions.map(_reaction).toList(growable: false);

    return AdverseReactionReport(
      rxnormCui: dto.rxnormCui,
      sourceVersion: dto.sourceVersion,
      reactions: reactions,
      groups: _group(reactions),
    );
  }

  ReactionDrugList reactionDrugsDtoToEntity(ReactionDrugsResponse dto) {
    return ReactionDrugList(
      meddraId: dto.meddraId,
      meddraName: _trimToNull(dto.meddraName),
      drugs: dto.drugs
          .map(
            (row) => ReactionDrug(
              drugbankId: row.drugbankId,
              name: row.name,
              labelCount: row.labelCount,
              confidence: ReactionConfidence.fromScore(
                row.confidenceMax?.toDouble(),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  AdverseReaction _reaction(IngredientReactionsResponseReactions row) {
    return AdverseReaction(
      meddraId: row.meddraId,
      name: row.name.trim(),
      termType: row.termType,
      labelCount: row.labelCount,
      labelSections: row.labelSections,
      sources: row.sources,
      confidence: ReactionConfidence.fromScore(row.confidenceMax?.toDouble()),
    );
  }

  /// Buckets by section, dropping empty buckets and keeping AR first.
  ///
  /// A reaction can carry several sections (a statement can appear in both the
  /// adverse-reactions section and a boxed warning), so it appears in each
  /// bucket it belongs to — that is what a reader expects when the same reaction
  /// is elevated to a warning.
  List<ReactionGroup> _group(List<AdverseReaction> reactions) {
    final bySection = <ReactionSection, List<AdverseReaction>>{};

    for (final reaction in reactions) {
      final sections = reaction.labelSections.isEmpty
          // No section recorded: still show the reaction rather than hiding it.
          ? const [ReactionSection.notApplicable]
          : reaction.labelSections.map(ReactionSection.fromWire).toSet();

      for (final section in sections) {
        (bySection[section] ??= <AdverseReaction>[]).add(reaction);
      }
    }

    return [
      for (final section in ReactionSection.values)
        if (bySection[section] case final items?)
          ReactionGroup(section: section, reactions: items),
    ];
  }

  String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
