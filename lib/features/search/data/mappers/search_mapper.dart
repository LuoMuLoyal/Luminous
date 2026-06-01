import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';

/// Converts Lucent DTOs to Luminous Search entities.
class MedicineSearchMapper {
  MedicineSearchResult dtoToResult(MedicineSearchItemDto dto) {
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

  MedicineSearchSource _toSource(MedicineSearchItemDtoSource_Enum source) {
    return switch (source) {
      MedicineSearchItemDtoSource_Enum.cn => MedicineSearchSource.cn,
      MedicineSearchItemDtoSource_Enum.drugbank =>
        MedicineSearchSource.drugbank,
      MedicineSearchItemDtoSource_Enum.unknownDefaultOpenApi =>
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
