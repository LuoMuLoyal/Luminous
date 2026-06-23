// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'record_nlp_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecordNlpState {

 RecordNlpStatus get status; String get draft; List<RecordNlpCandidateDraft> get candidates; RecordNlpResultMeta? get resultMeta; String? get errorMessage;
/// Create a copy of RecordNlpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordNlpStateCopyWith<RecordNlpState> get copyWith => _$RecordNlpStateCopyWithImpl<RecordNlpState>(this as RecordNlpState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordNlpState&&(identical(other.status, status) || other.status == status)&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other.candidates, candidates)&&(identical(other.resultMeta, resultMeta) || other.resultMeta == resultMeta)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,draft,const DeepCollectionEquality().hash(candidates),resultMeta,errorMessage);

@override
String toString() {
  return 'RecordNlpState(status: $status, draft: $draft, candidates: $candidates, resultMeta: $resultMeta, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $RecordNlpStateCopyWith<$Res>  {
  factory $RecordNlpStateCopyWith(RecordNlpState value, $Res Function(RecordNlpState) _then) = _$RecordNlpStateCopyWithImpl;
@useResult
$Res call({
 RecordNlpStatus status, String draft, List<RecordNlpCandidateDraft> candidates, RecordNlpResultMeta? resultMeta, String? errorMessage
});




}
/// @nodoc
class _$RecordNlpStateCopyWithImpl<$Res>
    implements $RecordNlpStateCopyWith<$Res> {
  _$RecordNlpStateCopyWithImpl(this._self, this._then);

  final RecordNlpState _self;
  final $Res Function(RecordNlpState) _then;

/// Create a copy of RecordNlpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? draft = null,Object? candidates = null,Object? resultMeta = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecordNlpStatus,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<RecordNlpCandidateDraft>,resultMeta: freezed == resultMeta ? _self.resultMeta : resultMeta // ignore: cast_nullable_to_non_nullable
as RecordNlpResultMeta?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordNlpState].
extension RecordNlpStatePatterns on RecordNlpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordNlpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordNlpState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordNlpState value)  $default,){
final _that = this;
switch (_that) {
case _RecordNlpState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordNlpState value)?  $default,){
final _that = this;
switch (_that) {
case _RecordNlpState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordNlpStatus status,  String draft,  List<RecordNlpCandidateDraft> candidates,  RecordNlpResultMeta? resultMeta,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordNlpState() when $default != null:
return $default(_that.status,_that.draft,_that.candidates,_that.resultMeta,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordNlpStatus status,  String draft,  List<RecordNlpCandidateDraft> candidates,  RecordNlpResultMeta? resultMeta,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _RecordNlpState():
return $default(_that.status,_that.draft,_that.candidates,_that.resultMeta,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordNlpStatus status,  String draft,  List<RecordNlpCandidateDraft> candidates,  RecordNlpResultMeta? resultMeta,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _RecordNlpState() when $default != null:
return $default(_that.status,_that.draft,_that.candidates,_that.resultMeta,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _RecordNlpState extends RecordNlpState {
  const _RecordNlpState({this.status = RecordNlpStatus.idle, this.draft = '', final  List<RecordNlpCandidateDraft> candidates = const [], this.resultMeta, this.errorMessage}): _candidates = candidates,super._();
  

@override@JsonKey() final  RecordNlpStatus status;
@override@JsonKey() final  String draft;
 final  List<RecordNlpCandidateDraft> _candidates;
@override@JsonKey() List<RecordNlpCandidateDraft> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}

@override final  RecordNlpResultMeta? resultMeta;
@override final  String? errorMessage;

/// Create a copy of RecordNlpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordNlpStateCopyWith<_RecordNlpState> get copyWith => __$RecordNlpStateCopyWithImpl<_RecordNlpState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordNlpState&&(identical(other.status, status) || other.status == status)&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other._candidates, _candidates)&&(identical(other.resultMeta, resultMeta) || other.resultMeta == resultMeta)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,draft,const DeepCollectionEquality().hash(_candidates),resultMeta,errorMessage);

@override
String toString() {
  return 'RecordNlpState(status: $status, draft: $draft, candidates: $candidates, resultMeta: $resultMeta, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$RecordNlpStateCopyWith<$Res> implements $RecordNlpStateCopyWith<$Res> {
  factory _$RecordNlpStateCopyWith(_RecordNlpState value, $Res Function(_RecordNlpState) _then) = __$RecordNlpStateCopyWithImpl;
@override @useResult
$Res call({
 RecordNlpStatus status, String draft, List<RecordNlpCandidateDraft> candidates, RecordNlpResultMeta? resultMeta, String? errorMessage
});




}
/// @nodoc
class __$RecordNlpStateCopyWithImpl<$Res>
    implements _$RecordNlpStateCopyWith<$Res> {
  __$RecordNlpStateCopyWithImpl(this._self, this._then);

  final _RecordNlpState _self;
  final $Res Function(_RecordNlpState) _then;

/// Create a copy of RecordNlpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? draft = null,Object? candidates = null,Object? resultMeta = freezed,Object? errorMessage = freezed,}) {
  return _then(_RecordNlpState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecordNlpStatus,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String,candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<RecordNlpCandidateDraft>,resultMeta: freezed == resultMeta ? _self.resultMeta : resultMeta // ignore: cast_nullable_to_non_nullable
as RecordNlpResultMeta?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$RecordNlpCandidateDraft {

 DailyRecordKind get kind; String get occurredAt; String? get title; String? get value; String? get unit; String? get note; Map<String, dynamic>? get payload; String get rationale; bool get selected; String? get lastErrorMessage;
/// Create a copy of RecordNlpCandidateDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordNlpCandidateDraftCopyWith<RecordNlpCandidateDraft> get copyWith => _$RecordNlpCandidateDraftCopyWithImpl<RecordNlpCandidateDraft>(this as RecordNlpCandidateDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordNlpCandidateDraft&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.lastErrorMessage, lastErrorMessage) || other.lastErrorMessage == lastErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,kind,occurredAt,title,value,unit,note,const DeepCollectionEquality().hash(payload),rationale,selected,lastErrorMessage);

@override
String toString() {
  return 'RecordNlpCandidateDraft(kind: $kind, occurredAt: $occurredAt, title: $title, value: $value, unit: $unit, note: $note, payload: $payload, rationale: $rationale, selected: $selected, lastErrorMessage: $lastErrorMessage)';
}


}

/// @nodoc
abstract mixin class $RecordNlpCandidateDraftCopyWith<$Res>  {
  factory $RecordNlpCandidateDraftCopyWith(RecordNlpCandidateDraft value, $Res Function(RecordNlpCandidateDraft) _then) = _$RecordNlpCandidateDraftCopyWithImpl;
@useResult
$Res call({
 DailyRecordKind kind, String occurredAt, String? title, String? value, String? unit, String? note, Map<String, dynamic>? payload, String rationale, bool selected, String? lastErrorMessage
});




}
/// @nodoc
class _$RecordNlpCandidateDraftCopyWithImpl<$Res>
    implements $RecordNlpCandidateDraftCopyWith<$Res> {
  _$RecordNlpCandidateDraftCopyWithImpl(this._self, this._then);

  final RecordNlpCandidateDraft _self;
  final $Res Function(RecordNlpCandidateDraft) _then;

/// Create a copy of RecordNlpCandidateDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? occurredAt = null,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? payload = freezed,Object? rationale = null,Object? selected = null,Object? lastErrorMessage = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,lastErrorMessage: freezed == lastErrorMessage ? _self.lastErrorMessage : lastErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordNlpCandidateDraft].
extension RecordNlpCandidateDraftPatterns on RecordNlpCandidateDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordNlpCandidateDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordNlpCandidateDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordNlpCandidateDraft value)  $default,){
final _that = this;
switch (_that) {
case _RecordNlpCandidateDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordNlpCandidateDraft value)?  $default,){
final _that = this;
switch (_that) {
case _RecordNlpCandidateDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DailyRecordKind kind,  String occurredAt,  String? title,  String? value,  String? unit,  String? note,  Map<String, dynamic>? payload,  String rationale,  bool selected,  String? lastErrorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordNlpCandidateDraft() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.rationale,_that.selected,_that.lastErrorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DailyRecordKind kind,  String occurredAt,  String? title,  String? value,  String? unit,  String? note,  Map<String, dynamic>? payload,  String rationale,  bool selected,  String? lastErrorMessage)  $default,) {final _that = this;
switch (_that) {
case _RecordNlpCandidateDraft():
return $default(_that.kind,_that.occurredAt,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.rationale,_that.selected,_that.lastErrorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DailyRecordKind kind,  String occurredAt,  String? title,  String? value,  String? unit,  String? note,  Map<String, dynamic>? payload,  String rationale,  bool selected,  String? lastErrorMessage)?  $default,) {final _that = this;
switch (_that) {
case _RecordNlpCandidateDraft() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.rationale,_that.selected,_that.lastErrorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _RecordNlpCandidateDraft extends RecordNlpCandidateDraft {
  const _RecordNlpCandidateDraft({required this.kind, required this.occurredAt, this.title, this.value, this.unit, this.note, final  Map<String, dynamic>? payload, required this.rationale, this.selected = true, this.lastErrorMessage}): _payload = payload,super._();
  

@override final  DailyRecordKind kind;
@override final  String occurredAt;
@override final  String? title;
@override final  String? value;
@override final  String? unit;
@override final  String? note;
 final  Map<String, dynamic>? _payload;
@override Map<String, dynamic>? get payload {
  final value = _payload;
  if (value == null) return null;
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String rationale;
@override@JsonKey() final  bool selected;
@override final  String? lastErrorMessage;

/// Create a copy of RecordNlpCandidateDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordNlpCandidateDraftCopyWith<_RecordNlpCandidateDraft> get copyWith => __$RecordNlpCandidateDraftCopyWithImpl<_RecordNlpCandidateDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordNlpCandidateDraft&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.lastErrorMessage, lastErrorMessage) || other.lastErrorMessage == lastErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,kind,occurredAt,title,value,unit,note,const DeepCollectionEquality().hash(_payload),rationale,selected,lastErrorMessage);

@override
String toString() {
  return 'RecordNlpCandidateDraft(kind: $kind, occurredAt: $occurredAt, title: $title, value: $value, unit: $unit, note: $note, payload: $payload, rationale: $rationale, selected: $selected, lastErrorMessage: $lastErrorMessage)';
}


}

/// @nodoc
abstract mixin class _$RecordNlpCandidateDraftCopyWith<$Res> implements $RecordNlpCandidateDraftCopyWith<$Res> {
  factory _$RecordNlpCandidateDraftCopyWith(_RecordNlpCandidateDraft value, $Res Function(_RecordNlpCandidateDraft) _then) = __$RecordNlpCandidateDraftCopyWithImpl;
@override @useResult
$Res call({
 DailyRecordKind kind, String occurredAt, String? title, String? value, String? unit, String? note, Map<String, dynamic>? payload, String rationale, bool selected, String? lastErrorMessage
});




}
/// @nodoc
class __$RecordNlpCandidateDraftCopyWithImpl<$Res>
    implements _$RecordNlpCandidateDraftCopyWith<$Res> {
  __$RecordNlpCandidateDraftCopyWithImpl(this._self, this._then);

  final _RecordNlpCandidateDraft _self;
  final $Res Function(_RecordNlpCandidateDraft) _then;

/// Create a copy of RecordNlpCandidateDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? occurredAt = null,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? payload = freezed,Object? rationale = null,Object? selected = null,Object? lastErrorMessage = freezed,}) {
  return _then(_RecordNlpCandidateDraft(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,lastErrorMessage: freezed == lastErrorMessage ? _self.lastErrorMessage : lastErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
