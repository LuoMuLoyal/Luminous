import 'package:flutter/foundation.dart';

@immutable
class AssistantContextAccess {
  const AssistantContextAccess({
    required this.healthProfile,
    required this.dailyRecords,
    required this.sleepRecords,
    required this.currentMedicines,
  });

  final bool healthProfile;
  final bool dailyRecords;
  final bool sleepRecords;
  final bool currentMedicines;

  int get enabledCount => <bool>[
    healthProfile,
    dailyRecords,
    sleepRecords,
    currentMedicines,
  ].where((value) => value).length;
}

@immutable
class AssistantToolCapability {
  const AssistantToolCapability({
    required this.id,
    required this.requiredContextSources,
    required this.permittedByUser,
    required this.enabled,
    required this.implemented,
    required this.disabledReason,
  });

  final String id;
  final List<String> requiredContextSources;
  final bool permittedByUser;
  final bool enabled;
  final bool implemented;
  final String? disabledReason;
}

@immutable
class AssistantCapabilities {
  const AssistantCapabilities({
    required this.phase,
    required this.assistantEnabled,
    required this.assistantMemoryEnabled,
    required this.assistantContext,
    required this.chatModelConfigured,
    required this.interactiveChatReady,
    required this.langGraphReady,
    required this.streamingSupported,
    required this.streamingTransport,
    required this.markdownRenderingRecommended,
    required this.ragEnabled,
    required this.tools,
    required this.updatedAt,
  });

  final String phase;
  final bool assistantEnabled;
  final bool assistantMemoryEnabled;
  final AssistantContextAccess assistantContext;
  final bool chatModelConfigured;
  final bool interactiveChatReady;
  final bool langGraphReady;
  final bool streamingSupported;
  final String streamingTransport;
  final bool markdownRenderingRecommended;
  final bool ragEnabled;
  final List<AssistantToolCapability> tools;
  final DateTime? updatedAt;

  bool get canSendMessages =>
      assistantEnabled &&
      chatModelConfigured &&
      interactiveChatReady &&
      streamingSupported;

  int get enabledToolCount => tools.where((tool) => tool.enabled).length;
}

enum AssistantMessageRole { user, assistant }

enum AssistantProposalExecutionState {
  pending,
  executing,
  confirmed,
  dismissed,
  failed,
}

enum AssistantProposedActionType {
  createDailyRecord('create_daily_record'),
  updateDailyRecord('update_daily_record'),
  deleteDailyRecord('delete_daily_record'),
  updateUserSettings('update_user_settings');

  const AssistantProposedActionType(this.value);

  final String value;

  static AssistantProposedActionType? fromValue(String raw) {
    for (final value in values) {
      if (value.value == raw) {
        return value;
      }
    }
    return null;
  }
}

@immutable
class AssistantProposalPreviewField {
  const AssistantProposalPreviewField({required this.label, required this.value});

  final String label;
  final String value;
}

@immutable
class AssistantProposalTarget {
  const AssistantProposalTarget({
    required this.kind,
    required this.label,
    this.recordId,
    this.settingKeys = const <String>[],
    this.matchedBy = const <String>[],
    this.snapshot,
  });

  final String kind;
  final String label;
  final String? recordId;
  final List<String> settingKeys;
  final List<String> matchedBy;
  final Map<String, dynamic>? snapshot;
}

sealed class AssistantProposalPayload {
  const AssistantProposalPayload(this.type);

  final AssistantProposedActionType type;
}

@immutable
class AssistantCreateDailyRecordDraft {
  const AssistantCreateDailyRecordDraft({
    required this.kind,
    required this.occurredAt,
    required this.title,
    required this.value,
    required this.unit,
    required this.note,
    required this.payload,
  });

  final String kind;
  final String occurredAt;
  final String? title;
  final String? value;
  final String? unit;
  final String? note;
  final Map<String, dynamic>? payload;
}

class AssistantCreateDailyRecordProposalPayload extends AssistantProposalPayload {
  const AssistantCreateDailyRecordProposalPayload({required this.draft})
    : super(AssistantProposedActionType.createDailyRecord);

  final AssistantCreateDailyRecordDraft draft;
}

class AssistantUpdateDailyRecordProposalPayload extends AssistantProposalPayload {
  const AssistantUpdateDailyRecordProposalPayload({
    required this.recordId,
    required this.draft,
  }) : super(AssistantProposedActionType.updateDailyRecord);

  final String recordId;
  final Map<String, dynamic> draft;

  bool get hasOccurredAt => draft.containsKey('occurredAt');
  bool get hasTitle => draft.containsKey('title');
  bool get hasValue => draft.containsKey('value');
  bool get hasUnit => draft.containsKey('unit');
  bool get hasNote => draft.containsKey('note');
  bool get hasPayload => draft.containsKey('payload');

  String? get occurredAt => draft['occurredAt']?.toString();
  String? get title => draft['title']?.toString();
  String? get value => draft['value']?.toString();
  String? get unit => draft['unit']?.toString();
  String? get note => draft['note']?.toString();
  Map<String, dynamic>? get payload => switch (draft['payload']) {
    final Map<Object?, Object?> raw => raw.map(
      (key, value) => MapEntry(key.toString(), value),
    ),
    _ => null,
  };
}

class AssistantDeleteDailyRecordProposalPayload extends AssistantProposalPayload {
  const AssistantDeleteDailyRecordProposalPayload({required this.recordId})
    : super(AssistantProposedActionType.deleteDailyRecord);

  final String recordId;
}

@immutable
class AssistantUpdateUserSettingsDraft {
  const AssistantUpdateUserSettingsDraft({
    this.assistantEnabled,
    this.assistantMemoryEnabled,
    this.assistantContext,
  });

  final bool? assistantEnabled;
  final bool? assistantMemoryEnabled;
  final AssistantContextAccess? assistantContext;

  bool get isEmpty =>
      assistantEnabled == null &&
      assistantMemoryEnabled == null &&
      assistantContext == null;
}

class AssistantUpdateUserSettingsProposalPayload extends AssistantProposalPayload {
  const AssistantUpdateUserSettingsProposalPayload({required this.draft})
    : super(AssistantProposedActionType.updateUserSettings);

  final AssistantUpdateUserSettingsDraft draft;
}

@immutable
class AssistantProposedAction {
  const AssistantProposedAction({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.reason,
    required this.previewFields,
    required this.target,
    required this.constraints,
    required this.expiresAt,
    required this.payloadVersion,
    required this.payload,
    this.confirmationRequired = true,
    this.backendStatus = 'proposed',
    this.executionState = AssistantProposalExecutionState.pending,
    this.executionError,
  });

  final String id;
  final AssistantProposedActionType type;
  final String title;
  final String summary;
  final String? reason;
  final List<AssistantProposalPreviewField> previewFields;
  final AssistantProposalTarget target;
  final List<String> constraints;
  final DateTime? expiresAt;
  final int payloadVersion;
  final AssistantProposalPayload payload;
  final bool confirmationRequired;
  final String backendStatus;
  final AssistantProposalExecutionState executionState;
  final String? executionError;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isVisible =>
      executionState != AssistantProposalExecutionState.dismissed;
  bool get isActionable =>
      !isExpired &&
      (executionState == AssistantProposalExecutionState.pending ||
          executionState == AssistantProposalExecutionState.failed);

  AssistantProposedAction copyWith({
    AssistantProposalExecutionState? executionState,
    Object? executionError = _proposalSentinel,
  }) {
    return AssistantProposedAction(
      id: id,
      type: type,
      title: title,
      summary: summary,
      reason: reason,
      previewFields: previewFields,
      target: target,
      constraints: constraints,
      expiresAt: expiresAt,
      payloadVersion: payloadVersion,
      payload: payload,
      confirmationRequired: confirmationRequired,
      backendStatus: backendStatus,
      executionState: executionState ?? this.executionState,
      executionError: identical(executionError, _proposalSentinel)
          ? this.executionError
          : executionError as String?,
    );
  }
}

@immutable
class AssistantMessage {
  const AssistantMessage({
    required this.role,
    required this.content,
    required this.createdAt,
    this.usedTools = const <String>[],
    this.proposedActions = const <AssistantProposedAction>[],
  });

  final AssistantMessageRole role;
  final String content;
  final DateTime createdAt;
  final List<String> usedTools;
  final List<AssistantProposedAction> proposedActions;

  AssistantMessage copyWith({
    AssistantMessageRole? role,
    String? content,
    DateTime? createdAt,
    List<String>? usedTools,
    List<AssistantProposedAction>? proposedActions,
  }) {
    return AssistantMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      usedTools: usedTools ?? this.usedTools,
      proposedActions: proposedActions ?? this.proposedActions,
    );
  }
}

@immutable
class AssistantConversation {
  const AssistantConversation({
    required this.id,
    required this.title,
    required this.status,
    required this.messages,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? title;
  final String status;
  final List<AssistantMessage> messages;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

const Object _proposalSentinel = Object();

@immutable
class AssistantConversationSummary {
  const AssistantConversationSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? title;
  final String status;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
