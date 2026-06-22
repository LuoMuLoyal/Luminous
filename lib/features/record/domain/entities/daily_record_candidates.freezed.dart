// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_record_candidates.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyRecordCandidateResult {

 String get locale; String get generatedAt; String get confirmationHint; List<DailyRecordCandidateItem> get items;
/// Create a copy of DailyRecordCandidateResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordCandidateResultCopyWith<DailyRecordCandidateResult> get copyWith => _$DailyRecordCandidateResultCopyWithImpl<DailyRecordCandidateResult>(this as DailyRecordCandidateResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordCandidateResult&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.confirmationHint, confirmationHint) || other.confirmationHint == confirmationHint)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,locale,generatedAt,confirmationHint,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'DailyRecordCandidateResult(locale: $locale, generatedAt: $generatedAt, confirmationHint: $confirmationHint, items: $items)';
}


}

/// @nodoc
abstract mixin class $DailyRecordCandidateResultCopyWith<$Res>  {
  factory $DailyRecordCandidateResultCopyWith(DailyRecordCandidateResult value, $Res Function(DailyRecordCandidateResult) _then) = _$DailyRecordCandidateResultCopyWithImpl;
@useResult
$Res call({
 String locale, String generatedAt, String confirmationHint, List<DailyRecordCandidateItem> items
});




}
/// @nodoc
class _$DailyRecordCandidateResultCopyWithImpl<$Res>
    implements $DailyRecordCandidateResultCopyWith<$Res> {
  _$DailyRecordCandidateResultCopyWithImpl(this._self, this._then);

  final DailyRecordCandidateResult _self;
  final $Res Function(DailyRecordCandidateResult) _then;

/// Create a copy of DailyRecordCandidateResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,Object? generatedAt = null,Object? confirmationHint = null,Object? items = null,}) {
  return _then(_self.copyWith(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as String,confirmationHint: null == confirmationHint ? _self.confirmationHint : confirmationHint // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<DailyRecordCandidateItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordCandidateResult].
extension DailyRecordCandidateResultPatterns on DailyRecordCandidateResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordCandidateResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordCandidateResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordCandidateResult value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordCandidateResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordCandidateResult value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordCandidateResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String locale,  String generatedAt,  String confirmationHint,  List<DailyRecordCandidateItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordCandidateResult() when $default != null:
return $default(_that.locale,_that.generatedAt,_that.confirmationHint,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String locale,  String generatedAt,  String confirmationHint,  List<DailyRecordCandidateItem> items)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordCandidateResult():
return $default(_that.locale,_that.generatedAt,_that.confirmationHint,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String locale,  String generatedAt,  String confirmationHint,  List<DailyRecordCandidateItem> items)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordCandidateResult() when $default != null:
return $default(_that.locale,_that.generatedAt,_that.confirmationHint,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordCandidateResult implements DailyRecordCandidateResult {
  const _DailyRecordCandidateResult({required this.locale, required this.generatedAt, required this.confirmationHint, required final  List<DailyRecordCandidateItem> items}): _items = items;
  

@override final  String locale;
@override final  String generatedAt;
@override final  String confirmationHint;
 final  List<DailyRecordCandidateItem> _items;
@override List<DailyRecordCandidateItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of DailyRecordCandidateResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordCandidateResultCopyWith<_DailyRecordCandidateResult> get copyWith => __$DailyRecordCandidateResultCopyWithImpl<_DailyRecordCandidateResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordCandidateResult&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.confirmationHint, confirmationHint) || other.confirmationHint == confirmationHint)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,locale,generatedAt,confirmationHint,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'DailyRecordCandidateResult(locale: $locale, generatedAt: $generatedAt, confirmationHint: $confirmationHint, items: $items)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordCandidateResultCopyWith<$Res> implements $DailyRecordCandidateResultCopyWith<$Res> {
  factory _$DailyRecordCandidateResultCopyWith(_DailyRecordCandidateResult value, $Res Function(_DailyRecordCandidateResult) _then) = __$DailyRecordCandidateResultCopyWithImpl;
@override @useResult
$Res call({
 String locale, String generatedAt, String confirmationHint, List<DailyRecordCandidateItem> items
});




}
/// @nodoc
class __$DailyRecordCandidateResultCopyWithImpl<$Res>
    implements _$DailyRecordCandidateResultCopyWith<$Res> {
  __$DailyRecordCandidateResultCopyWithImpl(this._self, this._then);

  final _DailyRecordCandidateResult _self;
  final $Res Function(_DailyRecordCandidateResult) _then;

/// Create a copy of DailyRecordCandidateResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,Object? generatedAt = null,Object? confirmationHint = null,Object? items = null,}) {
  return _then(_DailyRecordCandidateResult(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as String,confirmationHint: null == confirmationHint ? _self.confirmationHint : confirmationHint // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<DailyRecordCandidateItem>,
  ));
}


}

/// @nodoc
mixin _$DailyRecordCandidateItem {

 DailyRecordKind get kind; String get occurredAt; String? get title; String? get value; String? get unit; String? get note; Map<String, dynamic>? get payload; String get rationale;
/// Create a copy of DailyRecordCandidateItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordCandidateItemCopyWith<DailyRecordCandidateItem> get copyWith => _$DailyRecordCandidateItemCopyWithImpl<DailyRecordCandidateItem>(this as DailyRecordCandidateItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordCandidateItem&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.rationale, rationale) || other.rationale == rationale));
}


@override
int get hashCode => Object.hash(runtimeType,kind,occurredAt,title,value,unit,note,const DeepCollectionEquality().hash(payload),rationale);

@override
String toString() {
  return 'DailyRecordCandidateItem(kind: $kind, occurredAt: $occurredAt, title: $title, value: $value, unit: $unit, note: $note, payload: $payload, rationale: $rationale)';
}


}

/// @nodoc
abstract mixin class $DailyRecordCandidateItemCopyWith<$Res>  {
  factory $DailyRecordCandidateItemCopyWith(DailyRecordCandidateItem value, $Res Function(DailyRecordCandidateItem) _then) = _$DailyRecordCandidateItemCopyWithImpl;
@useResult
$Res call({
 DailyRecordKind kind, String occurredAt, String? title, String? value, String? unit, String? note, Map<String, dynamic>? payload, String rationale
});




}
/// @nodoc
class _$DailyRecordCandidateItemCopyWithImpl<$Res>
    implements $DailyRecordCandidateItemCopyWith<$Res> {
  _$DailyRecordCandidateItemCopyWithImpl(this._self, this._then);

  final DailyRecordCandidateItem _self;
  final $Res Function(DailyRecordCandidateItem) _then;

/// Create a copy of DailyRecordCandidateItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? occurredAt = null,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? payload = freezed,Object? rationale = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordCandidateItem].
extension DailyRecordCandidateItemPatterns on DailyRecordCandidateItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordCandidateItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordCandidateItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordCandidateItem value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordCandidateItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordCandidateItem value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordCandidateItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DailyRecordKind kind,  String occurredAt,  String? title,  String? value,  String? unit,  String? note,  Map<String, dynamic>? payload,  String rationale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordCandidateItem() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.rationale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DailyRecordKind kind,  String occurredAt,  String? title,  String? value,  String? unit,  String? note,  Map<String, dynamic>? payload,  String rationale)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordCandidateItem():
return $default(_that.kind,_that.occurredAt,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.rationale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DailyRecordKind kind,  String occurredAt,  String? title,  String? value,  String? unit,  String? note,  Map<String, dynamic>? payload,  String rationale)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordCandidateItem() when $default != null:
return $default(_that.kind,_that.occurredAt,_that.title,_that.value,_that.unit,_that.note,_that.payload,_that.rationale);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordCandidateItem implements DailyRecordCandidateItem {
  const _DailyRecordCandidateItem({required this.kind, required this.occurredAt, this.title, this.value, this.unit, this.note, final  Map<String, dynamic>? payload, required this.rationale}): _payload = payload;
  

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

/// Create a copy of DailyRecordCandidateItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordCandidateItemCopyWith<_DailyRecordCandidateItem> get copyWith => __$DailyRecordCandidateItemCopyWithImpl<_DailyRecordCandidateItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordCandidateItem&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.rationale, rationale) || other.rationale == rationale));
}


@override
int get hashCode => Object.hash(runtimeType,kind,occurredAt,title,value,unit,note,const DeepCollectionEquality().hash(_payload),rationale);

@override
String toString() {
  return 'DailyRecordCandidateItem(kind: $kind, occurredAt: $occurredAt, title: $title, value: $value, unit: $unit, note: $note, payload: $payload, rationale: $rationale)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordCandidateItemCopyWith<$Res> implements $DailyRecordCandidateItemCopyWith<$Res> {
  factory _$DailyRecordCandidateItemCopyWith(_DailyRecordCandidateItem value, $Res Function(_DailyRecordCandidateItem) _then) = __$DailyRecordCandidateItemCopyWithImpl;
@override @useResult
$Res call({
 DailyRecordKind kind, String occurredAt, String? title, String? value, String? unit, String? note, Map<String, dynamic>? payload, String rationale
});




}
/// @nodoc
class __$DailyRecordCandidateItemCopyWithImpl<$Res>
    implements _$DailyRecordCandidateItemCopyWith<$Res> {
  __$DailyRecordCandidateItemCopyWithImpl(this._self, this._then);

  final _DailyRecordCandidateItem _self;
  final $Res Function(_DailyRecordCandidateItem) _then;

/// Create a copy of DailyRecordCandidateItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? occurredAt = null,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? payload = freezed,Object? rationale = null,}) {
  return _then(_DailyRecordCandidateItem(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
