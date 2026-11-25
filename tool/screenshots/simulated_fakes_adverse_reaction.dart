import 'package:luminous/features/medicine/domain/entities/adverse_reaction.dart';

/// Simulated OnSIDES adverse-reaction reports for the screenshot generator.
///
/// Authored for this generator, like the rest of `simulated_fakes_*`: a plausible
/// mid-study drug with a populated adverse-reaction section, so the captures show
/// the real render path rather than an empty state. Nothing here is fixture data
/// from the e2e suite.
///
/// The scores are `pred1` values copied from the real distribution
/// (3.26–6.07, quartiles 4.58 / 5.36) so the banding behaves exactly as it does
/// against the live endpoint: some rows land high, some medium, some low.
const simulatedAdverseReactionReport = AdverseReactionReport(
  rxnormCui: '5640',
  sourceVersion: 'v3.1.1',
  reactions: <AdverseReaction>[
    AdverseReaction(
      meddraId: '10037844',
      name: 'Rash',
      termType: 'LLT',
      labelCount: 12,
      labelSections: <String>['AR'],
      sources: <String>['US'],
      confidence: ReactionConfidence.high,
    ),
    AdverseReaction(
      meddraId: '10028813',
      name: 'Nausea',
      termType: 'LLT',
      labelCount: 9,
      labelSections: <String>['AR'],
      sources: <String>['US', 'JP'],
      confidence: ReactionConfidence.high,
    ),
    AdverseReaction(
      meddraId: '10019211',
      name: 'Headache',
      termType: 'LLT',
      labelCount: 4,
      labelSections: <String>['AR'],
      sources: <String>['US'],
      confidence: ReactionConfidence.medium,
    ),
    AdverseReaction(
      meddraId: '10013800',
      name: 'Dyspepsia',
      termType: 'LLT',
      labelCount: 3,
      labelSections: <String>['AR'],
      sources: <String>['US'],
      confidence: ReactionConfidence.medium,
    ),
    AdverseReaction(
      meddraId: '10043882',
      name: 'Tinnitus',
      termType: 'LLT',
      labelCount: 2,
      labelSections: <String>['AR'],
      sources: <String>['US'],
      confidence: ReactionConfidence.low,
    ),
    // A row the source left unscored: it must render without a badge, which is
    // the case that tells "unscored" apart from "scored low" in a capture.
    AdverseReaction(
      meddraId: '10047700',
      name: 'Vision blurred',
      termType: 'LLT',
      labelCount: 1,
      labelSections: <String>['AR'],
      sources: <String>['US'],
      confidence: ReactionConfidence.unscored,
    ),
    // Elevated to a boxed warning, so the second section bucket is populated.
    AdverseReaction(
      meddraId: '10020468',
      name: 'Gastrointestinal haemorrhage',
      termType: 'LLT',
      labelCount: 6,
      labelSections: <String>['BW'],
      sources: <String>['US'],
      confidence: ReactionConfidence.high,
    ),
    AdverseReaction(
      meddraId: '10020772',
      name: 'Hypersensitivity',
      termType: 'LLT',
      labelCount: 5,
      labelSections: <String>['WP'],
      sources: <String>['US', 'UK'],
      confidence: ReactionConfidence.high,
    ),
  ],
  groups: <ReactionGroup>[
    ReactionGroup(
      section: ReactionSection.adverseReaction,
      reactions: <AdverseReaction>[
        AdverseReaction(
          meddraId: '10037844',
          name: 'Rash',
          termType: 'LLT',
          labelCount: 12,
          labelSections: <String>['AR'],
          sources: <String>['US'],
          confidence: ReactionConfidence.high,
        ),
        AdverseReaction(
          meddraId: '10028813',
          name: 'Nausea',
          termType: 'LLT',
          labelCount: 9,
          labelSections: <String>['AR'],
          sources: <String>['US', 'JP'],
          confidence: ReactionConfidence.high,
        ),
        AdverseReaction(
          meddraId: '10019211',
          name: 'Headache',
          termType: 'LLT',
          labelCount: 4,
          labelSections: <String>['AR'],
          sources: <String>['US'],
          confidence: ReactionConfidence.medium,
        ),
        AdverseReaction(
          meddraId: '10013800',
          name: 'Dyspepsia',
          termType: 'LLT',
          labelCount: 3,
          labelSections: <String>['AR'],
          sources: <String>['US'],
          confidence: ReactionConfidence.medium,
        ),
        AdverseReaction(
          meddraId: '10043882',
          name: 'Tinnitus',
          termType: 'LLT',
          labelCount: 2,
          labelSections: <String>['AR'],
          sources: <String>['US'],
          confidence: ReactionConfidence.low,
        ),
        AdverseReaction(
          meddraId: '10047700',
          name: 'Vision blurred',
          termType: 'LLT',
          labelCount: 1,
          labelSections: <String>['AR'],
          sources: <String>['US'],
          confidence: ReactionConfidence.unscored,
        ),
      ],
    ),
    ReactionGroup(
      section: ReactionSection.boxedWarning,
      reactions: <AdverseReaction>[
        AdverseReaction(
          meddraId: '10020468',
          name: 'Gastrointestinal haemorrhage',
          termType: 'LLT',
          labelCount: 6,
          labelSections: <String>['BW'],
          sources: <String>['US'],
          confidence: ReactionConfidence.high,
        ),
      ],
    ),
    ReactionGroup(
      section: ReactionSection.warningPrecautions,
      reactions: <AdverseReaction>[
        AdverseReaction(
          meddraId: '10020772',
          name: 'Hypersensitivity',
          termType: 'LLT',
          labelCount: 5,
          labelSections: <String>['WP'],
          sources: <String>['US', 'UK'],
          confidence: ReactionConfidence.high,
        ),
      ],
    ),
  ],
);

/// Reports keyed by DrugBank id, for the drugbank-variant detail captures.
const simulatedAdverseReactionReportsByDrugbankId =
    <String, AdverseReactionReport>{'DB01050': simulatedAdverseReactionReport};

/// The empty report the section shows once a drug is bridged but has no rows.
const simulatedEmptyAdverseReactionReport = AdverseReactionReport(
  rxnormCui: '5640',
  sourceVersion: 'v3.1.1',
  reactions: <AdverseReaction>[],
  groups: <ReactionGroup>[],
);
