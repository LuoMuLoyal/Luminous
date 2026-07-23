import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/search/data/mappers/medicine_search.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

MedicineSearchItemDto _dto({
  required String id,
  required MedicineSearchItemDtoSourceSource source,
  required String name,
  String subtitle = '',
  String summary = '',
  List<String> tags = const [],
  String imageUrl = '',
  List<String> matchedBy = const ['name'],
}) {
  return MedicineSearchItemDto(
    id: id,
    source: source,
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
        source: MedicineSearchItemDtoSourceSource.cn,
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
        source: MedicineSearchItemDtoSourceSource.drugbank,
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
        source: MedicineSearchItemDtoSourceSource.$unknown,
        name: 'X',
      );

      expect(mapper.dtoToResult(dto).source, MedicineSearchSource.drugbank);
    });

    test('defaults matchType to name when ingredient not in matchedBy', () {
      final dto = _dto(
        id: '1',
        source: MedicineSearchItemDtoSourceSource.cn,
        name: 'Test',
        matchedBy: ['brand', 'category'],
      );

      expect(mapper.dtoToResult(dto).matchType, MedicineSearchMatchType.name);
    });

    test('ingredient matchedBy takes priority over name', () {
      final dto = _dto(
        id: '2',
        source: MedicineSearchItemDtoSourceSource.drugbank,
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
