import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/search/data/mappers/medicine_search.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

void main() {
  group('MedicineSearchMapper', () {
    test('maps cn search DTO fields to frontend entity', () {
      final mapper = MedicineSearchMapper();

      final result = mapper.dtoToResult(
        MedicineSearchResponseItems(
          id: 'cn_1',
          source_: MedicineSearchResponseItemsSource_Enum.cn,
          name: '硫酸镁注射液',
          subtitle: '10ml:2.5g · 杭州民生药业股份有限公司',
          summary: '用于妊娠高血压、先兆子痫和子痫等。',
          tags: ['处方药', '注射剂'],
          imageUrl: null,
          matchedBy: ['ingredient'],
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
        MedicineSearchResponseItems(
          id: 'DB01050',
          source_: MedicineSearchResponseItemsSource_Enum.drugbank,
          name: 'Ibuprofen',
          subtitle: 'Small molecule',
          summary: 'A nonsteroidal anti-inflammatory drug.',
          tags: ['approved', 'anti-inflammatory'],
          imageUrl: null,
          matchedBy: ['name'],
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
