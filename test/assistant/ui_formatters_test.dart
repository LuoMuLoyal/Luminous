import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

AssistantProposedAction _p(AssistantProposalExecutionState s) {
  return AssistantProposedAction(
    id: 'p1',
    type: AssistantProposedActionType.createDailyRecord,
    title: 'T',
    summary: 'S',
    reason: null,
    previewFields: const [],
    target: const AssistantProposalTarget(kind: 'record', label: 'test'),
    constraints: const [],
    expiresAt: null,
    payloadVersion: 1,
    payload: const AssistantCreateDailyRecordProposalPayload(
      draft: AssistantCreateDailyRecordDraft(
        kind: 'meal',
        occurredAt: '2026-06-15',
        title: null,
        value: null,
        unit: null,
        note: null,
        payload: null,
      ),
    ),
    executionState: s,
  );
}

void main() {
  setUpAll(initializeDateFormatting);

  group('proposalStateColor', () {
    final colors = appThemeData(appDefaultThemeFamily, Brightness.light).colors;
    test('pending → primary', () {
      expect(
        proposalStateColor(colors, _p(AssistantProposalExecutionState.pending)),
        colors.primary,
      );
    });
    test('confirmed → secondary', () {
      expect(
        proposalStateColor(
          colors,
          _p(AssistantProposalExecutionState.confirmed),
        ),
        colors.secondary,
      );
    });
    test('dismissed → mutedForeground', () {
      expect(
        proposalStateColor(
          colors,
          _p(AssistantProposalExecutionState.dismissed),
        ),
        colors.mutedForeground,
      );
    });
    test('failed → destructive', () {
      expect(
        proposalStateColor(colors, _p(AssistantProposalExecutionState.failed)),
        colors.destructive,
      );
    });
    test('covers all states', () {
      for (final s in AssistantProposalExecutionState.values) {
        expect(proposalStateColor(colors, _p(s)), isA<Color>());
      }
    });
  });

  group('sendErrorIcon', () {
    test('streamInterrupted → wifiOff', () {
      expect(
        sendErrorIcon(AssistantSendErrorType.streamInterrupted),
        SemanticIcons.statusUnavailable,
      );
    });
    test('null → circleAlert', () {
      expect(sendErrorIcon(null), SemanticIcons.statusError);
    });
    test('covers all types', () {
      for (final t in AssistantSendErrorType.values) {
        expect(sendErrorIcon(t), isA<IconData>());
      }
    });
  });

  group('formatAssistantDateTimeShort', () {
    test('uses the Chinese short date pattern for zh locales', () {
      expect(
        formatAssistantDateTimeShort(
          const Locale('zh'),
          DateTime(2026, 8, 17, 10, 5),
        ),
        '8月17日 10:05',
      );
    });

    test('uses the English short date pattern for en locales', () {
      expect(
        formatAssistantDateTimeShort(
          const Locale('en'),
          DateTime(2026, 8, 17, 10, 5),
        ),
        'Aug 17, 10:05',
      );
    });
  });

  group('knowledgeSourceTypeOf', () {
    test('leaflet tool → leaflet tier', () {
      expect(
        knowledgeSourceTypeOf('search_medicine_leaflets'),
        AssistantKnowledgeSourceType.leaflet,
      );
    });
    test('drugbank tools → drugbank tier', () {
      expect(
        knowledgeSourceTypeOf('resolve_drugbank_entity'),
        AssistantKnowledgeSourceType.drugbank,
      );
      expect(
        knowledgeSourceTypeOf('search_drugbank_passages'),
        AssistantKnowledgeSourceType.drugbank,
      );
    });
    test('medical QA tool → medicalQa tier', () {
      expect(
        knowledgeSourceTypeOf('search_medical_qa_corpus'),
        AssistantKnowledgeSourceType.medicalQa,
      );
    });
    test('non-knowledge tools → null', () {
      expect(knowledgeSourceTypeOf('get_user_profile'), isNull);
      expect(knowledgeSourceTypeOf('propose_create_daily_record'), isNull);
      expect(knowledgeSourceTypeOf('unknown_tool'), isNull);
    });
  });

  group('assistantToolDisabledReasonText (F-10)', () {
    final zh = lookupAppLocalizations(const Locale('zh'));

    test('maps each backend disabled reason to user copy', () {
      expect(
        assistantToolDisabledReasonText(zh, 'chat_disabled', implemented: true),
        '对话功能未启用',
      );
      expect(
        assistantToolDisabledReasonText(
          zh,
          'context_disabled',
          implemented: true,
        ),
        '未开放所需健康上下文',
      );
      expect(
        assistantToolDisabledReasonText(
          zh,
          'model_not_configured',
          implemented: true,
        ),
        '服务端模型未配置',
      );
      expect(
        assistantToolDisabledReasonText(
          zh,
          'not_implemented',
          implemented: true,
        ),
        '尚未实现',
      );
    });

    test('shows raw text for unknown reasons (no fabrication)', () {
      expect(
        assistantToolDisabledReasonText(
          zh,
          'some_future_reason',
          implemented: true,
        ),
        'some_future_reason',
      );
    });

    test('empty reason falls back by implementation state', () {
      expect(
        assistantToolDisabledReasonText(zh, null, implemented: true),
        '已停用',
      );
      expect(
        assistantToolDisabledReasonText(zh, null, implemented: false),
        '尚未实现',
      );
    });
  });

  group('assistantToolStatusText (F-10)', () {
    final zh = lookupAppLocalizations(const Locale('zh'));

    AssistantToolCapability tool({
      required bool enabled,
      required String? disabledReason,
      bool implemented = true,
    }) {
      return AssistantToolCapability(
        id: 'get_today_records',
        requiredContextSources: const <String>[],
        permittedByUser: true,
        enabled: enabled,
        implemented: implemented,
        disabledReason: disabledReason,
      );
    }

    test('enabled tool shows 可用', () {
      expect(
        assistantToolStatusText(zh, tool(enabled: true, disabledReason: null)),
        '可用',
      );
    });

    test('disabled tool shows the translated reason', () {
      expect(
        assistantToolStatusText(
          zh,
          tool(enabled: false, disabledReason: 'context_disabled'),
        ),
        '未开放所需健康上下文',
      );
    });
  });
}
