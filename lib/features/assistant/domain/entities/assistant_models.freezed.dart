// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantProposedAction implements DiagnosticableTreeMixin {

 String get id; AssistantProposedActionType get type; String get title; String get summary; String? get reason; List<AssistantProposalPreviewField> get previewFields; AssistantProposalTarget get target; List<String> get constraints; DateTime? get expiresAt; int get payloadVersion; AssistantProposalPayload get payload; bool get confirmationRequired; String get backendStatus; AssistantProposalExecutionState get executionState; String? get executionError;
/// Create a copy of AssistantProposedAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantProposedActionCopyWith<AssistantProposedAction> get copyWith => _$AssistantProposedActionCopyWithImpl<AssistantProposedAction>(this as AssistantProposedAction, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AssistantProposedAction'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('summary', summary))..add(DiagnosticsProperty('reason', reason))..add(DiagnosticsProperty('previewFields', previewFields))..add(DiagnosticsProperty('target', target))..add(DiagnosticsProperty('constraints', constraints))..add(DiagnosticsProperty('expiresAt', expiresAt))..add(DiagnosticsProperty('payloadVersion', payloadVersion))..add(DiagnosticsProperty('payload', payload))..add(DiagnosticsProperty('confirmationRequired', confirmationRequired))..add(DiagnosticsProperty('backendStatus', backendStatus))..add(DiagnosticsProperty('executionState', executionState))..add(DiagnosticsProperty('executionError', executionError));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantProposedAction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.previewFields, previewFields)&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.constraints, constraints)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.payloadVersion, payloadVersion) || other.payloadVersion == payloadVersion)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.confirmationRequired, confirmationRequired) || other.confirmationRequired == confirmationRequired)&&(identical(other.backendStatus, backendStatus) || other.backendStatus == backendStatus)&&(identical(other.executionState, executionState) || other.executionState == executionState)&&(identical(other.executionError, executionError) || other.executionError == executionError));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,title,summary,reason,const DeepCollectionEquality().hash(previewFields),target,const DeepCollectionEquality().hash(constraints),expiresAt,payloadVersion,payload,confirmationRequired,backendStatus,executionState,executionError);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AssistantProposedAction(id: $id, type: $type, title: $title, summary: $summary, reason: $reason, previewFields: $previewFields, target: $target, constraints: $constraints, expiresAt: $expiresAt, payloadVersion: $payloadVersion, payload: $payload, confirmationRequired: $confirmationRequired, backendStatus: $backendStatus, executionState: $executionState, executionError: $executionError)';
}


}

/// @nodoc
abstract mixin class $AssistantProposedActionCopyWith<$Res>  {
  factory $AssistantProposedActionCopyWith(AssistantProposedAction value, $Res Function(AssistantProposedAction) _then) = _$AssistantProposedActionCopyWithImpl;
@useResult
$Res call({
 String id, AssistantProposedActionType type, String title, String summary, String? reason, List<AssistantProposalPreviewField> previewFields, AssistantProposalTarget target, List<String> constraints, DateTime? expiresAt, int payloadVersion, AssistantProposalPayload payload, bool confirmationRequired, String backendStatus, AssistantProposalExecutionState executionState, String? executionError
});




}
/// @nodoc
class _$AssistantProposedActionCopyWithImpl<$Res>
    implements $AssistantProposedActionCopyWith<$Res> {
  _$AssistantProposedActionCopyWithImpl(this._self, this._then);

  final AssistantProposedAction _self;
  final $Res Function(AssistantProposedAction) _then;

/// Create a copy of AssistantProposedAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? summary = null,Object? reason = freezed,Object? previewFields = null,Object? target = null,Object? constraints = null,Object? expiresAt = freezed,Object? payloadVersion = null,Object? payload = null,Object? confirmationRequired = null,Object? backendStatus = null,Object? executionState = null,Object? executionError = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AssistantProposedActionType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,previewFields: null == previewFields ? _self.previewFields : previewFields // ignore: cast_nullable_to_non_nullable
as List<AssistantProposalPreviewField>,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as AssistantProposalTarget,constraints: null == constraints ? _self.constraints : constraints // ignore: cast_nullable_to_non_nullable
as List<String>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,payloadVersion: null == payloadVersion ? _self.payloadVersion : payloadVersion // ignore: cast_nullable_to_non_nullable
as int,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as AssistantProposalPayload,confirmationRequired: null == confirmationRequired ? _self.confirmationRequired : confirmationRequired // ignore: cast_nullable_to_non_nullable
as bool,backendStatus: null == backendStatus ? _self.backendStatus : backendStatus // ignore: cast_nullable_to_non_nullable
as String,executionState: null == executionState ? _self.executionState : executionState // ignore: cast_nullable_to_non_nullable
as AssistantProposalExecutionState,executionError: freezed == executionError ? _self.executionError : executionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantProposedAction].
extension AssistantProposedActionPatterns on AssistantProposedAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantProposedAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantProposedAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantProposedAction value)  $default,){
final _that = this;
switch (_that) {
case _AssistantProposedAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantProposedAction value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantProposedAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AssistantProposedActionType type,  String title,  String summary,  String? reason,  List<AssistantProposalPreviewField> previewFields,  AssistantProposalTarget target,  List<String> constraints,  DateTime? expiresAt,  int payloadVersion,  AssistantProposalPayload payload,  bool confirmationRequired,  String backendStatus,  AssistantProposalExecutionState executionState,  String? executionError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantProposedAction() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.summary,_that.reason,_that.previewFields,_that.target,_that.constraints,_that.expiresAt,_that.payloadVersion,_that.payload,_that.confirmationRequired,_that.backendStatus,_that.executionState,_that.executionError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AssistantProposedActionType type,  String title,  String summary,  String? reason,  List<AssistantProposalPreviewField> previewFields,  AssistantProposalTarget target,  List<String> constraints,  DateTime? expiresAt,  int payloadVersion,  AssistantProposalPayload payload,  bool confirmationRequired,  String backendStatus,  AssistantProposalExecutionState executionState,  String? executionError)  $default,) {final _that = this;
switch (_that) {
case _AssistantProposedAction():
return $default(_that.id,_that.type,_that.title,_that.summary,_that.reason,_that.previewFields,_that.target,_that.constraints,_that.expiresAt,_that.payloadVersion,_that.payload,_that.confirmationRequired,_that.backendStatus,_that.executionState,_that.executionError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AssistantProposedActionType type,  String title,  String summary,  String? reason,  List<AssistantProposalPreviewField> previewFields,  AssistantProposalTarget target,  List<String> constraints,  DateTime? expiresAt,  int payloadVersion,  AssistantProposalPayload payload,  bool confirmationRequired,  String backendStatus,  AssistantProposalExecutionState executionState,  String? executionError)?  $default,) {final _that = this;
switch (_that) {
case _AssistantProposedAction() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.summary,_that.reason,_that.previewFields,_that.target,_that.constraints,_that.expiresAt,_that.payloadVersion,_that.payload,_that.confirmationRequired,_that.backendStatus,_that.executionState,_that.executionError);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantProposedAction extends AssistantProposedAction with DiagnosticableTreeMixin {
  const _AssistantProposedAction({required this.id, required this.type, required this.title, required this.summary, required this.reason, required final  List<AssistantProposalPreviewField> previewFields, required this.target, required final  List<String> constraints, required this.expiresAt, required this.payloadVersion, required this.payload, this.confirmationRequired = true, this.backendStatus = 'proposed', this.executionState = AssistantProposalExecutionState.pending, this.executionError}): _previewFields = previewFields,_constraints = constraints,super._();
  

@override final  String id;
@override final  AssistantProposedActionType type;
@override final  String title;
@override final  String summary;
@override final  String? reason;
 final  List<AssistantProposalPreviewField> _previewFields;
@override List<AssistantProposalPreviewField> get previewFields {
  if (_previewFields is EqualUnmodifiableListView) return _previewFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_previewFields);
}

@override final  AssistantProposalTarget target;
 final  List<String> _constraints;
@override List<String> get constraints {
  if (_constraints is EqualUnmodifiableListView) return _constraints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_constraints);
}

@override final  DateTime? expiresAt;
@override final  int payloadVersion;
@override final  AssistantProposalPayload payload;
@override@JsonKey() final  bool confirmationRequired;
@override@JsonKey() final  String backendStatus;
@override@JsonKey() final  AssistantProposalExecutionState executionState;
@override final  String? executionError;

/// Create a copy of AssistantProposedAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantProposedActionCopyWith<_AssistantProposedAction> get copyWith => __$AssistantProposedActionCopyWithImpl<_AssistantProposedAction>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AssistantProposedAction'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('summary', summary))..add(DiagnosticsProperty('reason', reason))..add(DiagnosticsProperty('previewFields', previewFields))..add(DiagnosticsProperty('target', target))..add(DiagnosticsProperty('constraints', constraints))..add(DiagnosticsProperty('expiresAt', expiresAt))..add(DiagnosticsProperty('payloadVersion', payloadVersion))..add(DiagnosticsProperty('payload', payload))..add(DiagnosticsProperty('confirmationRequired', confirmationRequired))..add(DiagnosticsProperty('backendStatus', backendStatus))..add(DiagnosticsProperty('executionState', executionState))..add(DiagnosticsProperty('executionError', executionError));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantProposedAction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other._previewFields, _previewFields)&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other._constraints, _constraints)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.payloadVersion, payloadVersion) || other.payloadVersion == payloadVersion)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.confirmationRequired, confirmationRequired) || other.confirmationRequired == confirmationRequired)&&(identical(other.backendStatus, backendStatus) || other.backendStatus == backendStatus)&&(identical(other.executionState, executionState) || other.executionState == executionState)&&(identical(other.executionError, executionError) || other.executionError == executionError));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,title,summary,reason,const DeepCollectionEquality().hash(_previewFields),target,const DeepCollectionEquality().hash(_constraints),expiresAt,payloadVersion,payload,confirmationRequired,backendStatus,executionState,executionError);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AssistantProposedAction(id: $id, type: $type, title: $title, summary: $summary, reason: $reason, previewFields: $previewFields, target: $target, constraints: $constraints, expiresAt: $expiresAt, payloadVersion: $payloadVersion, payload: $payload, confirmationRequired: $confirmationRequired, backendStatus: $backendStatus, executionState: $executionState, executionError: $executionError)';
}


}

/// @nodoc
abstract mixin class _$AssistantProposedActionCopyWith<$Res> implements $AssistantProposedActionCopyWith<$Res> {
  factory _$AssistantProposedActionCopyWith(_AssistantProposedAction value, $Res Function(_AssistantProposedAction) _then) = __$AssistantProposedActionCopyWithImpl;
@override @useResult
$Res call({
 String id, AssistantProposedActionType type, String title, String summary, String? reason, List<AssistantProposalPreviewField> previewFields, AssistantProposalTarget target, List<String> constraints, DateTime? expiresAt, int payloadVersion, AssistantProposalPayload payload, bool confirmationRequired, String backendStatus, AssistantProposalExecutionState executionState, String? executionError
});




}
/// @nodoc
class __$AssistantProposedActionCopyWithImpl<$Res>
    implements _$AssistantProposedActionCopyWith<$Res> {
  __$AssistantProposedActionCopyWithImpl(this._self, this._then);

  final _AssistantProposedAction _self;
  final $Res Function(_AssistantProposedAction) _then;

/// Create a copy of AssistantProposedAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? summary = null,Object? reason = freezed,Object? previewFields = null,Object? target = null,Object? constraints = null,Object? expiresAt = freezed,Object? payloadVersion = null,Object? payload = null,Object? confirmationRequired = null,Object? backendStatus = null,Object? executionState = null,Object? executionError = freezed,}) {
  return _then(_AssistantProposedAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AssistantProposedActionType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,previewFields: null == previewFields ? _self._previewFields : previewFields // ignore: cast_nullable_to_non_nullable
as List<AssistantProposalPreviewField>,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as AssistantProposalTarget,constraints: null == constraints ? _self._constraints : constraints // ignore: cast_nullable_to_non_nullable
as List<String>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,payloadVersion: null == payloadVersion ? _self.payloadVersion : payloadVersion // ignore: cast_nullable_to_non_nullable
as int,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as AssistantProposalPayload,confirmationRequired: null == confirmationRequired ? _self.confirmationRequired : confirmationRequired // ignore: cast_nullable_to_non_nullable
as bool,backendStatus: null == backendStatus ? _self.backendStatus : backendStatus // ignore: cast_nullable_to_non_nullable
as String,executionState: null == executionState ? _self.executionState : executionState // ignore: cast_nullable_to_non_nullable
as AssistantProposalExecutionState,executionError: freezed == executionError ? _self.executionError : executionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AssistantMessage implements DiagnosticableTreeMixin {

 AssistantMessageRole get role; String get content; DateTime get createdAt; List<String> get usedTools; List<AssistantProposedAction> get proposedActions;
/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantMessageCopyWith<AssistantMessage> get copyWith => _$AssistantMessageCopyWithImpl<AssistantMessage>(this as AssistantMessage, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AssistantMessage'))
    ..add(DiagnosticsProperty('role', role))..add(DiagnosticsProperty('content', content))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('usedTools', usedTools))..add(DiagnosticsProperty('proposedActions', proposedActions));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.usedTools, usedTools)&&const DeepCollectionEquality().equals(other.proposedActions, proposedActions));
}


@override
int get hashCode => Object.hash(runtimeType,role,content,createdAt,const DeepCollectionEquality().hash(usedTools),const DeepCollectionEquality().hash(proposedActions));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AssistantMessage(role: $role, content: $content, createdAt: $createdAt, usedTools: $usedTools, proposedActions: $proposedActions)';
}


}

/// @nodoc
abstract mixin class $AssistantMessageCopyWith<$Res>  {
  factory $AssistantMessageCopyWith(AssistantMessage value, $Res Function(AssistantMessage) _then) = _$AssistantMessageCopyWithImpl;
@useResult
$Res call({
 AssistantMessageRole role, String content, DateTime createdAt, List<String> usedTools, List<AssistantProposedAction> proposedActions
});




}
/// @nodoc
class _$AssistantMessageCopyWithImpl<$Res>
    implements $AssistantMessageCopyWith<$Res> {
  _$AssistantMessageCopyWithImpl(this._self, this._then);

  final AssistantMessage _self;
  final $Res Function(AssistantMessage) _then;

/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? content = null,Object? createdAt = null,Object? usedTools = null,Object? proposedActions = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AssistantMessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,usedTools: null == usedTools ? _self.usedTools : usedTools // ignore: cast_nullable_to_non_nullable
as List<String>,proposedActions: null == proposedActions ? _self.proposedActions : proposedActions // ignore: cast_nullable_to_non_nullable
as List<AssistantProposedAction>,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantMessage].
extension AssistantMessagePatterns on AssistantMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantMessage value)  $default,){
final _that = this;
switch (_that) {
case _AssistantMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantMessage value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AssistantMessageRole role,  String content,  DateTime createdAt,  List<String> usedTools,  List<AssistantProposedAction> proposedActions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
return $default(_that.role,_that.content,_that.createdAt,_that.usedTools,_that.proposedActions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AssistantMessageRole role,  String content,  DateTime createdAt,  List<String> usedTools,  List<AssistantProposedAction> proposedActions)  $default,) {final _that = this;
switch (_that) {
case _AssistantMessage():
return $default(_that.role,_that.content,_that.createdAt,_that.usedTools,_that.proposedActions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AssistantMessageRole role,  String content,  DateTime createdAt,  List<String> usedTools,  List<AssistantProposedAction> proposedActions)?  $default,) {final _that = this;
switch (_that) {
case _AssistantMessage() when $default != null:
return $default(_that.role,_that.content,_that.createdAt,_that.usedTools,_that.proposedActions);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantMessage with DiagnosticableTreeMixin implements AssistantMessage {
  const _AssistantMessage({required this.role, required this.content, required this.createdAt, final  List<String> usedTools = const <String>[], final  List<AssistantProposedAction> proposedActions = const <AssistantProposedAction>[]}): _usedTools = usedTools,_proposedActions = proposedActions;
  

@override final  AssistantMessageRole role;
@override final  String content;
@override final  DateTime createdAt;
 final  List<String> _usedTools;
@override@JsonKey() List<String> get usedTools {
  if (_usedTools is EqualUnmodifiableListView) return _usedTools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usedTools);
}

 final  List<AssistantProposedAction> _proposedActions;
@override@JsonKey() List<AssistantProposedAction> get proposedActions {
  if (_proposedActions is EqualUnmodifiableListView) return _proposedActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proposedActions);
}


/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantMessageCopyWith<_AssistantMessage> get copyWith => __$AssistantMessageCopyWithImpl<_AssistantMessage>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AssistantMessage'))
    ..add(DiagnosticsProperty('role', role))..add(DiagnosticsProperty('content', content))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('usedTools', usedTools))..add(DiagnosticsProperty('proposedActions', proposedActions));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._usedTools, _usedTools)&&const DeepCollectionEquality().equals(other._proposedActions, _proposedActions));
}


@override
int get hashCode => Object.hash(runtimeType,role,content,createdAt,const DeepCollectionEquality().hash(_usedTools),const DeepCollectionEquality().hash(_proposedActions));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AssistantMessage(role: $role, content: $content, createdAt: $createdAt, usedTools: $usedTools, proposedActions: $proposedActions)';
}


}

/// @nodoc
abstract mixin class _$AssistantMessageCopyWith<$Res> implements $AssistantMessageCopyWith<$Res> {
  factory _$AssistantMessageCopyWith(_AssistantMessage value, $Res Function(_AssistantMessage) _then) = __$AssistantMessageCopyWithImpl;
@override @useResult
$Res call({
 AssistantMessageRole role, String content, DateTime createdAt, List<String> usedTools, List<AssistantProposedAction> proposedActions
});




}
/// @nodoc
class __$AssistantMessageCopyWithImpl<$Res>
    implements _$AssistantMessageCopyWith<$Res> {
  __$AssistantMessageCopyWithImpl(this._self, this._then);

  final _AssistantMessage _self;
  final $Res Function(_AssistantMessage) _then;

/// Create a copy of AssistantMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? content = null,Object? createdAt = null,Object? usedTools = null,Object? proposedActions = null,}) {
  return _then(_AssistantMessage(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AssistantMessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,usedTools: null == usedTools ? _self._usedTools : usedTools // ignore: cast_nullable_to_non_nullable
as List<String>,proposedActions: null == proposedActions ? _self._proposedActions : proposedActions // ignore: cast_nullable_to_non_nullable
as List<AssistantProposedAction>,
  ));
}


}

// dart format on
