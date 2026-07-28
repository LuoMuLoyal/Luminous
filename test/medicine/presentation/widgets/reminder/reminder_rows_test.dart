import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/rows.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';

AppLocalizations _getL10n(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold));
  return AppLocalizations.of(context)!;
}

CurrentMedicineItem _buildMedicine({
  String id = 'med-1',
  String displayName = '阿莫西林胶囊',
  String? strengthText = '0.25g',
  String? doseText = '每次1粒',
}) {
  return CurrentMedicineItem(
    id: id,
    source: 'cn',
    sourceRefId: null,
    displayName: displayName,
    strengthText: strengthText,
    doseText: doseText,
    route: '口服',
    startedAt: '2026-01-01',
    endedAt: null,
    isCurrent: true,
    note: null,
    createdAt: '2026-01-01',
    updatedAt: '2026-01-01',
  );
}

void main() {
  group('SelectedMedicineRow', () {
    testWidgets('renders medicine display name and dose text', (tester) async {
      final medicine = _buildMedicine();
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(body: SelectedMedicineRow(medicine: medicine)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('阿莫西林胶囊'), findsOneWidget);
      // doseText is "每次1粒", strengthText is "0.25g" → "0.25g · 每次1粒"
      expect(find.textContaining('0.25g'), findsOneWidget);
      expect(find.byIcon(SemanticIcons.recordMedicine), findsOneWidget);
    });

    testWidgets('shows not-set text when no dose info', (tester) async {
      final medicine = _buildMedicine(strengthText: null, doseText: null);

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(body: SelectedMedicineRow(medicine: medicine)),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = _getL10n(tester);
      expect(find.text(l10n.medicineDoseNotSet), findsOneWidget);
    });
  });
}
