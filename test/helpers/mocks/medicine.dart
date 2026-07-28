import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';

/// Test-only mock implementation of [MedicineWorkspaceRepository].
class MockMedicineWorkspaceRepository implements MedicineWorkspaceRepository {
  const MockMedicineWorkspaceRepository();

  @override
  Future<MedicineWorkspace> get signedOutWorkspace =>
      Future.value(previewWorkspace);

  @override
  Future<MedicineWorkspace> fetchWorkspace() async {
    return previewWorkspace;
  }

  static final _mobileScanQuickActions = <MedicineQuickAction>[
    const MedicineQuickAction(
      icon: SemanticIcons.actionCamera,
      titleKey: MedicineCopyKey.quickActionCameraTitle,
      subtitleKey: MedicineCopyKey.quickActionCameraSubtitle,
      accent: SemanticColor.primary,
    ),
    const MedicineQuickAction(
      icon: SemanticIcons.actionScan,
      titleKey: MedicineCopyKey.quickActionBarcodeTitle,
      subtitleKey: MedicineCopyKey.quickActionBarcodeSubtitle,
      accent: SemanticColor.primary,
    ),
    const MedicineQuickAction(
      icon: SemanticIcons.doseLog,
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
        icon: SemanticIcons.actionSearch,
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
        icon: SemanticIcons.safetyAlcohol,
        titleKey: MedicineCopyKey.alertAlcoholRiskTitle,
        bodyKey: MedicineCopyKey.alertAlcoholRiskBody,
        detailKey: MedicineCopyKey.alertAlcoholRiskDetail,
        actionKey: MedicineCopyKey.alertAlcoholRiskStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
      const MedicineAlert(
        icon: SemanticIcons.recordCaffeine,
        titleKey: MedicineCopyKey.alertCoffeeReminderTitle,
        bodyKey: MedicineCopyKey.alertCoffeeReminderBody,
        detailKey: MedicineCopyKey.alertCoffeeReminderDetail,
        actionKey: MedicineCopyKey.alertCoffeeReminderStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
      const MedicineAlert(
        icon: SemanticIcons.safetyDuplicate,
        titleKey: MedicineCopyKey.alertDuplicateCheckTitle,
        bodyKey: MedicineCopyKey.alertDuplicateCheckBody,
        detailKey: MedicineCopyKey.alertDuplicateCheckDetail,
        actionKey: MedicineCopyKey.alertDuplicateCheckStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
      const MedicineAlert(
        icon: SemanticIcons.recordWater,
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
