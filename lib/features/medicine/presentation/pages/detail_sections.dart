import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Builds the detail-page section list for one medicine, ordered by how often
/// a patient actually looks for each piece of information.
///
/// The source payload is a flat bag of fields; rendering it in payload order
/// put a one-word field such as "Drug type" in the same visual weight as the
/// approved indications. The tiers below encode the real reading order:
///
/// 1. [Tier.primary] — indications, expanded by default.
/// 2. [Tier.safety] — mechanism, toxicity, interactions.
/// 3. [Tier.clinical] — targets, description, pharmacodynamics.
/// 4. [Tier.pharmacokinetics] — metabolism, absorption, half-life, ...
/// 5. [Tier.reference] — molecular/pharmacopoeia reference data and links.
///
/// A section is omitted entirely when the payload has nothing for it.
class MedicineDetailSections {
  const MedicineDetailSections(this.detail, this.l10n);

  final MedicineDetail detail;
  final AppLocalizations l10n;

  /// How long referral text may get before the UI collapses it. Measured
  /// source fields run to several thousand characters (Imatinib `toxicity` is
  /// 4.6k), which is unreadable as one block.
  static const longTextThreshold = 420;

  List<MedicineDetailSection> build() {
    return detail.source == 'drugbank' ? _drugbank() : _cn();
  }

  List<MedicineDetailSection> _cn() {
    return [
      ..._text(
        Tier.primary,
        l10n.medicineDetailSectionIndications,
        detail.indications,
      ),
      ..._text(
        Tier.primary,
        l10n.medicineDetailSectionIngredients,
        detail.ingredients,
      ),
      ..._text(
        Tier.safety,
        l10n.medicineDetailSectionContraindications,
        detail.contraindications,
      ),
      ..._text(
        Tier.safety,
        l10n.medicineDetailSectionPrecautions,
        detail.precautions,
      ),
      ..._text(
        Tier.safety,
        l10n.medicineDetailSectionAdverseReactions,
        detail.adverseReactions,
      ),
      ..._text(Tier.primary, l10n.medicineDetailSectionDosage, detail.dosage),
      ..._text(
        Tier.clinical,
        l10n.medicineDetailSectionPharmacology,
        detail.pharmacologyToxicology,
      ),
      ..._text(
        Tier.clinical,
        l10n.medicineDetailSectionPharmacokinetics,
        detail.pharmacokinetics,
      ),
      ..._text(
        Tier.clinical,
        l10n.medicineDetailSectionProperties,
        detail.properties,
      ),
      ..._text(
        Tier.safety,
        l10n.medicineDetailSectionOverdose,
        detail.overdose,
      ),
      ..._text(
        Tier.pharmacokinetics,
        l10n.medicineDetailSectionStorage,
        detail.storage,
      ),
      ..._text(
        Tier.pharmacokinetics,
        l10n.medicineDetailSectionValidity,
        detail.validityPeriod,
      ),
      ..._referenceRows(),
    ];
  }

  List<MedicineDetailSection> _drugbank() {
    return [
      ..._text(
        Tier.primary,
        l10n.medicineDetailSectionIndications,
        detail.indication,
      ),
      ..._text(
        Tier.safety,
        l10n.medicineDetailSectionMechanism,
        detail.mechanismOfAction,
      ),
      ..._text(
        Tier.safety,
        l10n.medicineDetailSectionToxicity,
        detail.toxicity,
      ),
      ..._interactions(),
      ..._text(
        Tier.safety,
        l10n.medicineDetailSectionFoodInteractions,
        detail.foodInteractions.join('\n'),
      ),
      ..._targets(),
      ..._text(
        Tier.clinical,
        l10n.medicineDetailSectionDescription,
        detail.description,
      ),
      ..._text(
        Tier.clinical,
        l10n.medicineDetailSectionPharmacodynamics,
        detail.pharmacodynamics,
      ),
      ..._text(
        Tier.pharmacokinetics,
        l10n.medicineDetailSectionMetabolism,
        detail.metabolism,
      ),
      ..._text(
        Tier.pharmacokinetics,
        l10n.medicineDetailSectionAbsorption,
        detail.absorption,
      ),
      ..._text(
        Tier.pharmacokinetics,
        l10n.medicineDetailSectionHalfLife,
        detail.halfLife,
      ),
      ..._text(
        Tier.pharmacokinetics,
        l10n.medicineDetailSectionProteinBinding,
        detail.proteinBinding,
      ),
      ..._text(
        Tier.pharmacokinetics,
        l10n.medicineDetailSectionElimination,
        detail.routeOfElimination,
      ),
      ..._text(
        Tier.pharmacokinetics,
        l10n.medicineDetailSectionDistribution,
        detail.volumeOfDistribution,
      ),
      ..._text(
        Tier.pharmacokinetics,
        l10n.medicineDetailSectionClearance,
        detail.clearance,
      ),
      ..._chips(
        Tier.reference,
        l10n.medicineDetailSectionCategories,
        detail.categories,
      ),
      ..._chips(
        Tier.reference,
        l10n.medicineDetailSectionGroups,
        detail.groups,
      ),
      ..._chips(Tier.reference, l10n.medicineDetailSectionAtc, detail.atcCodes),
      ..._chips(
        Tier.reference,
        l10n.medicineDetailSectionSynonyms,
        detail.synonyms,
      ),
      ..._externalIdentifiers(),
      ..._externalLinks(),
      ..._sequences(),
      ..._referenceRows(),
    ];
  }

  /// Long prose. Emitted only when non-blank.
  List<MedicineDetailSection> _text(Tier tier, String title, String? body) {
    final value = body?.trim();
    if (value == null || value.isEmpty) return const [];
    return [
      MedicineDetailSection(
        tier: tier,
        title: title,
        body: DetailSectionBody.text(value),
      ),
    ];
  }

  /// Short enumerations rendered as a wrapping chip flow rather than a
  /// comma-joined paragraph that ran off the card.
  List<MedicineDetailSection> _chips(
    Tier tier,
    String title,
    List<String> items,
  ) {
    final values = items
        .map((item) => item.trim())
        .where((v) => v.isNotEmpty)
        .toList();
    if (values.isEmpty) return const [];
    return [
      MedicineDetailSection(
        tier: tier,
        title: title,
        body: DetailSectionBody.chips(values),
      ),
    ];
  }

  List<MedicineDetailSection> _interactions() {
    if (detail.drugInteractions.isEmpty) return const [];
    return [
      MedicineDetailSection(
        tier: Tier.safety,
        title: l10n.medicineDetailSectionDrugInteractions,
        count: detail.drugInteractions.length,
        body: DetailSectionBody.text(
          detail.drugInteractions
              .map((item) => '${item.drugbankId}: ${item.description}')
              .join('\n\n'),
        ),
      ),
    ];
  }

  List<MedicineDetailSection> _targets() {
    if (detail.targets.isEmpty) return const [];
    return [
      MedicineDetailSection(
        tier: Tier.clinical,
        title: l10n.medicineDetailSectionTargets,
        count: detail.targets.length,
        body: DetailSectionBody.targets(detail.targets, l10n),
      ),
    ];
  }

  List<MedicineDetailSection> _externalIdentifiers() {
    if (detail.externalIdentifiers.isEmpty) return const [];
    return [
      MedicineDetailSection(
        tier: Tier.reference,
        title: l10n.medicineDetailSectionExternalIdentifiers,
        count: detail.externalIdentifiers.length,
        body: DetailSectionBody.references(detail.externalIdentifiers, l10n),
      ),
    ];
  }

  List<MedicineDetailSection> _externalLinks() {
    if (detail.externalLinks.isEmpty) return const [];
    return [
      MedicineDetailSection(
        tier: Tier.reference,
        title: l10n.medicineDetailSectionExternalLinks,
        count: detail.externalLinks.length,
        body: DetailSectionBody.references(detail.externalLinks, l10n),
      ),
    ];
  }

  /// Sequences, advertised by count only.
  ///
  /// The text itself is never in the detail payload — the section body fetches
  /// it on demand, so this only decides whether the section is worth showing.
  List<MedicineDetailSection> _sequences() {
    final summary = detail.sequenceSummary;
    if (summary == null || summary.isEmpty) return const [];
    return [
      MedicineDetailSection(
        tier: Tier.reference,
        title: l10n.medicineDetailSectionSequences,
        count: summary.total,
        body: DetailSectionBody.sequences(summary),
      ),
    ];
  }

  /// Provenance rows the payload already carried but the page never rendered.
  /// Each is short enough to stand as its own self-titled section.
  List<MedicineDetailSection> _referenceRows() {
    return [
      ..._text(
        Tier.reference,
        l10n.medicineDetailSectionBarcode,
        detail.barcode,
      ),
      ..._text(
        Tier.reference,
        l10n.medicineDetailSectionNationalDrugCode,
        detail.nationalDrugCode,
      ),
      ..._text(
        Tier.reference,
        l10n.medicineDetailSectionSource,
        detail.sourceUrl,
      ),
    ];
  }
}

/// Reading-order tier; also the order sections and cards are laid out in.
enum Tier { primary, safety, clinical, pharmacokinetics, reference }

/// What a section renders as.
sealed class DetailSectionBody {
  const DetailSectionBody();

  const factory DetailSectionBody.text(String value) = TextSectionBody;
  const factory DetailSectionBody.chips(List<String> values) = ChipsSectionBody;
  const factory DetailSectionBody.targets(
    List<MedicineDetailTarget> values,
    AppLocalizations l10n,
  ) = TargetsSectionBody;
  const factory DetailSectionBody.references(
    List<MedicineDetailExternalReference> values,
    AppLocalizations l10n,
  ) = ReferencesSectionBody;
  const factory DetailSectionBody.sequences(
    MedicineDetailSequenceSummary summary,
  ) = SequencesSectionBody;
}

class TextSectionBody extends DetailSectionBody {
  const TextSectionBody(this.value);
  final String value;
}

class ChipsSectionBody extends DetailSectionBody {
  const ChipsSectionBody(this.values);
  final List<String> values;
}

class TargetsSectionBody extends DetailSectionBody {
  const TargetsSectionBody(this.values, this.l10n);
  final List<MedicineDetailTarget> values;
  final AppLocalizations l10n;
}

class ReferencesSectionBody extends DetailSectionBody {
  const ReferencesSectionBody(this.values, this.l10n);
  final List<MedicineDetailExternalReference> values;
  final AppLocalizations l10n;
}

class SequencesSectionBody extends DetailSectionBody {
  const SequencesSectionBody(this.summary);
  final MedicineDetailSequenceSummary summary;
}

class MedicineDetailSection {
  const MedicineDetailSection({
    required this.tier,
    required this.title,
    required this.body,
    this.count,
  });

  final Tier tier;
  final String title;
  final DetailSectionBody body;

  /// Shown as a badge in the collapsed header so the user can tell whether
  /// expanding is worth it.
  final int? count;
}
