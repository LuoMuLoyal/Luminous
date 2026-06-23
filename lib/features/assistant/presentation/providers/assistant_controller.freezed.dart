// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantState {

 bool get isLoadingCapabilities; bool get isLoadingConversation; bool get isLoadingRecentConversations; bool get isOpeningConversation; bool get isSending; AssistantCapabilities? get capabilities; String? get capabilityError; String? get conversationError; String? get recentConversationError; String? get sendError; AssistantSendErrorType? get sendErrorType; String? get lastFailedInput; String? get conversationId; List<AssistantConversationSummary> get recentConversations; List<AssistantMessage> get messages; String get streamingDraft;
/// Create a copy of AssistantState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantStateCopyWith<AssistantState> get copyWith => _$AssistantStateCopyWithImpl<AssistantState>(this as AssistantState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantState&&(identical(other.isLoadingCapabilities, isLoadingCapabilities) || other.isLoadingCapabilities == isLoadingCapabilities)&&(identical(other.isLoadingConversation, isLoadingConversation) || other.isLoadingConversation == isLoadingConversation)&&(identical(other.isLoadingRecentConversations, isLoadingRecentConversations) || other.isLoadingRecentConversations == isLoadingRecentConversations)&&(identical(other.isOpeningConversation, isOpeningConversation) || other.isOpeningConversation == isOpeningConversation)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.capabilities, capabilities) || other.capabilities == capabilities)&&(identical(other.capabilityError, capabilityError) || other.capabilityError == capabilityError)&&(identical(other.conversationError, conversationError) || other.conversationError == conversationError)&&(identical(other.recentConversationError, recentConversationError) || other.recentConversationError == recentConversationError)&&(identical(other.sendError, sendError) || other.sendError == sendError)&&(identical(other.sendErrorType, sendErrorType) || other.sendErrorType == sendErrorType)&&(identical(other.lastFailedInput, lastFailedInput) || other.lastFailedInput == lastFailedInput)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&const DeepCollectionEquality().equals(other.recentConversations, recentConversations)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.streamingDraft, streamingDraft) || other.streamingDraft == streamingDraft));
}


@override
int get hashCode => Object.hash(runtimeType,isLoadingCapabilities,isLoadingConversation,isLoadingRecentConversations,isOpeningConversation,isSending,capabilities,capabilityError,conversationError,recentConversationError,sendError,sendErrorType,lastFailedInput,conversationId,const DeepCollectionEquality().hash(recentConversations),const DeepCollectionEquality().hash(messages),streamingDraft);

@override
String toString() {
  return 'AssistantState(isLoadingCapabilities: $isLoadingCapabilities, isLoadingConversation: $isLoadingConversation, isLoadingRecentConversations: $isLoadingRecentConversations, isOpeningConversation: $isOpeningConversation, isSending: $isSending, capabilities: $capabilities, capabilityError: $capabilityError, conversationError: $conversationError, recentConversationError: $recentConversationError, sendError: $sendError, sendErrorType: $sendErrorType, lastFailedInput: $lastFailedInput, conversationId: $conversationId, recentConversations: $recentConversations, messages: $messages, streamingDraft: $streamingDraft)';
}


}

/// @nodoc
abstract mixin class $AssistantStateCopyWith<$Res>  {
  factory $AssistantStateCopyWith(AssistantState value, $Res Function(AssistantState) _then) = _$AssistantStateCopyWithImpl;
@useResult
$Res call({
 bool isLoadingCapabilities, bool isLoadingConversation, bool isLoadingRecentConversations, bool isOpeningConversation, bool isSending, AssistantCapabilities? capabilities, String? capabilityError, String? conversationError, String? recentConversationError, String? sendError, AssistantSendErrorType? sendErrorType, String? lastFailedInput, String? conversationId, List<AssistantConversationSummary> recentConversations, List<AssistantMessage> messages, String streamingDraft
});




}
/// @nodoc
class _$AssistantStateCopyWithImpl<$Res>
    implements $AssistantStateCopyWith<$Res> {
  _$AssistantStateCopyWithImpl(this._self, this._then);

  final AssistantState _self;
  final $Res Function(AssistantState) _then;

/// Create a copy of AssistantState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoadingCapabilities = null,Object? isLoadingConversation = null,Object? isLoadingRecentConversations = null,Object? isOpeningConversation = null,Object? isSending = null,Object? capabilities = freezed,Object? capabilityError = freezed,Object? conversationError = freezed,Object? recentConversationError = freezed,Object? sendError = freezed,Object? sendErrorType = freezed,Object? lastFailedInput = freezed,Object? conversationId = freezed,Object? recentConversations = null,Object? messages = null,Object? streamingDraft = null,}) {
  return _then(_self.copyWith(
isLoadingCapabilities: null == isLoadingCapabilities ? _self.isLoadingCapabilities : isLoadingCapabilities // ignore: cast_nullable_to_non_nullable
as bool,isLoadingConversation: null == isLoadingConversation ? _self.isLoadingConversation : isLoadingConversation // ignore: cast_nullable_to_non_nullable
as bool,isLoadingRecentConversations: null == isLoadingRecentConversations ? _self.isLoadingRecentConversations : isLoadingRecentConversations // ignore: cast_nullable_to_non_nullable
as bool,isOpeningConversation: null == isOpeningConversation ? _self.isOpeningConversation : isOpeningConversation // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,capabilities: freezed == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as AssistantCapabilities?,capabilityError: freezed == capabilityError ? _self.capabilityError : capabilityError // ignore: cast_nullable_to_non_nullable
as String?,conversationError: freezed == conversationError ? _self.conversationError : conversationError // ignore: cast_nullable_to_non_nullable
as String?,recentConversationError: freezed == recentConversationError ? _self.recentConversationError : recentConversationError // ignore: cast_nullable_to_non_nullable
as String?,sendError: freezed == sendError ? _self.sendError : sendError // ignore: cast_nullable_to_non_nullable
as String?,sendErrorType: freezed == sendErrorType ? _self.sendErrorType : sendErrorType // ignore: cast_nullable_to_non_nullable
as AssistantSendErrorType?,lastFailedInput: freezed == lastFailedInput ? _self.lastFailedInput : lastFailedInput // ignore: cast_nullable_to_non_nullable
as String?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,recentConversations: null == recentConversations ? _self.recentConversations : recentConversations // ignore: cast_nullable_to_non_nullable
as List<AssistantConversationSummary>,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<AssistantMessage>,streamingDraft: null == streamingDraft ? _self.streamingDraft : streamingDraft // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantState].
extension AssistantStatePatterns on AssistantState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantState value)  $default,){
final _that = this;
switch (_that) {
case _AssistantState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantState value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoadingCapabilities,  bool isLoadingConversation,  bool isLoadingRecentConversations,  bool isOpeningConversation,  bool isSending,  AssistantCapabilities? capabilities,  String? capabilityError,  String? conversationError,  String? recentConversationError,  String? sendError,  AssistantSendErrorType? sendErrorType,  String? lastFailedInput,  String? conversationId,  List<AssistantConversationSummary> recentConversations,  List<AssistantMessage> messages,  String streamingDraft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantState() when $default != null:
return $default(_that.isLoadingCapabilities,_that.isLoadingConversation,_that.isLoadingRecentConversations,_that.isOpeningConversation,_that.isSending,_that.capabilities,_that.capabilityError,_that.conversationError,_that.recentConversationError,_that.sendError,_that.sendErrorType,_that.lastFailedInput,_that.conversationId,_that.recentConversations,_that.messages,_that.streamingDraft);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoadingCapabilities,  bool isLoadingConversation,  bool isLoadingRecentConversations,  bool isOpeningConversation,  bool isSending,  AssistantCapabilities? capabilities,  String? capabilityError,  String? conversationError,  String? recentConversationError,  String? sendError,  AssistantSendErrorType? sendErrorType,  String? lastFailedInput,  String? conversationId,  List<AssistantConversationSummary> recentConversations,  List<AssistantMessage> messages,  String streamingDraft)  $default,) {final _that = this;
switch (_that) {
case _AssistantState():
return $default(_that.isLoadingCapabilities,_that.isLoadingConversation,_that.isLoadingRecentConversations,_that.isOpeningConversation,_that.isSending,_that.capabilities,_that.capabilityError,_that.conversationError,_that.recentConversationError,_that.sendError,_that.sendErrorType,_that.lastFailedInput,_that.conversationId,_that.recentConversations,_that.messages,_that.streamingDraft);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoadingCapabilities,  bool isLoadingConversation,  bool isLoadingRecentConversations,  bool isOpeningConversation,  bool isSending,  AssistantCapabilities? capabilities,  String? capabilityError,  String? conversationError,  String? recentConversationError,  String? sendError,  AssistantSendErrorType? sendErrorType,  String? lastFailedInput,  String? conversationId,  List<AssistantConversationSummary> recentConversations,  List<AssistantMessage> messages,  String streamingDraft)?  $default,) {final _that = this;
switch (_that) {
case _AssistantState() when $default != null:
return $default(_that.isLoadingCapabilities,_that.isLoadingConversation,_that.isLoadingRecentConversations,_that.isOpeningConversation,_that.isSending,_that.capabilities,_that.capabilityError,_that.conversationError,_that.recentConversationError,_that.sendError,_that.sendErrorType,_that.lastFailedInput,_that.conversationId,_that.recentConversations,_that.messages,_that.streamingDraft);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantState extends AssistantState {
  const _AssistantState({this.isLoadingCapabilities = false, this.isLoadingConversation = false, this.isLoadingRecentConversations = false, this.isOpeningConversation = false, this.isSending = false, this.capabilities, this.capabilityError, this.conversationError, this.recentConversationError, this.sendError, this.sendErrorType, this.lastFailedInput, this.conversationId, final  List<AssistantConversationSummary> recentConversations = const [], final  List<AssistantMessage> messages = const [], this.streamingDraft = ''}): _recentConversations = recentConversations,_messages = messages,super._();
  

@override@JsonKey() final  bool isLoadingCapabilities;
@override@JsonKey() final  bool isLoadingConversation;
@override@JsonKey() final  bool isLoadingRecentConversations;
@override@JsonKey() final  bool isOpeningConversation;
@override@JsonKey() final  bool isSending;
@override final  AssistantCapabilities? capabilities;
@override final  String? capabilityError;
@override final  String? conversationError;
@override final  String? recentConversationError;
@override final  String? sendError;
@override final  AssistantSendErrorType? sendErrorType;
@override final  String? lastFailedInput;
@override final  String? conversationId;
 final  List<AssistantConversationSummary> _recentConversations;
@override@JsonKey() List<AssistantConversationSummary> get recentConversations {
  if (_recentConversations is EqualUnmodifiableListView) return _recentConversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentConversations);
}

 final  List<AssistantMessage> _messages;
@override@JsonKey() List<AssistantMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  String streamingDraft;

/// Create a copy of AssistantState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantStateCopyWith<_AssistantState> get copyWith => __$AssistantStateCopyWithImpl<_AssistantState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantState&&(identical(other.isLoadingCapabilities, isLoadingCapabilities) || other.isLoadingCapabilities == isLoadingCapabilities)&&(identical(other.isLoadingConversation, isLoadingConversation) || other.isLoadingConversation == isLoadingConversation)&&(identical(other.isLoadingRecentConversations, isLoadingRecentConversations) || other.isLoadingRecentConversations == isLoadingRecentConversations)&&(identical(other.isOpeningConversation, isOpeningConversation) || other.isOpeningConversation == isOpeningConversation)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.capabilities, capabilities) || other.capabilities == capabilities)&&(identical(other.capabilityError, capabilityError) || other.capabilityError == capabilityError)&&(identical(other.conversationError, conversationError) || other.conversationError == conversationError)&&(identical(other.recentConversationError, recentConversationError) || other.recentConversationError == recentConversationError)&&(identical(other.sendError, sendError) || other.sendError == sendError)&&(identical(other.sendErrorType, sendErrorType) || other.sendErrorType == sendErrorType)&&(identical(other.lastFailedInput, lastFailedInput) || other.lastFailedInput == lastFailedInput)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&const DeepCollectionEquality().equals(other._recentConversations, _recentConversations)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.streamingDraft, streamingDraft) || other.streamingDraft == streamingDraft));
}


@override
int get hashCode => Object.hash(runtimeType,isLoadingCapabilities,isLoadingConversation,isLoadingRecentConversations,isOpeningConversation,isSending,capabilities,capabilityError,conversationError,recentConversationError,sendError,sendErrorType,lastFailedInput,conversationId,const DeepCollectionEquality().hash(_recentConversations),const DeepCollectionEquality().hash(_messages),streamingDraft);

@override
String toString() {
  return 'AssistantState(isLoadingCapabilities: $isLoadingCapabilities, isLoadingConversation: $isLoadingConversation, isLoadingRecentConversations: $isLoadingRecentConversations, isOpeningConversation: $isOpeningConversation, isSending: $isSending, capabilities: $capabilities, capabilityError: $capabilityError, conversationError: $conversationError, recentConversationError: $recentConversationError, sendError: $sendError, sendErrorType: $sendErrorType, lastFailedInput: $lastFailedInput, conversationId: $conversationId, recentConversations: $recentConversations, messages: $messages, streamingDraft: $streamingDraft)';
}


}

/// @nodoc
abstract mixin class _$AssistantStateCopyWith<$Res> implements $AssistantStateCopyWith<$Res> {
  factory _$AssistantStateCopyWith(_AssistantState value, $Res Function(_AssistantState) _then) = __$AssistantStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoadingCapabilities, bool isLoadingConversation, bool isLoadingRecentConversations, bool isOpeningConversation, bool isSending, AssistantCapabilities? capabilities, String? capabilityError, String? conversationError, String? recentConversationError, String? sendError, AssistantSendErrorType? sendErrorType, String? lastFailedInput, String? conversationId, List<AssistantConversationSummary> recentConversations, List<AssistantMessage> messages, String streamingDraft
});




}
/// @nodoc
class __$AssistantStateCopyWithImpl<$Res>
    implements _$AssistantStateCopyWith<$Res> {
  __$AssistantStateCopyWithImpl(this._self, this._then);

  final _AssistantState _self;
  final $Res Function(_AssistantState) _then;

/// Create a copy of AssistantState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoadingCapabilities = null,Object? isLoadingConversation = null,Object? isLoadingRecentConversations = null,Object? isOpeningConversation = null,Object? isSending = null,Object? capabilities = freezed,Object? capabilityError = freezed,Object? conversationError = freezed,Object? recentConversationError = freezed,Object? sendError = freezed,Object? sendErrorType = freezed,Object? lastFailedInput = freezed,Object? conversationId = freezed,Object? recentConversations = null,Object? messages = null,Object? streamingDraft = null,}) {
  return _then(_AssistantState(
isLoadingCapabilities: null == isLoadingCapabilities ? _self.isLoadingCapabilities : isLoadingCapabilities // ignore: cast_nullable_to_non_nullable
as bool,isLoadingConversation: null == isLoadingConversation ? _self.isLoadingConversation : isLoadingConversation // ignore: cast_nullable_to_non_nullable
as bool,isLoadingRecentConversations: null == isLoadingRecentConversations ? _self.isLoadingRecentConversations : isLoadingRecentConversations // ignore: cast_nullable_to_non_nullable
as bool,isOpeningConversation: null == isOpeningConversation ? _self.isOpeningConversation : isOpeningConversation // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,capabilities: freezed == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as AssistantCapabilities?,capabilityError: freezed == capabilityError ? _self.capabilityError : capabilityError // ignore: cast_nullable_to_non_nullable
as String?,conversationError: freezed == conversationError ? _self.conversationError : conversationError // ignore: cast_nullable_to_non_nullable
as String?,recentConversationError: freezed == recentConversationError ? _self.recentConversationError : recentConversationError // ignore: cast_nullable_to_non_nullable
as String?,sendError: freezed == sendError ? _self.sendError : sendError // ignore: cast_nullable_to_non_nullable
as String?,sendErrorType: freezed == sendErrorType ? _self.sendErrorType : sendErrorType // ignore: cast_nullable_to_non_nullable
as AssistantSendErrorType?,lastFailedInput: freezed == lastFailedInput ? _self.lastFailedInput : lastFailedInput // ignore: cast_nullable_to_non_nullable
as String?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,recentConversations: null == recentConversations ? _self._recentConversations : recentConversations // ignore: cast_nullable_to_non_nullable
as List<AssistantConversationSummary>,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<AssistantMessage>,streamingDraft: null == streamingDraft ? _self.streamingDraft : streamingDraft // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
