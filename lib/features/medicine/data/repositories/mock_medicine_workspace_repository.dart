import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/medicine_workspace_repository.dart';

class MockMedicineWorkspaceRepository implements MedicineWorkspaceRepository {
  const MockMedicineWorkspaceRepository();

  @override
  Future<MedicineWorkspace> fetchWorkspace() async {
    return const MedicineWorkspace(
      hero: MedicineHero(
        metricDosesToday: '2',
        metricAdherence: '100%',
        metricNextDose: '20:00',
      ),
      quickActions: <MedicineQuickAction>[
        MedicineQuickAction(
          icon: Icons.photo_camera_outlined,
          titleKey: MedicineCopyKey.quickActionCameraTitle,
          subtitleKey: MedicineCopyKey.quickActionCameraSubtitle,
          accent: AppColorTokens.gradientDevelopStart,
        ),
        MedicineQuickAction(
          icon: Icons.qr_code_scanner_rounded,
          titleKey: MedicineCopyKey.quickActionBarcodeTitle,
          subtitleKey: MedicineCopyKey.quickActionBarcodeSubtitle,
          accent: AppColorTokens.cyanDeep,
        ),
        MedicineQuickAction(
          icon: Icons.receipt_long_outlined,
          titleKey: MedicineCopyKey.quickActionPrescriptionTitle,
          subtitleKey: MedicineCopyKey.quickActionPrescriptionSubtitle,
          accent: AppColorTokens.warningDeep,
        ),
      ],
      plan: MedicinePlanSurface(
        items: <MedicinePlanItem>[
          MedicinePlanItem(
            color: AppColorTokens.link,
            nameKey: MedicineCopyKey.mockNameMetformin,
            dosageKey: MedicineCopyKey.mockDoseMetformin,
            scheduleKey: MedicineCopyKey.mockScheduleMorningEvening,
            nextSlotKey: MedicineCopyKey.mockTime0800Taken,
            laterSlotKey: MedicineCopyKey.mockTime2000Pending,
            stockKey: MedicineCopyKey.mockStock7Days,
            stateKey: MedicineCopyKey.statusStable,
            stateColor: AppColorTokens.success,
          ),
          MedicinePlanItem(
            color: AppColorTokens.warning,
            nameKey: MedicineCopyKey.mockNameVitaminD,
            dosageKey: MedicineCopyKey.mockDoseVitaminD,
            scheduleKey: MedicineCopyKey.mockScheduleDailyOnce,
            nextSlotKey: MedicineCopyKey.mockTime2000Pending,
            laterSlotKey: MedicineCopyKey.mockWithDinner,
            stockKey: MedicineCopyKey.mockStock15Days,
            stateKey: MedicineCopyKey.statusNeedsCheckin,
            stateColor: AppColorTokens.warningDeep,
          ),
          MedicinePlanItem(
            color: AppColorTokens.highlightMagenta,
            nameKey: MedicineCopyKey.mockNameSertraline,
            dosageKey: MedicineCopyKey.mockDoseSertraline,
            scheduleKey: MedicineCopyKey.mockScheduleDailyOnce,
            nextSlotKey: MedicineCopyKey.mockTime2200Pending,
            laterSlotKey: MedicineCopyKey.mockStressRisk,
            stockKey: MedicineCopyKey.mockStock3Days,
            stateKey: MedicineCopyKey.statusNeedRefillSoon,
            stateColor: AppColorTokens.error,
          ),
        ],
      ),
      alerts: <MedicineAlert>[
        MedicineAlert(
          icon: Icons.warning_amber_rounded,
          titleKey: MedicineCopyKey.alertRefillTitle,
          bodyKey: MedicineCopyKey.alertRefillBody,
          actionKey: MedicineCopyKey.alertRefillAction,
          color: AppColorTokens.warningDeep,
          softColor: AppColorTokens.warningSoft,
        ),
        MedicineAlert(
          icon: Icons.report_problem_outlined,
          titleKey: MedicineCopyKey.alertInteractionTitle,
          bodyKey: MedicineCopyKey.alertInteractionBody,
          actionKey: MedicineCopyKey.alertInteractionAction,
          color: AppColorTokens.error,
          softColor: AppColorTokens.errorSoft,
        ),
      ],
      promisePoints: <MedicinePromisePoint>[
        MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointBoundary),
        MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPregnancy),
        MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPrivacy),
      ],
    );
  }
}

final medicineWorkspaceRepositoryProvider =
    Provider<MedicineWorkspaceRepository>((ref) {
      return const MockMedicineWorkspaceRepository();
    });
