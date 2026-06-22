// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_edit_forms.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HealthProfileFormState {

 bool get isSaving; String? get errorMessage; bool get saved;
/// Create a copy of HealthProfileFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthProfileFormStateCopyWith<HealthProfileFormState> get copyWith => _$HealthProfileFormStateCopyWithImpl<HealthProfileFormState>(this as HealthProfileFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthProfileFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,saved);

@override
String toString() {
  return 'HealthProfileFormState(isSaving: $isSaving, errorMessage: $errorMessage, saved: $saved)';
}


}

/// @nodoc
abstract mixin class $HealthProfileFormStateCopyWith<$Res>  {
  factory $HealthProfileFormStateCopyWith(HealthProfileFormState value, $Res Function(HealthProfileFormState) _then) = _$HealthProfileFormStateCopyWithImpl;
@useResult
$Res call({
 bool isSaving, String? errorMessage, bool saved
});




}
/// @nodoc
class _$HealthProfileFormStateCopyWithImpl<$Res>
    implements $HealthProfileFormStateCopyWith<$Res> {
  _$HealthProfileFormStateCopyWithImpl(this._self, this._then);

  final HealthProfileFormState _self;
  final $Res Function(HealthProfileFormState) _then;

/// Create a copy of HealthProfileFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? saved = null,}) {
  return _then(_self.copyWith(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthProfileFormState].
extension HealthProfileFormStatePatterns on HealthProfileFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthProfileFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthProfileFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthProfileFormState value)  $default,){
final _that = this;
switch (_that) {
case _HealthProfileFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthProfileFormState value)?  $default,){
final _that = this;
switch (_that) {
case _HealthProfileFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool saved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthProfileFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool saved)  $default,) {final _that = this;
switch (_that) {
case _HealthProfileFormState():
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSaving,  String? errorMessage,  bool saved)?  $default,) {final _that = this;
switch (_that) {
case _HealthProfileFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
  return null;

}
}

}

/// @nodoc


class _HealthProfileFormState implements HealthProfileFormState {
  const _HealthProfileFormState({this.isSaving = false, this.errorMessage, this.saved = false});
  

@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;
@override@JsonKey() final  bool saved;

/// Create a copy of HealthProfileFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthProfileFormStateCopyWith<_HealthProfileFormState> get copyWith => __$HealthProfileFormStateCopyWithImpl<_HealthProfileFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthProfileFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,saved);

@override
String toString() {
  return 'HealthProfileFormState(isSaving: $isSaving, errorMessage: $errorMessage, saved: $saved)';
}


}

/// @nodoc
abstract mixin class _$HealthProfileFormStateCopyWith<$Res> implements $HealthProfileFormStateCopyWith<$Res> {
  factory _$HealthProfileFormStateCopyWith(_HealthProfileFormState value, $Res Function(_HealthProfileFormState) _then) = __$HealthProfileFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSaving, String? errorMessage, bool saved
});




}
/// @nodoc
class __$HealthProfileFormStateCopyWithImpl<$Res>
    implements _$HealthProfileFormStateCopyWith<$Res> {
  __$HealthProfileFormStateCopyWithImpl(this._self, this._then);

  final _HealthProfileFormState _self;
  final $Res Function(_HealthProfileFormState) _then;

/// Create a copy of HealthProfileFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? saved = null,}) {
  return _then(_HealthProfileFormState(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$AllergyFormState {

 bool get isSaving; String? get errorMessage; bool get saved;
/// Create a copy of AllergyFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllergyFormStateCopyWith<AllergyFormState> get copyWith => _$AllergyFormStateCopyWithImpl<AllergyFormState>(this as AllergyFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllergyFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,saved);

@override
String toString() {
  return 'AllergyFormState(isSaving: $isSaving, errorMessage: $errorMessage, saved: $saved)';
}


}

/// @nodoc
abstract mixin class $AllergyFormStateCopyWith<$Res>  {
  factory $AllergyFormStateCopyWith(AllergyFormState value, $Res Function(AllergyFormState) _then) = _$AllergyFormStateCopyWithImpl;
@useResult
$Res call({
 bool isSaving, String? errorMessage, bool saved
});




}
/// @nodoc
class _$AllergyFormStateCopyWithImpl<$Res>
    implements $AllergyFormStateCopyWith<$Res> {
  _$AllergyFormStateCopyWithImpl(this._self, this._then);

  final AllergyFormState _self;
  final $Res Function(AllergyFormState) _then;

/// Create a copy of AllergyFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? saved = null,}) {
  return _then(_self.copyWith(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AllergyFormState].
extension AllergyFormStatePatterns on AllergyFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllergyFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllergyFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllergyFormState value)  $default,){
final _that = this;
switch (_that) {
case _AllergyFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllergyFormState value)?  $default,){
final _that = this;
switch (_that) {
case _AllergyFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool saved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllergyFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool saved)  $default,) {final _that = this;
switch (_that) {
case _AllergyFormState():
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSaving,  String? errorMessage,  bool saved)?  $default,) {final _that = this;
switch (_that) {
case _AllergyFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
  return null;

}
}

}

/// @nodoc


class _AllergyFormState implements AllergyFormState {
  const _AllergyFormState({this.isSaving = false, this.errorMessage, this.saved = false});
  

@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;
@override@JsonKey() final  bool saved;

/// Create a copy of AllergyFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllergyFormStateCopyWith<_AllergyFormState> get copyWith => __$AllergyFormStateCopyWithImpl<_AllergyFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllergyFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,saved);

@override
String toString() {
  return 'AllergyFormState(isSaving: $isSaving, errorMessage: $errorMessage, saved: $saved)';
}


}

/// @nodoc
abstract mixin class _$AllergyFormStateCopyWith<$Res> implements $AllergyFormStateCopyWith<$Res> {
  factory _$AllergyFormStateCopyWith(_AllergyFormState value, $Res Function(_AllergyFormState) _then) = __$AllergyFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSaving, String? errorMessage, bool saved
});




}
/// @nodoc
class __$AllergyFormStateCopyWithImpl<$Res>
    implements _$AllergyFormStateCopyWith<$Res> {
  __$AllergyFormStateCopyWithImpl(this._self, this._then);

  final _AllergyFormState _self;
  final $Res Function(_AllergyFormState) _then;

/// Create a copy of AllergyFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? saved = null,}) {
  return _then(_AllergyFormState(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ConditionFormState {

 bool get isSaving; String? get errorMessage; bool get saved;
/// Create a copy of ConditionFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConditionFormStateCopyWith<ConditionFormState> get copyWith => _$ConditionFormStateCopyWithImpl<ConditionFormState>(this as ConditionFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConditionFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,saved);

@override
String toString() {
  return 'ConditionFormState(isSaving: $isSaving, errorMessage: $errorMessage, saved: $saved)';
}


}

/// @nodoc
abstract mixin class $ConditionFormStateCopyWith<$Res>  {
  factory $ConditionFormStateCopyWith(ConditionFormState value, $Res Function(ConditionFormState) _then) = _$ConditionFormStateCopyWithImpl;
@useResult
$Res call({
 bool isSaving, String? errorMessage, bool saved
});




}
/// @nodoc
class _$ConditionFormStateCopyWithImpl<$Res>
    implements $ConditionFormStateCopyWith<$Res> {
  _$ConditionFormStateCopyWithImpl(this._self, this._then);

  final ConditionFormState _self;
  final $Res Function(ConditionFormState) _then;

/// Create a copy of ConditionFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? saved = null,}) {
  return _then(_self.copyWith(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ConditionFormState].
extension ConditionFormStatePatterns on ConditionFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConditionFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConditionFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConditionFormState value)  $default,){
final _that = this;
switch (_that) {
case _ConditionFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConditionFormState value)?  $default,){
final _that = this;
switch (_that) {
case _ConditionFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool saved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConditionFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool saved)  $default,) {final _that = this;
switch (_that) {
case _ConditionFormState():
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSaving,  String? errorMessage,  bool saved)?  $default,) {final _that = this;
switch (_that) {
case _ConditionFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
  return null;

}
}

}

/// @nodoc


class _ConditionFormState implements ConditionFormState {
  const _ConditionFormState({this.isSaving = false, this.errorMessage, this.saved = false});
  

@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;
@override@JsonKey() final  bool saved;

/// Create a copy of ConditionFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConditionFormStateCopyWith<_ConditionFormState> get copyWith => __$ConditionFormStateCopyWithImpl<_ConditionFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConditionFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,saved);

@override
String toString() {
  return 'ConditionFormState(isSaving: $isSaving, errorMessage: $errorMessage, saved: $saved)';
}


}

/// @nodoc
abstract mixin class _$ConditionFormStateCopyWith<$Res> implements $ConditionFormStateCopyWith<$Res> {
  factory _$ConditionFormStateCopyWith(_ConditionFormState value, $Res Function(_ConditionFormState) _then) = __$ConditionFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSaving, String? errorMessage, bool saved
});




}
/// @nodoc
class __$ConditionFormStateCopyWithImpl<$Res>
    implements _$ConditionFormStateCopyWith<$Res> {
  __$ConditionFormStateCopyWithImpl(this._self, this._then);

  final _ConditionFormState _self;
  final $Res Function(_ConditionFormState) _then;

/// Create a copy of ConditionFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? saved = null,}) {
  return _then(_ConditionFormState(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CurrentMedicineFormState {

 bool get isSaving; String? get errorMessage; bool get saved;
/// Create a copy of CurrentMedicineFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentMedicineFormStateCopyWith<CurrentMedicineFormState> get copyWith => _$CurrentMedicineFormStateCopyWithImpl<CurrentMedicineFormState>(this as CurrentMedicineFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentMedicineFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,saved);

@override
String toString() {
  return 'CurrentMedicineFormState(isSaving: $isSaving, errorMessage: $errorMessage, saved: $saved)';
}


}

/// @nodoc
abstract mixin class $CurrentMedicineFormStateCopyWith<$Res>  {
  factory $CurrentMedicineFormStateCopyWith(CurrentMedicineFormState value, $Res Function(CurrentMedicineFormState) _then) = _$CurrentMedicineFormStateCopyWithImpl;
@useResult
$Res call({
 bool isSaving, String? errorMessage, bool saved
});




}
/// @nodoc
class _$CurrentMedicineFormStateCopyWithImpl<$Res>
    implements $CurrentMedicineFormStateCopyWith<$Res> {
  _$CurrentMedicineFormStateCopyWithImpl(this._self, this._then);

  final CurrentMedicineFormState _self;
  final $Res Function(CurrentMedicineFormState) _then;

/// Create a copy of CurrentMedicineFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? saved = null,}) {
  return _then(_self.copyWith(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentMedicineFormState].
extension CurrentMedicineFormStatePatterns on CurrentMedicineFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentMedicineFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentMedicineFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentMedicineFormState value)  $default,){
final _that = this;
switch (_that) {
case _CurrentMedicineFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentMedicineFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentMedicineFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool saved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentMedicineFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool saved)  $default,) {final _that = this;
switch (_that) {
case _CurrentMedicineFormState():
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSaving,  String? errorMessage,  bool saved)?  $default,) {final _that = this;
switch (_that) {
case _CurrentMedicineFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.saved);case _:
  return null;

}
}

}

/// @nodoc


class _CurrentMedicineFormState implements CurrentMedicineFormState {
  const _CurrentMedicineFormState({this.isSaving = false, this.errorMessage, this.saved = false});
  

@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;
@override@JsonKey() final  bool saved;

/// Create a copy of CurrentMedicineFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentMedicineFormStateCopyWith<_CurrentMedicineFormState> get copyWith => __$CurrentMedicineFormStateCopyWithImpl<_CurrentMedicineFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentMedicineFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,saved);

@override
String toString() {
  return 'CurrentMedicineFormState(isSaving: $isSaving, errorMessage: $errorMessage, saved: $saved)';
}


}

/// @nodoc
abstract mixin class _$CurrentMedicineFormStateCopyWith<$Res> implements $CurrentMedicineFormStateCopyWith<$Res> {
  factory _$CurrentMedicineFormStateCopyWith(_CurrentMedicineFormState value, $Res Function(_CurrentMedicineFormState) _then) = __$CurrentMedicineFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSaving, String? errorMessage, bool saved
});




}
/// @nodoc
class __$CurrentMedicineFormStateCopyWithImpl<$Res>
    implements _$CurrentMedicineFormStateCopyWith<$Res> {
  __$CurrentMedicineFormStateCopyWithImpl(this._self, this._then);

  final _CurrentMedicineFormState _self;
  final $Res Function(_CurrentMedicineFormState) _then;

/// Create a copy of CurrentMedicineFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? saved = null,}) {
  return _then(_CurrentMedicineFormState(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
