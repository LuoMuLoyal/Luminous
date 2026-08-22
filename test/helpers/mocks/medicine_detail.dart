import 'package:lucent_api/lucent_api.dart';

/// A test-only [MedicineDetailResponseDtoDetail] whose [toJson] returns the raw
/// detail JSON map supplied by the test.
///
/// The generated [MedicineDetailResponseDtoDetail] has strongly typed fields, but
/// the medicine-risk domain code still reads the detail payload as a dynamic
/// map. Using this fake lets tests keep passing the old free-form JSON shape
/// (including list values such as `drugInteractions`) without needing to encode
/// them as the generated model's typed fields.
class TestMedicineDetailDataDtoDetail extends MedicineDetailResponseDtoDetail {
  TestMedicineDetailDataDtoDetail(this._rawJson)
    : super(
        kind: 'generic',
        groups: const [],
        categories: const [],
        atcCodes: const [],
        synonyms: const [],
        foodInteractions: const [],
      );

  final Map<String, dynamic> _rawJson;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(_rawJson);
}
