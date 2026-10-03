// Hand-written, fully populated fake repositories for the screenshot catalog.
//
// The five-tab shell captures (`/mine`, `/medicine`, profile surfaces and the
// Today suggestion feed) read from `MineRepository`, `MedicineWorkspaceRepository`,
// `HealthContextRepository` and `todaySuggestionProvider`. The offline fixture
// stack does not wire those, so without the fakes below the shell routes render
// guest/empty states instead of the mid-use screenshots the catalog wants.
//
// Everything here is new content written for the screenshot run — nothing is
// imported or copied from `integration_test/` or `test/`. Only the shared
// identity anchors (`simulatedUserName`, `simulatedCurrentMedicineIds`) come
// from the sibling `simulated_fakes_misc.dart`, so every simulated surface
// agrees on who the user is and which medicine boxes exist.
//
// This file is a generator fixture, not production code: nothing under `lib/`
// imports it.

import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/profile.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';

import 'simulated_fakes_misc.dart';

// ── Shared anchors ──────────────────────────────────────────────────────────

/// The fixed "now" every simulated clinical timestamp is written against
/// (2026-06-18 12:10 local), matching [simulatedNow]'s capture day.
final DateTime _simulatedCaptureNow = DateTime(2026, 6, 18, 12, 10);

/// The three simulated medicine boxes, in the same order as
/// [simulatedCurrentMedicineIds] so id and display name line up by index.
const List<String> _simulatedMedicineNames = <String>[
  '苯磺酸氨氯地平片',
  '阿司匹林肠溶片',
  '盐酸二甲双胍片',
];

String _simulatedMedicineId(int index) => simulatedCurrentMedicineIds[index];

String _simulatedMedicineName(int index) => _simulatedMedicineNames[index];

// ── 1. Mine dashboard ───────────────────────────────────────────────────────

/// [SimulatedMineRepository] fake backing the `/mine` tab.
///
/// Both the signed-in and the signed-out getter return the same populated
/// dashboard: a signed-out screenshot of this tab is a capture bug, not content
/// worth cataloguing.
class SimulatedMineRepository implements MineRepository {
  const SimulatedMineRepository();

  @override
  Future<MineDashboard> get signedOutDashboard =>
      Future<MineDashboard>.value(simulatedMineDashboard());

  @override
  TaskEither<LucentFailure, MineDashboard> fetchDashboard() =>
      TaskEither.right(simulatedMineDashboard());
}

/// The populated dashboard shared by both [SimulatedMineRepository] accessors.
MineDashboard simulatedMineDashboard() {
  return MineDashboard(
    account: MineAccount(
      isAuthenticated: true,
      displayNameKey: MineCopyKey.accountDisplayName,
      displayName: simulatedUserName,
      email: 'chen.jing@example.com',
      statusKey: MineCopyKey.accountSignedIn,
      roleKey: MineCopyKey.accountStudentRole,
      emailVerified: true,
      hasPassword: true,
      linkedIdentityCount: 1,
      lastLoginAt: DateTime.utc(2026, 6, 18, 1, 5),
    ),
    profile: const MineProfileSnapshot(
      age: 42,
      heightCm: 171,
      weightKg: 68,
      sexAtBirth: 'male',
      unitSystem: 'metric',
      allergyCount: 2,
      conditionCount: 2,
      currentMedicineCount: 3,
      basicInfoCompleted: true,
    ),
    completion: const MineCompletion(
      progress: 0.86,
      percentLabel: '86%',
      titleKey: MineCopyKey.completionTitle,
    ),
    alerts: <MineStatusCard>[
      const MineStatusCard(
        icon: SemanticIcons.statusWarning,
        accent: SemanticColor.destructive,
        titleKey: MineCopyKey.alertAllergyTitle,
        kind: MineStatusCardKind.allergy,
        items: <String>['青霉素', '花粉'],
        count: 2,
      ),
      MineStatusCard(
        icon: SemanticIcons.recordMedicine,
        accent: SemanticColor.primary,
        titleKey: MineCopyKey.alertMedicineTitle,
        kind: MineStatusCardKind.medicine,
        items: <String>[_simulatedMedicineName(0), _simulatedMedicineName(2)],
        count: 2,
      ),
      const MineStatusCard(
        icon: SemanticIcons.profileUser,
        accent: SemanticColor.neutral,
        titleKey: MineCopyKey.alertPrivacyTitle,
        kind: MineStatusCardKind.privacy,
        subtitleKey: MineCopyKey.alertPrivacySubtitle,
        badgeKey: MineCopyKey.alertPrivacyBadge,
      ),
    ],
    archiveEntries: const <MineArchiveEntry>[
      MineArchiveEntry(
        icon: FLucideIcons.badge,
        accent: SemanticColor.primary,
        titleKey: MineCopyKey.archiveBasicTitle,
        subtitleKey: MineCopyKey.archiveBasicSubtitle,
        statusKey: MineCopyKey.archiveCompleted,
        route: Routes.profile,
      ),
      MineArchiveEntry(
        icon: SemanticIcons.recordWater,
        accent: SemanticColor.primary,
        titleKey: MineCopyKey.archiveAllergyTitle,
        subtitleKey: MineCopyKey.archiveAllergySubtitle,
        statusKey: MineCopyKey.archiveCompleted,
        route: Routes.mineAllergyNew,
      ),
      MineArchiveEntry(
        icon: SemanticIcons.profileCondition,
        accent: SemanticColor.primary,
        titleKey: MineCopyKey.archiveConditionTitle,
        subtitleKey: MineCopyKey.archiveConditionSubtitle,
        route: Routes.mineConditionNew,
      ),
      MineArchiveEntry(
        icon: SemanticIcons.recordMedicine,
        accent: SemanticColor.primary,
        titleKey: MineCopyKey.archiveMedicineTitle,
        subtitleKey: MineCopyKey.archiveMedicineSubtitle,
        statusKey: MineCopyKey.archiveCompleted,
        route: Routes.mineMedicineNew,
      ),
      MineArchiveEntry(
        icon: SemanticIcons.profileContact,
        accent: SemanticColor.primary,
        titleKey: MineCopyKey.archiveEmergencyTitle,
        subtitleKey: MineCopyKey.archiveEmergencySubtitle,
        statusKey: MineCopyKey.archiveNeedsFill,
      ),
    ],
    privacyNotice: const MinePrivacyNotice(
      icon: SemanticIcons.safetyNeutral,
      titleKey: MineCopyKey.privacyNoticeTitle,
      actionKey: MineCopyKey.privacyNoticeAction,
    ),
  );
}

// ── 2. Medicine workspace ───────────────────────────────────────────────────

/// [SimulatedMedicineWorkspaceRepository] fake backing the `/medicine` tab.
class SimulatedMedicineWorkspaceRepository
    implements MedicineWorkspaceRepository {
  const SimulatedMedicineWorkspaceRepository();

  @override
  Future<MedicineWorkspace> get signedOutWorkspace =>
      Future<MedicineWorkspace>.value(simulatedMedicineWorkspace());

  @override
  TaskEither<LucentFailure, MedicineWorkspace> fetchWorkspace() =>
      TaskEither.right(simulatedMedicineWorkspace());
}

/// The populated workspace shared by both repository accessors.
MedicineWorkspace simulatedMedicineWorkspace() {
  return const MedicineWorkspace(
    hero: MedicineHero(
      metricDosesToday: '3 次',
      metricAdherence: '82%',
      metricNextDose: '12:30',
    ),
    quickActions: <MedicineQuickAction>[
      MedicineQuickAction(
        icon: SemanticIcons.actionSearch,
        titleKey: MedicineCopyKey.quickActionSearchTitle,
        subtitleKey: MedicineCopyKey.quickActionSearchSubtitle,
        accent: SemanticColor.primary,
      ),
      MedicineQuickAction(
        icon: SemanticIcons.actionScan,
        titleKey: MedicineCopyKey.quickActionBarcodeTitle,
        subtitleKey: MedicineCopyKey.quickActionBarcodeSubtitle,
        accent: SemanticColor.primary,
      ),
      MedicineQuickAction(
        icon: SemanticIcons.actionCamera,
        titleKey: MedicineCopyKey.quickActionCameraTitle,
        subtitleKey: MedicineCopyKey.quickActionCameraSubtitle,
        accent: SemanticColor.primary,
      ),
    ],
    plan: MedicinePlanSurface(
      items: <MedicinePlanItem>[
        MedicinePlanItem(
          color: SemanticColor.primary,
          nameKey: MedicineCopyKey.genericName,
          dosageKey: MedicineCopyKey.genericDosage,
          scheduleKey: MedicineCopyKey.genericSchedule,
          rawName: '苯磺酸氨氯地平片',
          rawDosage: '5mg，1 片',
          rawSchedule: '每日 2 次，早餐后与睡前',
          rawState: '血压平稳',
          currentMedicineId: 'cm_amlodipine_2026',
          source: 'cn',
          sourceRefId: 'cn-amlodipine-5mg',
          slots: <MedicineDoseSlot>[
            MedicineDoseSlot(
              reminderId: 'rmd-amlodipine-0800',
              scheduledTime: '2026-06-18T08:00:00.000Z',
              rawTime: '08:00',
              statusKey: MedicineCopyKey.doseStatusTaken,
              status: MedicineDoseStatus.taken,
            ),
            MedicineDoseSlot(
              reminderId: 'rmd-amlodipine-1230',
              scheduledTime: '2026-06-18T12:30:00.000Z',
              rawTime: '12:30',
              statusKey: MedicineCopyKey.doseStatusPending,
              status: MedicineDoseStatus.pending,
            ),
          ],
          stateKey: MedicineCopyKey.statusStable,
          stateColor: SemanticColor.primary,
          todayStatus: MedicineDoseStatus.pending,
        ),
        MedicinePlanItem(
          color: SemanticColor.primary,
          nameKey: MedicineCopyKey.genericName,
          dosageKey: MedicineCopyKey.genericDosage,
          scheduleKey: MedicineCopyKey.genericSchedule,
          rawName: '阿司匹林肠溶片',
          rawDosage: '100mg，1 片',
          rawSchedule: '每日 1 次，早餐后',
          rawState: '整片吞服',
          currentMedicineId: 'cm_aspirin_2026',
          source: 'cn',
          sourceRefId: 'cn-aspirin-100mg',
          slots: <MedicineDoseSlot>[
            MedicineDoseSlot(
              reminderId: 'rmd-aspirin-0800',
              scheduledTime: '2026-06-18T08:00:00.000Z',
              rawTime: '08:00',
              statusKey: MedicineCopyKey.doseStatusTaken,
              status: MedicineDoseStatus.taken,
            ),
          ],
          stateKey: MedicineCopyKey.statusStable,
          stateColor: SemanticColor.primary,
          todayStatus: MedicineDoseStatus.taken,
        ),
        MedicinePlanItem(
          color: SemanticColor.primary,
          nameKey: MedicineCopyKey.genericName,
          dosageKey: MedicineCopyKey.genericDosage,
          scheduleKey: MedicineCopyKey.genericSchedule,
          rawName: '盐酸二甲双胍片',
          rawDosage: '0.5g，1 片',
          rawSchedule: '每日 1 次，晚餐后',
          rawState: '随餐服用',
          currentMedicineId: 'cm_metformin_2026',
          source: 'cn',
          sourceRefId: 'cn-metformin-500mg',
          slots: <MedicineDoseSlot>[
            MedicineDoseSlot(
              reminderId: 'rmd-metformin-2000',
              scheduledTime: '2026-06-18T20:00:00.000Z',
              rawTime: '20:00',
              statusKey: MedicineCopyKey.doseStatusPending,
              status: MedicineDoseStatus.pending,
            ),
          ],
          stateKey: MedicineCopyKey.doseStatusPending,
          stateColor: SemanticColor.primary,
          todayStatus: MedicineDoseStatus.pending,
        ),
      ],
    ),
    alerts: <MedicineAlert>[
      MedicineAlert(
        icon: SemanticIcons.safetyInteraction,
        rawTitle: '降压药与阿司匹林联用提示',
        rawBody: '两者之间没有需要避免的相互作用，但需留意踝部水肿与胃部不适。',
        rawDetail: '若出现黑便、持续胃痛或明显头晕，请尽快线下就诊。',
        rawAction: '已确认用药方案',
        color: SemanticColor.warning,
        softColor: SemanticColor.warning,
      ),
      MedicineAlert(
        icon: SemanticIcons.recordCaffeine,
        rawTitle: '咖啡因与血压记录',
        rawBody: '近 7 天有 3 次在饮用咖啡后 1 小时内测量血压，读数普遍偏高 4-6 mmHg。',
        rawDetail: '建议测量前 30 分钟避免咖啡、浓茶与吸烟。',
        rawAction: '调整测量时间',
        color: SemanticColor.info,
        softColor: SemanticColor.info,
      ),
      MedicineAlert(
        icon: SemanticIcons.safetyDuplicate,
        rawTitle: '复方制剂重复成分检查',
        rawBody: '你录入的复方感冒灵颗粒含有解热镇痛成分，与阿司匹林肠溶片作用重叠。',
        rawDetail: '感冒期间请暂停其中一种，或先咨询药师。',
        rawAction: '查看重复成分',
        color: SemanticColor.destructive,
        softColor: SemanticColor.destructive,
      ),
      MedicineAlert(
        icon: SemanticIcons.safetySpecialGroup,
        rawTitle: '二甲双胍与肾功能随访',
        rawBody: '已连续服用盐酸二甲双胍片 11 周，建议复诊时复查肾功能与血糖。',
        rawDetail: '服药期间避免饮酒，可降低乳酸酸中毒风险。',
        rawAction: '了解复查项目',
        color: SemanticColor.primary,
        softColor: SemanticColor.primary,
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

// ── 3. Health context snapshot ──────────────────────────────────────────────

/// [SimulatedHealthContextRepository] fake backing the health-context hub.
///
/// The snapshot is the join key for the whole shell: `/mine`, the profile pages
/// and `/medicine/reminders/<medicineId>` all resolve against the ids in
/// [simulatedCurrentMedicineIds], so those three boxes exist here too.
class SimulatedHealthContextRepository implements HealthContextRepository {
  const SimulatedHealthContextRepository();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> fetchHealthContext() =>
      TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) => TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) => TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) => TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteAllergy(String id) =>
      TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) => TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) => TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCondition(String id) =>
      TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) => TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) => TaskEither.right(simulatedHealthContextSnapshot());

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCurrentMedicine(
    String id,
  ) => TaskEither.right(simulatedHealthContextSnapshot());
}

/// The populated health-context snapshot the fakes above serve.
HealthContextSnapshot simulatedHealthContextSnapshot() {
  return HealthContextSnapshot(
    summary: const HealthSummary(
      age: 42,
      onboardingCompleted: true,
      activeAllergyCount: 2,
      conditionCount: 2,
      currentMedicineCount: 3,
      missingCoreProfileFields: <String>[],
    ),
    profile: const HealthProfile(
      birthDate: '1984-03-12',
      sexAtBirth: 'male',
      heightCm: 171,
      weightKg: 68,
      activityLevel: 'moderatelyActive',
      dietaryPreferences: <String>['lowSalt'],
      locale: 'zh-CN',
      timezone: 'Asia/Shanghai',
      unitSystem: 'metric',
      onboardingCompletedAt: '2026-02-18T02:40:00.000Z',
      extras: <String, dynamic>{},
    ),
    allergies: const <AllergyItem>[
      AllergyItem(
        id: 'alg-penicillin-2026',
        kind: 'drug',
        label: '青霉素',
        reaction: '用药后出现全身荨麻疹',
        severity: 'severe',
        isActive: true,
        note: '就诊时请主动告知医生，改用其他类别的抗菌药物。',
        createdAt: '2026-02-18T03:10:00.000Z',
        updatedAt: '2026-04-02T07:25:00.000Z',
      ),
      AllergyItem(
        id: 'alg-pollen-2026',
        kind: 'environment',
        label: '花粉',
        reaction: '春季出现打喷嚏、眼痒',
        severity: 'moderate',
        isActive: true,
        note: '花粉季外出建议佩戴口罩。',
        createdAt: '2026-03-05T01:20:00.000Z',
        updatedAt: '2026-03-05T01:20:00.000Z',
      ),
    ],
    conditions: const <ConditionItem>[
      ConditionItem(
        id: 'cnd-hypertension-2026',
        label: '高血压',
        status: 'active',
        diagnosedAt: '2024-09-18',
        resolvedAt: null,
        note: '家庭血压维持在 130-140/80-88 mmHg。',
        createdAt: '2026-02-18T03:15:00.000Z',
        updatedAt: '2026-05-20T06:00:00.000Z',
      ),
      ConditionItem(
        id: 'cnd-t2dm-2026',
        label: '2型糖尿病',
        status: 'active',
        diagnosedAt: '2025-04-06',
        resolvedAt: null,
        note: '目前仅口服盐酸二甲双胍片，糖化血红蛋白 6.8%。',
        createdAt: '2026-02-18T03:18:00.000Z',
        updatedAt: '2026-05-20T06:02:00.000Z',
      ),
    ],
    currentMedicines: <CurrentMedicineItem>[
      CurrentMedicineItem(
        id: _simulatedMedicineId(0),
        source: 'cn',
        sourceRefId: 'cn-amlodipine-5mg',
        displayName: _simulatedMedicineName(0),
        strengthText: '5mg',
        doseText: '每次 1 片，每日 2 次',
        route: '口服',
        startedAt: '2026-01-05',
        endedAt: null,
        isCurrent: true,
        note: '早餐后与睡前各一次，服药前先测一次血压。',
        createdAt: '2026-01-05T00:20:00.000Z',
        updatedAt: '2026-06-01T06:20:00.000Z',
      ),
      CurrentMedicineItem(
        id: _simulatedMedicineId(1),
        source: 'cn',
        sourceRefId: 'cn-aspirin-100mg',
        displayName: _simulatedMedicineName(1),
        strengthText: '100mg',
        doseText: '每次 1 片，每日 1 次',
        route: '口服',
        startedAt: '2026-02-01',
        endedAt: null,
        isCurrent: true,
        note: '肠溶片需整片吞服，不可掰开或嚼碎。',
        createdAt: '2026-02-01T00:40:00.000Z',
        updatedAt: '2026-05-28T07:15:00.000Z',
      ),
      CurrentMedicineItem(
        id: _simulatedMedicineId(2),
        source: 'cn',
        sourceRefId: 'cn-metformin-500mg',
        displayName: _simulatedMedicineName(2),
        strengthText: '0.5g',
        doseText: '每次 1 片，每日 1 次',
        route: '口服',
        startedAt: '2026-04-01',
        endedAt: null,
        isCurrent: true,
        note: '随晚餐服用可减轻胃肠道反应。',
        createdAt: '2026-04-01T02:10:00.000Z',
        updatedAt: '2026-06-05T04:45:00.000Z',
      ),
    ],
  );
}

// ── 4. Today suggestion bundle ──────────────────────────────────────────────

/// [SimulatedTodaySuggestionNotifier] backing the Today suggestion section.
///
/// Returns the fixture directly instead of hitting the network, so the capture
/// always shows the urgent card rather than an error or an empty state.
class SimulatedTodaySuggestionNotifier extends TodaySuggestionNotifier {
  @override
  Future<TodaySuggestionBundle?> build() async =>
      buildSimulatedSuggestionBundle();
}

/// The populated suggestion bundle the Today tab renders.
TodaySuggestionBundle buildSimulatedSuggestionBundle() {
  return const TodaySuggestionBundle(
    generatedAt: '2026-06-18T04:10:00.000Z',
    materializationStatus: TodaySuggestionMaterializationStatus.ready,
    sourceVersion: 7,
    primary: TodaySuggestionCard(
      id: 'sim_sg_amlodipine_pending',
      type: TodaySuggestionType.compliance,
      cardTone: TodaySuggestionCardTone.urgent,
      icon: 'pill',
      title: '午间这次降压药还没确认服用',
      reason:
          '苯磺酸氨氯地平片的 12:30 这次服药仍未打卡，'
          '且近 7 天已有 2 次漏服，继续漏服可能让下午血压回升。',
      evidence: <TodaySuggestionEvidence>[
        TodaySuggestionEvidence(
          kind: TodaySuggestionEvidenceKind.reminder,
          label: '计划时间',
          value: '12:30',
        ),
        TodaySuggestionEvidence(
          kind: TodaySuggestionEvidenceKind.record,
          label: '今日状态',
          value: '未确认',
        ),
        TodaySuggestionEvidence(
          kind: TodaySuggestionEvidenceKind.trend,
          label: '近 7 天漏服',
          value: '2 次',
        ),
        TodaySuggestionEvidence(
          kind: TodaySuggestionEvidenceKind.baseline,
          label: '近 14 天依从率',
          value: '82%',
        ),
      ],
      boundary:
          '此提醒仅基于你的用药计划与打卡记录，不构成医疗建议；'
          '如需调整剂量请咨询医生或药师。',
      primaryAction: TodaySuggestionAction(
        actionId: 'go_confirm_dose',
        label: '去确认',
        route: '/medicine',
        authRequired: true,
      ),
      secondaryActions: <TodaySuggestionAction>[
        TodaySuggestionAction(
          actionId: 'skip_this_dose',
          label: '跳过此次',
          route: '/medicine',
          authRequired: true,
        ),
        TodaySuggestionAction(
          actionId: 'view_evidence',
          label: '查看依据',
          route: '/medicine/detail/cn/amlodipine',
          authRequired: true,
        ),
      ],
      confidence: TodaySuggestionConfidence.high,
      ruleId: 'missed_dose_two_in_seven_days',
      ruleVersion: '1.4.0',
      triggerType: TodaySuggestionTriggerType.timer,
      lifecycleState: TodaySuggestionLifecycleState.active,
      notificationEligible: true,
      feedbackOptions: <TodaySuggestionFeedback>[
        TodaySuggestionFeedback.accepted,
        TodaySuggestionFeedback.later,
        TodaySuggestionFeedback.notApplicable,
        TodaySuggestionFeedback.suppress,
      ],
      subtype: 'dose_pending',
    ),
    secondary: <TodaySuggestionCard>[
      TodaySuggestionCard(
        id: 'sim_sg_heart_rate_trend',
        type: TodaySuggestionType.trend,
        cardTone: TodaySuggestionCardTone.soft,
        icon: 'activity',
        title: '静息心率连续 3 天高于你的基线',
        reason: '近 3 天晨起静息心率平均 78 次/分，比 14 天基线高 7 次/分。',
        evidence: <TodaySuggestionEvidence>[
          TodaySuggestionEvidence(
            kind: TodaySuggestionEvidenceKind.trend,
            label: '近 3 天均值',
            value: '78 次/分',
          ),
          TodaySuggestionEvidence(
            kind: TodaySuggestionEvidenceKind.baseline,
            label: '14 天基线',
            value: '71 次/分',
          ),
        ],
        boundary: '心率受睡眠、情绪与运动影响，单次偏高不代表异常。',
        primaryAction: TodaySuggestionAction(
          actionId: 'open_review_trend',
          label: '查看趋势',
          route: '/review',
          authRequired: true,
        ),
        confidence: TodaySuggestionConfidence.medium,
        ruleId: 'resting_hr_above_baseline',
        ruleVersion: '1.1.0',
        triggerType: TodaySuggestionTriggerType.timer,
        lifecycleState: TodaySuggestionLifecycleState.active,
        feedbackOptions: <TodaySuggestionFeedback>[
          TodaySuggestionFeedback.accepted,
          TodaySuggestionFeedback.later,
          TodaySuggestionFeedback.notApplicable,
        ],
        subtype: 'heart_rate',
      ),
      TodaySuggestionCard(
        id: 'sim_sg_water_behind',
        type: TodaySuggestionType.behaviorAdvice,
        cardTone: TodaySuggestionCardTone.neutral,
        icon: 'droplets',
        title: '今日饮水还差 3 杯',
        reason: '当前已完成 5/8 杯，午后少量多次补水更容易达标。',
        evidence: <TodaySuggestionEvidence>[
          TodaySuggestionEvidence(
            kind: TodaySuggestionEvidenceKind.record,
            label: '今日饮水',
            value: '5/8',
          ),
        ],
        boundary: '建议饮水量因人而异，请结合自身情况与医生建议调整。',
        primaryAction: TodaySuggestionAction(
          actionId: 'go_record_water',
          label: '去记录',
          route: '/record/create?kind=water',
          authRequired: true,
        ),
        confidence: TodaySuggestionConfidence.medium,
        ruleId: 'water_behind_target',
        ruleVersion: '1.0.0',
        triggerType: TodaySuggestionTriggerType.timer,
        lifecycleState: TodaySuggestionLifecycleState.active,
        feedbackOptions: <TodaySuggestionFeedback>[
          TodaySuggestionFeedback.accepted,
          TodaySuggestionFeedback.later,
          TodaySuggestionFeedback.suppress,
        ],
        subtype: 'water',
      ),
    ],
    observations: <TodaySuggestionCard>[
      TodaySuggestionCard(
        id: 'sim_sg_coverage_sleep',
        type: TodaySuggestionType.coverage,
        cardTone: TodaySuggestionCardTone.neutral,
        icon: 'info',
        title: '睡眠数据不足，暂无法生成睡眠趋势建议',
        reason: '需要至少 3 天连续睡眠记录才能建立基线，当前仅有 2 天。',
        evidence: <TodaySuggestionEvidence>[],
        boundary: '记录越完整，趋势判断越可靠。',
        primaryAction: TodaySuggestionAction(
          actionId: 'go_record_sleep',
          label: '记录睡眠',
          route: '/record/create?kind=sleep',
          authRequired: true,
        ),
        confidence: TodaySuggestionConfidence.high,
        ruleId: 'coverage_explanation',
        ruleVersion: '1.0.0',
        triggerType: TodaySuggestionTriggerType.timer,
        lifecycleState: TodaySuggestionLifecycleState.active,
      ),
      TodaySuggestionCard(
        id: 'sim_sg_coverage_allergy',
        type: TodaySuggestionType.coverage,
        cardTone: TodaySuggestionCardTone.neutral,
        icon: 'clipboard',
        title: '过敏史已记录 2 项，可用于用药风险检查',
        reason: '青霉素与花粉已写入健康档案，风险检查会自动纳入这两项。',
        evidence: <TodaySuggestionEvidence>[
          TodaySuggestionEvidence(
            kind: TodaySuggestionEvidenceKind.profile,
            label: '已记录过敏',
            value: '2 项',
          ),
        ],
        boundary: '档案内容仅用于你本人的健康提示。',
        primaryAction: TodaySuggestionAction(
          actionId: 'open_allergy_archive',
          label: '查看档案',
          route: '/mine',
          authRequired: true,
        ),
        confidence: TodaySuggestionConfidence.high,
        ruleId: 'allergy_recorded_coverage',
        ruleVersion: '1.0.0',
        triggerType: TodaySuggestionTriggerType.event,
        lifecycleState: TodaySuggestionLifecycleState.active,
      ),
    ],
  );
}

/// Unused by the fakes above, but keeps the simulated "now" compiled in one
/// place so the capture day is not retyped per fixture.
// ignore: unused_element
DateTime get simulatedCaptureNow => _simulatedCaptureNow;
