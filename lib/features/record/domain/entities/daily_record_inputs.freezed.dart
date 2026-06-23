// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_record_inputs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyRecordCreateInput {

 DailyRecordKind get kind; String get occurredAt; String? get occurredTime; String? get title; String? get value; String? get unit; String? get note; Map<String, dynamic>? get payload; List<DailyRecordAttachmentInput> get attachments;
/// Create a copy of DailyRecordCreateInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordCreateInputCopyWith<DailyRecordCreateInput> get copyWith => _$DailyRecordCreateInputCopyWithImpl<DailyRecordCreateInput>(this as DailyRecordCreateInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordCreateInput&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.occurredTime, occurredTime) || other.occurredTime == occurredTime)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.payload, payload)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}


@override
int get hashCode => Object.hash(runtimeType,kind,occurredAt,occurredTime,title,value,unit,note,const DeepCollectionEquality().hash(payload),const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'DailyRecordCreateInput(kind: $kind, occurredAt: $occurredAt, occurredTime: $occurredTime, title: $title, value: $value, unit: $unit, note: $note, payload: $payload, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $DailyRecordCreateInputCopyWith<$Res>  {
  factory $DailyRecordCreateInputCopyWith(DailyRecordCreateInput value, $Res Function(DailyRecordCreateInput) _then) = _$DailyRecordCreateInputCopyWithImpl;
@useResult
$Res call({
 DailyRecordKind kind, String occurredAt, String? occurredTime, String? title, String? value, String? unit, String? note, Map<String, dynamic>? payload, List<DailyRecordAttachmentInput> attachments
});




}
/// @nodoc
class _$DailyRecordCreateInputCopyWithImpl<$Res>
    implements $DailyRecordCreateInputCopyWith<$Res> {
  _$DailyRecordCreateInputCopyWithImpl(this._self, this._then);

  final DailyRecordCreateInput _self;
  final $Res Function(DailyRecordCreateInput) _then;

/// Create a copy of DailyRecordCreateInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? occurredAt = null,Object? occurredTime = freezed,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? payload = freezed,Object? attachments = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,occurredTime: freezed == occurredTime ? _self.occurredTime : occurredTime // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<DailyRecordAttachmentInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordCreateInput].
extension DailyRecordCreateInputPatterns on DailyRecordCreateInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordCreateInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordCreateInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordCreateInput value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordCreateInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordCreateInput value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordCreateInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DailyRecordKind kind,  String occurredAt,  String? occurredTime,  String? title,  String? value,  String? unit,  String? note,  Map<String, dynamic>? payload,  List<DailyRecordAttachmentInput> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordCreateInput() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.occurredTime,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DailyRecordKind kind,  String occurredAt,  String? occurredTime,  String? title,  String? value,  String? unit,  String? note,  Map<String, dynamic>? payload,  List<DailyRecordAttachmentInput> attachments)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordCreateInput():
return $default(_that.kind,_that.occurredAt,_that.occurredTime,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DailyRecordKind kind,  String occurredAt,  String? occurredTime,  String? title,  String? value,  String? unit,  String? note,  Map<String, dynamic>? payload,  List<DailyRecordAttachmentInput> attachments)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordCreateInput() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.occurredTime,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordCreateInput implements DailyRecordCreateInput {
  const _DailyRecordCreateInput({required this.kind, required this.occurredAt, this.occurredTime, this.title, this.value, this.unit, this.note, final  Map<String, dynamic>? payload, final  List<DailyRecordAttachmentInput> attachments = const []}): _payload = payload,_attachments = attachments;
  

@override final  DailyRecordKind kind;
@override final  String occurredAt;
@override final  String? occurredTime;
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

 final  List<DailyRecordAttachmentInput> _attachments;
@override@JsonKey() List<DailyRecordAttachmentInput> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of DailyRecordCreateInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordCreateInputCopyWith<_DailyRecordCreateInput> get copyWith => __$DailyRecordCreateInputCopyWithImpl<_DailyRecordCreateInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordCreateInput&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.occurredTime, occurredTime) || other.occurredTime == occurredTime)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._payload, _payload)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}


@override
int get hashCode => Object.hash(runtimeType,kind,occurredAt,occurredTime,title,value,unit,note,const DeepCollectionEquality().hash(_payload),const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'DailyRecordCreateInput(kind: $kind, occurredAt: $occurredAt, occurredTime: $occurredTime, title: $title, value: $value, unit: $unit, note: $note, payload: $payload, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordCreateInputCopyWith<$Res> implements $DailyRecordCreateInputCopyWith<$Res> {
  factory _$DailyRecordCreateInputCopyWith(_DailyRecordCreateInput value, $Res Function(_DailyRecordCreateInput) _then) = __$DailyRecordCreateInputCopyWithImpl;
@override @useResult
$Res call({
 DailyRecordKind kind, String occurredAt, String? occurredTime, String? title, String? value, String? unit, String? note, Map<String, dynamic>? payload, List<DailyRecordAttachmentInput> attachments
});




}
/// @nodoc
class __$DailyRecordCreateInputCopyWithImpl<$Res>
    implements _$DailyRecordCreateInputCopyWith<$Res> {
  __$DailyRecordCreateInputCopyWithImpl(this._self, this._then);

  final _DailyRecordCreateInput _self;
  final $Res Function(_DailyRecordCreateInput) _then;

/// Create a copy of DailyRecordCreateInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? occurredAt = null,Object? occurredTime = freezed,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? payload = freezed,Object? attachments = null,}) {
  return _then(_DailyRecordCreateInput(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,occurredTime: freezed == occurredTime ? _self.occurredTime : occurredTime // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<DailyRecordAttachmentInput>,
  ));
}


}

/// @nodoc
mixin _$DailyRecordUpdateInput {

 Object? get kind; Object? get occurredAt; Object? get occurredTime; Object? get title; Object? get value; Object? get unit; Object? get note; Object? get payload;/// Attachment PATCH semantics:
/// - [dailyRecordNoChange]: omit field and keep existing attachments.
/// - empty list: send [] and clear attachments.
/// - non-empty list: replace attachments with the given metadata list.
 Object? get attachments;
/// Create a copy of DailyRecordUpdateInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordUpdateInputCopyWith<DailyRecordUpdateInput> get copyWith => _$DailyRecordUpdateInputCopyWithImpl<DailyRecordUpdateInput>(this as DailyRecordUpdateInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordUpdateInput&&const DeepCollectionEquality().equals(other.kind, kind)&&const DeepCollectionEquality().equals(other.occurredAt, occurredAt)&&const DeepCollectionEquality().equals(other.occurredTime, occurredTime)&&const DeepCollectionEquality().equals(other.title, title)&&const DeepCollectionEquality().equals(other.value, value)&&const DeepCollectionEquality().equals(other.unit, unit)&&const DeepCollectionEquality().equals(other.note, note)&&const DeepCollectionEquality().equals(other.payload, payload)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(kind),const DeepCollectionEquality().hash(occurredAt),const DeepCollectionEquality().hash(occurredTime),const DeepCollectionEquality().hash(title),const DeepCollectionEquality().hash(value),const DeepCollectionEquality().hash(unit),const DeepCollectionEquality().hash(note),const DeepCollectionEquality().hash(payload),const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'DailyRecordUpdateInput(kind: $kind, occurredAt: $occurredAt, occurredTime: $occurredTime, title: $title, value: $value, unit: $unit, note: $note, payload: $payload, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $DailyRecordUpdateInputCopyWith<$Res>  {
  factory $DailyRecordUpdateInputCopyWith(DailyRecordUpdateInput value, $Res Function(DailyRecordUpdateInput) _then) = _$DailyRecordUpdateInputCopyWithImpl;
@useResult
$Res call({
 Object? kind, Object? occurredAt, Object? occurredTime, Object? title, Object? value, Object? unit, Object? note, Object? payload, Object? attachments
});




}
/// @nodoc
class _$DailyRecordUpdateInputCopyWithImpl<$Res>
    implements $DailyRecordUpdateInputCopyWith<$Res> {
  _$DailyRecordUpdateInputCopyWithImpl(this._self, this._then);

  final DailyRecordUpdateInput _self;
  final $Res Function(DailyRecordUpdateInput) _then;

/// Create a copy of DailyRecordUpdateInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = freezed,Object? occurredAt = freezed,Object? occurredTime = freezed,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? payload = freezed,Object? attachments = freezed,}) {
  return _then(_self.copyWith(
kind: freezed == kind ? _self.kind : kind ,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt ,occurredTime: freezed == occurredTime ? _self.occurredTime : occurredTime ,title: freezed == title ? _self.title : title ,value: freezed == value ? _self.value : value ,unit: freezed == unit ? _self.unit : unit ,note: freezed == note ? _self.note : note ,payload: freezed == payload ? _self.payload : payload ,attachments: freezed == attachments ? _self.attachments : attachments ,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordUpdateInput].
extension DailyRecordUpdateInputPatterns on DailyRecordUpdateInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordUpdateInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordUpdateInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordUpdateInput value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordUpdateInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordUpdateInput value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordUpdateInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Object? kind,  Object? occurredAt,  Object? occurredTime,  Object? title,  Object? value,  Object? unit,  Object? note,  Object? payload,  Object? attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordUpdateInput() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.occurredTime,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Object? kind,  Object? occurredAt,  Object? occurredTime,  Object? title,  Object? value,  Object? unit,  Object? note,  Object? payload,  Object? attachments)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordUpdateInput():
return $default(_that.kind,_that.occurredAt,_that.occurredTime,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Object? kind,  Object? occurredAt,  Object? occurredTime,  Object? title,  Object? value,  Object? unit,  Object? note,  Object? payload,  Object? attachments)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordUpdateInput() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.occurredTime,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordUpdateInput implements DailyRecordUpdateInput {
  const _DailyRecordUpdateInput({this.kind = dailyRecordNoChange, this.occurredAt = dailyRecordNoChange, this.occurredTime = dailyRecordNoChange, this.title = dailyRecordNoChange, this.value = dailyRecordNoChange, this.unit = dailyRecordNoChange, this.note = dailyRecordNoChange, this.payload = dailyRecordNoChange, this.attachments = dailyRecordNoChange});
  

@override@JsonKey() final  Object? kind;
@override@JsonKey() final  Object? occurredAt;
@override@JsonKey() final  Object? occurredTime;
@override@JsonKey() final  Object? title;
@override@JsonKey() final  Object? value;
@override@JsonKey() final  Object? unit;
@override@JsonKey() final  Object? note;
@override@JsonKey() final  Object? payload;
/// Attachment PATCH semantics:
/// - [dailyRecordNoChange]: omit field and keep existing attachments.
/// - empty list: send [] and clear attachments.
/// - non-empty list: replace attachments with the given metadata list.
@override@JsonKey() final  Object? attachments;

/// Create a copy of DailyRecordUpdateInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordUpdateInputCopyWith<_DailyRecordUpdateInput> get copyWith => __$DailyRecordUpdateInputCopyWithImpl<_DailyRecordUpdateInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordUpdateInput&&const DeepCollectionEquality().equals(other.kind, kind)&&const DeepCollectionEquality().equals(other.occurredAt, occurredAt)&&const DeepCollectionEquality().equals(other.occurredTime, occurredTime)&&const DeepCollectionEquality().equals(other.title, title)&&const DeepCollectionEquality().equals(other.value, value)&&const DeepCollectionEquality().equals(other.unit, unit)&&const DeepCollectionEquality().equals(other.note, note)&&const DeepCollectionEquality().equals(other.payload, payload)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(kind),const DeepCollectionEquality().hash(occurredAt),const DeepCollectionEquality().hash(occurredTime),const DeepCollectionEquality().hash(title),const DeepCollectionEquality().hash(value),const DeepCollectionEquality().hash(unit),const DeepCollectionEquality().hash(note),const DeepCollectionEquality().hash(payload),const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'DailyRecordUpdateInput(kind: $kind, occurredAt: $occurredAt, occurredTime: $occurredTime, title: $title, value: $value, unit: $unit, note: $note, payload: $payload, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordUpdateInputCopyWith<$Res> implements $DailyRecordUpdateInputCopyWith<$Res> {
  factory _$DailyRecordUpdateInputCopyWith(_DailyRecordUpdateInput value, $Res Function(_DailyRecordUpdateInput) _then) = __$DailyRecordUpdateInputCopyWithImpl;
@override @useResult
$Res call({
 Object? kind, Object? occurredAt, Object? occurredTime, Object? title, Object? value, Object? unit, Object? note, Object? payload, Object? attachments
});




}
/// @nodoc
class __$DailyRecordUpdateInputCopyWithImpl<$Res>
    implements _$DailyRecordUpdateInputCopyWith<$Res> {
  __$DailyRecordUpdateInputCopyWithImpl(this._self, this._then);

  final _DailyRecordUpdateInput _self;
  final $Res Function(_DailyRecordUpdateInput) _then;

/// Create a copy of DailyRecordUpdateInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = freezed,Object? occurredAt = freezed,Object? occurredTime = freezed,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? payload = freezed,Object? attachments = freezed,}) {
  return _then(_DailyRecordUpdateInput(
kind: freezed == kind ? _self.kind : kind ,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt ,occurredTime: freezed == occurredTime ? _self.occurredTime : occurredTime ,title: freezed == title ? _self.title : title ,value: freezed == value ? _self.value : value ,unit: freezed == unit ? _self.unit : unit ,note: freezed == note ? _self.note : note ,payload: freezed == payload ? _self.payload : payload ,attachments: freezed == attachments ? _self.attachments : attachments ,
  ));
}


}

/// @nodoc
mixin _$DailyRecordAttachmentInput {

 String get objectKey; String? get bucket; String? get provider; String? get fileName; String? get contentType; int? get sizeBytes; int? get width; int? get height; String? get publicUrl;
/// Create a copy of DailyRecordAttachmentInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordAttachmentInputCopyWith<DailyRecordAttachmentInput> get copyWith => _$DailyRecordAttachmentInputCopyWithImpl<DailyRecordAttachmentInput>(this as DailyRecordAttachmentInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordAttachmentInput&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.publicUrl, publicUrl) || other.publicUrl == publicUrl));
}


@override
int get hashCode => Object.hash(runtimeType,objectKey,bucket,provider,fileName,contentType,sizeBytes,width,height,publicUrl);

@override
String toString() {
  return 'DailyRecordAttachmentInput(objectKey: $objectKey, bucket: $bucket, provider: $provider, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, width: $width, height: $height, publicUrl: $publicUrl)';
}


}

/// @nodoc
abstract mixin class $DailyRecordAttachmentInputCopyWith<$Res>  {
  factory $DailyRecordAttachmentInputCopyWith(DailyRecordAttachmentInput value, $Res Function(DailyRecordAttachmentInput) _then) = _$DailyRecordAttachmentInputCopyWithImpl;
@useResult
$Res call({
 String objectKey, String? bucket, String? provider, String? fileName, String? contentType, int? sizeBytes, int? width, int? height, String? publicUrl
});




}
/// @nodoc
class _$DailyRecordAttachmentInputCopyWithImpl<$Res>
    implements $DailyRecordAttachmentInputCopyWith<$Res> {
  _$DailyRecordAttachmentInputCopyWithImpl(this._self, this._then);

  final DailyRecordAttachmentInput _self;
  final $Res Function(DailyRecordAttachmentInput) _then;

/// Create a copy of DailyRecordAttachmentInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? objectKey = null,Object? bucket = freezed,Object? provider = freezed,Object? fileName = freezed,Object? contentType = freezed,Object? sizeBytes = freezed,Object? width = freezed,Object? height = freezed,Object? publicUrl = freezed,}) {
  return _then(_self.copyWith(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,publicUrl: freezed == publicUrl ? _self.publicUrl : publicUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordAttachmentInput].
extension DailyRecordAttachmentInputPatterns on DailyRecordAttachmentInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordAttachmentInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordAttachmentInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordAttachmentInput value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordAttachmentInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordAttachmentInput value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordAttachmentInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String objectKey,  String? bucket,  String? provider,  String? fileName,  String? contentType,  int? sizeBytes,  int? width,  int? height,  String? publicUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordAttachmentInput() when $default != null:
return $default(_that.objectKey,_that.bucket,_that.provider,_that.fileName,_that.contentType,_that.sizeBytes,_that.width,_that.height,_that.publicUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String objectKey,  String? bucket,  String? provider,  String? fileName,  String? contentType,  int? sizeBytes,  int? width,  int? height,  String? publicUrl)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordAttachmentInput():
return $default(_that.objectKey,_that.bucket,_that.provider,_that.fileName,_that.contentType,_that.sizeBytes,_that.width,_that.height,_that.publicUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String objectKey,  String? bucket,  String? provider,  String? fileName,  String? contentType,  int? sizeBytes,  int? width,  int? height,  String? publicUrl)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordAttachmentInput() when $default != null:
return $default(_that.objectKey,_that.bucket,_that.provider,_that.fileName,_that.contentType,_that.sizeBytes,_that.width,_that.height,_that.publicUrl);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordAttachmentInput implements DailyRecordAttachmentInput {
  const _DailyRecordAttachmentInput({required this.objectKey, this.bucket, this.provider, this.fileName, this.contentType, this.sizeBytes, this.width, this.height, this.publicUrl});
  

@override final  String objectKey;
@override final  String? bucket;
@override final  String? provider;
@override final  String? fileName;
@override final  String? contentType;
@override final  int? sizeBytes;
@override final  int? width;
@override final  int? height;
@override final  String? publicUrl;

/// Create a copy of DailyRecordAttachmentInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordAttachmentInputCopyWith<_DailyRecordAttachmentInput> get copyWith => __$DailyRecordAttachmentInputCopyWithImpl<_DailyRecordAttachmentInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordAttachmentInput&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.publicUrl, publicUrl) || other.publicUrl == publicUrl));
}


@override
int get hashCode => Object.hash(runtimeType,objectKey,bucket,provider,fileName,contentType,sizeBytes,width,height,publicUrl);

@override
String toString() {
  return 'DailyRecordAttachmentInput(objectKey: $objectKey, bucket: $bucket, provider: $provider, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, width: $width, height: $height, publicUrl: $publicUrl)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordAttachmentInputCopyWith<$Res> implements $DailyRecordAttachmentInputCopyWith<$Res> {
  factory _$DailyRecordAttachmentInputCopyWith(_DailyRecordAttachmentInput value, $Res Function(_DailyRecordAttachmentInput) _then) = __$DailyRecordAttachmentInputCopyWithImpl;
@override @useResult
$Res call({
 String objectKey, String? bucket, String? provider, String? fileName, String? contentType, int? sizeBytes, int? width, int? height, String? publicUrl
});




}
/// @nodoc
class __$DailyRecordAttachmentInputCopyWithImpl<$Res>
    implements _$DailyRecordAttachmentInputCopyWith<$Res> {
  __$DailyRecordAttachmentInputCopyWithImpl(this._self, this._then);

  final _DailyRecordAttachmentInput _self;
  final $Res Function(_DailyRecordAttachmentInput) _then;

/// Create a copy of DailyRecordAttachmentInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? objectKey = null,Object? bucket = freezed,Object? provider = freezed,Object? fileName = freezed,Object? contentType = freezed,Object? sizeBytes = freezed,Object? width = freezed,Object? height = freezed,Object? publicUrl = freezed,}) {
  return _then(_DailyRecordAttachmentInput(
objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,publicUrl: freezed == publicUrl ? _self.publicUrl : publicUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$DailyRecordImageUploadInput {

 List<int> get bytes; String get contentType; int get sizeBytes; String? get fileName;
/// Create a copy of DailyRecordImageUploadInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordImageUploadInputCopyWith<DailyRecordImageUploadInput> get copyWith => _$DailyRecordImageUploadInputCopyWithImpl<DailyRecordImageUploadInput>(this as DailyRecordImageUploadInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordImageUploadInput&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),contentType,sizeBytes,fileName);

@override
String toString() {
  return 'DailyRecordImageUploadInput(bytes: $bytes, contentType: $contentType, sizeBytes: $sizeBytes, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $DailyRecordImageUploadInputCopyWith<$Res>  {
  factory $DailyRecordImageUploadInputCopyWith(DailyRecordImageUploadInput value, $Res Function(DailyRecordImageUploadInput) _then) = _$DailyRecordImageUploadInputCopyWithImpl;
@useResult
$Res call({
 List<int> bytes, String contentType, int sizeBytes, String? fileName
});




}
/// @nodoc
class _$DailyRecordImageUploadInputCopyWithImpl<$Res>
    implements $DailyRecordImageUploadInputCopyWith<$Res> {
  _$DailyRecordImageUploadInputCopyWithImpl(this._self, this._then);

  final DailyRecordImageUploadInput _self;
  final $Res Function(DailyRecordImageUploadInput) _then;

/// Create a copy of DailyRecordImageUploadInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bytes = null,Object? contentType = null,Object? sizeBytes = null,Object? fileName = freezed,}) {
  return _then(_self.copyWith(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as List<int>,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordImageUploadInput].
extension DailyRecordImageUploadInputPatterns on DailyRecordImageUploadInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordImageUploadInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordImageUploadInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordImageUploadInput value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordImageUploadInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordImageUploadInput value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordImageUploadInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> bytes,  String contentType,  int sizeBytes,  String? fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordImageUploadInput() when $default != null:
return $default(_that.bytes,_that.contentType,_that.sizeBytes,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> bytes,  String contentType,  int sizeBytes,  String? fileName)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordImageUploadInput():
return $default(_that.bytes,_that.contentType,_that.sizeBytes,_that.fileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> bytes,  String contentType,  int sizeBytes,  String? fileName)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordImageUploadInput() when $default != null:
return $default(_that.bytes,_that.contentType,_that.sizeBytes,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordImageUploadInput implements DailyRecordImageUploadInput {
  const _DailyRecordImageUploadInput({required final  List<int> bytes, required this.contentType, required this.sizeBytes, this.fileName}): _bytes = bytes;
  

 final  List<int> _bytes;
@override List<int> get bytes {
  if (_bytes is EqualUnmodifiableListView) return _bytes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bytes);
}

@override final  String contentType;
@override final  int sizeBytes;
@override final  String? fileName;

/// Create a copy of DailyRecordImageUploadInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordImageUploadInputCopyWith<_DailyRecordImageUploadInput> get copyWith => __$DailyRecordImageUploadInputCopyWithImpl<_DailyRecordImageUploadInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordImageUploadInput&&const DeepCollectionEquality().equals(other._bytes, _bytes)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bytes),contentType,sizeBytes,fileName);

@override
String toString() {
  return 'DailyRecordImageUploadInput(bytes: $bytes, contentType: $contentType, sizeBytes: $sizeBytes, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordImageUploadInputCopyWith<$Res> implements $DailyRecordImageUploadInputCopyWith<$Res> {
  factory _$DailyRecordImageUploadInputCopyWith(_DailyRecordImageUploadInput value, $Res Function(_DailyRecordImageUploadInput) _then) = __$DailyRecordImageUploadInputCopyWithImpl;
@override @useResult
$Res call({
 List<int> bytes, String contentType, int sizeBytes, String? fileName
});




}
/// @nodoc
class __$DailyRecordImageUploadInputCopyWithImpl<$Res>
    implements _$DailyRecordImageUploadInputCopyWith<$Res> {
  __$DailyRecordImageUploadInputCopyWithImpl(this._self, this._then);

  final _DailyRecordImageUploadInput _self;
  final $Res Function(_DailyRecordImageUploadInput) _then;

/// Create a copy of DailyRecordImageUploadInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? contentType = null,Object? sizeBytes = null,Object? fileName = freezed,}) {
  return _then(_DailyRecordImageUploadInput(
bytes: null == bytes ? _self._bytes : bytes // ignore: cast_nullable_to_non_nullable
as List<int>,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
