import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

/// Converts Lucent DTOs to Luminous Search entities.
class MedicineSearchMapper {
  MedicineSearchResult dtoToResult(MedicineSearchResponseDtoItemsInner dto) {
    return MedicineSearchResult(
      id: dto.id,
      source: _toSource(dto.source_),
      name: dto.name,
      subtitle: dto.subtitle?.toString() ?? '',
      summary: dto.summary?.toString() ?? '',
      tags: dto.tags,
      matchType: _toMatchType(dto.matchedBy),
    );
  }

  MedicineSearchSource _toSource(
    MedicineSearchResponseDtoItemsInnerSource_Enum source,
  ) {
    return switch (source) {
      MedicineSearchResponseDtoItemsInnerSource_Enum.cn =>
        MedicineSearchSource.cn,
      MedicineSearchResponseDtoItemsInnerSource_Enum.drugbank =>
        MedicineSearchSource.drugbank,
      MedicineSearchResponseDtoItemsInnerSource_Enum.unknownDefaultOpenApi =>
        MedicineSearchSource.drugbank,
    };
  }

  MedicineSearchMatchType _toMatchType(List<String> matchedBy) {
    if (matchedBy.contains('ingredient')) {
      return MedicineSearchMatchType.ingredient;
    }
    return MedicineSearchMatchType.name;
  }
}
