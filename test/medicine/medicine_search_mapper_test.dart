import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/search/data/mappers/search_mapper.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';

void main() {
  group('MedicineSearchMapper', () {
    test('maps cn search DTO fields to frontend entity', () {
      final mapper = MedicineSearchMapper();

      final result = mapper.dtoToResult(
        MedicineSearchItemDto(
          id: 'cn_1',
          source_: MedicineSearchItemDtoSource_Enum.cn,
          name: '硫酸镁注射液',
          subtitle: '10ml:2.5g · 杭州民生药业股份有限公司',
          summary: '用于妊娠高血压、先兆子痫和子痫等。',
          tags: const ['处方药', '注射剂'],
          imageUrl: null,
          matchedBy: const ['ingredient'],
        ),
      );

      expect(result.id, 'cn_1');
      expect(result.source, MedicineSearchSource.cn);
      expect(result.name, '硫酸镁注射液');
      expect(result.subtitle, '10ml:2.5g · 杭州民生药业股份有限公司');
      expect(result.summary, '用于妊娠高血压、先兆子痫和子痫等。');
      expect(result.tags, ['处方药', '注射剂']);
      expect(result.matchType, MedicineSearchMatchType.ingredient);
    });

    test('maps DrugBank search DTO fields to frontend entity', () {
      final mapper = MedicineSearchMapper();

      final result = mapper.dtoToResult(
        MedicineSearchItemDto(
          id: 'DB01050',
          source_: MedicineSearchItemDtoSource_Enum.drugbank,
          name: 'Ibuprofen',
          subtitle: 'Small molecule',
          summary: 'A nonsteroidal anti-inflammatory drug.',
          tags: const ['approved', 'anti-inflammatory'],
          imageUrl: null,
          matchedBy: const ['name'],
        ),
      );

      expect(result.id, 'DB01050');
      expect(result.source, MedicineSearchSource.drugbank);
      expect(result.name, 'Ibuprofen');
      expect(result.subtitle, 'Small molecule');
      expect(result.summary, 'A nonsteroidal anti-inflammatory drug.');
      expect(result.tags, ['approved', 'anti-inflammatory']);
      expect(result.matchType, MedicineSearchMatchType.name);
    });
  });
}
