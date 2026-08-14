import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/report/presentation/widgets/shared/clinic_summary_content.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

ClinicSummaryCoverageEntryDto _coverageEntry() {
  return ClinicSummaryCoverageEntryDto(
    state: ClinicSummaryCoverageEntryDtoStateEnum.observed,
    coverage: ClinicSummaryCoverageEntryDtoCoverageEnum.none,
    sources: const [ClinicSummaryCoverageEntryDtoSourcesEnum.manual],
    observedCount: 0,
    expectedCount: null,
    windowStart: null,
    windowEnd: null,
  );
}

ClinicSummaryCoverageDto _coverage() {
  return ClinicSummaryCoverageDto(
    checkIns: _coverageEntry(),
    water: _coverageEntry(),
    dose: _coverageEntry(),
    sleep: _coverageEntry(),
  );
}

ClinicSummaryDto _dto({
  List<String> allergies = const ['青霉素', '头孢'],
  List<String> conditions = const ['高血压'],
  List<String> medicines = const ['阿莫西林'],
  List<String>? findings = const ['长期服用需监测'],
  String dataRange = 'last_7_days',
  List<String> selectedFields = const [],
  int? age = 30,
  String? sexAtBirth = 'male',
  String? bloodType = 'A',
}) {
  return ClinicSummaryDto(
    generatedAt: '2026-07-01T10:30:00',
    scopeLabel: dataRange,
    start: '2026-06-24T00:00:00',
    end: '2026-07-01T00:00:00',
    selectedFields: selectedFields,
    coverage: _coverage(),
    dataRange: dataRange,
    profile: ClinicSummaryProfileDto(
      nickname: 'Lumi',
      age: age,
      sexAtBirth: sexAtBirth,
      bloodType: bloodType,
    ),
    allergies: allergies,
    conditions: conditions,
    currentMedicines: medicines,
    findings: findings,
    disclaimer: '本摘要仅供参考，不构成医疗建议',
  );
}

void main() {
  Future<void> pumpContent(
    WidgetTester tester,
    ClinicSummaryDto dto, {
    VoidCallback? onDownloadPdf,
    VoidCallback? onShare,
    bool isPdfDownloading = false,
    bool isSharing = false,
  }) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ClinicSummaryContent(
              dto: dto,
              onDownloadPdf: onDownloadPdf,
              onShare: onShare,
              isPdfDownloading: isPdfDownloading,
              isSharing: isSharing,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  AppLocalizations l10n(WidgetTester tester) {
    return AppLocalizations.of(
      tester.element(find.byType(ClinicSummaryContent)),
    )!;
  }

  testWidgets('renders all populated sections', (tester) async {
    await pumpContent(tester, _dto());

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reportClinicSummaryProfileSection), findsOneWidget);
    expect(find.text('Lumi'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('male'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);

    expect(
      find.text(l10n_.reportClinicSummaryAllergiesSection),
      findsOneWidget,
    );
    expect(find.text('青霉素'), findsOneWidget);
    expect(find.text('头孢'), findsOneWidget);

    expect(
      find.text(l10n_.reportClinicSummaryConditionsSection),
      findsOneWidget,
    );
    expect(find.text('高血压'), findsOneWidget);

    expect(
      find.text(l10n_.reportClinicSummaryMedicinesSection),
      findsOneWidget,
    );
    expect(find.text('阿莫西林'), findsOneWidget);

    expect(find.text(l10n_.reportClinicSummaryFindingsSection), findsOneWidget);
    expect(find.text('长期服用需监测'), findsOneWidget);

    expect(
      find.text(l10n_.reportClinicSummaryDisclaimerSection),
      findsOneWidget,
    );
    expect(find.text('本摘要仅供参考，不构成医疗建议'), findsOneWidget);
  });

  testWidgets('hides empty sections', (tester) async {
    await pumpContent(
      tester,
      _dto(
        allergies: const [],
        conditions: const [],
        medicines: const [],
        findings: null,
      ),
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reportClinicSummaryAllergiesSection), findsNothing);
    expect(find.text(l10n_.reportClinicSummaryConditionsSection), findsNothing);
    expect(find.text(l10n_.reportClinicSummaryMedicinesSection), findsNothing);
    expect(find.text(l10n_.reportClinicSummaryFindingsSection), findsNothing);
    // Profile + disclaimer sections still render
    expect(find.text(l10n_.reportClinicSummaryProfileSection), findsOneWidget);
    expect(
      find.text(l10n_.reportClinicSummaryDisclaimerSection),
      findsOneWidget,
    );
  });

  testWidgets(
    'renders only the sections listed in selectedFields (deselected fields '
    'are absent even when data exists)',
    (tester) async {
      // symptom_changes (conditions) and notes unselected: conditions are
      // populated but the server excluded the section, so it must not render.
      await pumpContent(
        tester,
        _dto(selectedFields: const ['profile', 'currentMedicines']),
      );

      final l10n_ = l10n(tester);
      expect(
        find.text(l10n_.reportClinicSummaryProfileSection),
        findsOneWidget,
      );
      expect(
        find.text(l10n_.reportClinicSummaryConditionsSection),
        findsNothing,
      );
      expect(find.text('高血压'), findsNothing);
      // allergies is not in the effective section list either.
      expect(
        find.text(l10n_.reportClinicSummaryAllergiesSection),
        findsNothing,
      );
      expect(
        find.text(l10n_.reportClinicSummaryMedicinesSection),
        findsOneWidget,
      );
      expect(find.text('阿莫西林'), findsOneWidget);
      // findings + disclaimer are metadata and stay.
      expect(
        find.text(l10n_.reportClinicSummaryFindingsSection),
        findsOneWidget,
      );
      expect(
        find.text(l10n_.reportClinicSummaryDisclaimerSection),
        findsOneWidget,
      );
    },
  );

  testWidgets('hides the profile section when event_overview is unselected', (
    tester,
  ) async {
    await pumpContent(
      tester,
      _dto(selectedFields: const ['conditions', 'currentMedicines']),
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reportClinicSummaryProfileSection), findsNothing);
    expect(find.text('Lumi'), findsNothing);
    expect(
      find.text(l10n_.reportClinicSummaryConditionsSection),
      findsOneWidget,
    );
  });

  testWidgets('empty selectedFields keeps every section (legacy semantics)', (
    tester,
  ) async {
    await pumpContent(tester, _dto(selectedFields: const []));

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reportClinicSummaryProfileSection), findsOneWidget);
    expect(
      find.text(l10n_.reportClinicSummaryAllergiesSection),
      findsOneWidget,
    );
    expect(
      find.text(l10n_.reportClinicSummaryConditionsSection),
      findsOneWidget,
    );
    expect(
      find.text(l10n_.reportClinicSummaryMedicinesSection),
      findsOneWidget,
    );
  });

  testWidgets('shows not-set for missing profile fields', (tester) async {
    await pumpContent(
      tester,
      _dto(age: null, sexAtBirth: null, bloodType: null),
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reportClinicSummaryNotSet), findsNWidgets(3));
  });

  testWidgets('maps known and unknown data ranges', (tester) async {
    await pumpContent(tester, _dto(dataRange: 'last_7_days'));
    expect(find.text(l10n(tester).reportRangeLast7Days), findsOneWidget);

    await pumpContent(tester, _dto(dataRange: 'last_30_days'));
    expect(find.text(l10n(tester).reportRangeLast30Days), findsOneWidget);

    await pumpContent(tester, _dto(dataRange: 'custom'));
    expect(find.text('custom'), findsOneWidget);
  });

  testWidgets(
    'renders download and share buttons when callbacks are provided',
    (tester) async {
      await pumpContent(tester, _dto(), onDownloadPdf: () {}, onShare: () {});

      final l10n_ = l10n(tester);
      expect(find.text(l10n_.reportClinicSummaryDownloadPdf), findsOneWidget);
      expect(find.text(l10n_.reportClinicSummaryShare), findsOneWidget);
    },
  );

  testWidgets('renders only download button when share is missing', (
    tester,
  ) async {
    await pumpContent(tester, _dto(), onDownloadPdf: () {});

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reportClinicSummaryDownloadPdf), findsOneWidget);
    expect(find.text(l10n_.reportClinicSummaryShare), findsNothing);
  });

  testWidgets('hides action buttons without callbacks', (tester) async {
    await pumpContent(tester, _dto());

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reportClinicSummaryDownloadPdf), findsNothing);
    expect(find.text(l10n_.reportClinicSummaryShare), findsNothing);
  });

  testWidgets('shows progress and disables button while pdf is downloading', (
    tester,
  ) async {
    await pumpContent(
      tester,
      _dto(),
      onDownloadPdf: () {},
      isPdfDownloading: true,
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reportClinicSummaryDownloadPdf), findsNothing);
    expect(find.byType(FCircularProgress), findsOneWidget);
    // No share button wired in this variant
    expect(find.text(l10n_.reportClinicSummaryShare), findsNothing);
  });

  testWidgets('shows progress and disables button while sharing', (
    tester,
  ) async {
    await pumpContent(tester, _dto(), onShare: () {}, isSharing: true);

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reportClinicSummaryShare), findsNothing);
    expect(find.byType(FCircularProgress), findsOneWidget);
    expect(find.text(l10n_.reportClinicSummaryDownloadPdf), findsNothing);
  });
}
