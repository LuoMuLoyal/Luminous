import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

void main() {
  group('MedicineSearchSource', () {
    test('has cn and drugbank values', () {
      expect(MedicineSearchSource.values, contains(MedicineSearchSource.cn));
      expect(
        MedicineSearchSource.values,
        contains(MedicineSearchSource.drugbank),
      );
    });
  });

  group('MedicineSearchMatchType', () {
    test('has ingredient and name values', () {
      expect(
        MedicineSearchMatchType.values,
        contains(MedicineSearchMatchType.ingredient),
      );
      expect(
        MedicineSearchMatchType.values,
        contains(MedicineSearchMatchType.name),
      );
    });
  });

  group('MedicineSearchCategoryType', () {
    test('has all expected values', () {
      expect(
        MedicineSearchCategoryType.values,
        containsAll([
          MedicineSearchCategoryType.painFever,
          MedicineSearchCategoryType.coldCough,
          MedicineSearchCategoryType.stomach,
          MedicineSearchCategoryType.supplement,
          MedicineSearchCategoryType.chronic,
        ]),
      );
    });
  });

  group('MedicineSearchActionType', () {
    test('has all expected values', () {
      expect(
        MedicineSearchActionType.values,
        containsAll([
          MedicineSearchActionType.photo,
          MedicineSearchActionType.barcode,
          MedicineSearchActionType.keyword,
          MedicineSearchActionType.switchSource,
        ]),
      );
    });
  });
}
