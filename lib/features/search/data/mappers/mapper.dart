import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

/// Converts Lucent DTOs to Luminous Search entities.
class MedicineSearchMapper {
  MedicineSearchResult dtoToResult(MedicineSearchItemDto dto) {
    return MedicineSearchResult(
      id: dto.id,
      source: _toSource(dto.source),
      name: dto.name,
      subtitle: dto.subtitle?.toString() ?? '',
      summary: dto.summary?.toString() ?? '',
      tags: dto.tags,
      matchType: _toMatchType(dto.matchedBy),
    );
  }

  MedicineSearchSource _toSource(MedicineSearchItemDtoSourceSource source) {
    return switch (source) {
      MedicineSearchItemDtoSourceSource.cn => MedicineSearchSource.cn,
      MedicineSearchItemDtoSourceSource.drugbank =>
        MedicineSearchSource.drugbank,
      MedicineSearchItemDtoSourceSource.$unknown =>
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
