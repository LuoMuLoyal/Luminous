import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/data/mappers/medicine_detail.dart';

MedicineDetailDataDtoDetail _detail({
  String kind = 'cnProduct',
  List<String> groups = const [],
  List<String> categories = const [],
  List<String> atcCodes = const [],
  List<String> synonyms = const [],
  List<String> foodInteractions = const [],
  List<DrugbankDrugInteractionDto>? drugInteractions,
  String? approvalNumber,
  String? manufacturer,
  String? packageSpec,
  String? brandName,
  String? ingredients,
  String? properties,
  String? indications,
  String? dosage,
  String? adverseReactions,
  String? contraindications,
  String? precautions,
  String? pharmacologyToxicology,
  String? pharmacokinetics,
  String? overdose,
  String? storage,
  String? validityPeriod,
  String? drugType,
  String? state,
  String? description,
  String? indication,
  String? mechanismOfAction,
  String? halfLife,
}) {
  return MedicineDetailDataDtoDetail(
    kind: kind,
    groups: groups,
    categories: categories,
    atcCodes: atcCodes,
    synonyms: synonyms,
    foodInteractions: foodInteractions,
    drugInteractions: drugInteractions,
    approvalNumber: approvalNumber,
    manufacturer: manufacturer,
    packageSpec: packageSpec,
    brandName: brandName,
    ingredients: ingredients,
    properties: properties,
    indications: indications,
    dosage: dosage,
    adverseReactions: adverseReactions,
    contraindications: contraindications,
    precautions: precautions,
    pharmacologyToxicology: pharmacologyToxicology,
    pharmacokinetics: pharmacokinetics,
    overdose: overdose,
    storage: storage,
    validityPeriod: validityPeriod,
    drugType: drugType,
    state: state,
    description: description,
    indication: indication,
    mechanismOfAction: mechanismOfAction,
    halfLife: halfLife,
  );
}

void main() {
  group('MedicineDetailMapper', () {
    const mapper = MedicineDetailMapper();

    test('maps CN detail and trims empty/whitespace strings to null', () {
      final dto = MedicineDetailDataDto(
        id: 'cn_1',
        source_: MedicineDetailDataDtoSource_Enum.cn,
        name: '布洛芬片',
        subtitle: '   ',
        detail: _detail(
          approvalNumber: '国药准字 H20013062',
          manufacturer: '   ',
          packageSpec: '0.2g*12片',
          indications: '用于缓解轻至中度疼痛',
          contraindications: '对本品过敏者禁用',
          storage: '  ',
        ),
      );

      final result = mapper.dataDtoToEntity(dto);

      expect(result.id, 'cn_1');
      expect(result.source, 'cn');
      expect(result.name, '布洛芬片');
      expect(result.subtitle, isNull);
      expect(result.kind, 'cnProduct');
      expect(result.approvalNumber, '国药准字 H20013062');
      expect(result.manufacturer, isNull);
      expect(result.packageSpec, '0.2g*12片');
      expect(result.indications, '用于缓解轻至中度疼痛');
      expect(result.contraindications, '对本品过敏者禁用');
      expect(result.storage, isNull);
    });

    test('maps DrugBank detail lists and drug interactions', () {
      final dto = MedicineDetailDataDto(
        id: 'DB01050',
        source_: MedicineDetailDataDtoSource_Enum.drugbank,
        name: 'Ibuprofen',
        subtitle: 'Small molecule',
        detail: _detail(
          kind: 'drugbank',
          groups: const ['approved'],
          categories: const ['Anti-inflammatory'],
          atcCodes: const ['M01AE01'],
          synonyms: const ['Advil', 'Motrin'],
          foodInteractions: const ['alcohol'],
          description: 'A nonsteroidal anti-inflammatory drug.',
          halfLife: '2 hours',
          drugInteractions: [
            DrugbankDrugInteractionDto(
              drugbankId: 'DB00795',
              description: 'May increase bleeding risk.',
            ),
          ],
        ),
      );

      final result = mapper.dataDtoToEntity(dto);

      expect(result.source, 'drugbank');
      expect(result.kind, 'drugbank');
      expect(result.groups, ['approved']);
      expect(result.categories, ['Anti-inflammatory']);
      expect(result.atcCodes, ['M01AE01']);
      expect(result.synonyms, ['Advil', 'Motrin']);
      expect(result.foodInteractions, ['alcohol']);
      expect(result.description, 'A nonsteroidal anti-inflammatory drug.');
      expect(result.halfLife, '2 hours');
      expect(result.drugInteractions, hasLength(1));
      expect(result.drugInteractions.first.drugbankId, 'DB00795');
      expect(
        result.drugInteractions.first.description,
        'May increase bleeding risk.',
      );
    });

    test('maps null drug interactions to empty list', () {
      final dto = MedicineDetailDataDto(
        id: 'DB01050',
        source_: MedicineDetailDataDtoSource_Enum.drugbank,
        name: 'Ibuprofen',
        subtitle: null,
        detail: _detail(kind: 'drugbank'),
      );

      expect(mapper.dataDtoToEntity(dto).drugInteractions, isEmpty);
    });

    test('normalizes unknown source enum to drugbank', () {
      final dto = MedicineDetailDataDto(
        id: 'x',
        source_: MedicineDetailDataDtoSource_Enum.unknownDefaultOpenApi,
        name: 'X',
        subtitle: null,
        detail: _detail(kind: 'drugbank'),
      );

      expect(mapper.dataDtoToEntity(dto).source, 'drugbank');
    });
  });
}
