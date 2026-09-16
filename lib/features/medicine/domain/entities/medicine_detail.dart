/// Medication knowledge detail shown on the mobile medicine detail page
/// (F-14), backed by `GET /api/v1/medicines/{id}?source=`.
///
/// A single flat entity holds both CN (package insert) and DrugBank fields;
/// the [kind] discriminates which family of fields is populated.
class MedicineDetail {
  const MedicineDetail({
    required this.id,
    required this.source,
    required this.name,
    this.subtitle,
    required this.kind,
    // CN package-insert fields.
    this.approvalNumber,
    this.manufacturer,
    this.packageSpec,
    this.brandName,
    this.ingredients,
    this.properties,
    this.indications,
    this.dosage,
    this.adverseReactions,
    this.contraindications,
    this.precautions,
    this.pharmacologyToxicology,
    this.pharmacokinetics,
    this.overdose,
    this.storage,
    this.validityPeriod,
    this.barcode,
    this.nationalDrugCode,
    this.sourceUrl,
    // DrugBank fields.
    this.drugType,
    this.state,
    this.description,
    this.indication,
    this.mechanismOfAction,
    this.pharmacodynamics,
    this.toxicity,
    this.metabolism,
    this.absorption,
    this.halfLife,
    this.proteinBinding,
    this.routeOfElimination,
    this.volumeOfDistribution,
    this.clearance,
    this.groups = const [],
    this.categories = const [],
    this.atcCodes = const [],
    this.synonyms = const [],
    this.foodInteractions = const [],
    this.drugInteractions = const [],
    this.targets = const [],
    this.externalIdentifiers = const [],
    this.externalLinks = const [],
    this.sequenceSummary,
    this.structure,
  });

  final String id;

  /// Knowledge source: `cn` or `drugbank`.
  final String source;

  final String name;
  final String? subtitle;

  /// Detail payload discriminator: `cnProduct` or `drugbank`.
  final String kind;

  // ── CN package-insert fields ────────────────────────────────────────────
  final String? approvalNumber;
  final String? manufacturer;
  final String? packageSpec;
  final String? brandName;
  final String? ingredients;
  final String? properties;
  final String? indications;
  final String? dosage;
  final String? adverseReactions;
  final String? contraindications;
  final String? precautions;
  final String? pharmacologyToxicology;
  final String? pharmacokinetics;
  final String? overdose;
  final String? storage;
  final String? validityPeriod;
  final String? barcode;
  final String? nationalDrugCode;
  final String? sourceUrl;

  // ── DrugBank fields ─────────────────────────────────────────────────────
  final String? drugType;
  final String? state;
  final String? description;
  final String? indication;
  final String? mechanismOfAction;
  final String? pharmacodynamics;
  final String? toxicity;
  final String? metabolism;
  final String? absorption;
  final String? halfLife;
  final String? proteinBinding;
  final String? routeOfElimination;
  final String? volumeOfDistribution;
  final String? clearance;

  final List<String> groups;
  final List<String> categories;
  final List<String> atcCodes;
  final List<String> synonyms;
  final List<String> foodInteractions;
  final List<MedicineDetailInteraction> drugInteractions;

  /// Proteins/genes this drug acts on, with action labels.
  final List<MedicineDetailTarget> targets;

  /// External cross-reference identifiers (PubChem, KEGG, ChEBI, ...).
  final List<MedicineDetailExternalReference> externalIdentifiers;

  /// Outbound reference links (Drugs.com, RxList, ...).
  final List<MedicineDetailExternalReference> externalLinks;

  /// How many sequences exist for this medicine, or null when there are none.
  ///
  /// Counts only — the sequence text itself lives behind a separate request
  /// because it runs to tens of thousands of characters per drug.
  final MedicineDetailSequenceSummary? sequenceSummary;

  /// Computed structure descriptors, or null when the source has no structure.
  final MedicineStructure? structure;
}

/// Computed structure descriptors of a drug.
///
/// Every field is nullable: coverage in the source runs from complete (formula,
/// molecular weight) down to about 15% (pKa). The source's "traditional IUPAC"
/// column is deliberately not modelled — it names the wrong compound for most
/// drugs upstream.
class MedicineStructure {
  const MedicineStructure({
    this.smiles,
    this.inchiKey,
    this.inchiIdentifier,
    this.formula,
    this.iupacName,
    this.molecularWeight,
    this.exactMass,
    this.logP,
    this.polarSurfaceArea,
    this.polarizability,
    this.refractivity,
    this.alogpsLogP,
    this.alogpsLogS,
    this.alogpsSolubility,
    this.pka,
    this.pkaStrongestAcidic,
    this.pkaStrongestBasic,
    this.formalCharge,
    this.physiologicalCharge,
    this.neutralCharge,
    this.averageNeutralMicrospeciesCharge,
    this.atomCount,
    this.ringCount,
    this.rotatableBondCount,
    this.acceptorCount,
    this.donorCount,
    this.ruleOfFive,
    this.veberRule,
    this.ghoseFilter,
    this.mddrLikeRule,
    this.bioavailability,
    this.salts = const [],
  });

  // Identity and identifiers.
  final String? smiles;
  final String? inchiKey;
  final String? inchiIdentifier;
  final String? formula;
  final String? iupacName;

  // Mass.
  final double? molecularWeight;
  final double? exactMass;

  // Physicochemical.
  final double? logP;
  final double? polarSurfaceArea;
  final double? polarizability;
  final double? refractivity;
  final double? alogpsLogP;
  final double? alogpsLogS;
  final String? alogpsSolubility;
  final double? pka;
  final double? pkaStrongestAcidic;
  final double? pkaStrongestBasic;

  // Charge.
  final int? formalCharge;
  final int? physiologicalCharge;
  final int? neutralCharge;
  final double? averageNeutralMicrospeciesCharge;

  // Size and shape.
  final int? atomCount;
  final int? ringCount;
  final int? rotatableBondCount;
  final int? acceptorCount;
  final int? donorCount;

  // Drug-likeness verdicts, stored by the source as 0/1 flags.
  final int? ruleOfFive;
  final int? veberRule;
  final int? ghoseFilter;
  final int? mddrLikeRule;
  final int? bioavailability;

  final List<String> salts;

  /// True when every descriptor is absent, i.e. the block carries nothing.
  bool get isEmpty =>
      smiles == null &&
      inchiKey == null &&
      inchiIdentifier == null &&
      formula == null &&
      iupacName == null &&
      molecularWeight == null &&
      exactMass == null &&
      logP == null &&
      polarSurfaceArea == null &&
      polarizability == null &&
      refractivity == null &&
      alogpsLogP == null &&
      alogpsLogS == null &&
      alogpsSolubility == null &&
      pka == null &&
      pkaStrongestAcidic == null &&
      pkaStrongestBasic == null &&
      formalCharge == null &&
      physiologicalCharge == null &&
      neutralCharge == null &&
      averageNeutralMicrospeciesCharge == null &&
      atomCount == null &&
      ringCount == null &&
      rotatableBondCount == null &&
      acceptorCount == null &&
      donorCount == null &&
      ruleOfFive == null &&
      veberRule == null &&
      ghoseFilter == null &&
      mddrLikeRule == null &&
      bioavailability == null &&
      salts.isEmpty;
}

/// Availability counts for the medicine's sequences.
class MedicineDetailSequenceSummary {
  const MedicineDetailSequenceSummary({
    this.drugChainCount = 0,
    this.targetSequenceCount = 0,
  });

  /// Sequences belonging to the drug itself (biologics have one per chain).
  final int drugChainCount;

  /// Sequences of the drug's targets (protein and coding gene).
  final int targetSequenceCount;

  int get total => drugChainCount + targetSequenceCount;

  bool get isEmpty => total == 0;
}

/// One sequence of the drug itself, e.g. an antibody heavy chain.
class MedicineDrugSequence {
  const MedicineDrugSequence({
    required this.description,
    required this.length,
    required this.sequence,
  });

  /// Chain description exactly as the source spells it.
  final String description;

  final int length;
  final String sequence;
}

/// One sequence of a drug target, either its protein or its coding gene.
class MedicineTargetSequence {
  const MedicineTargetSequence({
    required this.uniprotId,
    required this.dataset,
    required this.length,
    required this.sequence,
    this.targetName,
  });

  final String uniprotId;

  /// Which sequence this is: `protein_fasta` or `gene_fasta`.
  final String dataset;

  final String? targetName;
  final int length;
  final String sequence;

  bool get isGene => dataset == 'gene_fasta';
}

/// The full sequence payload for one medicine, fetched on demand.
class MedicineSequences {
  const MedicineSequences({
    required this.id,
    required this.source,
    this.drug = const [],
    this.targets = const [],
  });

  final String id;
  final String source;
  final List<MedicineDrugSequence> drug;
  final List<MedicineTargetSequence> targets;

  bool get isEmpty => drug.isEmpty && targets.isEmpty;

  /// Target sequences grouped by UniProt id, in first-seen order.
  Map<String, List<MedicineTargetSequence>> get targetsByUniprotId {
    final grouped = <String, List<MedicineTargetSequence>>{};
    for (final target in targets) {
      grouped.putIfAbsent(target.uniprotId, () => []).add(target);
    }
    return grouped;
  }
}

/// A single DrugBank drug-interaction entry shown on the detail page.
class MedicineDetailInteraction {
  const MedicineDetailInteraction({
    required this.drugbankId,
    required this.description,
  });

  final String drugbankId;
  final String description;
}

/// A target (protein/gene) the drug acts on.
class MedicineDetailTarget {
  const MedicineDetailTarget({
    required this.name,
    this.geneName,
    this.uniprotId,
    this.uniprotTitle,
    this.species,
    this.pdbIds = const [],
    this.actions = const [],
    this.knownAction,
    this.relationKind,
  });

  final String name;
  final String? geneName;
  final String? uniprotId;
  final String? uniprotTitle;
  final String? species;

  /// Known PDB structure identifiers — can be long (80+ for well-studied
  /// kinases), so the UI shows a bounded preview.
  final List<String> pdbIds;

  /// Action labels such as `inhibitor` / `agonist`.
  final List<String> actions;

  final String? knownAction;

  /// Relationship kind: target, enzyme, carrier, transporter.
  final String? relationKind;
}

/// A labelled external reference — either an identifier or an outbound URL.
class MedicineDetailExternalReference {
  const MedicineDetailExternalReference({
    required this.resource,
    required this.value,
  });

  /// Source resource label, e.g. `PubChem Compound` or `Drugs.com`.
  final String resource;

  /// The identifier text or the URL, depending on which list it came from.
  final String value;
}
