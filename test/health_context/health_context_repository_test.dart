import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_context/data/datasources/health_context_remote_data_source.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';

void main() {
  group('health-context write payloads', () {
    test('profile update keeps explicit nulls but skips no-change fields', () {
      final payload = healthProfileUpdatePayload(
        const HealthProfileUpdateInput(
          birthDate: null,
          sexAtBirth: HealthSexAtBirth.female,
          heightCm: 168,
          bloodType: null,
          unitSystem: healthContextNoChange,
        ),
      );

      expect(payload, <String, dynamic>{
        'birthDate': null,
        'sexAtBirth': 'female',
        'heightCm': 168,
        'bloodType': null,
      });
      expect(payload.containsKey('unitSystem'), isFalse);
    });

    test('update payloads serialize enum wire values and clearing nulls', () {
      expect(
        healthAllergyUpdatePayload(
          const HealthAllergyUpdateInput(
            kind: HealthAllergyKind.food,
            reaction: null,
            severity: HealthAllergySeverity.severe,
            note: null,
          ),
        ),
        <String, dynamic>{
          'kind': 'food',
          'reaction': null,
          'severity': 'severe',
          'note': null,
        },
      );

      expect(
        currentMedicineUpdatePayload(
          const CurrentMedicineUpdateInput(
            source: HealthMedicineSource.manual,
            sourceRefId: null,
            startedAt: null,
            isCurrent: false,
          ),
        ),
        <String, dynamic>{
          'source': 'manual',
          'sourceRefId': null,
          'startedAt': null,
          'isCurrent': false,
        },
      );
    });

    test('create payloads omit nullable fields left unset', () {
      expect(
        currentMedicineCreatePayload(
          const CurrentMedicineWriteInput(
            source: HealthMedicineSource.cn,
            sourceRefId: 'cn_1',
            displayName: '布洛芬片',
          ),
        ),
        <String, dynamic>{
          'source': 'cn',
          'sourceRefId': 'cn_1',
          'displayName': '布洛芬片',
        },
      );
    });
  });
}
