import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';

/// Maps the generated medicine-detail DTOs to the [MedicineDetail] domain
/// entity.
///
/// The detail response is flattened by the backend into a single
/// [MedicineDetailResponseDtoDetail] carrying both CN and DrugBank fields; the
/// `kind` discriminator decides which family is meaningful.
class MedicineDetailMapper {
  const MedicineDetailMapper();

  MedicineDetail dataDtoToEntity(MedicineDetailResponseDto dto) {
    final detail = dto.detail;
    return MedicineDetail(
      id: dto.id,
      source: _sourceValue(dto.source_),
      name: dto.name,
      subtitle: _trimToNull(dto.subtitle),
      kind: detail.kind,
      // CN fields.
      approvalNumber: _trimToNull(detail.approvalNumber),
      manufacturer: _trimToNull(detail.manufacturer),
      packageSpec: _trimToNull(detail.packageSpec),
      brandName: _trimToNull(detail.brandName),
      ingredients: _trimToNull(detail.ingredients),
      properties: _trimToNull(detail.properties),
      indications: _trimToNull(detail.indications),
      dosage: _trimToNull(detail.dosage),
      adverseReactions: _trimToNull(detail.adverseReactions),
      contraindications: _trimToNull(detail.contraindications),
      precautions: _trimToNull(detail.precautions),
      pharmacologyToxicology: _trimToNull(detail.pharmacologyToxicology),
      pharmacokinetics: _trimToNull(detail.pharmacokinetics),
      overdose: _trimToNull(detail.overdose),
      storage: _trimToNull(detail.storage),
      validityPeriod: _trimToNull(detail.validityPeriod),
      barcode: _trimToNull(detail.barcode),
      nationalDrugCode: _trimToNull(detail.nationalDrugCode),
      sourceUrl: _trimToNull(detail.sourceUrl),
      // DrugBank fields.
      drugType: _trimToNull(detail.drugType),
      state: _trimToNull(detail.state),
      description: _trimToNull(detail.description),
      indication: _trimToNull(detail.indication),
      mechanismOfAction: _trimToNull(detail.mechanismOfAction),
      pharmacodynamics: _trimToNull(detail.pharmacodynamics),
      toxicity: _trimToNull(detail.toxicity),
      metabolism: _trimToNull(detail.metabolism),
      absorption: _trimToNull(detail.absorption),
      halfLife: _trimToNull(detail.halfLife),
      proteinBinding: _trimToNull(detail.proteinBinding),
      routeOfElimination: _trimToNull(detail.routeOfElimination),
      volumeOfDistribution: _trimToNull(detail.volumeOfDistribution),
      clearance: _trimToNull(detail.clearance),
      groups: detail.groups ?? const [],
      categories: detail.categories ?? const [],
      atcCodes: detail.atcCodes ?? const [],
      synonyms: detail.synonyms ?? const [],
      foodInteractions: detail.foodInteractions ?? const [],
      drugInteractions: (detail.drugInteractions ?? const [])
          .map(
            (item) => MedicineDetailInteraction(
              drugbankId: item.drugbankId,
              description: item.description,
            ),
          )
          .toList(growable: false),
    );
  }

  /// Normalizes the source enum to the `cn`/`drugbank` wire string. The
  /// generated client's `unknownDefaultOpenApi` fallback only appears on
  /// unexpected payloads; it is folded into `drugbank` (the client's default
  /// source) so the entity's `source` stays within the two known values.
  String _sourceValue(MedicineDetailResponseDtoSource_Enum source) =>
      switch (source) {
        MedicineDetailResponseDtoSource_Enum.cn => 'cn',
        MedicineDetailResponseDtoSource_Enum.drugbank => 'drugbank',
        MedicineDetailResponseDtoSource_Enum.unknownDefaultOpenApi =>
          'drugbank',
      };

  String? _trimToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
