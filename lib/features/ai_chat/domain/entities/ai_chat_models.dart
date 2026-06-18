import 'package:flutter/foundation.dart';

@immutable
class AiChatContextPermissions {
  const AiChatContextPermissions({
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
class AiChatToolCapability {
  const AiChatToolCapability({
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
class AiChatCapabilities {
  const AiChatCapabilities({
    required this.phase,
    required this.aiChatEnabled,
    required this.aiChatMemoryEnabled,
    required this.aiChatContext,
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
  final bool aiChatEnabled;
  final bool aiChatMemoryEnabled;
  final AiChatContextPermissions aiChatContext;
  final bool chatModelConfigured;
  final bool interactiveChatReady;
  final bool langGraphReady;
  final bool streamingSupported;
  final String streamingTransport;
  final bool markdownRenderingRecommended;
  final bool ragEnabled;
  final List<AiChatToolCapability> tools;
  final DateTime? updatedAt;

  bool get canSendMessages =>
      aiChatEnabled &&
      chatModelConfigured &&
      interactiveChatReady &&
      streamingSupported;

  int get enabledToolCount => tools.where((tool) => tool.enabled).length;
}

enum AiChatMessageRole { user, assistant }

enum AiChatProposalExecutionState {
  pending,
  executing,
  confirmed,
  dismissed,
  failed,
}

enum AiChatProposedActionType {
  createDailyRecord('create_daily_record'),
  updateDailyRecord('update_daily_record'),
  deleteDailyRecord('delete_daily_record'),
  updateUserSettings('update_user_settings');

  const AiChatProposedActionType(this.value);

  final String value;

  static AiChatProposedActionType? fromValue(String raw) {
    for (final value in values) {
      if (value.value == raw) {
        return value;
      }
    }
    return null;
  }
}

@immutable
class AiChatProposalPreviewField {
  const AiChatProposalPreviewField({required this.label, required this.value});

  final String label;
  final String value;
}

sealed class AiChatProposalPayload {
  const AiChatProposalPayload(this.type);

  final AiChatProposedActionType type;
}

@immutable
class AiChatCreateDailyRecordDraft {
  const AiChatCreateDailyRecordDraft({
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

class AiChatCreateDailyRecordProposalPayload extends AiChatProposalPayload {
  const AiChatCreateDailyRecordProposalPayload({required this.draft})
    : super(AiChatProposedActionType.createDailyRecord);

  final AiChatCreateDailyRecordDraft draft;
}

class AiChatUpdateDailyRecordProposalPayload extends AiChatProposalPayload {
  const AiChatUpdateDailyRecordProposalPayload({
    required this.recordId,
    required this.draft,
  }) : super(AiChatProposedActionType.updateDailyRecord);

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

class AiChatDeleteDailyRecordProposalPayload extends AiChatProposalPayload {
  const AiChatDeleteDailyRecordProposalPayload({required this.recordId})
    : super(AiChatProposedActionType.deleteDailyRecord);

  final String recordId;
}

@immutable
class AiChatUpdateUserSettingsDraft {
  const AiChatUpdateUserSettingsDraft({
    this.aiChatEnabled,
    this.aiChatMemoryEnabled,
    this.aiChatContext,
  });

  final bool? aiChatEnabled;
  final bool? aiChatMemoryEnabled;
  final AiChatContextPermissions? aiChatContext;

  bool get isEmpty =>
      aiChatEnabled == null &&
      aiChatMemoryEnabled == null &&
      aiChatContext == null;
}

class AiChatUpdateUserSettingsProposalPayload extends AiChatProposalPayload {
  const AiChatUpdateUserSettingsProposalPayload({required this.draft})
    : super(AiChatProposedActionType.updateUserSettings);

  final AiChatUpdateUserSettingsDraft draft;
}

@immutable
class AiChatProposedAction {
  const AiChatProposedAction({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.reason,
    required this.previewFields,
    required this.payloadVersion,
    required this.payload,
    this.confirmationRequired = true,
    this.backendStatus = 'proposed',
    this.executionState = AiChatProposalExecutionState.pending,
    this.executionError,
  });

  final String id;
  final AiChatProposedActionType type;
  final String title;
  final String summary;
  final String? reason;
  final List<AiChatProposalPreviewField> previewFields;
  final int payloadVersion;
  final AiChatProposalPayload payload;
  final bool confirmationRequired;
  final String backendStatus;
  final AiChatProposalExecutionState executionState;
  final String? executionError;

  bool get isVisible =>
      executionState != AiChatProposalExecutionState.dismissed;
  bool get isActionable =>
      executionState == AiChatProposalExecutionState.pending ||
      executionState == AiChatProposalExecutionState.failed;

  AiChatProposedAction copyWith({
    AiChatProposalExecutionState? executionState,
    Object? executionError = _proposalSentinel,
  }) {
    return AiChatProposedAction(
      id: id,
      type: type,
      title: title,
      summary: summary,
      reason: reason,
      previewFields: previewFields,
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
class AiChatMessage {
  const AiChatMessage({
    required this.role,
    required this.content,
    required this.createdAt,
    this.usedTools = const <String>[],
    this.proposedActions = const <AiChatProposedAction>[],
  });

  final AiChatMessageRole role;
  final String content;
  final DateTime createdAt;
  final List<String> usedTools;
  final List<AiChatProposedAction> proposedActions;

  AiChatMessage copyWith({
    AiChatMessageRole? role,
    String? content,
    DateTime? createdAt,
    List<String>? usedTools,
    List<AiChatProposedAction>? proposedActions,
  }) {
    return AiChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      usedTools: usedTools ?? this.usedTools,
      proposedActions: proposedActions ?? this.proposedActions,
    );
  }
}

@immutable
class AiChatConversation {
  const AiChatConversation({
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
  final List<AiChatMessage> messages;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

const Object _proposalSentinel = Object();

@immutable
class AiChatConversationSummary {
  const AiChatConversationSummary({
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
