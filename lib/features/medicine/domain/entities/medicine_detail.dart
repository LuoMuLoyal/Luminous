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
