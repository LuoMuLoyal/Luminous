import 'package:forui/forui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/providers/assistant_controller.dart';
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
    'propose_create_daily_record' => l10n.assistantToolProposeCreateRecord,
    'propose_update_daily_record' => l10n.assistantToolProposeUpdateRecord,
    'propose_delete_daily_record' => l10n.assistantToolProposeDeleteRecord,
    'propose_update_user_settings' => l10n.assistantToolProposeUpdateSettings,
    _ => toolId,
  };
}

String messageIdFor(AssistantMessage message) {
  return '${message.role.name}-${message.createdAt.toIso8601String()}-${message.content.hashCode}';
}

IconData proposalIcon(AssistantProposedActionType type) {
  return switch (type) {
    AssistantProposedActionType.createDailyRecord => FLucideIcons.squarePlus,
    AssistantProposedActionType.updateDailyRecord => FLucideIcons.squarePen,
    AssistantProposedActionType.deleteDailyRecord => FLucideIcons.trash2,
    AssistantProposedActionType.updateUserSettings => FLucideIcons.settings2,
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

Color proposalStateColor(ThemeData theme, AssistantProposedAction proposal) {
  return switch (proposal.executionState) {
    AssistantProposalExecutionState.pending => theme.colorScheme.primary,
    AssistantProposalExecutionState.executing => theme.colorScheme.primary,
    AssistantProposalExecutionState.confirmed => theme.colorScheme.tertiary,
    AssistantProposalExecutionState.dismissed => theme.colorScheme.outline,
    AssistantProposalExecutionState.failed => theme.colorScheme.error,
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
    AssistantSendErrorType.streamInterrupted => FLucideIcons.wifiOff,
    AssistantSendErrorType.emptyResult => FLucideIcons.hourglass,
    AssistantSendErrorType.server => FLucideIcons.cloudOff,
    AssistantSendErrorType.unknown || null => FLucideIcons.circleAlert,
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
  final pattern = locale.startsWith('zh') ? 'M月d日 HH:mm' : 'MMM d, HH:mm';
  return intl.DateFormat(pattern, locale).format(local);
}
