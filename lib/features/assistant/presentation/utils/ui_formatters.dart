import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart' as intl;
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/l10n/app_localizations.dart';

String localizeToolName(String toolId, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return switch (toolId) {
    'get_today_records' => l10n.assistantToolTodayRecords,
    'get_records_by_date' => l10n.assistantToolRecordsByDate,
    'get_records_by_range' => l10n.assistantToolRecordsByRange,
    'get_today_summary_by_date' => l10n.assistantToolTodaySummaryByDate,
    'get_report_summary_by_range' => l10n.assistantToolReportSummaryByRange,
    'get_recent_today_summaries' => l10n.assistantToolRecentTodaySummaries,
    'get_recent_report_summaries' => l10n.assistantToolRecentReportSummaries,
    'get_user_profile' => l10n.assistantToolUserProfile,
    'get_user_settings' => l10n.assistantToolUserSettings,
    'get_current_medicines' => l10n.assistantToolCurrentMedicines,
    'get_sleep_summary_by_range' => l10n.assistantToolSleepByRange,
    'search_medicine_leaflets' => l10n.assistantToolSearchMedicineLeaflets,
    'search_medical_qa_corpus' => l10n.assistantToolSearchMedicalQaCorpus,
    'resolve_drugbank_entity' => l10n.assistantToolResolveDrugbankEntity,
    'search_drugbank_passages' => l10n.assistantToolSearchDrugbankPassages,
    'search_cn_medicine_products' => l10n.assistantToolSearchCnMedicineProducts,
    'get_cn_medicine_detail' => l10n.assistantToolCnMedicineDetail,
    'get_drugbank_detail' => l10n.assistantToolDrugbankDetail,
    'propose_create_daily_record' => l10n.assistantToolProposeCreateRecord,
    'propose_update_daily_record' => l10n.assistantToolProposeUpdateRecord,
    'propose_delete_daily_record' => l10n.assistantToolProposeDeleteRecord,
    'propose_update_user_settings' => l10n.assistantToolProposeUpdateSettings,
    _ => toolId,
  };
}

/// F-10 能力详情:工具停用原因的用户话术。后端 `AssistantToolDisabledReason`
/// 枚举值映射为本地化文案,未知值显示原文(不硬造)。
String assistantToolDisabledReasonText(
  AppLocalizations l10n,
  String? reason, {
  required bool implemented,
}) {
  final raw = reason?.trim() ?? '';
  return switch (raw) {
    'chat_disabled' => l10n.assistantToolDisabledChat,
    'context_disabled' => l10n.assistantToolDisabledContext,
    'model_not_configured' => l10n.assistantToolDisabledModel,
    'not_implemented' => l10n.assistantToolDisabledNotImplemented,
    '' =>
      implemented
          ? l10n.assistantToolDisabledGeneric
          : l10n.assistantToolDisabledNotImplemented,
    _ => raw,
  };
}

/// F-10 能力详情:工具状态文案 —— enabled 显示「可用」,disabled 显示
/// disabledReason 翻译。
String assistantToolStatusText(
  AppLocalizations l10n,
  AssistantToolCapability tool,
) {
  if (tool.enabled) {
    return l10n.assistantToolEnabledLabel;
  }
  return assistantToolDisabledReasonText(
    l10n,
    tool.disabledReason,
    implemented: tool.implemented,
  );
}

String formatAssistantDateTimeShort(Locale locale, DateTime dateTime) {
  final pattern = locale.languageCode == 'zh' ? 'M月d日 HH:mm' : 'MMM d, HH:mm';
  return intl.DateFormat(pattern, locale.toString()).format(dateTime.toLocal());
}

IconData proposalIcon(AssistantProposedActionType type) {
  return switch (type) {
    AssistantProposedActionType.createDailyRecord =>
      SemanticIcons.actionAddCard,
    AssistantProposedActionType.updateDailyRecord =>
      SemanticIcons.actionEditCard,
    AssistantProposedActionType.deleteDailyRecord => SemanticIcons.actionDelete,
    AssistantProposedActionType.updateUserSettings =>
      SemanticIcons.actionSettings,
  };
}

String proposalConfirmLabel(
  AppLocalizations l10n,
  AssistantProposedActionType type,
) {
  return switch (type) {
    AssistantProposedActionType.createDailyRecord =>
      l10n.assistantProposalConfirmCreateAction,
    AssistantProposedActionType.updateDailyRecord =>
      l10n.assistantProposalConfirmUpdateAction,
    AssistantProposedActionType.deleteDailyRecord =>
      l10n.assistantProposalConfirmDeleteAction,
    AssistantProposedActionType.updateUserSettings =>
      l10n.assistantProposalConfirmSettingsAction,
  };
}

String proposalStateText(
  AppLocalizations l10n,
  AssistantProposedAction proposal,
) {
  return switch (proposal.executionState) {
    AssistantProposalExecutionState.pending =>
      l10n.assistantProposalPendingState,
    AssistantProposalExecutionState.executing =>
      l10n.assistantProposalExecutingState,
    AssistantProposalExecutionState.confirmed =>
      l10n.assistantProposalConfirmedState,
    AssistantProposalExecutionState.dismissed =>
      l10n.assistantProposalDismissedState,
    AssistantProposalExecutionState.failed => l10n.assistantProposalFailedState,
  };
}

Color proposalStateColor(FColors colors, AssistantProposedAction proposal) {
  return switch (proposal.executionState) {
    AssistantProposalExecutionState.pending => colors.primary,
    AssistantProposalExecutionState.executing => colors.primary,
    AssistantProposalExecutionState.confirmed => colors.secondary,
    AssistantProposalExecutionState.dismissed => colors.mutedForeground,
    AssistantProposalExecutionState.failed => colors.destructive,
  };
}

String sendErrorDescription(
  AppLocalizations l10n,
  AssistantSendErrorType? errorType,
  String fallback,
) {
  return switch (errorType) {
    AssistantSendErrorType.streamInterrupted =>
      l10n.assistantErrorStreamInterrupted,
    AssistantSendErrorType.emptyResult => l10n.assistantErrorEmptyResult,
    AssistantSendErrorType.server => l10n.assistantErrorServer,
    AssistantSendErrorType.unknown || null => fallback,
  };
}

IconData sendErrorIcon(AssistantSendErrorType? errorType) {
  return switch (errorType) {
    AssistantSendErrorType.streamInterrupted => SemanticIcons.statusUnavailable,
    AssistantSendErrorType.emptyResult => SemanticIcons.safetyLongTerm,
    AssistantSendErrorType.server => SemanticIcons.statusUnavailable,
    AssistantSendErrorType.unknown || null => SemanticIcons.statusError,
  };
}

String conversationTitle(
  BuildContext context,
  AssistantConversationSummary summary,
) {
  final title = summary.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  return AppLocalizations.of(context)!.assistantUntitledConversation;
}

String conversationTimestampLabel(
  BuildContext context,
  AssistantConversationSummary summary,
) {
  final locale = Localizations.localeOf(context).toString();
  final value = summary.lastMessageAt ?? summary.updatedAt;
  final local = value.toLocal();
  return intl.DateFormat.MMMd(locale).add_Hm().format(local);
}

/// Trust tier of a knowledge-retrieval tool, used for source badges and the
/// low-trust hint on the source strip.
enum AssistantKnowledgeSourceType { leaflet, drugbank, medicalQa }

/// Maps a tool id to its knowledge source tier, or null for non-knowledge
/// tools (record/sleep/profile reads, proposals, etc.).
AssistantKnowledgeSourceType? knowledgeSourceTypeOf(String toolId) {
  return switch (toolId) {
    'search_medicine_leaflets' => AssistantKnowledgeSourceType.leaflet,
    'resolve_drugbank_entity' ||
    'search_drugbank_passages' => AssistantKnowledgeSourceType.drugbank,
    'search_medical_qa_corpus' => AssistantKnowledgeSourceType.medicalQa,
    _ => null,
  };
}
