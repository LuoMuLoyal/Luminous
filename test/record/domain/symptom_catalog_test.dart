import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/constants/symptom_catalog.dart';

void main() {
  group('SymptomCode', () {
    test('wire values are the catalog codes Lucent stores', () {
      expect(SymptomCode.values.map((code) => code.wireValue), [
        'headache',
        'stomachache',
        'dizzy',
        'fever',
      ]);
    });

    test('parses wire values and rejects unknown ones', () {
      expect(SymptomCode.fromWire('headache'), SymptomCode.headache);
      expect(SymptomCode.fromWire('nausea'), isNull);
      expect(SymptomCode.fromWire(null), isNull);
      expect(SymptomCode.fromWire(3), isNull);
    });
  });

  group('SymptomSeverity', () {
    test('wire vocabulary matches health_context severity wording', () {
      expect(SymptomSeverity.values.map((s) => s.wireValue), [
        'mild',
        'moderate',
        'severe',
        'unknown',
      ]);
      expect(SymptomSeverity.ordered, [
        SymptomSeverity.mild,
        SymptomSeverity.moderate,
        SymptomSeverity.severe,
        SymptomSeverity.unknown,
      ]);
    });

    test('parses wire values, including unknown, and rejects junk', () {
      expect(SymptomSeverity.fromWire('moderate'), SymptomSeverity.moderate);
      expect(SymptomSeverity.fromWire('unknown'), SymptomSeverity.unknown);
      expect(SymptomSeverity.fromWire('severe-ish'), isNull);
      expect(SymptomSeverity.fromWire(null), isNull);
    });
  });
}
