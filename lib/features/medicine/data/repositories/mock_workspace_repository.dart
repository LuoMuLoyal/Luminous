import 'package:luminous/core/design/semantic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:forui/forui.dart';
import 'dart:io';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/health_context/data/providers/data_providers.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_workspace_repository.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check_repository.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mock_workspace_repository.g.dart';

/// Demo-only mock implementation of [MedicineWorkspaceRepository] used for tests.
///
/// Hero metrics and medicine names are intentionally placeholder so they cannot
/// be mistaken for real clinical data.
class MockMedicineWorkspaceRepository implements MedicineWorkspaceRepository {
  const MockMedicineWorkspaceRepository();

  @override
  Future<MedicineWorkspace> get signedOutWorkspace =>
      Future.value(MedicineWorkspace.signedOut());

  @override
  Future<MedicineWorkspace> fetchWorkspace() async {
    return previewWorkspace;
  }

  // Camera recognition and barcode scan are live on mobile devices.
  // Prescription import remains deferred pending OCR/contract work.
  static final _mobileScanQuickActions = <MedicineQuickAction>[
    const MedicineQuickAction(
      icon: FLucideIcons.camera,
      titleKey: MedicineCopyKey.quickActionCameraTitle,
      subtitleKey: MedicineCopyKey.quickActionCameraSubtitle,
      accent: SemanticColor.primary,
    ),
    const MedicineQuickAction(
      icon: FLucideIcons.scanLine,
      titleKey: MedicineCopyKey.quickActionBarcodeTitle,
      subtitleKey: MedicineCopyKey.quickActionBarcodeSubtitle,
      accent: SemanticColor.primary,
    ),
    const MedicineQuickAction(
      icon: FLucideIcons.receiptText,
      titleKey: MedicineCopyKey.quickActionPrescriptionTitle,
      subtitleKey: MedicineCopyKey.quickActionPrescriptionSubtitle,
      accent: SemanticColor.primary,
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
        icon: FLucideIcons.search,
        titleKey: MedicineCopyKey.quickActionSearchTitle,
        subtitleKey: MedicineCopyKey.quickActionSearchSubtitle,
        accent: SemanticColor.primary,
      ),
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
        ..._mobileScanQuickActions,
    ],
    plan: const MedicinePlanSurface(
      items: <MedicinePlanItem>[
        MedicinePlanItem(
          color: SemanticColor.primary,
          nameKey: MedicineCopyKey.genericName,
          dosageKey: MedicineCopyKey.genericDosage,
          scheduleKey: MedicineCopyKey.genericSchedule,
          rawName: 'Metformin',
          rawDosage: '0.5 g',
          rawSchedule: 'Twice daily',
          slots: <MedicineDoseSlot>[
            MedicineDoseSlot(
              rawTime: '08:00',
              statusKey: MedicineCopyKey.doseStatusTaken,
              status: MedicineDoseStatus.taken,
            ),
            MedicineDoseSlot(
              rawTime: '20:00',
              statusKey: MedicineCopyKey.doseStatusPending,
              status: MedicineDoseStatus.pending,
            ),
          ],
          stateKey: MedicineCopyKey.statusStable,
          stateColor: SemanticColor.primary,
        ),
        MedicinePlanItem(
          color: SemanticColor.primary,
          nameKey: MedicineCopyKey.genericName,
          dosageKey: MedicineCopyKey.genericDosage,
          scheduleKey: MedicineCopyKey.genericSchedule,
          rawName: 'Atorvastatin',
          rawDosage: '20 mg',
          rawSchedule: 'Once daily',
          slots: <MedicineDoseSlot>[
            MedicineDoseSlot(
              rawTime: '12:00',
              statusKey: MedicineCopyKey.doseStatusTaken,
              status: MedicineDoseStatus.taken,
            ),
          ],
          stateKey: MedicineCopyKey.statusNeedsCheckin,
          stateColor: SemanticColor.primary,
        ),
        MedicinePlanItem(
          color: SemanticColor.primary,
          nameKey: MedicineCopyKey.genericName,
          dosageKey: MedicineCopyKey.genericDosage,
          scheduleKey: MedicineCopyKey.genericSchedule,
          rawName: 'Omeprazole',
          rawDosage: '20 mg',
          rawSchedule: 'Once daily',
          slots: <MedicineDoseSlot>[
            MedicineDoseSlot(
              rawTime: '08:00',
              statusKey: MedicineCopyKey.doseStatusPending,
              status: MedicineDoseStatus.pending,
            ),
          ],
          stateKey: MedicineCopyKey.doseStatusPending,
          stateColor: SemanticColor.primary,
        ),
      ],
    ),
    alerts: <MedicineAlert>[
      const MedicineAlert(
        icon: FLucideIcons.wine,
        titleKey: MedicineCopyKey.alertAlcoholRiskTitle,
        bodyKey: MedicineCopyKey.alertAlcoholRiskBody,
        detailKey: MedicineCopyKey.alertAlcoholRiskDetail,
        actionKey: MedicineCopyKey.alertAlcoholRiskStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
      const MedicineAlert(
        icon: FLucideIcons.coffee,
        titleKey: MedicineCopyKey.alertCoffeeReminderTitle,
        bodyKey: MedicineCopyKey.alertCoffeeReminderBody,
        detailKey: MedicineCopyKey.alertCoffeeReminderDetail,
        actionKey: MedicineCopyKey.alertCoffeeReminderStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
      const MedicineAlert(
        icon: FLucideIcons.copy,
        titleKey: MedicineCopyKey.alertDuplicateCheckTitle,
        bodyKey: MedicineCopyKey.alertDuplicateCheckBody,
        detailKey: MedicineCopyKey.alertDuplicateCheckDetail,
        actionKey: MedicineCopyKey.alertDuplicateCheckStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
      const MedicineAlert(
        icon: FLucideIcons.droplets,
        titleKey: MedicineCopyKey.alertSpecialGroupSafetyTitle,
        bodyKey: MedicineCopyKey.alertSpecialGroupSafetyBody,
        detailKey: MedicineCopyKey.alertSpecialGroupSafetyDetail,
        actionKey: MedicineCopyKey.alertSpecialGroupSafetyStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
    ],
    promisePoints: <MedicinePromisePoint>[
      const MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointBoundary),
      const MedicinePromisePoint(
        copyKey: MedicineCopyKey.promisePointSpecialGroup,
      ),
      const MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPrivacy),
      const MedicinePromisePoint(
        copyKey: MedicineCopyKey.promisePointDiagnosis,
      ),
    ],
  );
}

@riverpod
MedicineReminderRemoteDataSource medicineReminderRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentMedicineRemindersApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return MedicineReminderRemoteDataSource(api: api, dio: dio);
}

@riverpod
MedicineWorkspaceRepository medicineWorkspaceRepository(Ref ref) {
  final healthRepo = ref.watch(healthContextRepositoryProvider);
  final doseLogDs = ref.watch(doseLogRemoteDataSourceProvider);
  final reminderDs = ref.watch(medicineReminderRemoteDataSourceProvider);
  final riskCheckRepository = ref.watch(medicineRiskCheckRepositoryProvider);
  return LucentMedicineWorkspaceRepository(
    healthRepo: healthRepo,
    doseLogDs: doseLogDs,
    reminderDs: reminderDs,
    riskCheckRepository: riskCheckRepository,
  );
}
