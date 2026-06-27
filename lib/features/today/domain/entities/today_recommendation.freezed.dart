// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodayRecommendation {

 String get id; String get text; String? get category;
/// Create a copy of TodayRecommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayRecommendationCopyWith<TodayRecommendation> get copyWith => _$TodayRecommendationCopyWithImpl<TodayRecommendation>(this as TodayRecommendation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayRecommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,category);

@override
String toString() {
  return 'TodayRecommendation(id: $id, text: $text, category: $category)';
}


}

/// @nodoc
abstract mixin class $TodayRecommendationCopyWith<$Res>  {
  factory $TodayRecommendationCopyWith(TodayRecommendation value, $Res Function(TodayRecommendation) _then) = _$TodayRecommendationCopyWithImpl;
@useResult
$Res call({
 String id, String text, String? category
});




}
/// @nodoc
class _$TodayRecommendationCopyWithImpl<$Res>
    implements $TodayRecommendationCopyWith<$Res> {
  _$TodayRecommendationCopyWithImpl(this._self, this._then);

  final TodayRecommendation _self;
  final $Res Function(TodayRecommendation) _then;

/// Create a copy of TodayRecommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? category = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayRecommendation].
extension TodayRecommendationPatterns on TodayRecommendation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayRecommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayRecommendation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayRecommendation value)  $default,){
final _that = this;
switch (_that) {
case _TodayRecommendation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayRecommendation value)?  $default,){
final _that = this;
switch (_that) {
case _TodayRecommendation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  String? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayRecommendation() when $default != null:
return $default(_that.id,_that.text,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  String? category)  $default,) {final _that = this;
switch (_that) {
case _TodayRecommendation():
return $default(_that.id,_that.text,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  String? category)?  $default,) {final _that = this;
switch (_that) {
case _TodayRecommendation() when $default != null:
return $default(_that.id,_that.text,_that.category);case _:
  return null;

}
}

}

/// @nodoc


class _TodayRecommendation implements TodayRecommendation {
  const _TodayRecommendation({required this.id, required this.text, this.category});
  

@override final  String id;
@override final  String text;
@override final  String? category;

/// Create a copy of TodayRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayRecommendationCopyWith<_TodayRecommendation> get copyWith => __$TodayRecommendationCopyWithImpl<_TodayRecommendation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayRecommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,category);

@override
String toString() {
  return 'TodayRecommendation(id: $id, text: $text, category: $category)';
}


}

/// @nodoc
abstract mixin class _$TodayRecommendationCopyWith<$Res> implements $TodayRecommendationCopyWith<$Res> {
  factory _$TodayRecommendationCopyWith(_TodayRecommendation value, $Res Function(_TodayRecommendation) _then) = __$TodayRecommendationCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, String? category
});




}
/// @nodoc
class __$TodayRecommendationCopyWithImpl<$Res>
    implements _$TodayRecommendationCopyWith<$Res> {
  __$TodayRecommendationCopyWithImpl(this._self, this._then);

  final _TodayRecommendation _self;
  final $Res Function(_TodayRecommendation) _then;

/// Create a copy of TodayRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? category = freezed,}) {
  return _then(_TodayRecommendation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
