import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_capabilities.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_management.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_proposals.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_regenerate.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_sending.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation_streams.dart';

part 'conversation.freezed.dart';

/// Why a send/regenerate attempt failed, as far as the user needs to know.
///
/// [dependency] and [modelRejected] split what used to be one blanket
/// `server` bucket: the former is a transient model outage worth retrying,
/// the latter means the model refuses this request outright, so offering
/// "Continue generating" would only reproduce the same failure.
enum AssistantSendErrorType {
  server,
  streamInterrupted,
  emptyResult,
  dependency,
  modelRejected,
  unknown,
}

@freezed
abstract class AssistantState with _$AssistantState {
  const AssistantState._();

  const factory AssistantState({
    @Default(false) bool isLoadingCapabilities,
    @Default(false) bool isLoadingConversation,
    @Default(false) bool isLoadingRecentConversations,
    @Default(false) bool isOpeningConversation,
    @Default(false) bool isClearingConversation,
    @Default(false) bool isSending,
    AssistantCapabilities? capabilities,
    String? capabilityError,
    String? conversationError,
    String? recentConversationError,
    String? sendError,
    AssistantSendErrorType? sendErrorType,
    String? lastFailedInput,
    String? conversationId,
    @Default([]) List<AssistantConversationSummary> recentConversations,
    @Default([]) List<AssistantMessage> messages,
    @Default('') String streamingDraft,
  }) = _AssistantState;

  bool get hasConversation => messages.isNotEmpty || streamingDraft.isNotEmpty;
}

class AssistantController extends Notifier<AssistantState>
    with
        CapabilitiesLoader,
        ConversationStreams,
        MessageSending,
        MessageRegeneration,
        ConversationManagement,
        ProposalHandling {
  @override
  AssistantState build() {
    final session = ref.watch(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const AssistantState();
    }

    unawaited(Future<void>.microtask(_bootstrap));
    return const AssistantState(
      isLoadingCapabilities: true,
      isLoadingConversation: true,
      isLoadingRecentConversations: true,
    );
  }

  Future<void> _bootstrap() async {
    await Future.wait<void>([
      loadCapabilities(),
      loadLatestConversation(),
      loadRecentConversations(),
    ]);
  }
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(
      AssistantController.new,
    );
