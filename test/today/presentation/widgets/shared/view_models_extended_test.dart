import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  // Helper to load Chinese l10n
  Future<AppLocalizations> loadZh() async {
    return AppLocalizations.delegate.load(const Locale('zh'));
  }

  // ── greetingSubtitle ─────────────────────────────────────────
  group('greetingSubtitle', () {
    test('morning with pending meds returns pending message', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut().copyWith(
        user: const TodayUserSnapshot(
          moment: TodayDayMoment.morning,
          hasUnreadNotifications: false,
          updatedAtLabel: '--',
        ),
        medication: const TodayMedicationSummary(
          medicineCount: 3,
          pendingCount: 2,
          nextDoseTimeLabel: '--',
          nextMedicine: TodayMedicationKind.atorvastatin,
        ),
      );

      final subtitle = greetingSubtitle(l10n, dashboard);
      expect(subtitle, l10n.todayGreetingMorningPending(2));
    });

    test('morning with no pending meds returns clear message', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut().copyWith(
        user: const TodayUserSnapshot(
          moment: TodayDayMoment.morning,
          hasUnreadNotifications: false,
          updatedAtLabel: '--',
        ),
        medication: const TodayMedicationSummary(
          medicineCount: 2,
          pendingCount: 0,
          nextDoseTimeLabel: '--',
          nextMedicine: TodayMedicationKind.atorvastatin,
        ),
      );

      final subtitle = greetingSubtitle(l10n, dashboard);
      expect(subtitle, l10n.todayGreetingMorningClear);
    });

    test(
      'afternoon with remaining water returns water short message',
      () async {
        final l10n = await loadZh();
        final dashboard = TodayDashboard.signedOut().copyWith(
          user: const TodayUserSnapshot(
            moment: TodayDayMoment.afternoon,
            hasUnreadNotifications: false,
            updatedAtLabel: '--',
          ),
          water: const TodayWaterSummary(completedCount: 3, targetCount: 8),
        );

        final subtitle = greetingSubtitle(l10n, dashboard);
        expect(subtitle, l10n.todayGreetingAfternoonWaterShort(5));
      },
    );

    test(
      'afternoon with no remaining water returns water done message',
      () async {
        final l10n = await loadZh();
        final dashboard = TodayDashboard.signedOut().copyWith(
          user: const TodayUserSnapshot(
            moment: TodayDayMoment.afternoon,
            hasUnreadNotifications: false,
            updatedAtLabel: '--',
          ),
          water: const TodayWaterSummary(completedCount: 8, targetCount: 8),
        );

        final subtitle = greetingSubtitle(l10n, dashboard);
        expect(subtitle, l10n.todayGreetingAfternoonWaterDone);
      },
    );

    test('evening with pending meds returns evening pending message', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut().copyWith(
        user: const TodayUserSnapshot(
          moment: TodayDayMoment.evening,
          hasUnreadNotifications: false,
          updatedAtLabel: '--',
        ),
        medication: const TodayMedicationSummary(
          medicineCount: 2,
          pendingCount: 1,
          nextDoseTimeLabel: '--',
          nextMedicine: TodayMedicationKind.atorvastatin,
        ),
      );

      final subtitle = greetingSubtitle(l10n, dashboard);
      expect(subtitle, l10n.todayGreetingEveningPending(1));
    });

    test('evening with no pending meds returns all done message', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut().copyWith(
        user: const TodayUserSnapshot(
          moment: TodayDayMoment.evening,
          hasUnreadNotifications: false,
          updatedAtLabel: '--',
        ),
        medication: const TodayMedicationSummary(
          medicineCount: 2,
          pendingCount: 0,
          nextDoseTimeLabel: '--',
          nextMedicine: TodayMedicationKind.atorvastatin,
        ),
      );

      final subtitle = greetingSubtitle(l10n, dashboard);
      expect(subtitle, l10n.todayGreetingEveningAllDone);
    });
  });

  test(
    'overview uses canonical water ml when observed metric is available',
    () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut().copyWith(
        water: const TodayWaterSummary(
          completedCount: 3,
          targetCount: 8,
          observedMetric: TodayObservedMetric(
            value: 500,
            state: TodayObservedMetricState.observed,
            coverage: TodayObservedMetricCoverage.sufficient,
            sources: [TodayObservedMetricSource.manual],
            observedCount: 2,
            expectedCount: null,
            windowStart: '2026-08-11',
            windowEnd: '2026-08-11',
          ),
        ),
      );

      expect(buildOverviewItems(l10n, dashboard)[1].value, '500 / 2000 ml');
    },
  );

  test('overview keeps unknown water metric explicit', () async {
    final l10n = await loadZh();
    final dashboard = TodayDashboard.signedOut().copyWith(
      water: const TodayWaterSummary(
        completedCount: 3,
        targetCount: 8,
        observedMetric: TodayObservedMetric(
          value: null,
          state: TodayObservedMetricState.unknown,
          coverage: TodayObservedMetricCoverage.none,
          sources: [TodayObservedMetricSource.manual],
          observedCount: 0,
          expectedCount: null,
          windowStart: '2026-08-11',
          windowEnd: '2026-08-11',
        ),
      ),
    );

    expect(buildOverviewItems(l10n, dashboard)[1].value, '-- / 2000 ml');
  });

  // ── medicationName ───────────────────────────────────────────
  group('medicationName', () {
    test('returns localized name for atorvastatin', () async {
      final l10n = await loadZh();
      final name = medicationName(l10n, TodayMedicationKind.atorvastatin);
      expect(name, l10n.todayMedicationNameAtorvastatin);
    });

    test('returns localized name for vitaminBComplex', () async {
      final l10n = await loadZh();
      final name = medicationName(l10n, TodayMedicationKind.vitaminBComplex);
      expect(name, l10n.todayMedicationNameVitaminBComplex);
    });

    test('returns non-empty string for all medication kinds', () async {
      final l10n = await loadZh();
      for (final kind in TodayMedicationKind.values) {
        final name = medicationName(l10n, kind);
        expect(name, isNotEmpty, reason: 'Name for $kind should be non-empty');
      }
    });
  });

  // ── buildQuickActionItems ────────────────────────────────────
  group('buildQuickActionItems', () {
    test('returns exactly 5 items', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final items = buildQuickActionItems(l10n, dashboard);
      expect(items, hasLength(5));
    });

    test('first item is confirm with badge when pendingCount > 0', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut().copyWith(
        medication: const TodayMedicationSummary(
          medicineCount: 3,
          pendingCount: 2,
          nextDoseTimeLabel: '--',
          nextMedicine: TodayMedicationKind.atorvastatin,
        ),
      );
      final items = buildQuickActionItems(l10n, dashboard);
      expect(items[0].icon, SemanticIcons.doseTaken);
      expect(items[0].badge, '2');
      expect(items[0].route, Routes.medicine);
    });

    test('first item has no badge when pendingCount is 0', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut().copyWith(
        medication: const TodayMedicationSummary(
          medicineCount: 2,
          pendingCount: 0,
          nextDoseTimeLabel: '--',
          nextMedicine: TodayMedicationKind.atorvastatin,
        ),
      );
      final items = buildQuickActionItems(l10n, dashboard);
      expect(items[0].badge, isNull);
    });

    test('second item is record with usePush=true', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final items = buildQuickActionItems(l10n, dashboard);
      expect(items[1].icon, SemanticIcons.actionEditCard);
      expect(items[1].usePush, isTrue);
      expect(items[1].route, contains(Routes.recordCreate));
    });

    test('third item is explain', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final items = buildQuickActionItems(l10n, dashboard);
      expect(items[2].icon, SemanticIcons.safetyCaution);
      expect(items[2].route, Routes.medicineRiskCheck);
    });

    test('fourth item is reminder', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final items = buildQuickActionItems(l10n, dashboard);
      expect(items[3].icon, SemanticIcons.doseSchedule);
      expect(items[3].route, Routes.medicineRemindersNew);
    });

    test('fifth item is profile', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final items = buildQuickActionItems(l10n, dashboard);
      expect(items[4].icon, SemanticIcons.profileUser);
      expect(items[4].route, Routes.mine);
    });

    test('all items have non-empty titles and subtitles', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final items = buildQuickActionItems(l10n, dashboard);
      for (var i = 0; i < items.length; i++) {
        expect(
          items[i].title,
          isNotEmpty,
          reason: 'Item $i title should be non-empty',
        );
        expect(
          items[i].subtitle,
          isNotEmpty,
          reason: 'Item $i subtitle should be non-empty',
        );
      }
    });
  });

  // ── buildAiSummaryBullets ────────────────────────────────────
  group('buildAiSummaryBullets', () {
    test('returns exactly 3 bullets', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final bullets = buildAiSummaryBullets(l10n, dashboard);
      expect(bullets, hasLength(3));
    });

    test('first bullet is medication-related', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final bullets = buildAiSummaryBullets(l10n, dashboard);
      expect(bullets[0].icon, SemanticIcons.recordMedicine);
    });

    test(
      'medication bullet shows pending text when pendingCount > 0',
      () async {
        final l10n = await loadZh();
        final dashboard = TodayDashboard.signedOut().copyWith(
          medication: const TodayMedicationSummary(
            medicineCount: 3,
            pendingCount: 2,
            nextDoseTimeLabel: '--',
            nextMedicine: TodayMedicationKind.atorvastatin,
          ),
        );
        final bullets = buildAiSummaryBullets(l10n, dashboard);
        expect(bullets[0].text, l10n.todayAiSummaryMedicationPending(2));
      },
    );

    test('medication bullet shows done text when pendingCount is 0', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut().copyWith(
        medication: const TodayMedicationSummary(
          medicineCount: 2,
          pendingCount: 0,
          nextDoseTimeLabel: '--',
          nextMedicine: TodayMedicationKind.atorvastatin,
        ),
      );
      final bullets = buildAiSummaryBullets(l10n, dashboard);
      expect(bullets[0].text, l10n.todayAiSummaryMedicationDone);
    });

    test('second bullet is hydration-related', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final bullets = buildAiSummaryBullets(l10n, dashboard);
      expect(bullets[1].icon, SemanticIcons.recordWater);
    });

    test(
      'hydration bullet shows remaining text when water remaining > 0',
      () async {
        final l10n = await loadZh();
        final dashboard = TodayDashboard.signedOut().copyWith(
          water: const TodayWaterSummary(completedCount: 3, targetCount: 8),
        );
        final bullets = buildAiSummaryBullets(l10n, dashboard);
        expect(bullets[1].text, l10n.todayAiSummaryWaterRemaining(5));
      },
    );

    test(
      'hydration bullet shows done text when water remaining is 0',
      () async {
        final l10n = await loadZh();
        final dashboard = TodayDashboard.signedOut().copyWith(
          water: const TodayWaterSummary(completedCount: 8, targetCount: 8),
        );
        final bullets = buildAiSummaryBullets(l10n, dashboard);
        expect(bullets[1].text, l10n.todayAiSummaryWaterDone);
      },
    );

    test('third bullet is sleep-related', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final bullets = buildAiSummaryBullets(l10n, dashboard);
      expect(bullets[2].icon, SemanticIcons.recordSleep);
    });

    test('all bullets use SemanticColor.primary', () async {
      final l10n = await loadZh();
      final dashboard = TodayDashboard.signedOut();
      final bullets = buildAiSummaryBullets(l10n, dashboard);
      for (var i = 0; i < bullets.length; i++) {
        expect(bullets[i].color, SemanticColor.primary, reason: 'Bullet $i');
      }
    });
  });
}
