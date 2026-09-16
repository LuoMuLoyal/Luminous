import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';

/// Maps the generated sequence resource onto the domain entity.
///
/// Blank sequences are dropped: the section exists to show sequence text, so a
/// row with no residues is noise rather than information.
class MedicineSequencesMapper {
  const MedicineSequencesMapper();

  MedicineSequences dataDtoToEntity(MedicineSequenceResponse dto) {
    return MedicineSequences(
      id: dto.id,
      source: switch (dto.source_) {
        MedicineSequenceResponseSource_Enum.cn => 'cn',
        MedicineSequenceResponseSource_Enum.drugbank => 'drugbank',
        MedicineSequenceResponseSource_Enum.unknownDefaultOpenApi => 'drugbank',
      },
      drug: dto.drug
          .where((row) => row.sequence.trim().isNotEmpty)
          .map(
            (row) => MedicineDrugSequence(
              description: row.description.trim(),
              // Trust the actual text over the reported count: the two agreeing
              // is what makes the summary label truthful.
              length: row.sequence.trim().length,
              sequence: row.sequence.trim(),
            ),
          )
          .toList(growable: false),
      targets: dto.targets
          .where((row) => row.sequence.trim().isNotEmpty)
          .map(
            (row) => MedicineTargetSequence(
              uniprotId: row.uniprotId.trim(),
              targetName: _trimToNull(row.targetName),
              dataset: row.dataset.trim(),
              length: row.sequence.trim().length,
              sequence: row.sequence.trim(),
            ),
          )
          .toList(growable: false),
    );
  }

  String? _trimToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
