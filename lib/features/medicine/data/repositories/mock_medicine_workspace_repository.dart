import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_medicine_workspace_repository.dart';
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
            slots: <MedicineDoseSlot>[
              MedicineDoseSlot(
                timeKey: MedicineCopyKey.mockTime0800,
                statusKey: MedicineCopyKey.doseStatusTaken,
                status: MedicineDoseStatus.taken,
              ),
              MedicineDoseSlot(
                timeKey: MedicineCopyKey.mockTime2000,
                statusKey: MedicineCopyKey.doseStatusPending,
                status: MedicineDoseStatus.pending,
              ),
            ],
            stockKey: MedicineCopyKey.mockStock7Days,
            stateKey: MedicineCopyKey.statusStable,
            stateColor: AppColorTokens.success,
          ),
          MedicinePlanItem(
            color: AppColorTokens.warning,
            nameKey: MedicineCopyKey.mockNameAtorvastatin,
            dosageKey: MedicineCopyKey.mockDoseAtorvastatin,
            scheduleKey: MedicineCopyKey.mockScheduleDailyOnce,
            slots: <MedicineDoseSlot>[
              MedicineDoseSlot(
                timeKey: MedicineCopyKey.mockTime1200,
                statusKey: MedicineCopyKey.doseStatusTaken,
                status: MedicineDoseStatus.taken,
              ),
            ],
            stockKey: MedicineCopyKey.mockStock15Days,
            stateKey: MedicineCopyKey.statusNeedsCheckin,
            stateColor: AppColorTokens.warningDeep,
          ),
          MedicinePlanItem(
            color: AppColorTokens.highlightMagenta,
            nameKey: MedicineCopyKey.mockNameOmeprazole,
            dosageKey: MedicineCopyKey.mockDoseOmeprazole,
            scheduleKey: MedicineCopyKey.mockScheduleDailyOnce,
            slots: <MedicineDoseSlot>[
              MedicineDoseSlot(
                timeKey: MedicineCopyKey.mockTime0800,
                statusKey: MedicineCopyKey.doseStatusPending,
                status: MedicineDoseStatus.pending,
              ),
            ],
            stockKey: MedicineCopyKey.mockStock3Days,
            stateKey: MedicineCopyKey.statusNeedRefillSoon,
            stateColor: AppColorTokens.error,
            stockWarningKey: MedicineCopyKey.stockWarningLow,
          ),
        ],
      ),
      alerts: <MedicineAlert>[
        MedicineAlert(
          icon: Icons.health_and_safety_rounded,
          titleKey: MedicineCopyKey.alertRefillTitle,
          bodyKey: MedicineCopyKey.alertRefillBody,
          detailKey: MedicineCopyKey.alertRefillDetail,
          actionKey: MedicineCopyKey.alertRefillAction,
          color: AppColorTokens.error,
          softColor: AppColorTokens.errorSoft,
        ),
        MedicineAlert(
          icon: Icons.shield_outlined,
          titleKey: MedicineCopyKey.alertInteractionTitle,
          bodyKey: MedicineCopyKey.alertInteractionBody,
          detailKey: MedicineCopyKey.alertInteractionDetail,
          actionKey: MedicineCopyKey.alertInteractionAction,
          color: AppColorTokens.warningDeep,
          softColor: AppColorTokens.warningSoft,
        ),
        MedicineAlert(
          icon: Icons.verified_user_outlined,
          titleKey: MedicineCopyKey.alertOtherTitle,
          bodyKey: MedicineCopyKey.alertOtherBody,
          detailKey: MedicineCopyKey.alertOtherDetail,
          actionKey: MedicineCopyKey.alertOtherAction,
          color: AppColorTokens.linkDeep,
          softColor: AppColorTokens.linkSoft,
        ),
      ],
      promisePoints: <MedicinePromisePoint>[
        MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointBoundary),
        MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPregnancy),
        MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPrivacy),
        MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointDiagnosis),
      ],
    );
  }
}

final medicineWorkspaceRepositoryProvider =
    Provider<MedicineWorkspaceRepository>((ref) {
      final healthRepo = ref.watch(healthContextRepositoryProvider);
      return LucentMedicineWorkspaceRepository(healthRepo: healthRepo);
    });
