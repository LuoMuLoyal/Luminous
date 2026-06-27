// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shell_sidebar_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShellSidebarState {

/// Whether the desktop sidebar is collapsed to its narrow form.
 bool get collapsed;
/// Create a copy of ShellSidebarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShellSidebarStateCopyWith<ShellSidebarState> get copyWith => _$ShellSidebarStateCopyWithImpl<ShellSidebarState>(this as ShellSidebarState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShellSidebarState&&(identical(other.collapsed, collapsed) || other.collapsed == collapsed));
}


@override
int get hashCode => Object.hash(runtimeType,collapsed);

@override
String toString() {
  return 'ShellSidebarState(collapsed: $collapsed)';
}


}

/// @nodoc
abstract mixin class $ShellSidebarStateCopyWith<$Res>  {
  factory $ShellSidebarStateCopyWith(ShellSidebarState value, $Res Function(ShellSidebarState) _then) = _$ShellSidebarStateCopyWithImpl;
@useResult
$Res call({
 bool collapsed
});




}
/// @nodoc
class _$ShellSidebarStateCopyWithImpl<$Res>
    implements $ShellSidebarStateCopyWith<$Res> {
  _$ShellSidebarStateCopyWithImpl(this._self, this._then);

  final ShellSidebarState _self;
  final $Res Function(ShellSidebarState) _then;

/// Create a copy of ShellSidebarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collapsed = null,}) {
  return _then(_self.copyWith(
collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShellSidebarState].
extension ShellSidebarStatePatterns on ShellSidebarState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShellSidebarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShellSidebarState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShellSidebarState value)  $default,){
final _that = this;
switch (_that) {
case _ShellSidebarState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShellSidebarState value)?  $default,){
final _that = this;
switch (_that) {
case _ShellSidebarState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool collapsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShellSidebarState() when $default != null:
return $default(_that.collapsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool collapsed)  $default,) {final _that = this;
switch (_that) {
case _ShellSidebarState():
return $default(_that.collapsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool collapsed)?  $default,) {final _that = this;
switch (_that) {
case _ShellSidebarState() when $default != null:
return $default(_that.collapsed);case _:
  return null;

}
}

}

/// @nodoc


class _ShellSidebarState implements ShellSidebarState {
  const _ShellSidebarState({this.collapsed = false});
  

/// Whether the desktop sidebar is collapsed to its narrow form.
@override@JsonKey() final  bool collapsed;

/// Create a copy of ShellSidebarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShellSidebarStateCopyWith<_ShellSidebarState> get copyWith => __$ShellSidebarStateCopyWithImpl<_ShellSidebarState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShellSidebarState&&(identical(other.collapsed, collapsed) || other.collapsed == collapsed));
}


@override
int get hashCode => Object.hash(runtimeType,collapsed);

@override
String toString() {
  return 'ShellSidebarState(collapsed: $collapsed)';
}


}

/// @nodoc
abstract mixin class _$ShellSidebarStateCopyWith<$Res> implements $ShellSidebarStateCopyWith<$Res> {
  factory _$ShellSidebarStateCopyWith(_ShellSidebarState value, $Res Function(_ShellSidebarState) _then) = __$ShellSidebarStateCopyWithImpl;
@override @useResult
$Res call({
 bool collapsed
});




}
/// @nodoc
class __$ShellSidebarStateCopyWithImpl<$Res>
    implements _$ShellSidebarStateCopyWith<$Res> {
  __$ShellSidebarStateCopyWithImpl(this._self, this._then);

  final _ShellSidebarState _self;
  final $Res Function(_ShellSidebarState) _then;

/// Create a copy of ShellSidebarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collapsed = null,}) {
  return _then(_ShellSidebarState(
collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
