import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_medicine_workspace.dart';
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
          titleKey: MedicineCopyKey.alertPeriodPregnancyTitle,
          bodyKey: MedicineCopyKey.alertPeriodPregnancyBody,
          detailKey: MedicineCopyKey.alertPeriodPregnancyDetail,
          actionKey: MedicineCopyKey.alertPeriodPregnancyStatus,
          color: AppColorTokens.error,
          softColor: AppColorTokens.errorSoft,
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

final doseLogRemoteDataSourceProvider = Provider<DoseLogRemoteDataSource>((
  ref,
) {
  final api = ref.watch(lucentMedicineDoseLogsApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return DoseLogRemoteDataSource(api: api, dio: dio);
});

final medicineWorkspaceRepositoryProvider =
    Provider<MedicineWorkspaceRepository>((ref) {
      final healthRepo = ref.watch(healthContextRepositoryProvider);
      final doseLogDs = ref.watch(doseLogRemoteDataSourceProvider);
      return LucentMedicineWorkspaceRepository(
        healthRepo: healthRepo,
        doseLogDs: doseLogDs,
      );
    });
