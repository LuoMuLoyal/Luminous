import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/router/medicine/routes.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';

void main() {
  // Drift guard: core may not import feature code, so `MedicineRoutes` mirrors
  // the medicine feature's typed routes. Tests may cross layers; this keeps the
  // mirrored paths byte-identical to the typed route `location`.
  group('MedicineRoutes.detail mirrors MedicineDetailRoute', () {
    const cases = <({String source, String id})>[
      (source: 'cn', id: '123'),
      (source: 'drugbank', id: 'DB00945'),
      (source: '中文源', id: 'a b'),
      (source: 'x&y', id: 'p/q?r=1'),
    ];

    for (final c in cases) {
      test('source=${c.source} id=${c.id}', () {
        expect(
          MedicineRoutes.detail(source: c.source, id: c.id),
          MedicineDetailRoute(source: c.source, id: c.id).location,
        );
      });
    }
  });

  group('MedicineRoutes.reminder mirrors MedicineReminderDetailRoute', () {
    for (final id in <String>['med-001', '中文', 'a b', 'x&y=z?q=1']) {
      test('medicineId=$id', () {
        expect(
          MedicineRoutes.reminder(id),
          MedicineReminderDetailRoute(medicineId: id).location,
        );
      });
    }
  });
}
