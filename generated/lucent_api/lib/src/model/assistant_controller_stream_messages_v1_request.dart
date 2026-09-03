//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/assistant_controller_stream_messages_v1_request_messages_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_controller_stream_messages_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantControllerStreamMessagesV1Request {
  /// Returns a new [AssistantControllerStreamMessagesV1Request] instance.
  AssistantControllerStreamMessagesV1Request({
    required this.messages,

    this.conversationId,
  });

  /// Conversation window ending with the latest user message to answer.
  @JsonKey(name: r'messages', required: true, includeIfNull: false)
  final List<AssistantControllerStreamMessagesV1RequestMessagesInner> messages;

  /// Optional persisted conversation id used as the LangGraph thread id. When absent the conversation runs statelessly (no checkpoint / no in-graph review).
  @JsonKey(name: r'conversationId', required: false, includeIfNull: false)
  final String? conversationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantControllerStreamMessagesV1Request &&
          other.messages == messages &&
          other.conversationId == conversationId;

  @override
  int get hashCode => messages.hashCode + conversationId.hashCode;

  factory AssistantControllerStreamMessagesV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantControllerStreamMessagesV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantControllerStreamMessagesV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
