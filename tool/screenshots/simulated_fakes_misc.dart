// Hand-written, fully populated fake repositories for the screenshot catalog.
//
// The page-catalog generator captures every route in the app; routes whose
// data comes from a repository that the offline fixture stack does not wire
// render as empty states, endless shimmer skeletons, or error cards. The fakes
// below return rich, realistic Chinese content so those secondary pages
// (notifications, reminder detail/edit, assistant, sync failures, medicine
// search, risk check, legal, help, settings, scan, medicine detail) capture as
// populated pages.
//
// Everything here is new content written for the screenshot run — nothing is
// imported or copied from `integration_test/` or `test/`.
//
// This file is a generator fixture, not production code: nothing under `lib/`
// imports it.
//
// ignore_for_file: avoid_classes_with_only_static_members

import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/domain/repositories/assistant.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_permission.dart';
import 'package:luminous/features/health_data/domain/entities/health_sync_result.dart';
import 'package:luminous/features/health_data/domain/repositories/health_sync.dart';
import 'package:luminous/features/legal/domain/entities/doc_type.dart';
import 'package:luminous/features/legal/domain/entities/document.dart';
import 'package:luminous/features/legal/domain/repositories/documents.dart';
import 'package:luminous/features/medicine/domain/entities/dose_log.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/domain/entities/reminder.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/reminder.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';
import 'package:luminous/features/notification/domain/entities/notification.dart';
import 'package:luminous/features/notification/domain/repositories/notification.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/repositories/scan.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/domain/repositories/user_settings.dart';
import 'package:luminous/features/support/domain/entities/app_info.dart';
import 'package:luminous/features/support/domain/repositories/support.dart';

// ── Shared identity / time anchors ──────────────────────────────────────────

/// The simulated account behind every page in this fixture set.
const String simulatedUserName = '陈静';

/// Fixed "now" for every simulated timestamp (2026-06-18 09:30 local).
final DateTime simulatedNow = DateTime(2026, 6, 18, 9, 30);

/// Medicine-box ids the reminder fakes are keyed on.
///
/// `/medicine/reminders/<medicineId>` joins the route id against the health
/// context snapshot's current medicines, so the reminder fakes cover all three
/// ids here and the catalog can point at any of them.
const List<String> simulatedCurrentMedicineIds = <String>[
  'cm_amlodipine_2026',
  'cm_aspirin_2026',
  'cm_metformin_2026',
];

// ── 1. Notifications ────────────────────────────────────────────────────────

const List<NotificationItem> _notifications = <NotificationItem>[
  NotificationItem(
    id: 'ntf-med-0001',
    type: NotificationType.medicineReminder,
    title: '用药提醒：苯磺酸氨氯地平片',
    content:
        '早上 08:00 的苯磺酸氨氯地平片（5mg，1 片）还没有打卡，'
        '现在补记仍然有效。血压偏高时请先测量再服药。',
    isRead: false,
    createdAt: '2026-06-18T00:00:00.000Z',
    action: 'open_reminder',
  ),
  NotificationItem(
    id: 'ntf-sleep-0002',
    type: NotificationType.aiWeeklyInsight,
    title: '睡眠周报已生成',
    content:
        '上周（06-08 至 06-14）平均睡眠 6 小时 52 分，比前一周少了 24 分钟；'
        '深睡比例 21%，入睡时间集中在 23:40 之后。',
    isRead: false,
    createdAt: '2026-06-15T01:05:00.000Z',
    action: 'open_report',
  ),
  NotificationItem(
    id: 'ntf-visit-0003',
    type: NotificationType.aiProactiveSuggestion,
    title: '复诊提醒：心内科随访',
    content:
        '距离上次复诊已满 12 周，建议在 06-25 前预约心内科复查血压与血脂。'
        '带上近两周的家庭血压记录会更有帮助。',
    isRead: false,
    createdAt: '2026-06-14T02:30:00.000Z',
  ),
  NotificationItem(
    id: 'ntf-bp-0004',
    type: NotificationType.aiTodaySummary,
    title: '今日血压小结',
    content:
        '今天已记录 2 次血压：晨起 138/86 mmHg，午后 132/82 mmHg，'
        '收缩压较上周同期下降约 5 mmHg。',
    isRead: true,
    createdAt: '2026-06-13T12:10:00.000Z',
    action: 'open_today',
  ),
  NotificationItem(
    id: 'ntf-report-0005',
    type: NotificationType.reportGenerated,
    title: '6 月健康报告已生成',
    content:
        '6 月上半月的用药依从率 92%，步数日均 6,480 步，饮水日均 7 杯。'
        '报告已保存，可在「回顾」中查看。',
    isRead: true,
    createdAt: '2026-06-12T23:00:00.000Z',
    action: 'open_report',
  ),
  NotificationItem(
    id: 'ntf-system-0006',
    type: NotificationType.systemAnnouncement,
    title: '药品库数据已更新',
    content:
        '国家药品说明书库已于 06-10 同步更新，新增 1,240 条说明书与 '
        '368 条药物相互作用记录。',
    isRead: true,
    createdAt: '2026-06-10T03:20:00.000Z',
  ),
];

/// [SimulatedNotificationRepository] fake backing `/notifications`.
class SimulatedNotificationRepository implements NotificationRepository {
  @override
  TaskEither<LucentFailure, NotificationPage> findAll({
    required int page,
    required int pageSize,
  }) {
    return TaskEither.right(
      const NotificationPage(
        items: _notifications,
        total: 6,
        page: 1,
        pageSize: 20,
      ),
    );
  }

  /// Always succeeds, echoing back the requested id, so `/notifications/<id>`
  /// renders a populated detail page for any deep link.
  @override
  TaskEither<LucentFailure, NotificationDetail?> findOne(String id) {
    final source = _notifications.firstWhere(
      (item) => item.id == id,
      orElse: () => _notifications.first,
    );
    return TaskEither.right(
      NotificationDetail(
        id: id,
        type: source.type,
        title: source.title,
        content: source.content,
        action: source.action,
        isRead: source.isRead,
        createdAt: source.createdAt,
        readAt: source.isRead ? '2026-06-18T02:00:00.000Z' : null,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, int> getUnreadCount() => TaskEither.right(3);

  @override
  TaskEither<LucentFailure, void> markAllAsRead() => TaskEither.right(null);

  @override
  TaskEither<LucentFailure, void> markAsRead(String id) =>
      TaskEither.right(null);

  @override
  TaskEither<LucentFailure, void> markAsUnread(String id) =>
      TaskEither.right(null);

  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);
}

// ── 2. Medicine reminders ───────────────────────────────────────────────────

const List<MedicineReminderItem> _reminders = <MedicineReminderItem>[
  MedicineReminderItem(
    id: 'rmd-amlodipine-0800',
    currentMedicineId: 'cm_amlodipine_2026',
    label: '早餐后',
    scheduledHour: 8,
    scheduledMinute: 0,
    daysOfWeek: <int>[1, 2, 3, 4, 5, 6, 7],
    startDate: '2026-01-05',
    endDate: '2026-12-31',
    isActive: true,
    note: '5mg，1 片，早餐后温水送服；服药后半小时内避免躺卧。',
    createdAt: '2026-01-05T00:10:00.000Z',
    updatedAt: '2026-06-01T06:20:00.000Z',
  ),
  MedicineReminderItem(
    id: 'rmd-amlodipine-2000',
    currentMedicineId: 'cm_amlodipine_2026',
    label: '睡前',
    scheduledHour: 20,
    scheduledMinute: 0,
    daysOfWeek: <int>[1, 2, 3, 4, 5, 6, 7],
    startDate: '2026-03-01',
    endDate: '2026-12-31',
    isActive: true,
    note: '医生调整的第二剂，服药前先测一次血压并记录。',
    createdAt: '2026-03-01T01:00:00.000Z',
    updatedAt: '2026-06-10T09:40:00.000Z',
  ),
  MedicineReminderItem(
    id: 'rmd-aspirin-0800',
    currentMedicineId: 'cm_aspirin_2026',
    label: '早餐后',
    scheduledHour: 8,
    scheduledMinute: 0,
    daysOfWeek: <int>[1, 2, 3, 4, 5, 6, 7],
    startDate: '2026-02-01',
    endDate: '2026-12-31',
    isActive: true,
    note: '100mg，肠溶片整片吞服，不可掰开或嚼碎。',
    createdAt: '2026-02-01T00:30:00.000Z',
    updatedAt: '2026-05-28T07:15:00.000Z',
  ),
  MedicineReminderItem(
    id: 'rmd-metformin-1230',
    currentMedicineId: 'cm_metformin_2026',
    label: '午餐后',
    scheduledHour: 12,
    scheduledMinute: 30,
    daysOfWeek: <int>[1, 2, 3, 4, 5],
    startDate: '2026-04-01',
    endDate: '2026-10-31',
    isActive: true,
    note: '0.5g，1 片随餐服用，减少胃部不适。',
    createdAt: '2026-04-01T02:00:00.000Z',
    updatedAt: '2026-06-05T04:45:00.000Z',
  ),
  MedicineReminderItem(
    id: 'rmd-aspirin-legacy',
    currentMedicineId: 'cm_aspirin_2026',
    label: '下午',
    scheduledHour: 15,
    scheduledMinute: 30,
    daysOfWeek: <int>[1, 3, 5],
    startDate: '2025-11-01',
    endDate: '2026-02-28',
    isActive: false,
    note: '已由医生调整为早餐后服用，此条保留备查。',
    createdAt: '2025-11-01T03:00:00.000Z',
    updatedAt: '2026-02-28T08:00:00.000Z',
  ),
];

const List<ReminderDeliveryItem> _deliveries = <ReminderDeliveryItem>[
  ReminderDeliveryItem(
    id: 'dlv-20260618-0800',
    reminderId: 'rmd-amlodipine-0800',
    deviceId: 'dev-chenjing-pixel8pro',
    channel: 'local',
    status: 'delivered',
    scheduledFor: '2026-06-18T08:00:00.000Z',
    deliveredAt: '2026-06-18T08:00:04.000Z',
    createdAt: '2026-06-18T00:00:00.000Z',
  ),
  ReminderDeliveryItem(
    id: 'dlv-20260618-0801',
    reminderId: 'rmd-aspirin-0800',
    deviceId: 'dev-chenjing-pixel8pro',
    channel: 'local',
    status: 'delivered',
    scheduledFor: '2026-06-18T08:00:00.000Z',
    deliveredAt: '2026-06-18T08:00:05.000Z',
    createdAt: '2026-06-18T00:00:00.000Z',
  ),
  ReminderDeliveryItem(
    id: 'dlv-20260617-2000',
    reminderId: 'rmd-amlodipine-2000',
    deviceId: 'dev-chenjing-pixel8pro',
    channel: 'jpush',
    status: 'failed',
    scheduledFor: '2026-06-17T20:00:00.000Z',
    errorMessage: '设备未在预期时间内上报本地投递回执，已回退至推送通道。',
    createdAt: '2026-06-17T12:00:00.000Z',
  ),
];

/// The simulated reminder set, exposed so the generator can override the
/// medicine-reminder *presentation* providers. Those read
/// `medicineReminderRemoteDataSourceProvider` directly rather than
/// `reminderRepositoryProvider`, so overriding the repository alone leaves the
/// reminder pages on the real network path.
List<MedicineReminderItem> simulatedReminders() => _reminders;

/// The simulated push/local delivery history, exposed for the same reason.
List<ReminderDeliveryItem> simulatedReminderDeliveries() => _deliveries;

/// Today's simulated dose logs, keyed to the reminder ids above.
List<DoseLogItem> simulatedTodayDoseLogs() => const <DoseLogItem>[
  DoseLogItem(
    id: 'dose-amlodipine-20260618-0800',
    currentMedicineId: 'cm_amlodipine_2026',
    reminderId: 'rmd-amlodipine-0800',
    status: DoseLogStatus.taken,
    scheduledFor: '2026-06-18',
    scheduledTime: '08:00',
    doseText: '5mg，1 片',
    note: '早餐后服用，无不适。',
    createdAt: '2026-06-18T00:00:00.000Z',
    updatedAt: '2026-06-18T00:08:00.000Z',
  ),
  DoseLogItem(
    id: 'dose-aspirin-20260618-0800',
    currentMedicineId: 'cm_aspirin_2026',
    reminderId: 'rmd-aspirin-0800',
    status: DoseLogStatus.taken,
    scheduledFor: '2026-06-18',
    scheduledTime: '08:00',
    doseText: '100mg，1 片',
    note: '肠溶片整片吞服。',
    createdAt: '2026-06-18T00:00:00.000Z',
    updatedAt: '2026-06-18T00:09:00.000Z',
  ),
  DoseLogItem(
    id: 'dose-metformin-20260618-1230',
    currentMedicineId: 'cm_metformin_2026',
    reminderId: 'rmd-metformin-1230',
    status: DoseLogStatus.skipped,
    scheduledFor: '2026-06-18',
    scheduledTime: '12:30',
    doseText: '0.5g，1 片',
    note: '午餐推迟，顺延至餐后服用。',
    createdAt: '2026-06-18T00:00:00.000Z',
    updatedAt: '2026-06-18T04:31:00.000Z',
  ),
];

/// [SimulatedReminderRepository] fake backing `/medicine/reminders/<id>`.
class SimulatedReminderRepository implements ReminderRepository {
  /// Never throws: an unknown/empty id still gets the full reminder set so the
  /// reminder detail and edit pages prefill instead of showing the
  /// "提醒暂时没有加载出来" error card.
  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchAll() =>
      TaskEither.right(_reminders);

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchActive() =>
      TaskEither.right(
        _reminders.where((item) => item.isActive).toList(growable: false),
      );

  @override
  TaskEither<LucentFailure, List<ReminderDeliveryItem>> fetchDeliveries({
    String? date,
    int limit = 20,
  }) {
    final filtered = date == null
        ? _deliveries
        : _deliveries
              .where((item) => item.scheduledFor.startsWith(date))
              .toList(growable: false);
    return TaskEither.right(filtered.take(limit).toList(growable: false));
  }

  @override
  TaskEither<LucentFailure, MedicineReminderItem> create(
    MedicineReminderWriteInput input,
  ) => TaskEither.right(_reminderFromWrite('rmd-new-created', input));

  @override
  TaskEither<LucentFailure, MedicineReminderItem> update(
    String id,
    MedicineReminderWriteInput input,
  ) => TaskEither.right(_reminderFromWrite(id, input));

  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> upsertGroup(
    MedicineReminderGroupUpsertInput input,
  ) {
    final items = <MedicineReminderItem>[];
    for (var i = 0; i < input.slots.length; i += 1) {
      final slot = input.slots[i];
      items.add(
        MedicineReminderItem(
          id: slot.id ?? 'rmd-group-$i',
          currentMedicineId: input.currentMedicineId,
          label: input.label ?? '按医嘱',
          scheduledHour: slot.scheduledHour,
          scheduledMinute: slot.scheduledMinute,
          daysOfWeek: input.daysOfWeek,
          startDate: input.startDate,
          endDate: input.endDate,
          isActive: input.isActive ?? true,
          note: input.note,
          createdAt: '2026-06-18T01:30:00.000Z',
          updatedAt: '2026-06-18T01:30:00.000Z',
        ),
      );
    }
    return TaskEither.right(items);
  }

  @override
  TaskEither<LucentFailure, void> reportLocalReceipt({
    required String reminderId,
    required String scheduledDate,
    required String scheduledTime,
  }) => TaskEither.right(null);

  @override
  TaskEither<LucentFailure, void> reportLocalCapability(String state) =>
      TaskEither.right(null);

  MedicineReminderItem _reminderFromWrite(
    String id,
    MedicineReminderWriteInput input,
  ) {
    return MedicineReminderItem(
      id: id,
      currentMedicineId:
          input.currentMedicineId ?? simulatedCurrentMedicineIds.first,
      label: input.label ?? '按医嘱',
      scheduledHour: input.scheduledHour,
      scheduledMinute: input.scheduledMinute,
      daysOfWeek: input.daysOfWeek,
      startDate: input.startDate,
      endDate: input.endDate,
      isActive: input.isActive,
      note: input.note,
      createdAt: '2026-06-18T01:30:00.000Z',
      updatedAt: '2026-06-18T01:30:00.000Z',
    );
  }
}

// ── 3. Assistant ────────────────────────────────────────────────────────────

const String _assistantConversationId = 'conv-bp-20260618';

AssistantConversation assistantConversationFixture() {
  return AssistantConversation(
    id: _assistantConversationId,
    title: '血压波动与用药咨询',
    status: 'active',
    lastMessageAt: DateTime(2026, 6, 18, 9, 32),
    createdAt: DateTime(2026, 6, 18, 9, 20),
    updatedAt: DateTime(2026, 6, 18, 9, 32),
    messages: <AssistantMessage>[
      AssistantMessage(
        role: AssistantMessageRole.user,
        content: '最近早上量的血压都是 138/86 左右，晚上会降到 130/80，这样正常吗？',
        createdAt: DateTime(2026, 6, 18, 9, 20),
      ),
      AssistantMessage(
        role: AssistantMessageRole.assistant,
        content:
            '从你 6 月 10 日至 6 月 18 日的记录看，晨起收缩压平均 137 mmHg，'
            '午后平均 131 mmHg，整体呈早晨偏高、午后回落的节律，'
            '这在服用苯磺酸氨氯地平片的人群中比较常见。\n\n'
            '目前收缩压多在 130-140 mmHg 区间，尚未达到需要自行加量的程度。'
            '建议保持固定时间服药与测量，并把晨起数值连续记录两周，'
            '复诊时一起给心内科医生看。',
        createdAt: DateTime(2026, 6, 18, 9, 22),
        usedTools: <String>[
          'get_recent_daily_records',
          'list_current_medicines',
        ],
        toolDetails: const <AssistantToolDetail>[
          AssistantToolDetail(
            name: 'get_recent_daily_records',
            label: '近期每日记录',
            coverageStatus: 'ok',
            confidenceLevel: 'high',
            disclaimer: '数据来自你本人 2026-06-10 至 2026-06-18 的血压记录，共 14 条。',
            sourceTables: <String>['daily_records'],
          ),
          AssistantToolDetail(
            name: 'list_current_medicines',
            label: '当前用药',
            coverageStatus: 'ok',
            confidenceLevel: 'high',
            disclaimer: '药品资料来自国家药品说明书库，仅供健康参考，不替代医生诊断。',
            sourceTables: <String>['health_context_current_medicines'],
          ),
        ],
      ),
      AssistantMessage(
        role: AssistantMessageRole.user,
        content: '那苯磺酸氨氯地平和阿司匹林一起吃需要注意什么？',
        createdAt: DateTime(2026, 6, 18, 9, 28),
      ),
      AssistantMessage(
        role: AssistantMessageRole.assistant,
        content:
            '两者之间没有明确需要避免的相互作用，但有三点值得留意：\n\n'
            '1. 苯磺酸氨氯地平片常见不良反应包括踝部水肿和面部潮红，'
            '如果出现明显水肿请及时复诊。\n'
            '2. 阿司匹林肠溶片建议整片吞服，不要掰开或嚼碎，'
            '以免破坏肠溶衣刺激胃黏膜。\n'
            '3. 你目前的提醒设置在早餐后 08:00，两种药同服是可行的；'
            '只要保持每天同一时间服用，依从率会更稳定。\n\n'
            '如果出现黑便、持续胃痛或明显头晕，请尽快线下就医。',
        createdAt: DateTime(2026, 6, 18, 9, 32),
        usedTools: <String>['check_medicine_interaction'],
        toolDetails: const <AssistantToolDetail>[
          AssistantToolDetail(
            name: 'check_medicine_interaction',
            label: '药物相互作用检查',
            coverageStatus: 'partial',
            confidenceLevel: 'medium',
            coverageReason: '阿司匹林肠溶片的相互作用条目在本地药品库中覆盖不完整。',
            ambiguities: <String>['未匹配到与氯沙坦钾的联合用药记录'],
            sourceTables: <String>[
              'drugbank_drug_interactions',
              'cn_drug_instructions',
            ],
            disclaimer: '相互作用结果基于药品资料库，具体用药方案请遵医嘱。',
          ),
        ],
      ),
    ],
  );
}

AssistantConversationSummary _assistantSummary(String id, String title) {
  return AssistantConversationSummary(
    id: id,
    title: title,
    status: 'active',
    lastMessageAt: DateTime(2026, 6, 18, 9, 32),
    createdAt: DateTime(2026, 6, 18, 9, 20),
    updatedAt: DateTime(2026, 6, 18, 9, 32),
  );
}

/// [SimulatedAssistantRepository] fake backing `/assistant`.
///
/// [conversation] overrides the default fixture so the generator can capture
/// states a single at-rest route cannot show — a pending tool-write proposal
/// awaiting confirmation, the same proposal after confirmation, and a reply
/// whose tool envelope is worth expanding.
class SimulatedAssistantRepository implements AssistantRepository {
  SimulatedAssistantRepository({this.conversation});

  final AssistantConversation? conversation;

  AssistantConversation get _effectiveConversation =>
      conversation ?? assistantConversationFixture();

  @override
  TaskEither<LucentFailure, AssistantCapabilities> getCapabilities() {
    return TaskEither.right(
      AssistantCapabilities(
        phase: 'production',
        assistantEnabled: true,
        assistantMemoryEnabled: true,
        assistantContext: const AssistantContextAccess(
          healthProfile: true,
          dailyRecords: true,
          sleepRecords: true,
          currentMedicines: true,
        ),
        chatModelConfigured: true,
        interactiveChatReady: true,
        langGraphReady: true,
        streamingSupported: true,
        streamingTransport: 'sse',
        markdownRenderingRecommended: true,
        ragEnabled: true,
        tools: const <AssistantToolCapability>[
          AssistantToolCapability(
            id: 'get_user_profile',
            requiredContextSources: <String>['healthProfile'],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'get_recent_daily_records',
            requiredContextSources: <String>['dailyRecords'],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'list_current_medicines',
            requiredContextSources: <String>['currentMedicines'],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'search_cn_medicine_products',
            requiredContextSources: <String>[],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'get_cn_medicine_detail',
            requiredContextSources: <String>[],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'search_drugbank_passages',
            requiredContextSources: <String>[],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'check_medicine_interaction',
            requiredContextSources: <String>['currentMedicines'],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'reason_over_ontology',
            requiredContextSources: <String>['currentMedicines'],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'sleep_pattern_analysis',
            requiredContextSources: <String>['sleepRecords'],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'propose_create_daily_record',
            requiredContextSources: <String>['dailyRecords'],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'propose_update_daily_record',
            requiredContextSources: <String>['dailyRecords'],
            permittedByUser: true,
            enabled: true,
            implemented: true,
            disabledReason: null,
          ),
          AssistantToolCapability(
            id: 'propose_update_user_settings',
            requiredContextSources: <String>[],
            permittedByUser: false,
            enabled: false,
            implemented: true,
            disabledReason: '你尚未允许助手修改 App 设置。',
          ),
        ],
        updatedAt: DateTime(2026, 6, 18, 9, 0),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, AssistantConversation?> getLatestConversation() =>
      TaskEither.right(_effectiveConversation);

  @override
  TaskEither<LucentFailure, List<AssistantConversationSummary>>
  listRecentConversations() {
    return TaskEither.right(<AssistantConversationSummary>[
      _assistantSummary(_assistantConversationId, '血压波动与用药咨询'),
      _assistantSummary('conv-sleep-20260615', '睡眠时间偏晚怎么调整'),
      _assistantSummary('conv-aspirin-20260611', '阿司匹林肠溶片可以空腹吃吗'),
    ]);
  }

  @override
  TaskEither<LucentFailure, AssistantConversation> openConversation(
    String conversationId,
  ) => TaskEither.right(_effectiveConversation);

  @override
  TaskEither<LucentFailure, bool> clearLatestConversation() =>
      TaskEither.right(true);

  @override
  TaskEither<LucentFailure, void> renameConversation({
    required String conversationId,
    required String title,
  }) => TaskEither.right(null);

  @override
  TaskEither<LucentFailure, void> deleteConversation(String conversationId) =>
      TaskEither.right(null);

  @override
  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  }) async* {
    yield const AssistantGenerationChunkEvent('建议保持每天同一时间服药，');
    yield const AssistantGenerationChunkEvent('并把晨起血压连续记录两周。');
    yield AssistantGenerationResultEvent(
      conversationId: conversationId ?? _assistantConversationId,
      message: AssistantMessage(
        role: AssistantMessageRole.assistant,
        content:
            '建议保持每天同一时间服药，并把晨起血压连续记录两周，'
            '复诊时一并提供给心内科医生参考。',
        createdAt: simulatedNow,
      ),
    );
  }

  @override
  Stream<AssistantGenerationEvent> regenerateLastMessage(
    String conversationId, {
    required void Function(String content) onChunk,
  }) async* {
    const answer =
        '重新分析后的结论：晨起收缩压轻度偏高，暂无需自行调整剂量，'
        '请继续记录并按时复诊。';
    onChunk('重新分析后的结论：');
    yield const AssistantGenerationChunkEvent('重新分析后的结论：');
    onChunk(answer);
    yield const AssistantGenerationChunkEvent(answer);
    yield AssistantGenerationResultEvent(
      conversationId: conversationId,
      message: AssistantMessage(
        role: AssistantMessageRole.assistant,
        content: answer,
        createdAt: simulatedNow,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  }) => TaskEither.right('已按你的确认记录今日血压 138/86 mmHg。');
}

// ── 4. Health sync ──────────────────────────────────────────────────────────

List<HealthMetric> simulatedHealthMetrics() => <HealthMetric>[
  HealthMetric(
    type: HealthMetricType.bloodPressure,
    value: 138,
    unit: 'mmHg',
    secondaryValue: 86,
    secondaryUnit: 'mmHg',
    recordedAt: DateTime(2026, 6, 18, 7, 40),
    source: 'health_connect',
    sourcePlatform: 'android',
  ),
  HealthMetric(
    type: HealthMetricType.heartRate,
    value: 74,
    unit: 'bpm',
    recordedAt: DateTime(2026, 6, 18, 7, 40),
    source: 'health_connect',
    sourcePlatform: 'android',
  ),
  HealthMetric(
    type: HealthMetricType.steps,
    value: 6480,
    unit: '步',
    recordedAt: DateTime(2026, 6, 18, 21, 0),
    source: 'health_connect',
    sourcePlatform: 'android',
  ),
  HealthMetric(
    type: HealthMetricType.sleep,
    value: 6.87,
    unit: '小时',
    recordedAt: DateTime(2026, 6, 18, 7, 0),
    sleepDuration: const Duration(hours: 6, minutes: 52),
    sleepQuality: 'fair',
    deepMinutes: 87,
    lightMinutes: 268,
    remMinutes: 57,
    source: 'health_connect',
    sourcePlatform: 'android',
  ),
  HealthMetric(
    type: HealthMetricType.weight,
    value: 61.4,
    unit: 'kg',
    recordedAt: DateTime(2026, 6, 18, 7, 10),
    source: 'health_connect',
    sourcePlatform: 'android',
  ),
  HealthMetric(
    type: HealthMetricType.bloodOxygen,
    value: 97,
    unit: '%',
    recordedAt: DateTime(2026, 6, 18, 7, 42),
    source: 'health_connect',
    sourcePlatform: 'android',
  ),
];

/// [SimulatedHealthSyncRepository] fake backing `/health-sync`.
class SimulatedHealthSyncRepository implements HealthSyncRepository {
  @override
  bool get isPlatformAvailable => true;

  @override
  Future<HealthPermissionStatus> requestPermissions(
    Set<HealthMetricType> types,
  ) async => HealthPermissionStatus.granted;

  @override
  Future<Set<HealthMetricType>> getAuthorizedTypes() async =>
      const <HealthMetricType>{
        HealthMetricType.bloodPressure,
        HealthMetricType.heartRate,
        HealthMetricType.steps,
        HealthMetricType.sleep,
        HealthMetricType.weight,
        HealthMetricType.bloodOxygen,
      };

  @override
  Future<List<HealthMetric>> fetchMetrics({
    required Set<HealthMetricType> types,
    required DateTime start,
    required DateTime end,
  }) async {
    if (types.isEmpty) return simulatedHealthMetrics();
    return simulatedHealthMetrics()
        .where((metric) => types.contains(metric.type))
        .toList(growable: false);
  }

  /// Non-empty [HealthSyncResult.errors] so the result panel renders real
  /// failure rows instead of an all-clear card.
  @override
  Future<HealthSyncResult> syncToRecords(List<HealthMetric> metrics) async {
    return const HealthSyncResult(
      successCount: 4,
      skippedCount: 1,
      failedCount: 1,
      errors: <String>[
        '2026-06-18 睡眠记录同步失败：睡眠时段与已有记录重叠，已跳过该条。',
        '2026-06-17 血氧记录格式无法识别（缺少二次测量值），请重新采集。',
      ],
    );
  }
}

/// Permanently failed local sync rows for `/mine/sync/failures`.
///
/// That page reads the drift `pendingSyncDaoProvider`, not a repository, so
/// these rows are the content to seed into a fake DAO.
final List<PendingSyncEntry> simulatedPendingSyncFailures = <PendingSyncEntry>[
  PendingSyncEntry(
    id: 'psq-20260618-0001',
    entityType: 'daily_record',
    entityId: 'daily-bp-20260618-0740',
    operation: 'create',
    payload:
        '{"kind":"blood_pressure","value":138,"secondaryValue":86,'
        '"occurredAt":"2026-06-18T07:40:00.000Z"}',
    createdAt: DateTime(2026, 6, 18, 7, 41),
    retryCount: 5,
    maxRetry: 5,
    lastError: 'DioException [badResponse]: status code 409，该时间点已存在血压记录。',
  ),
  PendingSyncEntry(
    id: 'psq-20260617-0002',
    entityType: 'daily_record',
    entityId: 'daily-sleep-20260617',
    operation: 'create',
    payload:
        '{"kind":"sleep","value":6.87,"sleepQuality":"fair",'
        '"occurredAt":"2026-06-17T07:00:00.000Z"}',
    createdAt: DateTime(2026, 6, 17, 7, 2),
    retryCount: 5,
    maxRetry: 5,
    lastError: 'DioException [connectionError]: 连接超时，服务端未确认写入结果。',
  ),
  PendingSyncEntry(
    id: 'psq-20260616-0003',
    entityType: 'medicine_dose_log',
    entityId: 'dose-aspirin-20260616-0800',
    operation: 'update',
    payload: '{"status":"taken","takenAt":"2026-06-16T08:05:00.000Z"}',
    createdAt: DateTime(2026, 6, 16, 8, 6),
    retryCount: 5,
    maxRetry: 5,
    lastError:
        'DioException [badResponse]: status code 400，'
        'VALIDATION_FAILED：takenAt 早于该次提醒的计划时间。',
  ),
];

// ── 5. Medicine search ──────────────────────────────────────────────────────

const List<MedicineSearchResult> _searchResults = <MedicineSearchResult>[
  MedicineSearchResult(
    id: 'cn-amlodipine-5mg',
    source: MedicineSearchSource.cn,
    name: '苯磺酸氨氯地平片',
    subtitle: '5mg（按氨氯地平计）· 国药准字 H20051487 · 辉瑞制药有限公司',
    summary:
        '钙通道阻滞剂，用于高血压、慢性稳定性心绞痛的对症治疗，'
        '每日一次，晨起服用。',
    tags: <String>['降压药', '钙通道阻滞剂', '每日一次'],
    matchType: MedicineSearchMatchType.name,
  ),
  MedicineSearchResult(
    id: 'cn-aspirin-100mg',
    source: MedicineSearchSource.cn,
    name: '阿司匹林肠溶片',
    subtitle: '100mg · 国药准字 H10960313 · 拜耳医药保健有限公司',
    summary:
        '抗血小板聚集，用于降低心肌梗死与缺血性卒中的复发风险，'
        '肠溶衣需整片吞服。',
    tags: <String>['抗血小板', '肠溶片', '心血管'],
    matchType: MedicineSearchMatchType.name,
  ),
  MedicineSearchResult(
    id: 'cn-metformin-500mg',
    source: MedicineSearchSource.cn,
    name: '盐酸二甲双胍片',
    subtitle: '0.5g · 国药准字 H20023370 · 中美上海施贵宝制药有限公司',
    summary: '双胍类降糖药，用于 2 型糖尿病的一线治疗，随餐服用可减轻胃肠道反应。',
    tags: <String>['降糖药', '双胍类', '随餐服用'],
    matchType: MedicineSearchMatchType.ingredient,
  ),
  MedicineSearchResult(
    id: 'cn-losartan-50mg',
    source: MedicineSearchSource.cn,
    name: '氯沙坦钾片',
    subtitle: '50mg · 国药准字 H20000371 · 杭州默沙东制药有限公司',
    summary:
        '血管紧张素Ⅱ受体拮抗剂，用于原发性高血压，'
        '与氨氯地平联用时需关注血钾变化。',
    tags: <String>['降压药', 'ARB', '需查血钾'],
    matchType: MedicineSearchMatchType.ingredient,
  ),
  MedicineSearchResult(
    id: 'drugbank-DB00322',
    source: MedicineSearchSource.drugbank,
    name: 'Amlodipine',
    subtitle: 'DB00322 · Calcium channel blocker · 苯磺酸氨氯地平',
    summary:
        'Dihydropyridine calcium channel blocker that dilates peripheral '
        'arterioles, lowering blood pressure and relieving angina.',
    tags: <String>['Calcium channel blocker', 'Hypertension', 'DB00322'],
    matchType: MedicineSearchMatchType.name,
  ),
];

/// [SimulatedMedicineSearchRepository] fake backing `/medicine/search`.
class SimulatedMedicineSearchRepository implements MedicineSearchRepository {
  /// Returns the same rich result set for any query, so a search screenshot is
  /// never an empty state.
  @override
  TaskEither<LucentFailure, List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) {
    if (source == MedicineSearchSource.drugbank) {
      return TaskEither.right(
        _searchResults
            .where((item) => item.source == MedicineSearchSource.drugbank)
            .toList(growable: false),
      );
    }
    return TaskEither.right(_searchResults);
  }

  @override
  TaskEither<LucentFailure, MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) {
    return TaskEither.right(
      const MedicineSearchSafetyPreview(
        title: '苯磺酸氨氯地平片 5mg',
        conditions: <String>['规格：5mg（按氨氯地平计）', '生产企业：辉瑞制药有限公司'],
        checklist: <String>['确认无二氢吡啶类过敏史', '正在服用氯沙坦钾时需监测血钾'],
      ),
    );
  }
}

// ── 6. Risk check ───────────────────────────────────────────────────────────

MedicineRiskCheckResult simulatedRiskCheckResult() {
  return const MedicineRiskCheckResult(
    overallRiskLevel: MedicineRiskLevel.caution,
    overallRiskScore: 34,
    currentMedicineCount: 3,
    checkedMedicineCount: 3,
    findings: <MedicineRiskFinding>[
      MedicineRiskFinding(
        type: MedicineRiskFindingType.interaction,
        severity: MedicineRiskSeverity.medium,
        context: MedicineRiskFindingContext.none,
        primaryMedicineName: '苯磺酸氨氯地平片',
        secondaryMedicineName: '氯沙坦钾片',
        relatedLabel: '联用降压',
        evidence: '两药联用可增强降压作用，说明书提示需监测血压与血钾水平。',
        recommendation: '联用期间每周至少测量 3 次血压，并关注乏力、头晕等低血压表现。',
      ),
      MedicineRiskFinding(
        type: MedicineRiskFindingType.duplicateIngredient,
        severity: MedicineRiskSeverity.high,
        context: MedicineRiskFindingContext.none,
        primaryMedicineName: '阿司匹林肠溶片',
        secondaryMedicineName: '复方感冒灵颗粒',
        relatedLabel: '重复成分提示',
        evidence: '两者均含解热镇痛成分，同时服用可能增加胃肠道出血风险。',
        recommendation: '感冒期间暂停其中一种，或先咨询药师。',
      ),
    ],
    overallRecommendation:
        '当前用药存在 1 条需重点确认的风险提示，'
        '建议携带本页结果咨询药师或心内科医生。',
  );
}

/// [SimulatedRiskCheckRepository] fake backing `/medicine/risk-check`.
class SimulatedRiskCheckRepository implements MedicineRiskCheckRepository {
  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecords> getRecords() {
    final result = simulatedRiskCheckResult();
    return TaskEither.right(
      MedicineRiskCheckRecords(
        staticRecord: MedicineRiskCheckRecord(
          checkType: MedicineRiskCheckType.static_,
          result: result,
          riskScore: 34,
          riskLevel: MedicineRiskLevel.caution,
          stale: false,
          createdAt: DateTime(2026, 6, 18, 8, 5),
          updatedAt: DateTime(2026, 6, 18, 8, 5),
        ),
        llmRecord: MedicineRiskCheckRecord(
          checkType: MedicineRiskCheckType.llm,
          result: result,
          riskScore: 34,
          riskLevel: MedicineRiskLevel.caution,
          stale: false,
          createdAt: DateTime(2026, 6, 18, 8, 12),
          updatedAt: DateTime(2026, 6, 18, 8, 12),
        ),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecord> runCheck(
    MedicineRiskCheckType type,
  ) {
    return TaskEither.right(
      MedicineRiskCheckRecord(
        checkType: type,
        result: simulatedRiskCheckResult(),
        riskScore: 34,
        riskLevel: MedicineRiskLevel.caution,
        stale: false,
        createdAt: simulatedNow,
        updatedAt: simulatedNow,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) => TaskEither.right(simulatedRiskCheckResult());
}

// ── 7. Legal ────────────────────────────────────────────────────────────────

const String _termsBody = '''
# 服务条款

## 一、服务内容

本应用为个人健康记录工具，提供用药提醒、健康数据记录、健康报告与 AI 辅助解读
等功能。你可以在应用内记录血压、心率、睡眠、用药与饮水量，并随时查看历史趋势。

## 二、账号与安全

你应当妥善保管账号与登录凭证。如发现账号被他人使用，请立即通过应用内的
「意见反馈」联系我们。因你主动泄露凭证导致的损失，本应用不承担责任。

## 三、健康信息免责

应用内展示的药品说明、相互作用提示与 AI 分析结果均来自公开药品资料库或模型
生成，仅供健康参考，**不构成医疗建议**，不能替代执业医师的诊断与处方。

## 四、数据使用

在你开启 AI 摘要功能后，应用会将必要的健康记录发送至服务端用于生成摘要。
你可以在「设置 - 隐私」中随时关闭该功能。

## 五、条款变更

条款如有更新，我们会在应用内以通知形式告知。继续使用即视为接受更新后的条款。
''';

const String _privacyBody = '''
# 隐私政策

## 一、收集的信息

- 你主动填写的基础信息：昵称、出生年份、性别、身高、体重。
- 你记录的健康数据：血压、心率、血氧、睡眠、步数、饮水量、用药记录。
- 设备与日志信息：设备型号、系统版本、崩溃日志与请求 Trace ID。

## 二、信息的使用

上述信息仅用于生成你的个人健康记录与报告。除非你明确开启「数据共享同意」，
我们不会将可识别的健康数据用于研究或第三方分析。

## 三、信息的存储

健康数据默认保存在你的设备本地数据库中；开启云同步后，数据会加密传输并
存储于服务器，保存期限为你注销账号后 30 日内删除。

## 四、你的权利

你可以随时导出、修正或删除全部健康记录，也可以在设置中注销账号。
注销后所有云端数据将在 30 日内不可恢复地删除。

## 五、联系我们

隐私相关疑问请通过应用内「意见反馈」或 support@lumos.app 与我们联系。
''';

const String _disclaimerBody = '''
# 医疗免责声明

## 一、非医疗诊断

本应用提供的全部内容，包括药品说明书、相互作用提示、风险检查结果与 AI 解读，
**均不构成医疗诊断、治疗建议或处方**。任何用药调整都应由执业医师决定。

## 二、数据准确性

药品资料来自公开说明书库与 DrugBank，可能存在滞后或缺失。若说明书内容与本应用
展示不一致，请以药品实物说明书和医生意见为准。

## 三、紧急情况

如出现胸痛、呼吸困难、意识模糊、严重过敏或大量出血等急症表现，
请立即拨打 120 或前往最近的急诊科，不要依赖本应用的信息自行处理。

## 四、风险自担

你基于本应用内容做出的健康决策由你本人承担相应后果。
''';

const Map<LegalDocType, String> _legalBodies = <LegalDocType, String>{
  LegalDocType.terms: _termsBody,
  LegalDocType.privacy: _privacyBody,
  LegalDocType.disclaimer: _disclaimerBody,
  LegalDocType.minorProtection:
      '# 未成年人保护规则\n\n'
      '本应用面向 18 周岁以上用户。未满 18 周岁的用户应在监护人陪同下使用，'
      '并由监护人代为确认健康数据的收集与使用范围。',
  LegalDocType.sdkList:
      '# 第三方 SDK 目录\n\n'
      '| SDK 名称 | 用途 | 收集信息 |\n| --- | --- | --- |\n'
      '| 推送服务 | 提醒送达 | 设备标识 |\n'
      '| 崩溃统计 | 稳定性分析 | 崩溃堆栈、设备型号 |\n',
  LegalDocType.permissions:
      '# 权限使用说明\n\n'
      '- 通知权限：用于送达用药提醒。\n'
      '- 健康数据权限：用于导入步数、睡眠与心率。\n'
      '- 相机权限：用于扫描药盒条形码与说明书文字。',
  LegalDocType.accountCancellation:
      '# 账号注销说明\n\n'
      '在「设置 - 账号安全 - 注销账号」提交后，我们会验证你的登录密码。'
      '注销完成后，本地与云端健康数据将在 30 日内删除且不可恢复。',
};

const List<LegalDocumentSummary> _legalSummaries = <LegalDocumentSummary>[
  LegalDocumentSummary(
    docType: LegalDocType.terms,
    title: '服务条款',
    updatedAt: '2026-05-20',
  ),
  LegalDocumentSummary(
    docType: LegalDocType.privacy,
    title: '隐私政策',
    updatedAt: '2026-05-20',
  ),
  LegalDocumentSummary(
    docType: LegalDocType.disclaimer,
    title: '医疗免责声明',
    updatedAt: '2026-04-08',
  ),
  LegalDocumentSummary(
    docType: LegalDocType.minorProtection,
    title: '未成年人保护规则',
    updatedAt: '2026-03-12',
  ),
  LegalDocumentSummary(
    docType: LegalDocType.sdkList,
    title: '第三方 SDK 目录',
    updatedAt: '2026-05-20',
  ),
  LegalDocumentSummary(
    docType: LegalDocType.permissions,
    title: '权限使用说明',
    updatedAt: '2026-05-20',
  ),
  LegalDocumentSummary(
    docType: LegalDocType.accountCancellation,
    title: '账号注销说明',
    updatedAt: '2026-02-26',
  ),
];

/// [SimulatedLegalRepository] fake backing `/legal` and `/legal/<doc>`.
class SimulatedLegalRepository implements LegalRepository {
  @override
  TaskEither<LucentFailure, List<LegalDocumentSummary>> findAll() =>
      TaskEither.right(_legalSummaries);

  /// Never 404s: any doc type resolves to a populated Markdown body.
  @override
  TaskEither<LucentFailure, LegalDocument> findOne(LegalDocType docType) {
    final summary = _legalSummaries.firstWhere(
      (item) => item.docType == docType,
      orElse: () => _legalSummaries.first,
    );
    return TaskEither.right(
      LegalDocument(
        docType: docType,
        title: summary.title,
        content: _legalBodies[docType] ?? _termsBody,
        updatedAt: summary.updatedAt,
      ),
    );
  }
}

// ── 8. Support ──────────────────────────────────────────────────────────────

/// FAQ accordion content for `/settings/help`.
///
/// The help page reads Markdown from `assets/faq/`, so this list is the shape a
/// fake asset loader should serve.
const List<({String question, String answer})> simulatedFaqEntries =
    <({String question, String answer})>[
      (
        question: '用药提醒没有按时弹出怎么办？',
        answer:
            '请先在系统设置中确认已允许本应用发送通知，'
            '再检查「用药」页的提醒是否处于开启状态。'
            '部分手机在省电模式下会延迟本地通知，建议将本应用加入后台白名单。',
      ),
      (
        question: '血压记录可以修改或删除吗？',
        answer:
            '可以。在「记录」页找到对应条目，左滑即可修改或删除；'
            '云端同步的记录会在下次同步时一并更新。',
      ),
      (
        question: '为什么药品详情页显示暂无说明书内容？',
        answer:
            '部分手动录入的药品没有匹配到标准说明书资料。'
            '你可以在「用药 - 药品搜索」中按名称或条形码重新匹配，'
            '匹配成功后会显示完整说明书。',
      ),
      (
        question: 'AI 分析结果可以直接用来调整用药吗？',
        answer:
            '不可以。AI 分析仅基于你记录的数据与公开药品资料生成健康参考，'
            '不构成医疗建议。任何用药调整都应先咨询执业医师或药师。',
      ),
      (
        question: '如何导出我的健康数据？',
        answer:
            '进入「我的 - 数据导出」，选择时间范围与数据类型后即可导出 CSV 文件，'
            '文件会保存在系统下载目录。',
      ),
    ];

/// [SimulatedSupportRepository] fake backing the About/Help pages.
class SimulatedSupportRepository implements SupportRepository {
  @override
  TaskEither<LucentFailure, AppInfo?> getAppInfo() {
    return TaskEither.right(
      const AppInfo(
        minClientVersion: '0.9.0',
        latestVersion: '1.4.2',
        downloadUrl: 'https://lumos.app/download',
        supportEmail: 'support@lumos.app',
      ),
    );
  }
}

// ── 9. User settings ────────────────────────────────────────────────────────

/// [SimulatedUserSettingsRepository] fake backing `/settings`.
class SimulatedUserSettingsRepository implements UserSettingsRepository {
  @override
  TaskEither<LucentFailure, UserSettings> getSettings() {
    return TaskEither.right(
      const UserSettings(
        aiSummariesEnabled: true,
        dataSharingConsent: false,
        assistantEnabled: true,
        assistantMemoryEnabled: true,
        waterTargetCount: 8,
        assistantContext: AssistantContextSettings(
          healthProfile: true,
          dailyRecords: true,
          sleepRecords: true,
          currentMedicines: true,
        ),
        updatedAt: '2026-06-18T01:30:00.000Z',
        passwordReauthenticationRequired: true,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, UserSettings> updateSettings({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  }) {
    return TaskEither.right(
      UserSettings(
        aiSummariesEnabled: aiSummariesEnabled,
        dataSharingConsent: dataSharingConsent,
        assistantEnabled: assistantEnabled,
        assistantMemoryEnabled: assistantMemoryEnabled,
        waterTargetCount: waterTargetCount,
        assistantContext: AssistantContextSettings(
          healthProfile: assistantContext.healthProfile ?? true,
          dailyRecords: assistantContext.dailyRecords ?? true,
          sleepRecords: assistantContext.sleepRecords ?? true,
          currentMedicines: assistantContext.currentMedicines ?? true,
        ),
        updatedAt: '2026-06-18T01:30:00.000Z',
        passwordReauthenticationRequired: true,
      ),
    );
  }
}

// ── 10. Scan ────────────────────────────────────────────────────────────────

const List<ScanSearchResult> _scanResults = <ScanSearchResult>[
  ScanSearchResult(
    id: 'cn-amlodipine-5mg',
    name: '苯磺酸氨氯地平片',
    subtitle: '5mg · 国药准字 H20051487 · 辉瑞制药有限公司',
  ),
  ScanSearchResult(
    id: 'cn-aspirin-100mg',
    name: '阿司匹林肠溶片',
    subtitle: '100mg · 国药准字 H10960313 · 拜耳医药保健有限公司',
  ),
  ScanSearchResult(
    id: 'cn-metformin-500mg',
    name: '盐酸二甲双胍片',
    subtitle: '0.5g · 国药准字 H20023370 · 中美上海施贵宝制药有限公司',
  ),
];

/// [SimulatedScanRepository] fake backing the barcode/OCR/AI scan flows.
class SimulatedScanRepository implements ScanRepository {
  @override
  TaskEither<LucentFailure, List<ScanSearchResult>> search(String query) =>
      TaskEither.right(_scanResults);

  @override
  TaskEither<LucentFailure, String> uploadImage({
    required List<int> bytes,
    required String contentType,
    int? sizeBytes,
    String? fileName,
  }) => TaskEither.right(
    'https://cdn.lumos.app/scan/2026-06-18/chenjing-medicine-box.jpg',
  );

  @override
  TaskEither<LucentFailure, MedicineRecognitionResult> recognizeMedicine(
    String imageUrl,
  ) => TaskEither.right(
    const MedicineRecognitionResult(
      name: '苯磺酸氨氯地平片',
      approvalNumber: '国药准字H20051487',
    ),
  );
}

// ── 11. Medicine detail ─────────────────────────────────────────────────────

const List<MedicineDetail> _medicineDetails = <MedicineDetail>[
  MedicineDetail(
    id: 'cn-amlodipine-5mg',
    source: 'cn',
    name: '苯磺酸氨氯地平片',
    subtitle: '5mg（按氨氯地平计）· 国药准字 H20051487',
    kind: 'cnProduct',
    approvalNumber: '国药准字H20051487',
    manufacturer: '辉瑞制药有限公司',
    packageSpec: '5mg × 7 片/盒',
    brandName: '络活喜',
    ingredients:
        '本品主要成分为苯磺酸氨氯地平，辅料为微晶纤维素、'
        '无水磷酸氢钙、羧甲淀粉钠、硬脂酸镁。',
    properties: '本品为白色或类白色片，除去包衣后显白色。',
    indications:
        '高血压：可单独用药，也可与其他抗高血压药物合用。'
        '慢性稳定性心绞痛及变异型心绞痛：可单独用药，也可与其他抗心绞痛药物合用。',
    dosage:
        '口服，起始剂量为 5mg，每日一次，根据血压控制情况可增至 10mg，'
        '每日一次。老年患者或肝功能不全者起始剂量宜为 2.5mg，每日一次。',
    adverseReactions:
        '常见不良反应为踝部水肿、面部潮红、头痛、头晕、心悸；'
        '少见牙龈增生、皮疹。多数反应为轻至中度且可自行缓解。',
    contraindications:
        '对二氢吡啶类钙通道阻滞剂过敏者禁用；'
        '严重低血压、休克患者禁用。',
    precautions:
        '肝功能受损者半衰期延长，应慎用并减量；'
        '用药期间应定期监测血压与心率；停药前应逐渐减量，避免血压反跳。',
    pharmacologyToxicology:
        '本品为二氢吡啶类钙通道阻滞剂，'
        '选择性抑制钙离子跨膜进入血管平滑肌和心肌细胞，'
        '扩张外周小动脉，降低外周血管阻力从而降低血压。',
    pharmacokinetics:
        '口服吸收良好，血药浓度 6-12 小时达峰；'
        '血浆蛋白结合率约 93%；半衰期 35-50 小时；'
        '主要经肝脏代谢为无活性代谢物，经尿液排出。',
    overdose:
        '过量可导致显著而持久的周围血管扩张与反射性心动过速，'
        '应立即就医，必要时给予血管收缩剂与静脉输液支持。',
    storage: '遮光、密封，在干燥处保存。',
    validityPeriod: '36 个月',
    barcode: '6901234567892',
    nationalDrugCode: '86901234000125',
    sourceUrl: 'https://www.nmpa.gov.cn/',
    groups: <String>['approved', 'small molecule'],
    categories: <String>['抗高血压药', '钙通道阻滞剂'],
    atcCodes: <String>['C08CA01'],
    synonyms: <String>['氨氯地平', 'Amlodipine', '络活喜'],
    foodInteractions: <String>['葡萄柚汁可能升高本品血药浓度，建议避免同服。'],
    drugInteractions: <MedicineDetailInteraction>[
      MedicineDetailInteraction(
        drugbankId: 'DB00568',
        description: '与氯沙坦钾联用可增强降压作用，需监测血压与血钾。',
      ),
      MedicineDetailInteraction(
        drugbankId: 'DB00331',
        description:
            '与辛伐他汀联用可升高辛伐他汀暴露量，'
            '联用时辛伐他汀剂量不宜超过 20mg/日。',
      ),
    ],
    targets: <MedicineDetailTarget>[
      MedicineDetailTarget(
        name: 'Voltage-dependent L-type calcium channel subunit alpha-1C',
        geneName: 'CACNA1C',
        uniprotId: 'Q13936',
        species: 'Human',
        pdbIds: <String>['6JP5', '6JP8'],
        actions: <String>['blocker'],
        relationKind: 'target',
      ),
    ],
    externalIdentifiers: <MedicineDetailExternalReference>[
      MedicineDetailExternalReference(
        resource: 'PubChem Compound',
        value: '2162',
      ),
      MedicineDetailExternalReference(resource: 'ChEBI', value: 'CHEBI:2668'),
    ],
    externalLinks: <MedicineDetailExternalReference>[
      MedicineDetailExternalReference(
        resource: 'Drugs.com',
        value: 'https://www.drugs.com/amlodipine.html',
      ),
    ],
    structure: MedicineStructure(
      formula: 'C20H25ClN2O5',
      iupacName:
          '3-O-ethyl 5-O-methyl 2-(2-aminoethoxymethyl)-'
          '4-(2-chlorophenyl)-6-methyl-1,4-dihydropyridine-3,5-dicarboxylate',
      smiles: 'CCOC(=O)C1=C(C)NC(C)=C(C(=O)OC)C1c1ccccc1Cl',
      inchiKey: 'HTIQEAQVCYTUBX-UHFFFAOYSA-N',
      molecularWeight: 408.9,
      exactMass: 408.14,
      logP: 3.0,
      polarSurfaceArea: 99.9,
      pkaStrongestBasic: 8.6,
      physiologicalCharge: 1,
      atomCount: 28,
      ringCount: 2,
      rotatableBondCount: 9,
      acceptorCount: 7,
      donorCount: 2,
      ruleOfFive: 1,
      veberRule: 1,
      ghoseFilter: 1,
      salts: <String>['苯磺酸盐', '马来酸盐'],
    ),
  ),
  MedicineDetail(
    id: 'cn-aspirin-100mg',
    source: 'cn',
    name: '阿司匹林肠溶片',
    subtitle: '100mg · 国药准字 H10960313',
    kind: 'cnProduct',
    approvalNumber: '国药准字H10960313',
    manufacturer: '拜耳医药保健有限公司',
    packageSpec: '100mg × 30 片/盒',
    brandName: '拜阿司匹灵',
    ingredients:
        '本品主要成分为阿司匹林，辅料为玉米淀粉、药用滑石粉、'
        '邻苯二甲酸羟丙甲纤维素酯。',
    properties: '本品为肠溶包衣片，除去包衣后显白色。',
    indications:
        '用于降低急性心肌梗死疑似患者的发病风险；'
        '预防心肌梗死复发；降低短暂性脑缺血发作及缺血性卒中的复发风险。',
    dosage:
        '口服，肠溶片应整片吞服，一次 100mg，一日一次，'
        '建议早餐后服用。',
    adverseReactions:
        '常见胃肠道不适、恶心、上腹痛；'
        '长期使用可能引起胃肠道出血、皮下出血、耳鸣。',
    contraindications:
        '对阿司匹林或其他非甾体抗炎药过敏者禁用；'
        '活动性消化性溃疡、血友病、严重肝肾功能不全者禁用。',
    precautions:
        '服药期间避免同时使用其他含解热镇痛成分的感冒药；'
        '术前 5-7 天应告知医生正在服用本品；避免与酒精同服。',
    pharmacologyToxicology:
        '本品不可逆地抑制血小板环氧合酶，'
        '阻断血栓素 A2 生成，从而抑制血小板聚集，作用持续血小板整个生命周期。',
    pharmacokinetics:
        '口服后主要在胃和小肠上部吸收，'
        '肠溶片达峰时间约 3-6 小时；血浆蛋白结合率 80%-90%；'
        '经肝脏代谢，由肾脏排出。',
    overdose: '过量可引起耳鸣、眩晕、呼吸急促、代谢性酸中毒，需立即就医。',
    storage: '遮光、密封，在干燥处保存。',
    validityPeriod: '36 个月',
    barcode: '6901234567908',
    nationalDrugCode: '86901234000132',
    groups: <String>['approved', 'small molecule'],
    categories: <String>['抗血小板药', '非甾体抗炎药'],
    atcCodes: <String>['B01AC06', 'N02BA01'],
    synonyms: <String>['乙酰水杨酸', 'Aspirin', '拜阿司匹灵'],
    foodInteractions: <String>['与酒精同服会增加胃肠道出血风险。'],
    drugInteractions: <MedicineDetailInteraction>[
      MedicineDetailInteraction(
        drugbankId: 'DB00642',
        description: '与布洛芬联用可能削弱阿司匹林的抗血小板作用。',
      ),
    ],
    targets: <MedicineDetailTarget>[
      MedicineDetailTarget(
        name: 'Prostaglandin G/H synthase 1',
        geneName: 'PTGS1',
        uniprotId: 'P23219',
        species: 'Human',
        pdbIds: <String>['1EQG', '1PTH'],
        actions: <String>['inhibitor'],
        relationKind: 'target',
      ),
    ],
    externalIdentifiers: <MedicineDetailExternalReference>[
      MedicineDetailExternalReference(
        resource: 'PubChem Compound',
        value: '2244',
      ),
    ],
    externalLinks: <MedicineDetailExternalReference>[
      MedicineDetailExternalReference(
        resource: 'Drugs.com',
        value: 'https://www.drugs.com/aspirin.html',
      ),
    ],
    structure: MedicineStructure(
      formula: 'C9H8O4',
      molecularWeight: 180.16,
      exactMass: 180.04,
      logP: 1.2,
      polarSurfaceArea: 63.6,
      pkaStrongestAcidic: 3.5,
      atomCount: 13,
      ringCount: 1,
      rotatableBondCount: 2,
      acceptorCount: 4,
      donorCount: 1,
      ruleOfFive: 1,
      veberRule: 1,
      salts: <String>['赖氨酸盐', '钙盐'],
    ),
  ),
];

/// Fake backing `/medicine/detail/<source>/<id>`.
///
/// The detail page does **not** go through a repository interface — it watches
/// `medicineDetailProvider`, which constructs a `MedicineDetailRemoteDataSource`
/// directly. This class mirrors that datasource's read shape
/// (`fetchDetail` / `fetchSequences`) so a screenshot run can inject populated
/// data at the same seam.
class SimulatedMedicineDetailRepository {
  /// Always succeeds, so any deep link into a medicine detail page is populated.
  Future<MedicineDetail> fetchDetail({
    required String id,
    required String source,
  }) async {
    final match = _medicineDetails.where((item) => item.source == source).first;
    return MedicineDetail(
      id: id,
      source: source,
      name: match.name,
      subtitle: match.subtitle,
      kind: match.kind,
      approvalNumber: match.approvalNumber,
      manufacturer: match.manufacturer,
      packageSpec: match.packageSpec,
      brandName: match.brandName,
      ingredients: match.ingredients,
      properties: match.properties,
      indications: match.indications,
      dosage: match.dosage,
      adverseReactions: match.adverseReactions,
      contraindications: match.contraindications,
      precautions: match.precautions,
      pharmacologyToxicology: match.pharmacologyToxicology,
      pharmacokinetics: match.pharmacokinetics,
      overdose: match.overdose,
      storage: match.storage,
      validityPeriod: match.validityPeriod,
      barcode: match.barcode,
      nationalDrugCode: match.nationalDrugCode,
      sourceUrl: match.sourceUrl,
      groups: match.groups,
      categories: match.categories,
      atcCodes: match.atcCodes,
      synonyms: match.synonyms,
      foodInteractions: match.foodInteractions,
      drugInteractions: match.drugInteractions,
      targets: match.targets,
      externalIdentifiers: match.externalIdentifiers,
      externalLinks: match.externalLinks,
      structure: match.structure,
    );
  }

  /// Empty sequence payload: these two medicines are small molecules with no
  /// sequence data upstream.
  Future<MedicineSequences> fetchSequences({
    required String id,
    required String source,
  }) async => MedicineSequences(id: id, source: source);
}
