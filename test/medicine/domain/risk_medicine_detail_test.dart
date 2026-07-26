import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/risk_medicine_detail.dart';
import '../../helpers/mocks/medicine_detail.dart';

CurrentMedicineItem _mkItem({
  String source = 'cn',
  String? sourceRefId,
  String displayName = '',
}) {
  return CurrentMedicineItem(
    id: 'med-1',
    source: source,
    sourceRefId: sourceRefId,
    displayName: displayName,
    strengthText: null,
    doseText: null,
    route: null,
    startedAt: null,
    endedAt: null,
    isCurrent: true,
    note: null,
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
  );
}

MedicineDetailDataDto _mkDetail({
  String name = 'Test Medicine',
  String source = 'cn',
  Map<String, dynamic> detailJson = const {},
}) {
  return MedicineDetailDataDto(
    id: 'detail-1',
    source_: source == 'drugbank'
        ? MedicineDetailDataDtoSource_Enum.drugbank
        : MedicineDetailDataDtoSource_Enum.cn,
    name: name,
    subtitle: null,
    detail: TestMedicineDetailDataDtoDetail(detailJson),
  );
}

void main() {
  group('MedicineRiskMedicineDetail', () {
    group('displayName', () {
      test('uses item.displayName when non-empty', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(displayName: '阿莫西林'),
          detail: _mkDetail(name: 'Amoxicillin'),
        );
        expect(detail.displayName, '阿莫西林');
      });

      test('falls back to detail.name when item.displayName is empty', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(displayName: '  '),
          detail: _mkDetail(name: 'Amoxicillin'),
        );
        expect(detail.displayName, 'Amoxicillin');
      });

      test(
        'falls back to detail.name when item.displayName is empty string',
        () {
          final detail = MedicineRiskMedicineDetail(
            item: _mkItem(displayName: ''),
            detail: _mkDetail(name: 'Ibuprofen'),
          );
          expect(detail.displayName, 'Ibuprofen');
        },
      );
    });

    group('normalizedIngredientTokens — CN source', () {
      test('extracts ingredients from detail JSON', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(detailJson: {'ingredients': '阿莫西林, 克拉维酸钾'}),
        );
        final tokens = detail.normalizedIngredientTokens;
        expect(tokens, isNotEmpty);
        expect(tokens, contains('阿莫西林'));
      });

      test('returns empty set when ingredients field is null', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(detailJson: {}),
        );
        expect(detail.normalizedIngredientTokens, isEmpty);
      });

      test('returns empty set when ingredients field is empty string', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(detailJson: {'ingredients': ''}),
        );
        expect(detail.normalizedIngredientTokens, isEmpty);
      });
    });

    group('normalizedIngredientTokens — DrugBank source', () {
      test('uses drugbankSynonymTokens', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank', displayName: 'Ibuprofen'),
          detail: _mkDetail(
            name: 'Ibuprofen',
            source: 'drugbank',
            detailJson: {
              'synonyms': ['Advil', 'Motrin'],
            },
          ),
        );
        final tokens = detail.normalizedIngredientTokens;
        expect(tokens, contains('ibuprofen'));
        expect(tokens, contains('advil'));
        expect(tokens, contains('motrin'));
      });
    });

    group('normalizedIngredientTokens — unknown source', () {
      test('returns empty set', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'unknown'),
          detail: _mkDetail(),
        );
        expect(detail.normalizedIngredientTokens, isEmpty);
      });
    });

    group('drugbankSynonymTokens', () {
      test('returns empty for non-drugbank source', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(),
        );
        expect(detail.drugbankSynonymTokens, isEmpty);
      });

      test('includes normalized name for drugbank source', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank'),
          detail: _mkDetail(name: 'Acetaminophen', source: 'drugbank'),
        );
        expect(detail.drugbankSynonymTokens, contains('acetaminophen'));
      });

      test('includes normalized synonyms', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank'),
          detail: _mkDetail(
            name: 'Acetaminophen',
            source: 'drugbank',
            detailJson: {
              'synonyms': ['Paracetamol', 'Tylenol'],
            },
          ),
        );
        final tokens = detail.drugbankSynonymTokens;
        expect(
          tokens,
          containsAll(['acetaminophen', 'paracetamol', 'tylenol']),
        );
      });

      test('handles null synonyms list', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank'),
          detail: _mkDetail(name: 'Aspirin', source: 'drugbank'),
        );
        expect(detail.drugbankSynonymTokens, contains('aspirin'));
      });

      test('handles empty name', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank'),
          detail: _mkDetail(name: '  ', source: 'drugbank'),
        );
        expect(detail.drugbankSynonymTokens, isEmpty);
      });
    });

    group('canonicalIngredientKeys', () {
      test('maps known synonyms to canonical keys', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(detailJson: {'ingredients': '对乙酰氨基酚'}),
        );
        expect(detail.canonicalIngredientKeys, contains('acetaminophen'));
      });

      test('keeps unknown tokens as-is', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(detailJson: {'ingredients': '未知成分'}),
        );
        expect(detail.canonicalIngredientKeys, contains('未知成分'));
      });
    });

    group('allSourceIngredientTokens', () {
      test('includes canonical keys and normalized display name', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn', displayName: '布洛芬'),
          detail: _mkDetail(detailJson: {'ingredients': '布洛芬'}),
        );
        final tokens = detail.allSourceIngredientTokens;
        expect(tokens, contains('ibuprofen')); // canonical key
        expect(tokens, contains('布洛芬')); // normalized display name
      });
    });

    group('drugbankIds', () {
      test('returns sourceRefId for drugbank source', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank', sourceRefId: 'DB01088'),
          detail: _mkDetail(source: 'drugbank'),
        );
        expect(detail.drugbankIds, {'DB01088'});
      });

      test('returns empty when drugbank sourceRefId is null', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank', sourceRefId: null),
          detail: _mkDetail(source: 'drugbank'),
        );
        expect(detail.drugbankIds, isEmpty);
      });

      test('returns empty when drugbank sourceRefId is empty', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank', sourceRefId: ''),
          detail: _mkDetail(source: 'drugbank'),
        );
        expect(detail.drugbankIds, isEmpty);
      });

      test('reads drugbankIds from detail JSON for CN source', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(
            detailJson: {
              'drugbankIds': ['DB01088', 'DB09321'],
            },
          ),
        );
        expect(detail.drugbankIds, {'DB01088', 'DB09321'});
      });

      test('returns empty for CN source without drugbankIds', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(),
        );
        expect(detail.drugbankIds, isEmpty);
      });

      test('filters empty strings from drugbankIds', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(
            detailJson: {
              'drugbankIds': ['DB01088', '', '  ', 'DB09321'],
            },
          ),
        );
        expect(detail.drugbankIds, {'DB01088', 'DB09321'});
      });
    });

    group('drugbankInteractionTargets', () {
      test('returns empty for non-drugbank source', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'cn'),
          detail: _mkDetail(),
        );
        expect(detail.drugbankInteractionTargets, isEmpty);
      });

      test('extracts drugbankId from drugInteractions list', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank'),
          detail: _mkDetail(
            source: 'drugbank',
            detailJson: {
              'drugInteractions': [
                {'drugbankId': 'DB01088'},
                {'drugbankId': 'DB09321'},
              ],
            },
          ),
        );
        expect(detail.drugbankInteractionTargets, {'DB01088', 'DB09321'});
      });

      test('returns empty when drugInteractions is not a list', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank'),
          detail: _mkDetail(
            source: 'drugbank',
            detailJson: {'drugInteractions': 'not a list'},
          ),
        );
        expect(detail.drugbankInteractionTargets, isEmpty);
      });

      test('returns empty when drugInteractions is null', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank'),
          detail: _mkDetail(source: 'drugbank'),
        );
        expect(detail.drugbankInteractionTargets, isEmpty);
      });

      test('filters empty drugbankId values', () {
        final detail = MedicineRiskMedicineDetail(
          item: _mkItem(source: 'drugbank'),
          detail: _mkDetail(
            source: 'drugbank',
            detailJson: {
              'drugInteractions': [
                {'drugbankId': 'DB01088'},
                {'drugbankId': ''},
                {'drugbankId': '  '},
                {'name': 'no id here'},
              ],
            },
          ),
        );
        expect(detail.drugbankInteractionTargets, {'DB01088'});
      });
    });
  });
}
