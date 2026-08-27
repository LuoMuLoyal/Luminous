import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/review/presentation/widgets/shared/clinic_summary_content.dart';
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

/// Sentinel distinguishing "not passed" (use the populated default) from an
/// explicit null (a deselected section omitted from the wire response).
const _defaultSections = Object();

ClinicSummaryResponseDto _dto({
  Object? allergies = _defaultSections,
  Object? conditions = _defaultSections,
  Object? medicines = _defaultSections,
  List<String>? findings = const ['长期服用需监测'],
  List<ClinicSummaryWaterEntryDto>? waterEntries,
  List<ClinicSummarySleepEntryDto>? sleepEntries,
  List<ClinicSummaryNoteEntryDto>? noteEntries,
  String dataRange = 'last_7_days',
  List<String> selectedFields = const [],
  int? age = 30,
  String? sexAtBirth = 'male',
  String? bloodType = 'A',
}) {
  return ClinicSummaryResponseDto(
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
    allergies: identical(allergies, _defaultSections)
        ? <ClinicSummaryAllergyDto>[
            ClinicSummaryAllergyDto(
              label: '青霉素',
              reaction: '皮疹',
              severity: 'moderate',
            ),
            ClinicSummaryAllergyDto(
              label: '头孢',
              reaction: null,
              severity: null,
            ),
          ]
        : (allergies as List?)?.cast<ClinicSummaryAllergyDto>(),
    conditions: identical(conditions, _defaultSections)
        ? <ClinicSummaryConditionDto>[
            ClinicSummaryConditionDto(
              label: '高血压',
              status: 'active',
              diagnosedYear: 2023,
            ),
          ]
        : (conditions as List?)?.cast<ClinicSummaryConditionDto>(),
    currentMedicines: identical(medicines, _defaultSections)
        ? <ClinicSummaryMedicineDto>[
            ClinicSummaryMedicineDto(
              displayName: '阿莫西林',
              doseText: '0.5g 每日一次',
            ),
          ]
        : (medicines as List?)?.cast<ClinicSummaryMedicineDto>(),
    findings: findings,
    waterEntries: waterEntries,
    sleepEntries: sleepEntries,
    noteEntries: noteEntries,
    disclaimer: '本摘要仅供参考，不构成医疗建议',
  );
}

void main() {
  Future<void> pumpContent(
    WidgetTester tester,
    ClinicSummaryResponseDto dto, {
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
    expect(find.text(l10n_.reviewClinicSummaryProfileSection), findsOneWidget);
    expect(find.text('Lumi'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('male'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);

    expect(
      find.text(l10n_.reviewClinicSummaryAllergiesSection),
      findsOneWidget,
    );
    expect(find.text('青霉素'), findsOneWidget);
    expect(find.text('头孢'), findsOneWidget);

    expect(
      find.text(l10n_.reviewClinicSummaryConditionsSection),
      findsOneWidget,
    );
    expect(find.text('高血压'), findsOneWidget);

    expect(
      find.text(l10n_.reviewClinicSummaryMedicinesSection),
      findsOneWidget,
    );
    expect(find.text('阿莫西林'), findsOneWidget);

    expect(find.text(l10n_.reviewClinicSummaryFindingsSection), findsOneWidget);
    expect(find.text('长期服用需监测'), findsOneWidget);

    expect(
      find.text(l10n_.reviewClinicSummaryDisclaimerSection),
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
    expect(find.text(l10n_.reviewClinicSummaryAllergiesSection), findsNothing);
    expect(find.text(l10n_.reviewClinicSummaryConditionsSection), findsNothing);
    expect(find.text(l10n_.reviewClinicSummaryMedicinesSection), findsNothing);
    expect(find.text(l10n_.reviewClinicSummaryFindingsSection), findsNothing);
    // Profile + disclaimer sections still render
    expect(find.text(l10n_.reviewClinicSummaryProfileSection), findsOneWidget);
    expect(
      find.text(l10n_.reviewClinicSummaryDisclaimerSection),
      findsOneWidget,
    );
  });

  testWidgets('renders nothing for omitted (null) sections without crashing', (
    tester,
  ) async {
    // A deselected section is omitted from the wire response, so its DTO
    // field is null — the widget must skip it instead of dereferencing.
    await pumpContent(
      tester,
      _dto(
        allergies: null,
        conditions: null,
        medicines: null,
        selectedFields: const ['profile'],
      ),
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummaryProfileSection), findsOneWidget);
    expect(find.text('Lumi'), findsOneWidget);
    expect(find.text(l10n_.reviewClinicSummaryAllergiesSection), findsNothing);
    expect(find.text(l10n_.reviewClinicSummaryConditionsSection), findsNothing);
    expect(find.text(l10n_.reviewClinicSummaryMedicinesSection), findsNothing);
    expect(find.text('青霉素'), findsNothing);
    expect(find.text('高血压'), findsNothing);
    expect(find.text('阿莫西林'), findsNothing);
    expect(
      find.text(l10n_.reviewClinicSummaryDisclaimerSection),
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
        find.text(l10n_.reviewClinicSummaryProfileSection),
        findsOneWidget,
      );
      expect(
        find.text(l10n_.reviewClinicSummaryConditionsSection),
        findsNothing,
      );
      expect(find.text('高血压'), findsNothing);
      // Allergies are not a selectable share field — rendered as metadata
      // even when selectedFields does not include them (the server always
      // includes the section; the widget renders it whenever present).
      expect(
        find.text(l10n_.reviewClinicSummaryAllergiesSection),
        findsOneWidget,
      );
      expect(find.text('青霉素'), findsOneWidget);
      expect(
        find.text(l10n_.reviewClinicSummaryMedicinesSection),
        findsOneWidget,
      );
      expect(find.text('阿莫西林'), findsOneWidget);
      // findings + disclaimer are metadata and stay.
      expect(
        find.text(l10n_.reviewClinicSummaryFindingsSection),
        findsOneWidget,
      );
      expect(
        find.text(l10n_.reviewClinicSummaryDisclaimerSection),
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
    expect(find.text(l10n_.reviewClinicSummaryProfileSection), findsNothing);
    expect(find.text('Lumi'), findsNothing);
    expect(
      find.text(l10n_.reviewClinicSummaryConditionsSection),
      findsOneWidget,
    );
  });

  testWidgets('empty selectedFields keeps every section (legacy semantics)', (
    tester,
  ) async {
    await pumpContent(tester, _dto(selectedFields: const []));

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummaryProfileSection), findsOneWidget);
    expect(
      find.text(l10n_.reviewClinicSummaryAllergiesSection),
      findsOneWidget,
    );
    expect(
      find.text(l10n_.reviewClinicSummaryConditionsSection),
      findsOneWidget,
    );
    expect(
      find.text(l10n_.reviewClinicSummaryMedicinesSection),
      findsOneWidget,
    );
  });

  testWidgets('shows not-set for missing profile fields', (tester) async {
    await pumpContent(
      tester,
      _dto(age: null, sexAtBirth: null, bloodType: null),
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummaryNotSet), findsNWidgets(3));
  });

  testWidgets('maps known and unknown data ranges', (tester) async {
    await pumpContent(tester, _dto(dataRange: 'last_7_days'));
    expect(find.text(l10n(tester).reviewRangeLast7Days), findsOneWidget);

    await pumpContent(tester, _dto(dataRange: 'last_30_days'));
    expect(find.text(l10n(tester).reviewRangeLast30Days), findsOneWidget);

    await pumpContent(tester, _dto(dataRange: 'custom'));
    expect(find.text('custom'), findsOneWidget);
  });

  testWidgets(
    'renders download and share buttons when callbacks are provided',
    (tester) async {
      await pumpContent(tester, _dto(), onDownloadPdf: () {}, onShare: () {});

      final l10n_ = l10n(tester);
      expect(find.text(l10n_.reviewClinicSummaryDownloadPdf), findsOneWidget);
      expect(find.text(l10n_.reviewClinicSummaryShare), findsOneWidget);
    },
  );

  testWidgets('renders only download button when share is missing', (
    tester,
  ) async {
    await pumpContent(tester, _dto(), onDownloadPdf: () {});

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummaryDownloadPdf), findsOneWidget);
    expect(find.text(l10n_.reviewClinicSummaryShare), findsNothing);
  });

  testWidgets('hides action buttons without callbacks', (tester) async {
    await pumpContent(tester, _dto());

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummaryDownloadPdf), findsNothing);
    expect(find.text(l10n_.reviewClinicSummaryShare), findsNothing);
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
    expect(find.text(l10n_.reviewClinicSummaryDownloadPdf), findsNothing);
    expect(find.byType(FCircularProgress), findsOneWidget);
    // No share button wired in this variant
    expect(find.text(l10n_.reviewClinicSummaryShare), findsNothing);
  });

  testWidgets('shows progress and disables button while sharing', (
    tester,
  ) async {
    await pumpContent(tester, _dto(), onShare: () {}, isSharing: true);

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummaryShare), findsNothing);
    expect(find.byType(FCircularProgress), findsOneWidget);
    expect(find.text(l10n_.reviewClinicSummaryDownloadPdf), findsNothing);
  });

  // ── R-2: Water / Sleep / Notes rendering ──────────────────────────

  testWidgets('renders water entries when waterEntries is non-empty', (
    tester,
  ) async {
    await pumpContent(
      tester,
      _dto(
        waterEntries: [
          ClinicSummaryWaterEntryDto(date: '2026-08-10', ml: 1500),
        ],
      ),
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummaryWaterSection), findsOneWidget);
    expect(
      find.text('2026-08-10  1500${l10n_.reviewClinicSummaryWaterUnit}'),
      findsOneWidget,
    );
  });

  testWidgets('renders sleep entries when sleepEntries is non-empty', (
    tester,
  ) async {
    await pumpContent(
      tester,
      _dto(
        sleepEntries: [
          ClinicSummarySleepEntryDto(date: '2026-08-10', minutes: 420),
        ],
      ),
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummarySleepSection), findsOneWidget);
    expect(
      find.text('2026-08-10  420${l10n_.reviewClinicSummarySleepUnit}'),
      findsOneWidget,
    );
  });

  testWidgets('renders note entries when noteEntries is non-empty', (
    tester,
  ) async {
    await pumpContent(
      tester,
      _dto(
        noteEntries: [
          ClinicSummaryNoteEntryDto(
            date: '2026-08-10',
            kind: 'note',
            text: 'some note',
          ),
        ],
      ),
    );

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummaryNotesSection), findsOneWidget);
    expect(find.text('2026-08-10  (note)  some note'), findsOneWidget);
  });

  testWidgets('hides water/sleep/notes sections when entries are null', (
    tester,
  ) async {
    await pumpContent(tester, _dto());

    final l10n_ = l10n(tester);
    expect(find.text(l10n_.reviewClinicSummaryWaterSection), findsNothing);
    expect(find.text(l10n_.reviewClinicSummarySleepSection), findsNothing);
    expect(find.text(l10n_.reviewClinicSummaryNotesSection), findsNothing);
  });
}
