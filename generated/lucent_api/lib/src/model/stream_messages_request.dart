//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/stream_messages_request_messages.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stream_messages_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StreamMessagesRequest {
  /// Returns a new [StreamMessagesRequest] instance.
  StreamMessagesRequest({required this.messages, this.conversationId});

  /// Conversation window ending with the latest user message to answer.
  @JsonKey(name: r'messages', required: true, includeIfNull: false)
  final List<StreamMessagesRequestMessages> messages;

  /// Optional persisted conversation id used as the LangGraph thread id. When absent the conversation runs statelessly (no checkpoint / no in-graph review).
  @JsonKey(name: r'conversationId', required: false, includeIfNull: false)
  final String? conversationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamMessagesRequest &&
          other.messages == messages &&
          other.conversationId == conversationId;

  @override
  int get hashCode => messages.hashCode + conversationId.hashCode;

  factory StreamMessagesRequest.fromJson(Map<String, dynamic> json) =>
      _$StreamMessagesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StreamMessagesRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
