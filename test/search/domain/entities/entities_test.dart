import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

void main() {
  group('MedicineSearchDashboard.selectedResult', () {
    test('returns the result matching selectedResultId', () {
      const dashboard = MedicineSearchDashboard(
        query: 'aspirin',
        selectedSource: MedicineSearchSource.cn,
        recentKeywords: [],
        quickActions: [],
        categories: [],
        results: [
          MedicineSearchResult(
            id: 'r1',
            source: MedicineSearchSource.cn,
            name: 'Aspirin',
            subtitle: 'Pain reliever',
            summary: 'Common OTC drug',
            tags: ['pain', 'fever'],
            matchType: MedicineSearchMatchType.name,
          ),
          MedicineSearchResult(
            id: 'r2',
            source: MedicineSearchSource.drugbank,
            name: 'Ibuprofen',
            subtitle: 'NSAID',
            summary: 'Anti-inflammatory',
            tags: ['pain'],
            matchType: MedicineSearchMatchType.ingredient,
          ),
        ],
        selectedResultId: 'r2',
        safetyPreview: MedicineSearchSafetyPreview(
          title: 'Safety',
          conditions: [],
          checklist: [],
        ),
      );

      expect(dashboard.selectedResult!.id, 'r2');
      expect(dashboard.selectedResult!.name, 'Ibuprofen');
    });

    test('returns first match when selectedResultId matches first result', () {
      const dashboard = MedicineSearchDashboard(
        query: '',
        selectedSource: MedicineSearchSource.cn,
        recentKeywords: [],
        quickActions: [],
        categories: [],
        results: [
          MedicineSearchResult(
            id: 'r1',
            source: MedicineSearchSource.cn,
            name: 'Aspirin',
            subtitle: '',
            summary: '',
            tags: [],
            matchType: MedicineSearchMatchType.name,
          ),
        ],
        selectedResultId: 'r1',
        safetyPreview: MedicineSearchSafetyPreview(
          title: '',
          conditions: [],
          checklist: [],
        ),
      );

      expect(dashboard.selectedResult!.id, 'r1');
    });

    test('returns null when no result matches selectedResultId', () {
      const dashboard = MedicineSearchDashboard(
        query: '',
        selectedSource: MedicineSearchSource.cn,
        recentKeywords: [],
        quickActions: [],
        categories: [],
        results: [
          MedicineSearchResult(
            id: 'r1',
            source: MedicineSearchSource.cn,
            name: 'Aspirin',
            subtitle: '',
            summary: '',
            tags: [],
            matchType: MedicineSearchMatchType.name,
          ),
        ],
        selectedResultId: 'nonexistent',
        safetyPreview: MedicineSearchSafetyPreview(
          title: '',
          conditions: [],
          checklist: [],
        ),
      );

      expect(dashboard.selectedResult, isNull);
    });
  });

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
