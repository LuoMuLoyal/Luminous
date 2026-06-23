// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicineSearchState {

 String get query; MedicineSearchSource get source; List<MedicineSearchResult> get results; bool get isSearching; String? get errorMessage; String? get selectedResultId; MedicineSearchSafetyPreview? get detailPreview;
/// Create a copy of MedicineSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineSearchStateCopyWith<MedicineSearchState> get copyWith => _$MedicineSearchStateCopyWithImpl<MedicineSearchState>(this as MedicineSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineSearchState&&(identical(other.query, query) || other.query == query)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.selectedResultId, selectedResultId) || other.selectedResultId == selectedResultId)&&(identical(other.detailPreview, detailPreview) || other.detailPreview == detailPreview));
}


@override
int get hashCode => Object.hash(runtimeType,query,source,const DeepCollectionEquality().hash(results),isSearching,errorMessage,selectedResultId,detailPreview);

@override
String toString() {
  return 'MedicineSearchState(query: $query, source: $source, results: $results, isSearching: $isSearching, errorMessage: $errorMessage, selectedResultId: $selectedResultId, detailPreview: $detailPreview)';
}


}

/// @nodoc
abstract mixin class $MedicineSearchStateCopyWith<$Res>  {
  factory $MedicineSearchStateCopyWith(MedicineSearchState value, $Res Function(MedicineSearchState) _then) = _$MedicineSearchStateCopyWithImpl;
@useResult
$Res call({
 String query, MedicineSearchSource source, List<MedicineSearchResult> results, bool isSearching, String? errorMessage, String? selectedResultId, MedicineSearchSafetyPreview? detailPreview
});




}
/// @nodoc
class _$MedicineSearchStateCopyWithImpl<$Res>
    implements $MedicineSearchStateCopyWith<$Res> {
  _$MedicineSearchStateCopyWithImpl(this._self, this._then);

  final MedicineSearchState _self;
  final $Res Function(MedicineSearchState) _then;

/// Create a copy of MedicineSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? source = null,Object? results = null,Object? isSearching = null,Object? errorMessage = freezed,Object? selectedResultId = freezed,Object? detailPreview = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MedicineSearchSource,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<MedicineSearchResult>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,selectedResultId: freezed == selectedResultId ? _self.selectedResultId : selectedResultId // ignore: cast_nullable_to_non_nullable
as String?,detailPreview: freezed == detailPreview ? _self.detailPreview : detailPreview // ignore: cast_nullable_to_non_nullable
as MedicineSearchSafetyPreview?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineSearchState].
extension MedicineSearchStatePatterns on MedicineSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineSearchState value)  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  MedicineSearchSource source,  List<MedicineSearchResult> results,  bool isSearching,  String? errorMessage,  String? selectedResultId,  MedicineSearchSafetyPreview? detailPreview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineSearchState() when $default != null:
return $default(_that.query,_that.source,_that.results,_that.isSearching,_that.errorMessage,_that.selectedResultId,_that.detailPreview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  MedicineSearchSource source,  List<MedicineSearchResult> results,  bool isSearching,  String? errorMessage,  String? selectedResultId,  MedicineSearchSafetyPreview? detailPreview)  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchState():
return $default(_that.query,_that.source,_that.results,_that.isSearching,_that.errorMessage,_that.selectedResultId,_that.detailPreview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  MedicineSearchSource source,  List<MedicineSearchResult> results,  bool isSearching,  String? errorMessage,  String? selectedResultId,  MedicineSearchSafetyPreview? detailPreview)?  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchState() when $default != null:
return $default(_that.query,_that.source,_that.results,_that.isSearching,_that.errorMessage,_that.selectedResultId,_that.detailPreview);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineSearchState implements MedicineSearchState {
  const _MedicineSearchState({this.query = '', this.source = MedicineSearchSource.cn, final  List<MedicineSearchResult> results = const [], this.isSearching = false, this.errorMessage, this.selectedResultId, this.detailPreview}): _results = results;
  

@override@JsonKey() final  String query;
@override@JsonKey() final  MedicineSearchSource source;
 final  List<MedicineSearchResult> _results;
@override@JsonKey() List<MedicineSearchResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  bool isSearching;
@override final  String? errorMessage;
@override final  String? selectedResultId;
@override final  MedicineSearchSafetyPreview? detailPreview;

/// Create a copy of MedicineSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineSearchStateCopyWith<_MedicineSearchState> get copyWith => __$MedicineSearchStateCopyWithImpl<_MedicineSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineSearchState&&(identical(other.query, query) || other.query == query)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.selectedResultId, selectedResultId) || other.selectedResultId == selectedResultId)&&(identical(other.detailPreview, detailPreview) || other.detailPreview == detailPreview));
}


@override
int get hashCode => Object.hash(runtimeType,query,source,const DeepCollectionEquality().hash(_results),isSearching,errorMessage,selectedResultId,detailPreview);

@override
String toString() {
  return 'MedicineSearchState(query: $query, source: $source, results: $results, isSearching: $isSearching, errorMessage: $errorMessage, selectedResultId: $selectedResultId, detailPreview: $detailPreview)';
}


}

/// @nodoc
abstract mixin class _$MedicineSearchStateCopyWith<$Res> implements $MedicineSearchStateCopyWith<$Res> {
  factory _$MedicineSearchStateCopyWith(_MedicineSearchState value, $Res Function(_MedicineSearchState) _then) = __$MedicineSearchStateCopyWithImpl;
@override @useResult
$Res call({
 String query, MedicineSearchSource source, List<MedicineSearchResult> results, bool isSearching, String? errorMessage, String? selectedResultId, MedicineSearchSafetyPreview? detailPreview
});




}
/// @nodoc
class __$MedicineSearchStateCopyWithImpl<$Res>
    implements _$MedicineSearchStateCopyWith<$Res> {
  __$MedicineSearchStateCopyWithImpl(this._self, this._then);

  final _MedicineSearchState _self;
  final $Res Function(_MedicineSearchState) _then;

/// Create a copy of MedicineSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? source = null,Object? results = null,Object? isSearching = null,Object? errorMessage = freezed,Object? selectedResultId = freezed,Object? detailPreview = freezed,}) {
  return _then(_MedicineSearchState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MedicineSearchSource,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<MedicineSearchResult>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,selectedResultId: freezed == selectedResultId ? _self.selectedResultId : selectedResultId // ignore: cast_nullable_to_non_nullable
as String?,detailPreview: freezed == detailPreview ? _self.detailPreview : detailPreview // ignore: cast_nullable_to_non_nullable
as MedicineSearchSafetyPreview?,
  ));
}


}

// dart format on
