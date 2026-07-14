import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';

void main() {
  group('MedicineWorkspace.signedOut', () {
    test('creates a workspace with zero doses today', () {
      final ws = MedicineWorkspace.signedOut();

      expect(ws.hero.metricDosesToday, '0');
    });

    test('creates a workspace with placeholder adherence and next dose', () {
      final ws = MedicineWorkspace.signedOut();

      expect(ws.hero.metricAdherence, '--');
      expect(ws.hero.metricNextDose, '--');
    });

    test('has exactly one quick action (search)', () {
      final ws = MedicineWorkspace.signedOut();

      expect(ws.quickActions.length, 1);
      expect(
        ws.quickActions.first.titleKey,
        MedicineCopyKey.quickActionSearchTitle,
      );
      expect(
        ws.quickActions.first.subtitleKey,
        MedicineCopyKey.quickActionSearchSubtitle,
      );
      expect(ws.quickActions.first.accent, SemanticColor.primary);
      expect(ws.quickActions.first.icon, FLucideIcons.search);
    });

    test('has empty plan items', () {
      final ws = MedicineWorkspace.signedOut();

      expect(ws.plan.items, isEmpty);
    });

    test('has no alerts', () {
      final ws = MedicineWorkspace.signedOut();

      expect(ws.alerts, isEmpty);
    });

    test('has no promise points', () {
      final ws = MedicineWorkspace.signedOut();

      expect(ws.promisePoints, isEmpty);
    });

    test('has no risk check result', () {
      final ws = MedicineWorkspace.signedOut();

      expect(ws.riskCheckResult, isNull);
    });
  });

  group('MedicineCopyKey enum', () {
    test('has all expected values', () {
      // Spot-check a few critical keys
      expect(
        MedicineCopyKey.values,
        contains(MedicineCopyKey.quickActionSearchTitle),
      );
      expect(MedicineCopyKey.values, contains(MedicineCopyKey.doseStatusTaken));
      expect(
        MedicineCopyKey.values,
        contains(MedicineCopyKey.alertInteractionTitle),
      );
      expect(
        MedicineCopyKey.values,
        contains(MedicineCopyKey.promisePointBoundary),
      );
    });
  });

  group('MedicineDoseStatus enum', () {
    test('contains expected values', () {
      expect(
        MedicineDoseStatus.values,
        containsAll([
          MedicineDoseStatus.taken,
          MedicineDoseStatus.skipped,
          MedicineDoseStatus.pending,
        ]),
      );
    });
  });
}
