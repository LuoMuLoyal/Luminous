import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
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
  TaskEither<Never, MedicineWorkspace> fetchWorkspace() {
    return TaskEither.right(previewWorkspace);
  }

  static final _mobileScanQuickActions = <MedicineQuickAction>[
    const MedicineQuickAction(
      titleKey: MedicineCopy.quickActionCameraTitle,
      subtitleKey: MedicineCopy.quickActionCameraSubtitle,
    ),
    const MedicineQuickAction(
      titleKey: MedicineCopy.quickActionBarcodeTitle,
      subtitleKey: MedicineCopy.quickActionBarcodeSubtitle,
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
        titleKey: MedicineCopy.quickActionSearchTitle,
        subtitleKey: MedicineCopy.quickActionSearchSubtitle,
      ),
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
        ..._mobileScanQuickActions,
    ],
    plan: const MedicinePlanSurface(
      items: <MedicinePlanItem>[
        MedicinePlanItem(
          color: SemanticColor.primary,
          nameKey: MedicineCopy.genericName,
          dosageKey: MedicineCopy.genericDosage,
          scheduleKey: MedicineCopy.genericSchedule,
          rawName: 'Metformin',
          rawDosage: '0.5 g',
          rawSchedule: 'Twice daily',
          slots: <MedicineDoseSlot>[
            MedicineDoseSlot(
              rawTime: '08:00',
              statusKey: MedicineCopy.doseStatusTaken,
              status: MedicineDoseStatus.taken,
            ),
            MedicineDoseSlot(
              rawTime: '20:00',
              statusKey: MedicineCopy.doseStatusPending,
              status: MedicineDoseStatus.pending,
            ),
          ],
          stateKey: MedicineCopy.statusStable,
          stateColor: SemanticColor.primary,
        ),
        MedicinePlanItem(
          color: SemanticColor.primary,
          nameKey: MedicineCopy.genericName,
          dosageKey: MedicineCopy.genericDosage,
          scheduleKey: MedicineCopy.genericSchedule,
          rawName: 'Atorvastatin',
          rawDosage: '20 mg',
          rawSchedule: 'Once daily',
          slots: <MedicineDoseSlot>[
            MedicineDoseSlot(
              rawTime: '12:00',
              statusKey: MedicineCopy.doseStatusTaken,
              status: MedicineDoseStatus.taken,
            ),
          ],
          stateKey: MedicineCopy.statusNeedsCheckin,
          stateColor: SemanticColor.primary,
        ),
        MedicinePlanItem(
          color: SemanticColor.primary,
          nameKey: MedicineCopy.genericName,
          dosageKey: MedicineCopy.genericDosage,
          scheduleKey: MedicineCopy.genericSchedule,
          rawName: 'Omeprazole',
          rawDosage: '20 mg',
          rawSchedule: 'Once daily',
          slots: <MedicineDoseSlot>[
            MedicineDoseSlot(
              rawTime: '08:00',
              statusKey: MedicineCopy.doseStatusPending,
              status: MedicineDoseStatus.pending,
            ),
          ],
          stateKey: MedicineCopy.doseStatusPending,
          stateColor: SemanticColor.primary,
        ),
      ],
    ),
    alerts: <MedicineAlert>[
      const MedicineAlert(
        iconKey: MedicineAlertIcon.safetyAlcohol,
        titleKey: MedicineCopy.alertAlcoholRiskTitle,
        bodyKey: MedicineCopy.alertAlcoholRiskBody,
        detailKey: MedicineCopy.alertAlcoholRiskDetail,
        actionKey: MedicineCopy.alertAlcoholRiskStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
      const MedicineAlert(
        iconKey: MedicineAlertIcon.recordCaffeine,
        titleKey: MedicineCopy.alertCoffeeReminderTitle,
        bodyKey: MedicineCopy.alertCoffeeReminderBody,
        detailKey: MedicineCopy.alertCoffeeReminderDetail,
        actionKey: MedicineCopy.alertCoffeeReminderStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
      const MedicineAlert(
        iconKey: MedicineAlertIcon.safetyDuplicate,
        titleKey: MedicineCopy.alertDuplicateCheckTitle,
        bodyKey: MedicineCopy.alertDuplicateCheckBody,
        detailKey: MedicineCopy.alertDuplicateCheckDetail,
        actionKey: MedicineCopy.alertDuplicateCheckStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
      const MedicineAlert(
        iconKey: MedicineAlertIcon.recordWater,
        titleKey: MedicineCopy.alertSpecialGroupSafetyTitle,
        bodyKey: MedicineCopy.alertSpecialGroupSafetyBody,
        detailKey: MedicineCopy.alertSpecialGroupSafetyDetail,
        actionKey: MedicineCopy.alertSpecialGroupSafetyStatus,
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
      ),
    ],
    promisePoints: <MedicinePromisePoint>[
      const MedicinePromisePoint(copyKey: MedicineCopy.promisePointBoundary),
      const MedicinePromisePoint(
        copyKey: MedicineCopy.promisePointSpecialGroup,
      ),
      const MedicinePromisePoint(copyKey: MedicineCopy.promisePointPrivacy),
      const MedicinePromisePoint(copyKey: MedicineCopy.promisePointDiagnosis),
    ],
  );
}
