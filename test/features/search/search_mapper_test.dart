import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/search/data/mappers/search_mapper.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';

MedicineSearchItemDto _dto({
  required String id,
  required MedicineSearchItemDtoSource_Enum source,
  required String name,
  String subtitle = '',
  String summary = '',
  List<String> tags = const [],
  String imageUrl = '',
  List<String> matchedBy = const ['name'],
}) {
  return MedicineSearchItemDto(
    id: id,
    source_: source,
    name: name,
    subtitle: subtitle,
    summary: summary,
    tags: tags,
    imageUrl: imageUrl,
    matchedBy: matchedBy,
  );
}

void main() {
  group('MedicineSearchMapper', () {
    late MedicineSearchMapper mapper;

    setUp(() {
      mapper = MedicineSearchMapper();
    });

    test('maps cn source correctly', () {
      final dto = _dto(
        id: 'cn-123',
        source: MedicineSearchItemDtoSource_Enum.cn,
        name: '阿莫西林',
        tags: ['antibiotic'],
      );

      final result = mapper.dtoToResult(dto);

      expect(result.id, 'cn-123');
      expect(result.source, MedicineSearchSource.cn);
      expect(result.name, '阿莫西林');
      expect(result.tags, ['antibiotic']);
      expect(result.matchType, MedicineSearchMatchType.name);
    });

    test('maps drugbank source with full fields', () {
      final dto = _dto(
        id: 'DB01050',
        source: MedicineSearchItemDtoSource_Enum.drugbank,
        name: 'Ibuprofen',
        subtitle: 'NSAID',
        summary: 'Pain reliever',
        tags: ['pain', 'fever'],
        matchedBy: ['ingredient', 'name'],
      );

      final result = mapper.dtoToResult(dto);

      expect(result.source, MedicineSearchSource.drugbank);
      expect(result.subtitle, 'NSAID');
      expect(result.summary, 'Pain reliever');
      expect(result.matchType, MedicineSearchMatchType.ingredient);
    });

    test('defaults unknown source to drugbank', () {
      final dto = _dto(
        id: 'unknown',
        source: MedicineSearchItemDtoSource_Enum.unknownDefaultOpenApi,
        name: 'X',
      );

      expect(mapper.dtoToResult(dto).source, MedicineSearchSource.drugbank);
    });

    test('defaults matchType to name when ingredient not in matchedBy', () {
      final dto = _dto(
        id: '1',
        source: MedicineSearchItemDtoSource_Enum.cn,
        name: 'Test',
        matchedBy: ['brand', 'category'],
      );

      expect(mapper.dtoToResult(dto).matchType, MedicineSearchMatchType.name);
    });

    test('ingredient matchedBy takes priority over name', () {
      final dto = _dto(
        id: '2',
        source: MedicineSearchItemDtoSource_Enum.drugbank,
        name: 'Paracetamol',
        matchedBy: ['ingredient', 'brand'],
      );

      expect(
        mapper.dtoToResult(dto).matchType,
        MedicineSearchMatchType.ingredient,
      );
    });
  });
}
