import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_medicine_workspace.dart';
import 'package:luminous/features/medicine/data/repositories/medicine_risk_check_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/medicine_workspace_repository.dart';

/// Demo-only mock implementation of [MedicineWorkspaceRepository] used for tests.
///
/// Hero metrics and medicine names are intentionally placeholder so they cannot
/// be mistaken for real clinical data.
class MockMedicineWorkspaceRepository implements MedicineWorkspaceRepository {
  const MockMedicineWorkspaceRepository();

  @override
  Future<MedicineWorkspace> fetchWorkspace() async {
    return previewWorkspace;
  }

  static final signedOutWorkspace = MedicineWorkspace(
    hero: MedicineHero(
      metricDosesToday: '0',
      metricAdherence: '--',
      metricNextDose: '--',
    ),
    quickActions: previewWorkspace.quickActions,
    plan: MedicinePlanSurface(items: <MedicinePlanItem>[]),
    alerts: previewWorkspace.alerts,
    promisePoints: previewWorkspace.promisePoints,
  );

  // Deferred by Product_Vision MVP: keep scan/OCR quick-action shapes because
  // they are useful later, but do not surface them until the matching camera,
  // recognition, and prescription contract/product job is ready.
  static const deferredScanQuickActions = <MedicineQuickAction>[
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
  ];

  static final previewWorkspace = MedicineWorkspace(
    hero: const MedicineHero(
      metricDosesToday: '0',
      metricAdherence: '--',
      metricNextDose: '--',
    ),
    quickActions: [
      const MedicineQuickAction(
        icon: Icons.search_rounded,
        titleKey: MedicineCopyKey.quickActionSearchTitle,
        subtitleKey: MedicineCopyKey.quickActionSearchSubtitle,
        accent: AppColorTokens.cyanDeep,
      ),
      if (kDebugMode) ...deferredScanQuickActions,
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
          stateKey: MedicineCopyKey.doseStatusPending,
          stateColor: AppColorTokens.warningDeep,
        ),
      ],
    ),
    alerts: <MedicineAlert>[
      MedicineAlert(
        icon: Icons.wine_bar_rounded,
        titleKey: MedicineCopyKey.alertAlcoholRiskTitle,
        bodyKey: MedicineCopyKey.alertAlcoholRiskBody,
        detailKey: MedicineCopyKey.alertAlcoholRiskDetail,
        actionKey: MedicineCopyKey.alertAlcoholRiskStatus,
        color: AppColorTokens.warningDeep,
        softColor: AppColorTokens.warningSoft,
      ),
      MedicineAlert(
        icon: Icons.coffee_rounded,
        titleKey: MedicineCopyKey.alertCoffeeReminderTitle,
        bodyKey: MedicineCopyKey.alertCoffeeReminderBody,
        detailKey: MedicineCopyKey.alertCoffeeReminderDetail,
        actionKey: MedicineCopyKey.alertCoffeeReminderStatus,
        color: AppColorTokens.warningDeep,
        softColor: AppColorTokens.warningSoft,
      ),
      MedicineAlert(
        icon: Icons.content_copy_rounded,
        titleKey: MedicineCopyKey.alertDuplicateCheckTitle,
        bodyKey: MedicineCopyKey.alertDuplicateCheckBody,
        detailKey: MedicineCopyKey.alertDuplicateCheckDetail,
        actionKey: MedicineCopyKey.alertDuplicateCheckStatus,
        color: AppColorTokens.cyanDeep,
        softColor: AppColorTokens.cyanSoft,
      ),
      MedicineAlert(
        icon: Icons.water_drop_rounded,
        titleKey: MedicineCopyKey.alertSpecialGroupSafetyTitle,
        bodyKey: MedicineCopyKey.alertSpecialGroupSafetyBody,
        detailKey: MedicineCopyKey.alertSpecialGroupSafetyDetail,
        actionKey: MedicineCopyKey.alertSpecialGroupSafetyStatus,
        color: AppColorTokens.error,
        softColor: AppColorTokens.errorSoft,
      ),
    ],
    promisePoints: <MedicinePromisePoint>[
      MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointBoundary),
      MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointSpecialGroup),
      MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPrivacy),
      MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointDiagnosis),
    ],
  );
}

final medicineReminderRemoteDataSourceProvider =
    Provider<MedicineReminderRemoteDataSource>((ref) {
      final api = ref.watch(lucentMedicineRemindersApiProvider);
      final dio = ref.watch(lucentDioClientProvider).dio;
      return MedicineReminderRemoteDataSource(api: api, dio: dio);
    });

final medicineWorkspaceRepositoryProvider =
    Provider<MedicineWorkspaceRepository>((ref) {
      final healthRepo = ref.watch(healthContextRepositoryProvider);
      final doseLogDs = ref.watch(doseLogRemoteDataSourceProvider);
      final reminderDs = ref.watch(medicineReminderRemoteDataSourceProvider);
      final riskCheckRepository = ref.watch(
        medicineRiskCheckRepositoryProvider,
      );
      return LucentMedicineWorkspaceRepository(
        healthRepo: healthRepo,
        doseLogDs: doseLogDs,
        reminderDs: reminderDs,
        riskCheckRepository: riskCheckRepository,
      );
    });
