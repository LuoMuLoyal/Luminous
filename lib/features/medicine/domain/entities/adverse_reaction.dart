import 'package:freezed_annotation/freezed_annotation.dart';

part 'adverse_reaction.freezed.dart';

/// How much the extraction model trusts that a label actually states this
/// reaction.
///
/// This is a **data-quality** verdict, not a medical one. It says "the model is
/// confident it read the label correctly", never "this reaction is likely to
/// happen to you". The UI must not present it as risk.
///
/// The bands are cut from the source distribution, not from round numbers: over
/// the full 6.7M-row corpus `pred1` runs 3.26-6.07 with quartiles at 4.58 / 5.36,
/// so the three bands land at roughly 25% / 25% / 50% of all pairings.
enum ReactionConfidence {
  high,
  medium,
  low,

  /// The source carried no score at all. Distinct from [low]: "unscored" is not
  /// "scored badly", and the UI must not render them the same way.
  unscored;

  /// `pred1` quartile cut points, measured on the full corpus.
  static const mediumFloor = 4.58;
  static const highFloor = 5.36;

  /// Bands a raw `pred1` value.
  ///
  /// `pred1` is an unnormalised log-odds, so the raw number means nothing to a
  /// reader; it exists only to pick a band.
  static ReactionConfidence fromScore(double? score) {
    if (score == null) return ReactionConfidence.unscored;
    if (score >= highFloor) return ReactionConfidence.high;
    if (score >= mediumFloor) return ReactionConfidence.medium;
    return ReactionConfidence.low;
  }
}

/// One adverse reaction a product label states for an ingredient.
@freezed
abstract class AdverseReaction with _$AdverseReaction {
  const factory AdverseReaction({
    required String meddraId,
    required String name,
    required String termType,
    required int labelCount,
    required List<String> labelSections,
    required List<String> sources,
    required ReactionConfidence confidence,
  }) = _AdverseReaction;
}

/// The section a statement came from, in the order the source prioritises them.
///
/// `AR` is the adverse-reactions section proper; the rest are adjacent label
/// sections that also name reactions. Order matters because it decides which
/// group a user sees first.
enum ReactionSection {
  adverseReaction('AR'),
  boxedWarning('BW'),
  warningPrecautions('WP'),
  notApplicable('NA');

  const ReactionSection(this.wireValue);

  /// The raw value the source uses in `label_sections`.
  final String wireValue;

  /// Unknown values fall back to [notApplicable] rather than throwing: a new
  /// section code in a quarterly upstream release must not break the page.
  static ReactionSection fromWire(String value) {
    for (final section in ReactionSection.values) {
      if (section.wireValue == value) return section;
    }
    return ReactionSection.notApplicable;
  }
}

/// Reactions grouped by the label section they were stated in.
@freezed
abstract class ReactionGroup with _$ReactionGroup {
  const factory ReactionGroup({
    required ReactionSection section,
    required List<AdverseReaction> reactions,
  }) = _ReactionGroup;
}

/// All label-stated adverse reactions reachable from one medicine.
@freezed
abstract class AdverseReactionReport with _$AdverseReactionReport {
  const factory AdverseReactionReport({
    required String rxnormCui,
    required String sourceVersion,
    required List<AdverseReaction> reactions,
    required List<ReactionGroup> groups,
  }) = _AdverseReactionReport;

  const AdverseReactionReport._();

  bool get isEmpty => reactions.isEmpty;
}
