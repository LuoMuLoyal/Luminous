// Extra screenshot surfaces for the assistant + medicine-image flows.
//
// The catalog covers one shot per route, so it has a single assistant entry.
// These fixtures drive the *states* that a single route cannot show at rest:
// a pending tool-write proposal awaiting confirmation, the same proposal after
// confirmation, an expanded tool-source strip, and the medicine-box photo
// recognition dialog.
//
// Every shape here mirrors the real contract (`AssistantProposedAction`,
// `AssistantProposalPreviewField`, `AssistantToolDetail`, `MedicineMatchResult`),
// and the tool ids are the ones `localizeToolName` actually maps.
import 'package:clock/clock.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';

/// The user turn that triggers a write tool (`propose_create_daily_record`).
const String assistantWritePrompt = '帮我记一下，今天早上 7 点 40 血压 138/86，静息心率 72。';

/// The assistant reply carrying a *pending* `create_daily_record` proposal.
///
/// This is the confirmation gate the user asked to see: the model does not write
/// the record itself, it proposes one and waits for an explicit confirm.
///
/// `expiresAt` is anchored to the real clock (30 min out) rather than a fixed
/// date: [AssistantProposedAction.isExpired] compares against `clock.now()`, and
/// a hardcoded timestamp would render the card expired — and disable the very
/// confirm button the screenshot exists to show.
AssistantMessage buildAssistantPendingWriteMessage() {
  final proposedAt = clock.now();
  return AssistantMessage(
    role: AssistantMessageRole.assistant,
    content:
        '我看到你想补记今天早上的血压。我已经整理好一条草稿，'
        '确认后才会写入你的每日记录，现在还没有保存。',
    createdAt: DateTime(2026, 6, 18, 9, 34),
    usedTools: const <String>[
      'get_recent_daily_records',
      'propose_create_daily_record',
    ],
    toolDetails: const <AssistantToolDetail>[
      AssistantToolDetail(
        name: 'propose_create_daily_record',
        label: '创建每日记录（待确认）',
        coverageStatus: 'ok',
        confidenceLevel: 'high',
        disclaimer: '该操作需要你确认后才会写入，未确认前不会改动任何记录。',
        sourceTables: <String>['daily_records'],
      ),
    ],
    proposedActions: <AssistantProposedAction>[
      AssistantProposedAction(
        id: 'proposal-sim-create-bp-20260618',
        type: AssistantProposedActionType.createDailyRecord,
        title: '新建一条血压记录',
        summary: '2026-06-18 07:40 · 血压 138/86 mmHg · 静息心率 72 次/分',
        reason: '你说「帮我记一下」，所以我准备了这条草稿，没有直接写入。',
        previewFields: const <AssistantProposalPreviewField>[
          AssistantProposalPreviewField(label: '类型', value: '血压'),
          AssistantProposalPreviewField(label: '时间', value: '今天 07:40'),
          AssistantProposalPreviewField(label: '数值', value: '138/86'),
          AssistantProposalPreviewField(label: '单位', value: 'mmHg'),
          AssistantProposalPreviewField(label: '来源', value: '手动记录'),
        ],
        target: const AssistantProposalTarget(
          kind: 'daily_record',
          label: '每日记录 · 血压',
          matchedBy: <String>['occurredAt', 'kind'],
        ),
        constraints: const <String>[
          '确认后写入你的每日记录，可在「记录」页查看与修改。',
          '同一时间点已存在血压记录时会改为更新，而不是新增重复记录。',
          'AI 不提供诊断；如数值异常请以医生意见为准。',
        ],
        expiresAt: proposedAt.add(const Duration(minutes: 30)),
        payloadVersion: 1,
        payload: const AssistantCreateDailyRecordProposalPayload(
          draft: AssistantCreateDailyRecordDraft(
            kind: 'bloodPressure',
            occurredAt: '2026-06-18T07:40:00+08:00',
            title: '晨起血压',
            value: '138/86',
            unit: 'mmHg',
            note: '静息心率 72 次/分，服药前测量。',
            payload: <String, dynamic>{
              'systolic': 138,
              'diastolic': 86,
              'heartRate': 72,
            },
          ),
        ),
      ),
    ],
  );
}

/// The same proposal after the user confirmed it (`executionState.confirmed`).
///
/// The backend applies the write server-side when the proposal is approved
/// (`confirmProposals`), and the card flips to the confirmed state — copy
/// included, so the body no longer claims the draft is unsaved.
AssistantMessage buildAssistantConfirmedWriteMessage() {
  final pending = buildAssistantPendingWriteMessage();
  return pending.copyWith(
    content:
        '已根据你的确认写入这条血压记录，并同步到今日概览。'
        '如果数值或时间需要调整，可以直接在记录详情里修改。',
    createdAt: DateTime(2026, 6, 18, 9, 35),
    proposedActions: pending.proposedActions
        .map(
          (proposal) => proposal.copyWith(
            summary: '2026-06-18 07:40 · 血压 138/86 mmHg · 静息心率 72 次/分（已写入）',
            reason: '已按你的确认写入每日记录，可在「记录」页查看与修改。',
            executionState: AssistantProposalExecutionState.confirmed,
            backendStatus: 'approved',
          ),
        )
        .toList(growable: false),
  );
}

/// An assistant reply with a rich, *expanded*-worthy tool envelope.
///
/// Carries the F-14 confidence note, source version and a traceable citation so
/// the source strip's expanded body has something real to show.
AssistantMessage buildAssistantToolSourceMessage() {
  return AssistantMessage(
    role: AssistantMessageRole.assistant,
    content:
        '「苯磺酸氨氯地平片」与「阿司匹林肠溶片」之间没有明确需要避免的相互作用，'
        '但两者联用时建议固定服药时间并留意胃部不适。',
    createdAt: DateTime(2026, 6, 18, 9, 30),
    usedTools: const <String>[
      'get_current_medicines',
      'search_cn_medicine_products',
      'search_drugbank_passages',
      'reason_over_ontology',
    ],
    toolDetails: const <AssistantToolDetail>[
      AssistantToolDetail(
        name: 'get_current_medicines',
        label: '当前用药',
        coverageStatus: 'ok',
        confidenceLevel: 'high',
        disclaimer: '数据来自你本人当前用药清单，共 3 种。',
        sourceTables: <String>['health_context_current_medicines'],
      ),
      AssistantToolDetail(
        name: 'search_cn_medicine_products',
        label: '药品说明书检索',
        coverageStatus: 'ok',
        confidenceLevel: 'high',
        disclaimer: '药品资料来自国家药品说明书库，仅供健康参考，不替代医生诊断。',
        sourceTables: <String>['leaflet:cn_drug_instructions'],
        sourceVersion: 'cn-leaflet-2026.06',
        confidenceNote: '说明书条目完整，未发现版本冲突。',
      ),
      AssistantToolDetail(
        name: 'search_drugbank_passages',
        label: 'DrugBank 段落检索',
        coverageStatus: 'partial',
        coverageReason: '阿司匹林肠溶片的相互作用条目在本地药品库中覆盖不完整。',
        confidenceLevel: 'medium',
        confidenceReason: '仅命中 2 条相关段落，另有 1 条来自旧版本。',
        ambiguities: <String>['未匹配到与氯沙坦钾的联合用药记录'],
        sourceTables: <String>['qa:drugbank_drug_interactions'],
        disclaimer: '相互作用结果基于药品资料库，具体用药方案请遵医嘱。',
      ),
      AssistantToolDetail(
        name: 'reason_over_ontology',
        label: '本体推理',
        coverageStatus: 'ok',
        confidenceLevel: 'medium',
        disclaimer: '结论由药物相互作用本体推理得出，可直接回溯到来源行。',
        sourceTables: <String>['derived:ontology_assertions'],
        citations: <AssistantToolCitation>[
          AssistantToolCitation(
            id: 'lucent:drugbank_drugs/DB00381/drug_interactions/DB00945',
            entityType: 'drug_interaction',
            sourceDocument: 'DrugBank 5.1.14',
            sourceLocation: 'drug_interactions[DB00945]',
            sourceQuote:
                'No significant interaction is expected between amlodipine and aspirin.',
            confidence: 0.86,
            sequenceId: 41207,
            checksum: 'sha256:4f9c1a7e…',
          ),
        ],
      ),
    ],
  );
}

// ── Conversations ───────────────────────────────────────────────────────────

/// Wraps [messages] in a conversation record the repository can return.
AssistantConversation buildAssistantConversation({
  required List<AssistantMessage> messages,
}) {
  return AssistantConversation(
    id: 'conv-sim-write-20260618',
    title: '补记晨起血压',
    status: 'active',
    lastMessageAt: messages.last.createdAt,
    createdAt: messages.first.createdAt,
    updatedAt: messages.last.createdAt,
    messages: messages,
  );
}

/// A conversation whose last assistant turn carries a **pending** write proposal.
AssistantConversation buildAssistantPendingWriteConversation() {
  const prompt = assistantWritePrompt;
  final reply = buildAssistantPendingWriteMessage();
  return buildAssistantConversation(
    messages: <AssistantMessage>[
      AssistantMessage(
        role: AssistantMessageRole.user,
        content: prompt,
        createdAt: DateTime(2026, 6, 18, 9, 33),
      ),
      reply,
    ],
  );
}

/// The same thread after the user confirmed the write server-side.
AssistantConversation buildAssistantConfirmedWriteConversation() {
  final reply = buildAssistantConfirmedWriteMessage();
  return buildAssistantConversation(
    messages: <AssistantMessage>[
      AssistantMessage(
        role: AssistantMessageRole.user,
        content: assistantWritePrompt,
        createdAt: DateTime(2026, 6, 18, 9, 33),
      ),
      reply,
    ],
  );
}

/// A conversation whose last assistant turn carries a tool envelope with a
/// traceable citation — the payload the source strip's expanded body renders.
AssistantConversation buildAssistantToolSourceConversation() {
  return buildAssistantConversation(
    messages: <AssistantMessage>[
      AssistantMessage(
        role: AssistantMessageRole.user,
        content: '苯磺酸氨氯地平片和阿司匹林肠溶片一起吃要注意什么？',
        createdAt: DateTime(2026, 6, 18, 9, 29),
      ),
      buildAssistantToolSourceMessage(),
    ],
  );
}

/// A conversation whose previous answer was regenerated and is now greyed out
/// with the「已替换」label (F-5b).
AssistantConversation buildAssistantReplacedConversation() {
  return buildAssistantConversation(
    messages: <AssistantMessage>[
      AssistantMessage(
        role: AssistantMessageRole.user,
        content: '最近早上量的血压都是 138/86 左右，这样正常吗？',
        createdAt: DateTime(2026, 6, 18, 9, 20),
      ),
      AssistantMessage(
        role: AssistantMessageRole.assistant,
        content:
            '晨起收缩压 138 mmHg 属于 1 级高血压的边界值，'
            '建议先观察一周再决定是否调整用药。',
        createdAt: DateTime(2026, 6, 18, 9, 21),
        // The *superseded* answer carries the flag: regenerating appends a new
        // answer and greys out the one it replaced (F-5b).
        replaced: true,
      ),
      AssistantMessage(
        role: AssistantMessageRole.assistant,
        content:
            '重新分析后的结论：晨起收缩压轻度偏高，暂无需自行调整剂量，'
            '请继续记录并按时复诊。',
        createdAt: DateTime(2026, 6, 18, 9, 22),
      ),
    ],
  );
}

// ── Medicine-box photo recognition ──────────────────────────────────────────

/// Simulated OCR candidates for a photographed 苯磺酸氨氯地平片 box.
///
/// `matchType` is the real enum the result dialog switches on; `confidence` is
/// only used to order candidates, never displayed as a percentage.
List<MedicineMatchResult> simulatedBoxScanResults() {
  return const <MedicineMatchResult>[
    MedicineMatchResult(
      name: '苯磺酸氨氯地平片',
      approvalNumber: '国药准字H20051487',
      id: 'cn-amlodipine-5mg',
      confidence: 0.94,
      matchType: MedicineMatchType.approvalNumber,
    ),
    MedicineMatchResult(
      name: '苯磺酸左氨氯地平片',
      approvalNumber: '国药准字H20083460',
      id: 'cn-levamlodipine-25mg',
      confidence: 0.71,
      matchType: MedicineMatchType.nameFuzzy,
    ),
    MedicineMatchResult(
      name: '氨氯地平阿托伐他汀钙片',
      approvalNumber: '国药准字HJ20170307',
      id: 'cn-amlodipine-atorvastatin',
      confidence: 0.58,
      matchType: MedicineMatchType.nameFuzzy,
    ),
  ];
}
