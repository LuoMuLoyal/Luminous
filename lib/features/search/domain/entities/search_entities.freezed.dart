// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicineSearchDashboard {

 String get query; MedicineSearchSource get selectedSource; List<String> get recentKeywords; List<MedicineSearchQuickAction> get quickActions; List<MedicineSearchCategory> get categories; List<MedicineSearchResult> get results; String get selectedResultId; MedicineSearchSafetyPreview get safetyPreview;
/// Create a copy of MedicineSearchDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineSearchDashboardCopyWith<MedicineSearchDashboard> get copyWith => _$MedicineSearchDashboardCopyWithImpl<MedicineSearchDashboard>(this as MedicineSearchDashboard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineSearchDashboard&&(identical(other.query, query) || other.query == query)&&(identical(other.selectedSource, selectedSource) || other.selectedSource == selectedSource)&&const DeepCollectionEquality().equals(other.recentKeywords, recentKeywords)&&const DeepCollectionEquality().equals(other.quickActions, quickActions)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.selectedResultId, selectedResultId) || other.selectedResultId == selectedResultId)&&(identical(other.safetyPreview, safetyPreview) || other.safetyPreview == safetyPreview));
}


@override
int get hashCode => Object.hash(runtimeType,query,selectedSource,const DeepCollectionEquality().hash(recentKeywords),const DeepCollectionEquality().hash(quickActions),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(results),selectedResultId,safetyPreview);

@override
String toString() {
  return 'MedicineSearchDashboard(query: $query, selectedSource: $selectedSource, recentKeywords: $recentKeywords, quickActions: $quickActions, categories: $categories, results: $results, selectedResultId: $selectedResultId, safetyPreview: $safetyPreview)';
}


}

/// @nodoc
abstract mixin class $MedicineSearchDashboardCopyWith<$Res>  {
  factory $MedicineSearchDashboardCopyWith(MedicineSearchDashboard value, $Res Function(MedicineSearchDashboard) _then) = _$MedicineSearchDashboardCopyWithImpl;
@useResult
$Res call({
 String query, MedicineSearchSource selectedSource, List<String> recentKeywords, List<MedicineSearchQuickAction> quickActions, List<MedicineSearchCategory> categories, List<MedicineSearchResult> results, String selectedResultId, MedicineSearchSafetyPreview safetyPreview
});


$MedicineSearchSafetyPreviewCopyWith<$Res> get safetyPreview;

}
/// @nodoc
class _$MedicineSearchDashboardCopyWithImpl<$Res>
    implements $MedicineSearchDashboardCopyWith<$Res> {
  _$MedicineSearchDashboardCopyWithImpl(this._self, this._then);

  final MedicineSearchDashboard _self;
  final $Res Function(MedicineSearchDashboard) _then;

/// Create a copy of MedicineSearchDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? selectedSource = null,Object? recentKeywords = null,Object? quickActions = null,Object? categories = null,Object? results = null,Object? selectedResultId = null,Object? safetyPreview = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,selectedSource: null == selectedSource ? _self.selectedSource : selectedSource // ignore: cast_nullable_to_non_nullable
as MedicineSearchSource,recentKeywords: null == recentKeywords ? _self.recentKeywords : recentKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,quickActions: null == quickActions ? _self.quickActions : quickActions // ignore: cast_nullable_to_non_nullable
as List<MedicineSearchQuickAction>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<MedicineSearchCategory>,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<MedicineSearchResult>,selectedResultId: null == selectedResultId ? _self.selectedResultId : selectedResultId // ignore: cast_nullable_to_non_nullable
as String,safetyPreview: null == safetyPreview ? _self.safetyPreview : safetyPreview // ignore: cast_nullable_to_non_nullable
as MedicineSearchSafetyPreview,
  ));
}
/// Create a copy of MedicineSearchDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicineSearchSafetyPreviewCopyWith<$Res> get safetyPreview {
  
  return $MedicineSearchSafetyPreviewCopyWith<$Res>(_self.safetyPreview, (value) {
    return _then(_self.copyWith(safetyPreview: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicineSearchDashboard].
extension MedicineSearchDashboardPatterns on MedicineSearchDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineSearchDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineSearchDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineSearchDashboard value)  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineSearchDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  MedicineSearchSource selectedSource,  List<String> recentKeywords,  List<MedicineSearchQuickAction> quickActions,  List<MedicineSearchCategory> categories,  List<MedicineSearchResult> results,  String selectedResultId,  MedicineSearchSafetyPreview safetyPreview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineSearchDashboard() when $default != null:
return $default(_that.query,_that.selectedSource,_that.recentKeywords,_that.quickActions,_that.categories,_that.results,_that.selectedResultId,_that.safetyPreview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  MedicineSearchSource selectedSource,  List<String> recentKeywords,  List<MedicineSearchQuickAction> quickActions,  List<MedicineSearchCategory> categories,  List<MedicineSearchResult> results,  String selectedResultId,  MedicineSearchSafetyPreview safetyPreview)  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchDashboard():
return $default(_that.query,_that.selectedSource,_that.recentKeywords,_that.quickActions,_that.categories,_that.results,_that.selectedResultId,_that.safetyPreview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  MedicineSearchSource selectedSource,  List<String> recentKeywords,  List<MedicineSearchQuickAction> quickActions,  List<MedicineSearchCategory> categories,  List<MedicineSearchResult> results,  String selectedResultId,  MedicineSearchSafetyPreview safetyPreview)?  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchDashboard() when $default != null:
return $default(_that.query,_that.selectedSource,_that.recentKeywords,_that.quickActions,_that.categories,_that.results,_that.selectedResultId,_that.safetyPreview);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineSearchDashboard extends MedicineSearchDashboard {
  const _MedicineSearchDashboard({required this.query, required this.selectedSource, required final  List<String> recentKeywords, required final  List<MedicineSearchQuickAction> quickActions, required final  List<MedicineSearchCategory> categories, required final  List<MedicineSearchResult> results, required this.selectedResultId, required this.safetyPreview}): _recentKeywords = recentKeywords,_quickActions = quickActions,_categories = categories,_results = results,super._();
  

@override final  String query;
@override final  MedicineSearchSource selectedSource;
 final  List<String> _recentKeywords;
@override List<String> get recentKeywords {
  if (_recentKeywords is EqualUnmodifiableListView) return _recentKeywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentKeywords);
}

 final  List<MedicineSearchQuickAction> _quickActions;
@override List<MedicineSearchQuickAction> get quickActions {
  if (_quickActions is EqualUnmodifiableListView) return _quickActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quickActions);
}

 final  List<MedicineSearchCategory> _categories;
@override List<MedicineSearchCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<MedicineSearchResult> _results;
@override List<MedicineSearchResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override final  String selectedResultId;
@override final  MedicineSearchSafetyPreview safetyPreview;

/// Create a copy of MedicineSearchDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineSearchDashboardCopyWith<_MedicineSearchDashboard> get copyWith => __$MedicineSearchDashboardCopyWithImpl<_MedicineSearchDashboard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineSearchDashboard&&(identical(other.query, query) || other.query == query)&&(identical(other.selectedSource, selectedSource) || other.selectedSource == selectedSource)&&const DeepCollectionEquality().equals(other._recentKeywords, _recentKeywords)&&const DeepCollectionEquality().equals(other._quickActions, _quickActions)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.selectedResultId, selectedResultId) || other.selectedResultId == selectedResultId)&&(identical(other.safetyPreview, safetyPreview) || other.safetyPreview == safetyPreview));
}


@override
int get hashCode => Object.hash(runtimeType,query,selectedSource,const DeepCollectionEquality().hash(_recentKeywords),const DeepCollectionEquality().hash(_quickActions),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_results),selectedResultId,safetyPreview);

@override
String toString() {
  return 'MedicineSearchDashboard(query: $query, selectedSource: $selectedSource, recentKeywords: $recentKeywords, quickActions: $quickActions, categories: $categories, results: $results, selectedResultId: $selectedResultId, safetyPreview: $safetyPreview)';
}


}

/// @nodoc
abstract mixin class _$MedicineSearchDashboardCopyWith<$Res> implements $MedicineSearchDashboardCopyWith<$Res> {
  factory _$MedicineSearchDashboardCopyWith(_MedicineSearchDashboard value, $Res Function(_MedicineSearchDashboard) _then) = __$MedicineSearchDashboardCopyWithImpl;
@override @useResult
$Res call({
 String query, MedicineSearchSource selectedSource, List<String> recentKeywords, List<MedicineSearchQuickAction> quickActions, List<MedicineSearchCategory> categories, List<MedicineSearchResult> results, String selectedResultId, MedicineSearchSafetyPreview safetyPreview
});


@override $MedicineSearchSafetyPreviewCopyWith<$Res> get safetyPreview;

}
/// @nodoc
class __$MedicineSearchDashboardCopyWithImpl<$Res>
    implements _$MedicineSearchDashboardCopyWith<$Res> {
  __$MedicineSearchDashboardCopyWithImpl(this._self, this._then);

  final _MedicineSearchDashboard _self;
  final $Res Function(_MedicineSearchDashboard) _then;

/// Create a copy of MedicineSearchDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? selectedSource = null,Object? recentKeywords = null,Object? quickActions = null,Object? categories = null,Object? results = null,Object? selectedResultId = null,Object? safetyPreview = null,}) {
  return _then(_MedicineSearchDashboard(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,selectedSource: null == selectedSource ? _self.selectedSource : selectedSource // ignore: cast_nullable_to_non_nullable
as MedicineSearchSource,recentKeywords: null == recentKeywords ? _self._recentKeywords : recentKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,quickActions: null == quickActions ? _self._quickActions : quickActions // ignore: cast_nullable_to_non_nullable
as List<MedicineSearchQuickAction>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<MedicineSearchCategory>,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<MedicineSearchResult>,selectedResultId: null == selectedResultId ? _self.selectedResultId : selectedResultId // ignore: cast_nullable_to_non_nullable
as String,safetyPreview: null == safetyPreview ? _self.safetyPreview : safetyPreview // ignore: cast_nullable_to_non_nullable
as MedicineSearchSafetyPreview,
  ));
}

/// Create a copy of MedicineSearchDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicineSearchSafetyPreviewCopyWith<$Res> get safetyPreview {
  
  return $MedicineSearchSafetyPreviewCopyWith<$Res>(_self.safetyPreview, (value) {
    return _then(_self.copyWith(safetyPreview: value));
  });
}
}

/// @nodoc
mixin _$MedicineSearchQuickAction {

 MedicineSearchActionType get type; IconData get icon; Color get accent;
/// Create a copy of MedicineSearchQuickAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineSearchQuickActionCopyWith<MedicineSearchQuickAction> get copyWith => _$MedicineSearchQuickActionCopyWithImpl<MedicineSearchQuickAction>(this as MedicineSearchQuickAction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineSearchQuickAction&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent));
}


@override
int get hashCode => Object.hash(runtimeType,type,icon,accent);

@override
String toString() {
  return 'MedicineSearchQuickAction(type: $type, icon: $icon, accent: $accent)';
}


}

/// @nodoc
abstract mixin class $MedicineSearchQuickActionCopyWith<$Res>  {
  factory $MedicineSearchQuickActionCopyWith(MedicineSearchQuickAction value, $Res Function(MedicineSearchQuickAction) _then) = _$MedicineSearchQuickActionCopyWithImpl;
@useResult
$Res call({
 MedicineSearchActionType type, IconData icon, Color accent
});




}
/// @nodoc
class _$MedicineSearchQuickActionCopyWithImpl<$Res>
    implements $MedicineSearchQuickActionCopyWith<$Res> {
  _$MedicineSearchQuickActionCopyWithImpl(this._self, this._then);

  final MedicineSearchQuickAction _self;
  final $Res Function(MedicineSearchQuickAction) _then;

/// Create a copy of MedicineSearchQuickAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? icon = null,Object? accent = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicineSearchActionType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineSearchQuickAction].
extension MedicineSearchQuickActionPatterns on MedicineSearchQuickAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineSearchQuickAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineSearchQuickAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineSearchQuickAction value)  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchQuickAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineSearchQuickAction value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchQuickAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MedicineSearchActionType type,  IconData icon,  Color accent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineSearchQuickAction() when $default != null:
return $default(_that.type,_that.icon,_that.accent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MedicineSearchActionType type,  IconData icon,  Color accent)  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchQuickAction():
return $default(_that.type,_that.icon,_that.accent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MedicineSearchActionType type,  IconData icon,  Color accent)?  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchQuickAction() when $default != null:
return $default(_that.type,_that.icon,_that.accent);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineSearchQuickAction implements MedicineSearchQuickAction {
  const _MedicineSearchQuickAction({required this.type, required this.icon, required this.accent});
  

@override final  MedicineSearchActionType type;
@override final  IconData icon;
@override final  Color accent;

/// Create a copy of MedicineSearchQuickAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineSearchQuickActionCopyWith<_MedicineSearchQuickAction> get copyWith => __$MedicineSearchQuickActionCopyWithImpl<_MedicineSearchQuickAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineSearchQuickAction&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent));
}


@override
int get hashCode => Object.hash(runtimeType,type,icon,accent);

@override
String toString() {
  return 'MedicineSearchQuickAction(type: $type, icon: $icon, accent: $accent)';
}


}

/// @nodoc
abstract mixin class _$MedicineSearchQuickActionCopyWith<$Res> implements $MedicineSearchQuickActionCopyWith<$Res> {
  factory _$MedicineSearchQuickActionCopyWith(_MedicineSearchQuickAction value, $Res Function(_MedicineSearchQuickAction) _then) = __$MedicineSearchQuickActionCopyWithImpl;
@override @useResult
$Res call({
 MedicineSearchActionType type, IconData icon, Color accent
});




}
/// @nodoc
class __$MedicineSearchQuickActionCopyWithImpl<$Res>
    implements _$MedicineSearchQuickActionCopyWith<$Res> {
  __$MedicineSearchQuickActionCopyWithImpl(this._self, this._then);

  final _MedicineSearchQuickAction _self;
  final $Res Function(_MedicineSearchQuickAction) _then;

/// Create a copy of MedicineSearchQuickAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? icon = null,Object? accent = null,}) {
  return _then(_MedicineSearchQuickAction(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicineSearchActionType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

/// @nodoc
mixin _$MedicineSearchCategory {

 MedicineSearchCategoryType get type; IconData get icon; Color get accent; Color get softColor;
/// Create a copy of MedicineSearchCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineSearchCategoryCopyWith<MedicineSearchCategory> get copyWith => _$MedicineSearchCategoryCopyWithImpl<MedicineSearchCategory>(this as MedicineSearchCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineSearchCategory&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.softColor, softColor) || other.softColor == softColor));
}


@override
int get hashCode => Object.hash(runtimeType,type,icon,accent,softColor);

@override
String toString() {
  return 'MedicineSearchCategory(type: $type, icon: $icon, accent: $accent, softColor: $softColor)';
}


}

/// @nodoc
abstract mixin class $MedicineSearchCategoryCopyWith<$Res>  {
  factory $MedicineSearchCategoryCopyWith(MedicineSearchCategory value, $Res Function(MedicineSearchCategory) _then) = _$MedicineSearchCategoryCopyWithImpl;
@useResult
$Res call({
 MedicineSearchCategoryType type, IconData icon, Color accent, Color softColor
});




}
/// @nodoc
class _$MedicineSearchCategoryCopyWithImpl<$Res>
    implements $MedicineSearchCategoryCopyWith<$Res> {
  _$MedicineSearchCategoryCopyWithImpl(this._self, this._then);

  final MedicineSearchCategory _self;
  final $Res Function(MedicineSearchCategory) _then;

/// Create a copy of MedicineSearchCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? icon = null,Object? accent = null,Object? softColor = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicineSearchCategoryType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineSearchCategory].
extension MedicineSearchCategoryPatterns on MedicineSearchCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineSearchCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineSearchCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineSearchCategory value)  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineSearchCategory value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MedicineSearchCategoryType type,  IconData icon,  Color accent,  Color softColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineSearchCategory() when $default != null:
return $default(_that.type,_that.icon,_that.accent,_that.softColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MedicineSearchCategoryType type,  IconData icon,  Color accent,  Color softColor)  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchCategory():
return $default(_that.type,_that.icon,_that.accent,_that.softColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MedicineSearchCategoryType type,  IconData icon,  Color accent,  Color softColor)?  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchCategory() when $default != null:
return $default(_that.type,_that.icon,_that.accent,_that.softColor);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineSearchCategory implements MedicineSearchCategory {
  const _MedicineSearchCategory({required this.type, required this.icon, required this.accent, required this.softColor});
  

@override final  MedicineSearchCategoryType type;
@override final  IconData icon;
@override final  Color accent;
@override final  Color softColor;

/// Create a copy of MedicineSearchCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineSearchCategoryCopyWith<_MedicineSearchCategory> get copyWith => __$MedicineSearchCategoryCopyWithImpl<_MedicineSearchCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineSearchCategory&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.softColor, softColor) || other.softColor == softColor));
}


@override
int get hashCode => Object.hash(runtimeType,type,icon,accent,softColor);

@override
String toString() {
  return 'MedicineSearchCategory(type: $type, icon: $icon, accent: $accent, softColor: $softColor)';
}


}

/// @nodoc
abstract mixin class _$MedicineSearchCategoryCopyWith<$Res> implements $MedicineSearchCategoryCopyWith<$Res> {
  factory _$MedicineSearchCategoryCopyWith(_MedicineSearchCategory value, $Res Function(_MedicineSearchCategory) _then) = __$MedicineSearchCategoryCopyWithImpl;
@override @useResult
$Res call({
 MedicineSearchCategoryType type, IconData icon, Color accent, Color softColor
});




}
/// @nodoc
class __$MedicineSearchCategoryCopyWithImpl<$Res>
    implements _$MedicineSearchCategoryCopyWith<$Res> {
  __$MedicineSearchCategoryCopyWithImpl(this._self, this._then);

  final _MedicineSearchCategory _self;
  final $Res Function(_MedicineSearchCategory) _then;

/// Create a copy of MedicineSearchCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? icon = null,Object? accent = null,Object? softColor = null,}) {
  return _then(_MedicineSearchCategory(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicineSearchCategoryType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

/// @nodoc
mixin _$MedicineSearchResult {

 String get id; MedicineSearchSource get source; String get name; String get subtitle; String get summary; List<String> get tags; MedicineSearchMatchType get matchType;
/// Create a copy of MedicineSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineSearchResultCopyWith<MedicineSearchResult> get copyWith => _$MedicineSearchResultCopyWithImpl<MedicineSearchResult>(this as MedicineSearchResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineSearchResult&&(identical(other.id, id) || other.id == id)&&(identical(other.source, source) || other.source == source)&&(identical(other.name, name) || other.name == name)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.matchType, matchType) || other.matchType == matchType));
}


@override
int get hashCode => Object.hash(runtimeType,id,source,name,subtitle,summary,const DeepCollectionEquality().hash(tags),matchType);

@override
String toString() {
  return 'MedicineSearchResult(id: $id, source: $source, name: $name, subtitle: $subtitle, summary: $summary, tags: $tags, matchType: $matchType)';
}


}

/// @nodoc
abstract mixin class $MedicineSearchResultCopyWith<$Res>  {
  factory $MedicineSearchResultCopyWith(MedicineSearchResult value, $Res Function(MedicineSearchResult) _then) = _$MedicineSearchResultCopyWithImpl;
@useResult
$Res call({
 String id, MedicineSearchSource source, String name, String subtitle, String summary, List<String> tags, MedicineSearchMatchType matchType
});




}
/// @nodoc
class _$MedicineSearchResultCopyWithImpl<$Res>
    implements $MedicineSearchResultCopyWith<$Res> {
  _$MedicineSearchResultCopyWithImpl(this._self, this._then);

  final MedicineSearchResult _self;
  final $Res Function(MedicineSearchResult) _then;

/// Create a copy of MedicineSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? source = null,Object? name = null,Object? subtitle = null,Object? summary = null,Object? tags = null,Object? matchType = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MedicineSearchSource,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,matchType: null == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as MedicineSearchMatchType,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineSearchResult].
extension MedicineSearchResultPatterns on MedicineSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MedicineSearchSource source,  String name,  String subtitle,  String summary,  List<String> tags,  MedicineSearchMatchType matchType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineSearchResult() when $default != null:
return $default(_that.id,_that.source,_that.name,_that.subtitle,_that.summary,_that.tags,_that.matchType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MedicineSearchSource source,  String name,  String subtitle,  String summary,  List<String> tags,  MedicineSearchMatchType matchType)  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchResult():
return $default(_that.id,_that.source,_that.name,_that.subtitle,_that.summary,_that.tags,_that.matchType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MedicineSearchSource source,  String name,  String subtitle,  String summary,  List<String> tags,  MedicineSearchMatchType matchType)?  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchResult() when $default != null:
return $default(_that.id,_that.source,_that.name,_that.subtitle,_that.summary,_that.tags,_that.matchType);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineSearchResult implements MedicineSearchResult {
  const _MedicineSearchResult({required this.id, required this.source, required this.name, required this.subtitle, required this.summary, required final  List<String> tags, required this.matchType}): _tags = tags;
  

@override final  String id;
@override final  MedicineSearchSource source;
@override final  String name;
@override final  String subtitle;
@override final  String summary;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  MedicineSearchMatchType matchType;

/// Create a copy of MedicineSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineSearchResultCopyWith<_MedicineSearchResult> get copyWith => __$MedicineSearchResultCopyWithImpl<_MedicineSearchResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineSearchResult&&(identical(other.id, id) || other.id == id)&&(identical(other.source, source) || other.source == source)&&(identical(other.name, name) || other.name == name)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.matchType, matchType) || other.matchType == matchType));
}


@override
int get hashCode => Object.hash(runtimeType,id,source,name,subtitle,summary,const DeepCollectionEquality().hash(_tags),matchType);

@override
String toString() {
  return 'MedicineSearchResult(id: $id, source: $source, name: $name, subtitle: $subtitle, summary: $summary, tags: $tags, matchType: $matchType)';
}


}

/// @nodoc
abstract mixin class _$MedicineSearchResultCopyWith<$Res> implements $MedicineSearchResultCopyWith<$Res> {
  factory _$MedicineSearchResultCopyWith(_MedicineSearchResult value, $Res Function(_MedicineSearchResult) _then) = __$MedicineSearchResultCopyWithImpl;
@override @useResult
$Res call({
 String id, MedicineSearchSource source, String name, String subtitle, String summary, List<String> tags, MedicineSearchMatchType matchType
});




}
/// @nodoc
class __$MedicineSearchResultCopyWithImpl<$Res>
    implements _$MedicineSearchResultCopyWith<$Res> {
  __$MedicineSearchResultCopyWithImpl(this._self, this._then);

  final _MedicineSearchResult _self;
  final $Res Function(_MedicineSearchResult) _then;

/// Create a copy of MedicineSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? source = null,Object? name = null,Object? subtitle = null,Object? summary = null,Object? tags = null,Object? matchType = null,}) {
  return _then(_MedicineSearchResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MedicineSearchSource,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,matchType: null == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as MedicineSearchMatchType,
  ));
}


}

/// @nodoc
mixin _$MedicineSearchSafetyPreview {

 String get title; List<String> get conditions; List<String> get checklist;
/// Create a copy of MedicineSearchSafetyPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineSearchSafetyPreviewCopyWith<MedicineSearchSafetyPreview> get copyWith => _$MedicineSearchSafetyPreviewCopyWithImpl<MedicineSearchSafetyPreview>(this as MedicineSearchSafetyPreview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineSearchSafetyPreview&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.conditions, conditions)&&const DeepCollectionEquality().equals(other.checklist, checklist));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(conditions),const DeepCollectionEquality().hash(checklist));

@override
String toString() {
  return 'MedicineSearchSafetyPreview(title: $title, conditions: $conditions, checklist: $checklist)';
}


}

/// @nodoc
abstract mixin class $MedicineSearchSafetyPreviewCopyWith<$Res>  {
  factory $MedicineSearchSafetyPreviewCopyWith(MedicineSearchSafetyPreview value, $Res Function(MedicineSearchSafetyPreview) _then) = _$MedicineSearchSafetyPreviewCopyWithImpl;
@useResult
$Res call({
 String title, List<String> conditions, List<String> checklist
});




}
/// @nodoc
class _$MedicineSearchSafetyPreviewCopyWithImpl<$Res>
    implements $MedicineSearchSafetyPreviewCopyWith<$Res> {
  _$MedicineSearchSafetyPreviewCopyWithImpl(this._self, this._then);

  final MedicineSearchSafetyPreview _self;
  final $Res Function(MedicineSearchSafetyPreview) _then;

/// Create a copy of MedicineSearchSafetyPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? conditions = null,Object? checklist = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,conditions: null == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<String>,checklist: null == checklist ? _self.checklist : checklist // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineSearchSafetyPreview].
extension MedicineSearchSafetyPreviewPatterns on MedicineSearchSafetyPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineSearchSafetyPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineSearchSafetyPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineSearchSafetyPreview value)  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchSafetyPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineSearchSafetyPreview value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineSearchSafetyPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<String> conditions,  List<String> checklist)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineSearchSafetyPreview() when $default != null:
return $default(_that.title,_that.conditions,_that.checklist);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<String> conditions,  List<String> checklist)  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchSafetyPreview():
return $default(_that.title,_that.conditions,_that.checklist);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<String> conditions,  List<String> checklist)?  $default,) {final _that = this;
switch (_that) {
case _MedicineSearchSafetyPreview() when $default != null:
return $default(_that.title,_that.conditions,_that.checklist);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineSearchSafetyPreview implements MedicineSearchSafetyPreview {
  const _MedicineSearchSafetyPreview({required this.title, required final  List<String> conditions, required final  List<String> checklist}): _conditions = conditions,_checklist = checklist;
  

@override final  String title;
 final  List<String> _conditions;
@override List<String> get conditions {
  if (_conditions is EqualUnmodifiableListView) return _conditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conditions);
}

 final  List<String> _checklist;
@override List<String> get checklist {
  if (_checklist is EqualUnmodifiableListView) return _checklist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checklist);
}


/// Create a copy of MedicineSearchSafetyPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineSearchSafetyPreviewCopyWith<_MedicineSearchSafetyPreview> get copyWith => __$MedicineSearchSafetyPreviewCopyWithImpl<_MedicineSearchSafetyPreview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineSearchSafetyPreview&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._conditions, _conditions)&&const DeepCollectionEquality().equals(other._checklist, _checklist));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_conditions),const DeepCollectionEquality().hash(_checklist));

@override
String toString() {
  return 'MedicineSearchSafetyPreview(title: $title, conditions: $conditions, checklist: $checklist)';
}


}

/// @nodoc
abstract mixin class _$MedicineSearchSafetyPreviewCopyWith<$Res> implements $MedicineSearchSafetyPreviewCopyWith<$Res> {
  factory _$MedicineSearchSafetyPreviewCopyWith(_MedicineSearchSafetyPreview value, $Res Function(_MedicineSearchSafetyPreview) _then) = __$MedicineSearchSafetyPreviewCopyWithImpl;
@override @useResult
$Res call({
 String title, List<String> conditions, List<String> checklist
});




}
/// @nodoc
class __$MedicineSearchSafetyPreviewCopyWithImpl<$Res>
    implements _$MedicineSearchSafetyPreviewCopyWith<$Res> {
  __$MedicineSearchSafetyPreviewCopyWithImpl(this._self, this._then);

  final _MedicineSearchSafetyPreview _self;
  final $Res Function(_MedicineSearchSafetyPreview) _then;

/// Create a copy of MedicineSearchSafetyPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? conditions = null,Object? checklist = null,}) {
  return _then(_MedicineSearchSafetyPreview(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,conditions: null == conditions ? _self._conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<String>,checklist: null == checklist ? _self._checklist : checklist // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
