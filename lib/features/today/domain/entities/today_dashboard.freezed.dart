// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodayDashboard {

 TodayUserSnapshot get user; TodayWaterSummary get water; TodayMedicationSummary get medication; List<TodayVitalSummary> get vitals; TodayMealSuggestion get mealSuggestion;// Deferred by Product_Vision MVP: keep environment signals because Lucent has
// a useful reference-data contract, but do not surface it until a concrete
// Today or Mine product job is ready.
 TodayEnvironmentSummary get environment; TodayLumiSuggestion get lumiSuggestion; List<TodayPriorityItem> get priorityItems;
/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayDashboardCopyWith<TodayDashboard> get copyWith => _$TodayDashboardCopyWithImpl<TodayDashboard>(this as TodayDashboard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayDashboard&&(identical(other.user, user) || other.user == user)&&(identical(other.water, water) || other.water == water)&&(identical(other.medication, medication) || other.medication == medication)&&const DeepCollectionEquality().equals(other.vitals, vitals)&&(identical(other.mealSuggestion, mealSuggestion) || other.mealSuggestion == mealSuggestion)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.lumiSuggestion, lumiSuggestion) || other.lumiSuggestion == lumiSuggestion)&&const DeepCollectionEquality().equals(other.priorityItems, priorityItems));
}


@override
int get hashCode => Object.hash(runtimeType,user,water,medication,const DeepCollectionEquality().hash(vitals),mealSuggestion,environment,lumiSuggestion,const DeepCollectionEquality().hash(priorityItems));

@override
String toString() {
  return 'TodayDashboard(user: $user, water: $water, medication: $medication, vitals: $vitals, mealSuggestion: $mealSuggestion, environment: $environment, lumiSuggestion: $lumiSuggestion, priorityItems: $priorityItems)';
}


}

/// @nodoc
abstract mixin class $TodayDashboardCopyWith<$Res>  {
  factory $TodayDashboardCopyWith(TodayDashboard value, $Res Function(TodayDashboard) _then) = _$TodayDashboardCopyWithImpl;
@useResult
$Res call({
 TodayUserSnapshot user, TodayWaterSummary water, TodayMedicationSummary medication, List<TodayVitalSummary> vitals, TodayMealSuggestion mealSuggestion, TodayEnvironmentSummary environment, TodayLumiSuggestion lumiSuggestion, List<TodayPriorityItem> priorityItems
});


$TodayUserSnapshotCopyWith<$Res> get user;$TodayWaterSummaryCopyWith<$Res> get water;$TodayMedicationSummaryCopyWith<$Res> get medication;$TodayMealSuggestionCopyWith<$Res> get mealSuggestion;$TodayEnvironmentSummaryCopyWith<$Res> get environment;$TodayLumiSuggestionCopyWith<$Res> get lumiSuggestion;

}
/// @nodoc
class _$TodayDashboardCopyWithImpl<$Res>
    implements $TodayDashboardCopyWith<$Res> {
  _$TodayDashboardCopyWithImpl(this._self, this._then);

  final TodayDashboard _self;
  final $Res Function(TodayDashboard) _then;

/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? water = null,Object? medication = null,Object? vitals = null,Object? mealSuggestion = null,Object? environment = null,Object? lumiSuggestion = null,Object? priorityItems = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as TodayUserSnapshot,water: null == water ? _self.water : water // ignore: cast_nullable_to_non_nullable
as TodayWaterSummary,medication: null == medication ? _self.medication : medication // ignore: cast_nullable_to_non_nullable
as TodayMedicationSummary,vitals: null == vitals ? _self.vitals : vitals // ignore: cast_nullable_to_non_nullable
as List<TodayVitalSummary>,mealSuggestion: null == mealSuggestion ? _self.mealSuggestion : mealSuggestion // ignore: cast_nullable_to_non_nullable
as TodayMealSuggestion,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as TodayEnvironmentSummary,lumiSuggestion: null == lumiSuggestion ? _self.lumiSuggestion : lumiSuggestion // ignore: cast_nullable_to_non_nullable
as TodayLumiSuggestion,priorityItems: null == priorityItems ? _self.priorityItems : priorityItems // ignore: cast_nullable_to_non_nullable
as List<TodayPriorityItem>,
  ));
}
/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayUserSnapshotCopyWith<$Res> get user {
  
  return $TodayUserSnapshotCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayWaterSummaryCopyWith<$Res> get water {
  
  return $TodayWaterSummaryCopyWith<$Res>(_self.water, (value) {
    return _then(_self.copyWith(water: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayMedicationSummaryCopyWith<$Res> get medication {
  
  return $TodayMedicationSummaryCopyWith<$Res>(_self.medication, (value) {
    return _then(_self.copyWith(medication: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayMealSuggestionCopyWith<$Res> get mealSuggestion {
  
  return $TodayMealSuggestionCopyWith<$Res>(_self.mealSuggestion, (value) {
    return _then(_self.copyWith(mealSuggestion: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayEnvironmentSummaryCopyWith<$Res> get environment {
  
  return $TodayEnvironmentSummaryCopyWith<$Res>(_self.environment, (value) {
    return _then(_self.copyWith(environment: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayLumiSuggestionCopyWith<$Res> get lumiSuggestion {
  
  return $TodayLumiSuggestionCopyWith<$Res>(_self.lumiSuggestion, (value) {
    return _then(_self.copyWith(lumiSuggestion: value));
  });
}
}


/// Adds pattern-matching-related methods to [TodayDashboard].
extension TodayDashboardPatterns on TodayDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayDashboard value)  $default,){
final _that = this;
switch (_that) {
case _TodayDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _TodayDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TodayUserSnapshot user,  TodayWaterSummary water,  TodayMedicationSummary medication,  List<TodayVitalSummary> vitals,  TodayMealSuggestion mealSuggestion,  TodayEnvironmentSummary environment,  TodayLumiSuggestion lumiSuggestion,  List<TodayPriorityItem> priorityItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayDashboard() when $default != null:
return $default(_that.user,_that.water,_that.medication,_that.vitals,_that.mealSuggestion,_that.environment,_that.lumiSuggestion,_that.priorityItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TodayUserSnapshot user,  TodayWaterSummary water,  TodayMedicationSummary medication,  List<TodayVitalSummary> vitals,  TodayMealSuggestion mealSuggestion,  TodayEnvironmentSummary environment,  TodayLumiSuggestion lumiSuggestion,  List<TodayPriorityItem> priorityItems)  $default,) {final _that = this;
switch (_that) {
case _TodayDashboard():
return $default(_that.user,_that.water,_that.medication,_that.vitals,_that.mealSuggestion,_that.environment,_that.lumiSuggestion,_that.priorityItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TodayUserSnapshot user,  TodayWaterSummary water,  TodayMedicationSummary medication,  List<TodayVitalSummary> vitals,  TodayMealSuggestion mealSuggestion,  TodayEnvironmentSummary environment,  TodayLumiSuggestion lumiSuggestion,  List<TodayPriorityItem> priorityItems)?  $default,) {final _that = this;
switch (_that) {
case _TodayDashboard() when $default != null:
return $default(_that.user,_that.water,_that.medication,_that.vitals,_that.mealSuggestion,_that.environment,_that.lumiSuggestion,_that.priorityItems);case _:
  return null;

}
}

}

/// @nodoc


class _TodayDashboard implements TodayDashboard {
  const _TodayDashboard({required this.user, required this.water, required this.medication, required final  List<TodayVitalSummary> vitals, required this.mealSuggestion, required this.environment, required this.lumiSuggestion, required final  List<TodayPriorityItem> priorityItems}): _vitals = vitals,_priorityItems = priorityItems;
  

@override final  TodayUserSnapshot user;
@override final  TodayWaterSummary water;
@override final  TodayMedicationSummary medication;
 final  List<TodayVitalSummary> _vitals;
@override List<TodayVitalSummary> get vitals {
  if (_vitals is EqualUnmodifiableListView) return _vitals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vitals);
}

@override final  TodayMealSuggestion mealSuggestion;
// Deferred by Product_Vision MVP: keep environment signals because Lucent has
// a useful reference-data contract, but do not surface it until a concrete
// Today or Mine product job is ready.
@override final  TodayEnvironmentSummary environment;
@override final  TodayLumiSuggestion lumiSuggestion;
 final  List<TodayPriorityItem> _priorityItems;
@override List<TodayPriorityItem> get priorityItems {
  if (_priorityItems is EqualUnmodifiableListView) return _priorityItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_priorityItems);
}


/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayDashboardCopyWith<_TodayDashboard> get copyWith => __$TodayDashboardCopyWithImpl<_TodayDashboard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayDashboard&&(identical(other.user, user) || other.user == user)&&(identical(other.water, water) || other.water == water)&&(identical(other.medication, medication) || other.medication == medication)&&const DeepCollectionEquality().equals(other._vitals, _vitals)&&(identical(other.mealSuggestion, mealSuggestion) || other.mealSuggestion == mealSuggestion)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.lumiSuggestion, lumiSuggestion) || other.lumiSuggestion == lumiSuggestion)&&const DeepCollectionEquality().equals(other._priorityItems, _priorityItems));
}


@override
int get hashCode => Object.hash(runtimeType,user,water,medication,const DeepCollectionEquality().hash(_vitals),mealSuggestion,environment,lumiSuggestion,const DeepCollectionEquality().hash(_priorityItems));

@override
String toString() {
  return 'TodayDashboard(user: $user, water: $water, medication: $medication, vitals: $vitals, mealSuggestion: $mealSuggestion, environment: $environment, lumiSuggestion: $lumiSuggestion, priorityItems: $priorityItems)';
}


}

/// @nodoc
abstract mixin class _$TodayDashboardCopyWith<$Res> implements $TodayDashboardCopyWith<$Res> {
  factory _$TodayDashboardCopyWith(_TodayDashboard value, $Res Function(_TodayDashboard) _then) = __$TodayDashboardCopyWithImpl;
@override @useResult
$Res call({
 TodayUserSnapshot user, TodayWaterSummary water, TodayMedicationSummary medication, List<TodayVitalSummary> vitals, TodayMealSuggestion mealSuggestion, TodayEnvironmentSummary environment, TodayLumiSuggestion lumiSuggestion, List<TodayPriorityItem> priorityItems
});


@override $TodayUserSnapshotCopyWith<$Res> get user;@override $TodayWaterSummaryCopyWith<$Res> get water;@override $TodayMedicationSummaryCopyWith<$Res> get medication;@override $TodayMealSuggestionCopyWith<$Res> get mealSuggestion;@override $TodayEnvironmentSummaryCopyWith<$Res> get environment;@override $TodayLumiSuggestionCopyWith<$Res> get lumiSuggestion;

}
/// @nodoc
class __$TodayDashboardCopyWithImpl<$Res>
    implements _$TodayDashboardCopyWith<$Res> {
  __$TodayDashboardCopyWithImpl(this._self, this._then);

  final _TodayDashboard _self;
  final $Res Function(_TodayDashboard) _then;

/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? water = null,Object? medication = null,Object? vitals = null,Object? mealSuggestion = null,Object? environment = null,Object? lumiSuggestion = null,Object? priorityItems = null,}) {
  return _then(_TodayDashboard(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as TodayUserSnapshot,water: null == water ? _self.water : water // ignore: cast_nullable_to_non_nullable
as TodayWaterSummary,medication: null == medication ? _self.medication : medication // ignore: cast_nullable_to_non_nullable
as TodayMedicationSummary,vitals: null == vitals ? _self._vitals : vitals // ignore: cast_nullable_to_non_nullable
as List<TodayVitalSummary>,mealSuggestion: null == mealSuggestion ? _self.mealSuggestion : mealSuggestion // ignore: cast_nullable_to_non_nullable
as TodayMealSuggestion,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as TodayEnvironmentSummary,lumiSuggestion: null == lumiSuggestion ? _self.lumiSuggestion : lumiSuggestion // ignore: cast_nullable_to_non_nullable
as TodayLumiSuggestion,priorityItems: null == priorityItems ? _self._priorityItems : priorityItems // ignore: cast_nullable_to_non_nullable
as List<TodayPriorityItem>,
  ));
}

/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayUserSnapshotCopyWith<$Res> get user {
  
  return $TodayUserSnapshotCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayWaterSummaryCopyWith<$Res> get water {
  
  return $TodayWaterSummaryCopyWith<$Res>(_self.water, (value) {
    return _then(_self.copyWith(water: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayMedicationSummaryCopyWith<$Res> get medication {
  
  return $TodayMedicationSummaryCopyWith<$Res>(_self.medication, (value) {
    return _then(_self.copyWith(medication: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayMealSuggestionCopyWith<$Res> get mealSuggestion {
  
  return $TodayMealSuggestionCopyWith<$Res>(_self.mealSuggestion, (value) {
    return _then(_self.copyWith(mealSuggestion: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayEnvironmentSummaryCopyWith<$Res> get environment {
  
  return $TodayEnvironmentSummaryCopyWith<$Res>(_self.environment, (value) {
    return _then(_self.copyWith(environment: value));
  });
}/// Create a copy of TodayDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayLumiSuggestionCopyWith<$Res> get lumiSuggestion {
  
  return $TodayLumiSuggestionCopyWith<$Res>(_self.lumiSuggestion, (value) {
    return _then(_self.copyWith(lumiSuggestion: value));
  });
}
}

/// @nodoc
mixin _$TodayUserSnapshot {

 TodayDayMoment get moment; bool get hasUnreadNotifications; String get updatedAtLabel;
/// Create a copy of TodayUserSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayUserSnapshotCopyWith<TodayUserSnapshot> get copyWith => _$TodayUserSnapshotCopyWithImpl<TodayUserSnapshot>(this as TodayUserSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayUserSnapshot&&(identical(other.moment, moment) || other.moment == moment)&&(identical(other.hasUnreadNotifications, hasUnreadNotifications) || other.hasUnreadNotifications == hasUnreadNotifications)&&(identical(other.updatedAtLabel, updatedAtLabel) || other.updatedAtLabel == updatedAtLabel));
}


@override
int get hashCode => Object.hash(runtimeType,moment,hasUnreadNotifications,updatedAtLabel);

@override
String toString() {
  return 'TodayUserSnapshot(moment: $moment, hasUnreadNotifications: $hasUnreadNotifications, updatedAtLabel: $updatedAtLabel)';
}


}

/// @nodoc
abstract mixin class $TodayUserSnapshotCopyWith<$Res>  {
  factory $TodayUserSnapshotCopyWith(TodayUserSnapshot value, $Res Function(TodayUserSnapshot) _then) = _$TodayUserSnapshotCopyWithImpl;
@useResult
$Res call({
 TodayDayMoment moment, bool hasUnreadNotifications, String updatedAtLabel
});




}
/// @nodoc
class _$TodayUserSnapshotCopyWithImpl<$Res>
    implements $TodayUserSnapshotCopyWith<$Res> {
  _$TodayUserSnapshotCopyWithImpl(this._self, this._then);

  final TodayUserSnapshot _self;
  final $Res Function(TodayUserSnapshot) _then;

/// Create a copy of TodayUserSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? moment = null,Object? hasUnreadNotifications = null,Object? updatedAtLabel = null,}) {
  return _then(_self.copyWith(
moment: null == moment ? _self.moment : moment // ignore: cast_nullable_to_non_nullable
as TodayDayMoment,hasUnreadNotifications: null == hasUnreadNotifications ? _self.hasUnreadNotifications : hasUnreadNotifications // ignore: cast_nullable_to_non_nullable
as bool,updatedAtLabel: null == updatedAtLabel ? _self.updatedAtLabel : updatedAtLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayUserSnapshot].
extension TodayUserSnapshotPatterns on TodayUserSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayUserSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayUserSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayUserSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _TodayUserSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayUserSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _TodayUserSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TodayDayMoment moment,  bool hasUnreadNotifications,  String updatedAtLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayUserSnapshot() when $default != null:
return $default(_that.moment,_that.hasUnreadNotifications,_that.updatedAtLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TodayDayMoment moment,  bool hasUnreadNotifications,  String updatedAtLabel)  $default,) {final _that = this;
switch (_that) {
case _TodayUserSnapshot():
return $default(_that.moment,_that.hasUnreadNotifications,_that.updatedAtLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TodayDayMoment moment,  bool hasUnreadNotifications,  String updatedAtLabel)?  $default,) {final _that = this;
switch (_that) {
case _TodayUserSnapshot() when $default != null:
return $default(_that.moment,_that.hasUnreadNotifications,_that.updatedAtLabel);case _:
  return null;

}
}

}

/// @nodoc


class _TodayUserSnapshot implements TodayUserSnapshot {
  const _TodayUserSnapshot({required this.moment, required this.hasUnreadNotifications, required this.updatedAtLabel});
  

@override final  TodayDayMoment moment;
@override final  bool hasUnreadNotifications;
@override final  String updatedAtLabel;

/// Create a copy of TodayUserSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayUserSnapshotCopyWith<_TodayUserSnapshot> get copyWith => __$TodayUserSnapshotCopyWithImpl<_TodayUserSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayUserSnapshot&&(identical(other.moment, moment) || other.moment == moment)&&(identical(other.hasUnreadNotifications, hasUnreadNotifications) || other.hasUnreadNotifications == hasUnreadNotifications)&&(identical(other.updatedAtLabel, updatedAtLabel) || other.updatedAtLabel == updatedAtLabel));
}


@override
int get hashCode => Object.hash(runtimeType,moment,hasUnreadNotifications,updatedAtLabel);

@override
String toString() {
  return 'TodayUserSnapshot(moment: $moment, hasUnreadNotifications: $hasUnreadNotifications, updatedAtLabel: $updatedAtLabel)';
}


}

/// @nodoc
abstract mixin class _$TodayUserSnapshotCopyWith<$Res> implements $TodayUserSnapshotCopyWith<$Res> {
  factory _$TodayUserSnapshotCopyWith(_TodayUserSnapshot value, $Res Function(_TodayUserSnapshot) _then) = __$TodayUserSnapshotCopyWithImpl;
@override @useResult
$Res call({
 TodayDayMoment moment, bool hasUnreadNotifications, String updatedAtLabel
});




}
/// @nodoc
class __$TodayUserSnapshotCopyWithImpl<$Res>
    implements _$TodayUserSnapshotCopyWith<$Res> {
  __$TodayUserSnapshotCopyWithImpl(this._self, this._then);

  final _TodayUserSnapshot _self;
  final $Res Function(_TodayUserSnapshot) _then;

/// Create a copy of TodayUserSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? moment = null,Object? hasUnreadNotifications = null,Object? updatedAtLabel = null,}) {
  return _then(_TodayUserSnapshot(
moment: null == moment ? _self.moment : moment // ignore: cast_nullable_to_non_nullable
as TodayDayMoment,hasUnreadNotifications: null == hasUnreadNotifications ? _self.hasUnreadNotifications : hasUnreadNotifications // ignore: cast_nullable_to_non_nullable
as bool,updatedAtLabel: null == updatedAtLabel ? _self.updatedAtLabel : updatedAtLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TodayWaterSummary {

 int get completedCount; int get targetCount;
/// Create a copy of TodayWaterSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayWaterSummaryCopyWith<TodayWaterSummary> get copyWith => _$TodayWaterSummaryCopyWithImpl<TodayWaterSummary>(this as TodayWaterSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayWaterSummary&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount));
}


@override
int get hashCode => Object.hash(runtimeType,completedCount,targetCount);

@override
String toString() {
  return 'TodayWaterSummary(completedCount: $completedCount, targetCount: $targetCount)';
}


}

/// @nodoc
abstract mixin class $TodayWaterSummaryCopyWith<$Res>  {
  factory $TodayWaterSummaryCopyWith(TodayWaterSummary value, $Res Function(TodayWaterSummary) _then) = _$TodayWaterSummaryCopyWithImpl;
@useResult
$Res call({
 int completedCount, int targetCount
});




}
/// @nodoc
class _$TodayWaterSummaryCopyWithImpl<$Res>
    implements $TodayWaterSummaryCopyWith<$Res> {
  _$TodayWaterSummaryCopyWithImpl(this._self, this._then);

  final TodayWaterSummary _self;
  final $Res Function(TodayWaterSummary) _then;

/// Create a copy of TodayWaterSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completedCount = null,Object? targetCount = null,}) {
  return _then(_self.copyWith(
completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayWaterSummary].
extension TodayWaterSummaryPatterns on TodayWaterSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayWaterSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayWaterSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayWaterSummary value)  $default,){
final _that = this;
switch (_that) {
case _TodayWaterSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayWaterSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TodayWaterSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int completedCount,  int targetCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayWaterSummary() when $default != null:
return $default(_that.completedCount,_that.targetCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int completedCount,  int targetCount)  $default,) {final _that = this;
switch (_that) {
case _TodayWaterSummary():
return $default(_that.completedCount,_that.targetCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int completedCount,  int targetCount)?  $default,) {final _that = this;
switch (_that) {
case _TodayWaterSummary() when $default != null:
return $default(_that.completedCount,_that.targetCount);case _:
  return null;

}
}

}

/// @nodoc


class _TodayWaterSummary extends TodayWaterSummary {
  const _TodayWaterSummary({required this.completedCount, required this.targetCount}): super._();
  

@override final  int completedCount;
@override final  int targetCount;

/// Create a copy of TodayWaterSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayWaterSummaryCopyWith<_TodayWaterSummary> get copyWith => __$TodayWaterSummaryCopyWithImpl<_TodayWaterSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayWaterSummary&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount));
}


@override
int get hashCode => Object.hash(runtimeType,completedCount,targetCount);

@override
String toString() {
  return 'TodayWaterSummary(completedCount: $completedCount, targetCount: $targetCount)';
}


}

/// @nodoc
abstract mixin class _$TodayWaterSummaryCopyWith<$Res> implements $TodayWaterSummaryCopyWith<$Res> {
  factory _$TodayWaterSummaryCopyWith(_TodayWaterSummary value, $Res Function(_TodayWaterSummary) _then) = __$TodayWaterSummaryCopyWithImpl;
@override @useResult
$Res call({
 int completedCount, int targetCount
});




}
/// @nodoc
class __$TodayWaterSummaryCopyWithImpl<$Res>
    implements _$TodayWaterSummaryCopyWith<$Res> {
  __$TodayWaterSummaryCopyWithImpl(this._self, this._then);

  final _TodayWaterSummary _self;
  final $Res Function(_TodayWaterSummary) _then;

/// Create a copy of TodayWaterSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completedCount = null,Object? targetCount = null,}) {
  return _then(_TodayWaterSummary(
completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TodayMedicationSummary {

 int get medicineCount; int get pendingCount; String get nextDoseTimeLabel; TodayMedicationKind get nextMedicine; String? get nextMedicineName;
/// Create a copy of TodayMedicationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayMedicationSummaryCopyWith<TodayMedicationSummary> get copyWith => _$TodayMedicationSummaryCopyWithImpl<TodayMedicationSummary>(this as TodayMedicationSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayMedicationSummary&&(identical(other.medicineCount, medicineCount) || other.medicineCount == medicineCount)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.nextDoseTimeLabel, nextDoseTimeLabel) || other.nextDoseTimeLabel == nextDoseTimeLabel)&&(identical(other.nextMedicine, nextMedicine) || other.nextMedicine == nextMedicine)&&(identical(other.nextMedicineName, nextMedicineName) || other.nextMedicineName == nextMedicineName));
}


@override
int get hashCode => Object.hash(runtimeType,medicineCount,pendingCount,nextDoseTimeLabel,nextMedicine,nextMedicineName);

@override
String toString() {
  return 'TodayMedicationSummary(medicineCount: $medicineCount, pendingCount: $pendingCount, nextDoseTimeLabel: $nextDoseTimeLabel, nextMedicine: $nextMedicine, nextMedicineName: $nextMedicineName)';
}


}

/// @nodoc
abstract mixin class $TodayMedicationSummaryCopyWith<$Res>  {
  factory $TodayMedicationSummaryCopyWith(TodayMedicationSummary value, $Res Function(TodayMedicationSummary) _then) = _$TodayMedicationSummaryCopyWithImpl;
@useResult
$Res call({
 int medicineCount, int pendingCount, String nextDoseTimeLabel, TodayMedicationKind nextMedicine, String? nextMedicineName
});




}
/// @nodoc
class _$TodayMedicationSummaryCopyWithImpl<$Res>
    implements $TodayMedicationSummaryCopyWith<$Res> {
  _$TodayMedicationSummaryCopyWithImpl(this._self, this._then);

  final TodayMedicationSummary _self;
  final $Res Function(TodayMedicationSummary) _then;

/// Create a copy of TodayMedicationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? medicineCount = null,Object? pendingCount = null,Object? nextDoseTimeLabel = null,Object? nextMedicine = null,Object? nextMedicineName = freezed,}) {
  return _then(_self.copyWith(
medicineCount: null == medicineCount ? _self.medicineCount : medicineCount // ignore: cast_nullable_to_non_nullable
as int,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,nextDoseTimeLabel: null == nextDoseTimeLabel ? _self.nextDoseTimeLabel : nextDoseTimeLabel // ignore: cast_nullable_to_non_nullable
as String,nextMedicine: null == nextMedicine ? _self.nextMedicine : nextMedicine // ignore: cast_nullable_to_non_nullable
as TodayMedicationKind,nextMedicineName: freezed == nextMedicineName ? _self.nextMedicineName : nextMedicineName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayMedicationSummary].
extension TodayMedicationSummaryPatterns on TodayMedicationSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayMedicationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayMedicationSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayMedicationSummary value)  $default,){
final _that = this;
switch (_that) {
case _TodayMedicationSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayMedicationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TodayMedicationSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int medicineCount,  int pendingCount,  String nextDoseTimeLabel,  TodayMedicationKind nextMedicine,  String? nextMedicineName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayMedicationSummary() when $default != null:
return $default(_that.medicineCount,_that.pendingCount,_that.nextDoseTimeLabel,_that.nextMedicine,_that.nextMedicineName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int medicineCount,  int pendingCount,  String nextDoseTimeLabel,  TodayMedicationKind nextMedicine,  String? nextMedicineName)  $default,) {final _that = this;
switch (_that) {
case _TodayMedicationSummary():
return $default(_that.medicineCount,_that.pendingCount,_that.nextDoseTimeLabel,_that.nextMedicine,_that.nextMedicineName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int medicineCount,  int pendingCount,  String nextDoseTimeLabel,  TodayMedicationKind nextMedicine,  String? nextMedicineName)?  $default,) {final _that = this;
switch (_that) {
case _TodayMedicationSummary() when $default != null:
return $default(_that.medicineCount,_that.pendingCount,_that.nextDoseTimeLabel,_that.nextMedicine,_that.nextMedicineName);case _:
  return null;

}
}

}

/// @nodoc


class _TodayMedicationSummary implements TodayMedicationSummary {
  const _TodayMedicationSummary({required this.medicineCount, required this.pendingCount, required this.nextDoseTimeLabel, required this.nextMedicine, this.nextMedicineName});
  

@override final  int medicineCount;
@override final  int pendingCount;
@override final  String nextDoseTimeLabel;
@override final  TodayMedicationKind nextMedicine;
@override final  String? nextMedicineName;

/// Create a copy of TodayMedicationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayMedicationSummaryCopyWith<_TodayMedicationSummary> get copyWith => __$TodayMedicationSummaryCopyWithImpl<_TodayMedicationSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayMedicationSummary&&(identical(other.medicineCount, medicineCount) || other.medicineCount == medicineCount)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.nextDoseTimeLabel, nextDoseTimeLabel) || other.nextDoseTimeLabel == nextDoseTimeLabel)&&(identical(other.nextMedicine, nextMedicine) || other.nextMedicine == nextMedicine)&&(identical(other.nextMedicineName, nextMedicineName) || other.nextMedicineName == nextMedicineName));
}


@override
int get hashCode => Object.hash(runtimeType,medicineCount,pendingCount,nextDoseTimeLabel,nextMedicine,nextMedicineName);

@override
String toString() {
  return 'TodayMedicationSummary(medicineCount: $medicineCount, pendingCount: $pendingCount, nextDoseTimeLabel: $nextDoseTimeLabel, nextMedicine: $nextMedicine, nextMedicineName: $nextMedicineName)';
}


}

/// @nodoc
abstract mixin class _$TodayMedicationSummaryCopyWith<$Res> implements $TodayMedicationSummaryCopyWith<$Res> {
  factory _$TodayMedicationSummaryCopyWith(_TodayMedicationSummary value, $Res Function(_TodayMedicationSummary) _then) = __$TodayMedicationSummaryCopyWithImpl;
@override @useResult
$Res call({
 int medicineCount, int pendingCount, String nextDoseTimeLabel, TodayMedicationKind nextMedicine, String? nextMedicineName
});




}
/// @nodoc
class __$TodayMedicationSummaryCopyWithImpl<$Res>
    implements _$TodayMedicationSummaryCopyWith<$Res> {
  __$TodayMedicationSummaryCopyWithImpl(this._self, this._then);

  final _TodayMedicationSummary _self;
  final $Res Function(_TodayMedicationSummary) _then;

/// Create a copy of TodayMedicationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? medicineCount = null,Object? pendingCount = null,Object? nextDoseTimeLabel = null,Object? nextMedicine = null,Object? nextMedicineName = freezed,}) {
  return _then(_TodayMedicationSummary(
medicineCount: null == medicineCount ? _self.medicineCount : medicineCount // ignore: cast_nullable_to_non_nullable
as int,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,nextDoseTimeLabel: null == nextDoseTimeLabel ? _self.nextDoseTimeLabel : nextDoseTimeLabel // ignore: cast_nullable_to_non_nullable
as String,nextMedicine: null == nextMedicine ? _self.nextMedicine : nextMedicine // ignore: cast_nullable_to_non_nullable
as TodayMedicationKind,nextMedicineName: freezed == nextMedicineName ? _self.nextMedicineName : nextMedicineName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$TodayVitalSummary {

 TodayVitalType get type; String get valueLabel;
/// Create a copy of TodayVitalSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayVitalSummaryCopyWith<TodayVitalSummary> get copyWith => _$TodayVitalSummaryCopyWithImpl<TodayVitalSummary>(this as TodayVitalSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayVitalSummary&&(identical(other.type, type) || other.type == type)&&(identical(other.valueLabel, valueLabel) || other.valueLabel == valueLabel));
}


@override
int get hashCode => Object.hash(runtimeType,type,valueLabel);

@override
String toString() {
  return 'TodayVitalSummary(type: $type, valueLabel: $valueLabel)';
}


}

/// @nodoc
abstract mixin class $TodayVitalSummaryCopyWith<$Res>  {
  factory $TodayVitalSummaryCopyWith(TodayVitalSummary value, $Res Function(TodayVitalSummary) _then) = _$TodayVitalSummaryCopyWithImpl;
@useResult
$Res call({
 TodayVitalType type, String valueLabel
});




}
/// @nodoc
class _$TodayVitalSummaryCopyWithImpl<$Res>
    implements $TodayVitalSummaryCopyWith<$Res> {
  _$TodayVitalSummaryCopyWithImpl(this._self, this._then);

  final TodayVitalSummary _self;
  final $Res Function(TodayVitalSummary) _then;

/// Create a copy of TodayVitalSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? valueLabel = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayVitalType,valueLabel: null == valueLabel ? _self.valueLabel : valueLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayVitalSummary].
extension TodayVitalSummaryPatterns on TodayVitalSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayVitalSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayVitalSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayVitalSummary value)  $default,){
final _that = this;
switch (_that) {
case _TodayVitalSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayVitalSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TodayVitalSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TodayVitalType type,  String valueLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayVitalSummary() when $default != null:
return $default(_that.type,_that.valueLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TodayVitalType type,  String valueLabel)  $default,) {final _that = this;
switch (_that) {
case _TodayVitalSummary():
return $default(_that.type,_that.valueLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TodayVitalType type,  String valueLabel)?  $default,) {final _that = this;
switch (_that) {
case _TodayVitalSummary() when $default != null:
return $default(_that.type,_that.valueLabel);case _:
  return null;

}
}

}

/// @nodoc


class _TodayVitalSummary implements TodayVitalSummary {
  const _TodayVitalSummary({required this.type, required this.valueLabel});
  

@override final  TodayVitalType type;
@override final  String valueLabel;

/// Create a copy of TodayVitalSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayVitalSummaryCopyWith<_TodayVitalSummary> get copyWith => __$TodayVitalSummaryCopyWithImpl<_TodayVitalSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayVitalSummary&&(identical(other.type, type) || other.type == type)&&(identical(other.valueLabel, valueLabel) || other.valueLabel == valueLabel));
}


@override
int get hashCode => Object.hash(runtimeType,type,valueLabel);

@override
String toString() {
  return 'TodayVitalSummary(type: $type, valueLabel: $valueLabel)';
}


}

/// @nodoc
abstract mixin class _$TodayVitalSummaryCopyWith<$Res> implements $TodayVitalSummaryCopyWith<$Res> {
  factory _$TodayVitalSummaryCopyWith(_TodayVitalSummary value, $Res Function(_TodayVitalSummary) _then) = __$TodayVitalSummaryCopyWithImpl;
@override @useResult
$Res call({
 TodayVitalType type, String valueLabel
});




}
/// @nodoc
class __$TodayVitalSummaryCopyWithImpl<$Res>
    implements _$TodayVitalSummaryCopyWith<$Res> {
  __$TodayVitalSummaryCopyWithImpl(this._self, this._then);

  final _TodayVitalSummary _self;
  final $Res Function(_TodayVitalSummary) _then;

/// Create a copy of TodayVitalSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? valueLabel = null,}) {
  return _then(_TodayVitalSummary(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayVitalType,valueLabel: null == valueLabel ? _self.valueLabel : valueLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TodayMealSuggestion {

 TodayMealSuggestionType get type;
/// Create a copy of TodayMealSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayMealSuggestionCopyWith<TodayMealSuggestion> get copyWith => _$TodayMealSuggestionCopyWithImpl<TodayMealSuggestion>(this as TodayMealSuggestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayMealSuggestion&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,type);

@override
String toString() {
  return 'TodayMealSuggestion(type: $type)';
}


}

/// @nodoc
abstract mixin class $TodayMealSuggestionCopyWith<$Res>  {
  factory $TodayMealSuggestionCopyWith(TodayMealSuggestion value, $Res Function(TodayMealSuggestion) _then) = _$TodayMealSuggestionCopyWithImpl;
@useResult
$Res call({
 TodayMealSuggestionType type
});




}
/// @nodoc
class _$TodayMealSuggestionCopyWithImpl<$Res>
    implements $TodayMealSuggestionCopyWith<$Res> {
  _$TodayMealSuggestionCopyWithImpl(this._self, this._then);

  final TodayMealSuggestion _self;
  final $Res Function(TodayMealSuggestion) _then;

/// Create a copy of TodayMealSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayMealSuggestionType,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayMealSuggestion].
extension TodayMealSuggestionPatterns on TodayMealSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayMealSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayMealSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayMealSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _TodayMealSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayMealSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _TodayMealSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TodayMealSuggestionType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayMealSuggestion() when $default != null:
return $default(_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TodayMealSuggestionType type)  $default,) {final _that = this;
switch (_that) {
case _TodayMealSuggestion():
return $default(_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TodayMealSuggestionType type)?  $default,) {final _that = this;
switch (_that) {
case _TodayMealSuggestion() when $default != null:
return $default(_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _TodayMealSuggestion implements TodayMealSuggestion {
  const _TodayMealSuggestion({required this.type});
  

@override final  TodayMealSuggestionType type;

/// Create a copy of TodayMealSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayMealSuggestionCopyWith<_TodayMealSuggestion> get copyWith => __$TodayMealSuggestionCopyWithImpl<_TodayMealSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayMealSuggestion&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,type);

@override
String toString() {
  return 'TodayMealSuggestion(type: $type)';
}


}

/// @nodoc
abstract mixin class _$TodayMealSuggestionCopyWith<$Res> implements $TodayMealSuggestionCopyWith<$Res> {
  factory _$TodayMealSuggestionCopyWith(_TodayMealSuggestion value, $Res Function(_TodayMealSuggestion) _then) = __$TodayMealSuggestionCopyWithImpl;
@override @useResult
$Res call({
 TodayMealSuggestionType type
});




}
/// @nodoc
class __$TodayMealSuggestionCopyWithImpl<$Res>
    implements _$TodayMealSuggestionCopyWith<$Res> {
  __$TodayMealSuggestionCopyWithImpl(this._self, this._then);

  final _TodayMealSuggestion _self;
  final $Res Function(_TodayMealSuggestion) _then;

/// Create a copy of TodayMealSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,}) {
  return _then(_TodayMealSuggestion(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayMealSuggestionType,
  ));
}


}

/// @nodoc
mixin _$TodayEnvironmentSummary {

 List<TodayEnvironmentSignal> get signals;
/// Create a copy of TodayEnvironmentSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayEnvironmentSummaryCopyWith<TodayEnvironmentSummary> get copyWith => _$TodayEnvironmentSummaryCopyWithImpl<TodayEnvironmentSummary>(this as TodayEnvironmentSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayEnvironmentSummary&&const DeepCollectionEquality().equals(other.signals, signals));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(signals));

@override
String toString() {
  return 'TodayEnvironmentSummary(signals: $signals)';
}


}

/// @nodoc
abstract mixin class $TodayEnvironmentSummaryCopyWith<$Res>  {
  factory $TodayEnvironmentSummaryCopyWith(TodayEnvironmentSummary value, $Res Function(TodayEnvironmentSummary) _then) = _$TodayEnvironmentSummaryCopyWithImpl;
@useResult
$Res call({
 List<TodayEnvironmentSignal> signals
});




}
/// @nodoc
class _$TodayEnvironmentSummaryCopyWithImpl<$Res>
    implements $TodayEnvironmentSummaryCopyWith<$Res> {
  _$TodayEnvironmentSummaryCopyWithImpl(this._self, this._then);

  final TodayEnvironmentSummary _self;
  final $Res Function(TodayEnvironmentSummary) _then;

/// Create a copy of TodayEnvironmentSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? signals = null,}) {
  return _then(_self.copyWith(
signals: null == signals ? _self.signals : signals // ignore: cast_nullable_to_non_nullable
as List<TodayEnvironmentSignal>,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayEnvironmentSummary].
extension TodayEnvironmentSummaryPatterns on TodayEnvironmentSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayEnvironmentSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayEnvironmentSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayEnvironmentSummary value)  $default,){
final _that = this;
switch (_that) {
case _TodayEnvironmentSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayEnvironmentSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TodayEnvironmentSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TodayEnvironmentSignal> signals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayEnvironmentSummary() when $default != null:
return $default(_that.signals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TodayEnvironmentSignal> signals)  $default,) {final _that = this;
switch (_that) {
case _TodayEnvironmentSummary():
return $default(_that.signals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TodayEnvironmentSignal> signals)?  $default,) {final _that = this;
switch (_that) {
case _TodayEnvironmentSummary() when $default != null:
return $default(_that.signals);case _:
  return null;

}
}

}

/// @nodoc


class _TodayEnvironmentSummary implements TodayEnvironmentSummary {
  const _TodayEnvironmentSummary({required final  List<TodayEnvironmentSignal> signals}): _signals = signals;
  

 final  List<TodayEnvironmentSignal> _signals;
@override List<TodayEnvironmentSignal> get signals {
  if (_signals is EqualUnmodifiableListView) return _signals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_signals);
}


/// Create a copy of TodayEnvironmentSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayEnvironmentSummaryCopyWith<_TodayEnvironmentSummary> get copyWith => __$TodayEnvironmentSummaryCopyWithImpl<_TodayEnvironmentSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayEnvironmentSummary&&const DeepCollectionEquality().equals(other._signals, _signals));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_signals));

@override
String toString() {
  return 'TodayEnvironmentSummary(signals: $signals)';
}


}

/// @nodoc
abstract mixin class _$TodayEnvironmentSummaryCopyWith<$Res> implements $TodayEnvironmentSummaryCopyWith<$Res> {
  factory _$TodayEnvironmentSummaryCopyWith(_TodayEnvironmentSummary value, $Res Function(_TodayEnvironmentSummary) _then) = __$TodayEnvironmentSummaryCopyWithImpl;
@override @useResult
$Res call({
 List<TodayEnvironmentSignal> signals
});




}
/// @nodoc
class __$TodayEnvironmentSummaryCopyWithImpl<$Res>
    implements _$TodayEnvironmentSummaryCopyWith<$Res> {
  __$TodayEnvironmentSummaryCopyWithImpl(this._self, this._then);

  final _TodayEnvironmentSummary _self;
  final $Res Function(_TodayEnvironmentSummary) _then;

/// Create a copy of TodayEnvironmentSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? signals = null,}) {
  return _then(_TodayEnvironmentSummary(
signals: null == signals ? _self._signals : signals // ignore: cast_nullable_to_non_nullable
as List<TodayEnvironmentSignal>,
  ));
}


}

/// @nodoc
mixin _$TodayEnvironmentSignal {

 TodayEnvironmentSignalType get type; TodayEnvironmentLevel get level;
/// Create a copy of TodayEnvironmentSignal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayEnvironmentSignalCopyWith<TodayEnvironmentSignal> get copyWith => _$TodayEnvironmentSignalCopyWithImpl<TodayEnvironmentSignal>(this as TodayEnvironmentSignal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayEnvironmentSignal&&(identical(other.type, type) || other.type == type)&&(identical(other.level, level) || other.level == level));
}


@override
int get hashCode => Object.hash(runtimeType,type,level);

@override
String toString() {
  return 'TodayEnvironmentSignal(type: $type, level: $level)';
}


}

/// @nodoc
abstract mixin class $TodayEnvironmentSignalCopyWith<$Res>  {
  factory $TodayEnvironmentSignalCopyWith(TodayEnvironmentSignal value, $Res Function(TodayEnvironmentSignal) _then) = _$TodayEnvironmentSignalCopyWithImpl;
@useResult
$Res call({
 TodayEnvironmentSignalType type, TodayEnvironmentLevel level
});




}
/// @nodoc
class _$TodayEnvironmentSignalCopyWithImpl<$Res>
    implements $TodayEnvironmentSignalCopyWith<$Res> {
  _$TodayEnvironmentSignalCopyWithImpl(this._self, this._then);

  final TodayEnvironmentSignal _self;
  final $Res Function(TodayEnvironmentSignal) _then;

/// Create a copy of TodayEnvironmentSignal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? level = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayEnvironmentSignalType,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as TodayEnvironmentLevel,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayEnvironmentSignal].
extension TodayEnvironmentSignalPatterns on TodayEnvironmentSignal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayEnvironmentSignal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayEnvironmentSignal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayEnvironmentSignal value)  $default,){
final _that = this;
switch (_that) {
case _TodayEnvironmentSignal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayEnvironmentSignal value)?  $default,){
final _that = this;
switch (_that) {
case _TodayEnvironmentSignal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TodayEnvironmentSignalType type,  TodayEnvironmentLevel level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayEnvironmentSignal() when $default != null:
return $default(_that.type,_that.level);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TodayEnvironmentSignalType type,  TodayEnvironmentLevel level)  $default,) {final _that = this;
switch (_that) {
case _TodayEnvironmentSignal():
return $default(_that.type,_that.level);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TodayEnvironmentSignalType type,  TodayEnvironmentLevel level)?  $default,) {final _that = this;
switch (_that) {
case _TodayEnvironmentSignal() when $default != null:
return $default(_that.type,_that.level);case _:
  return null;

}
}

}

/// @nodoc


class _TodayEnvironmentSignal implements TodayEnvironmentSignal {
  const _TodayEnvironmentSignal({required this.type, required this.level});
  

@override final  TodayEnvironmentSignalType type;
@override final  TodayEnvironmentLevel level;

/// Create a copy of TodayEnvironmentSignal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayEnvironmentSignalCopyWith<_TodayEnvironmentSignal> get copyWith => __$TodayEnvironmentSignalCopyWithImpl<_TodayEnvironmentSignal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayEnvironmentSignal&&(identical(other.type, type) || other.type == type)&&(identical(other.level, level) || other.level == level));
}


@override
int get hashCode => Object.hash(runtimeType,type,level);

@override
String toString() {
  return 'TodayEnvironmentSignal(type: $type, level: $level)';
}


}

/// @nodoc
abstract mixin class _$TodayEnvironmentSignalCopyWith<$Res> implements $TodayEnvironmentSignalCopyWith<$Res> {
  factory _$TodayEnvironmentSignalCopyWith(_TodayEnvironmentSignal value, $Res Function(_TodayEnvironmentSignal) _then) = __$TodayEnvironmentSignalCopyWithImpl;
@override @useResult
$Res call({
 TodayEnvironmentSignalType type, TodayEnvironmentLevel level
});




}
/// @nodoc
class __$TodayEnvironmentSignalCopyWithImpl<$Res>
    implements _$TodayEnvironmentSignalCopyWith<$Res> {
  __$TodayEnvironmentSignalCopyWithImpl(this._self, this._then);

  final _TodayEnvironmentSignal _self;
  final $Res Function(_TodayEnvironmentSignal) _then;

/// Create a copy of TodayEnvironmentSignal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? level = null,}) {
  return _then(_TodayEnvironmentSignal(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayEnvironmentSignalType,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as TodayEnvironmentLevel,
  ));
}


}

/// @nodoc
mixin _$TodayLumiSuggestion {

 TodayLumiSuggestionType get type;
/// Create a copy of TodayLumiSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayLumiSuggestionCopyWith<TodayLumiSuggestion> get copyWith => _$TodayLumiSuggestionCopyWithImpl<TodayLumiSuggestion>(this as TodayLumiSuggestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayLumiSuggestion&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,type);

@override
String toString() {
  return 'TodayLumiSuggestion(type: $type)';
}


}

/// @nodoc
abstract mixin class $TodayLumiSuggestionCopyWith<$Res>  {
  factory $TodayLumiSuggestionCopyWith(TodayLumiSuggestion value, $Res Function(TodayLumiSuggestion) _then) = _$TodayLumiSuggestionCopyWithImpl;
@useResult
$Res call({
 TodayLumiSuggestionType type
});




}
/// @nodoc
class _$TodayLumiSuggestionCopyWithImpl<$Res>
    implements $TodayLumiSuggestionCopyWith<$Res> {
  _$TodayLumiSuggestionCopyWithImpl(this._self, this._then);

  final TodayLumiSuggestion _self;
  final $Res Function(TodayLumiSuggestion) _then;

/// Create a copy of TodayLumiSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayLumiSuggestionType,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayLumiSuggestion].
extension TodayLumiSuggestionPatterns on TodayLumiSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayLumiSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayLumiSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayLumiSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _TodayLumiSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayLumiSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _TodayLumiSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TodayLumiSuggestionType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayLumiSuggestion() when $default != null:
return $default(_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TodayLumiSuggestionType type)  $default,) {final _that = this;
switch (_that) {
case _TodayLumiSuggestion():
return $default(_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TodayLumiSuggestionType type)?  $default,) {final _that = this;
switch (_that) {
case _TodayLumiSuggestion() when $default != null:
return $default(_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _TodayLumiSuggestion implements TodayLumiSuggestion {
  const _TodayLumiSuggestion({required this.type});
  

@override final  TodayLumiSuggestionType type;

/// Create a copy of TodayLumiSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayLumiSuggestionCopyWith<_TodayLumiSuggestion> get copyWith => __$TodayLumiSuggestionCopyWithImpl<_TodayLumiSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayLumiSuggestion&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,type);

@override
String toString() {
  return 'TodayLumiSuggestion(type: $type)';
}


}

/// @nodoc
abstract mixin class _$TodayLumiSuggestionCopyWith<$Res> implements $TodayLumiSuggestionCopyWith<$Res> {
  factory _$TodayLumiSuggestionCopyWith(_TodayLumiSuggestion value, $Res Function(_TodayLumiSuggestion) _then) = __$TodayLumiSuggestionCopyWithImpl;
@override @useResult
$Res call({
 TodayLumiSuggestionType type
});




}
/// @nodoc
class __$TodayLumiSuggestionCopyWithImpl<$Res>
    implements _$TodayLumiSuggestionCopyWith<$Res> {
  __$TodayLumiSuggestionCopyWithImpl(this._self, this._then);

  final _TodayLumiSuggestion _self;
  final $Res Function(_TodayLumiSuggestion) _then;

/// Create a copy of TodayLumiSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,}) {
  return _then(_TodayLumiSuggestion(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayLumiSuggestionType,
  ));
}


}

/// @nodoc
mixin _$TodayPriorityItem {

 String get id; TodayPriorityItemType get type; int? get count; int? get targetCount; String? get timeLabel; String? get medicineName; double? get progress;
/// Create a copy of TodayPriorityItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayPriorityItemCopyWith<TodayPriorityItem> get copyWith => _$TodayPriorityItemCopyWithImpl<TodayPriorityItem>(this as TodayPriorityItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayPriorityItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.count, count) || other.count == count)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.timeLabel, timeLabel) || other.timeLabel == timeLabel)&&(identical(other.medicineName, medicineName) || other.medicineName == medicineName)&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,count,targetCount,timeLabel,medicineName,progress);

@override
String toString() {
  return 'TodayPriorityItem(id: $id, type: $type, count: $count, targetCount: $targetCount, timeLabel: $timeLabel, medicineName: $medicineName, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $TodayPriorityItemCopyWith<$Res>  {
  factory $TodayPriorityItemCopyWith(TodayPriorityItem value, $Res Function(TodayPriorityItem) _then) = _$TodayPriorityItemCopyWithImpl;
@useResult
$Res call({
 String id, TodayPriorityItemType type, int? count, int? targetCount, String? timeLabel, String? medicineName, double? progress
});




}
/// @nodoc
class _$TodayPriorityItemCopyWithImpl<$Res>
    implements $TodayPriorityItemCopyWith<$Res> {
  _$TodayPriorityItemCopyWithImpl(this._self, this._then);

  final TodayPriorityItem _self;
  final $Res Function(TodayPriorityItem) _then;

/// Create a copy of TodayPriorityItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? count = freezed,Object? targetCount = freezed,Object? timeLabel = freezed,Object? medicineName = freezed,Object? progress = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayPriorityItemType,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,targetCount: freezed == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int?,timeLabel: freezed == timeLabel ? _self.timeLabel : timeLabel // ignore: cast_nullable_to_non_nullable
as String?,medicineName: freezed == medicineName ? _self.medicineName : medicineName // ignore: cast_nullable_to_non_nullable
as String?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayPriorityItem].
extension TodayPriorityItemPatterns on TodayPriorityItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayPriorityItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayPriorityItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayPriorityItem value)  $default,){
final _that = this;
switch (_that) {
case _TodayPriorityItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayPriorityItem value)?  $default,){
final _that = this;
switch (_that) {
case _TodayPriorityItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TodayPriorityItemType type,  int? count,  int? targetCount,  String? timeLabel,  String? medicineName,  double? progress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayPriorityItem() when $default != null:
return $default(_that.id,_that.type,_that.count,_that.targetCount,_that.timeLabel,_that.medicineName,_that.progress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TodayPriorityItemType type,  int? count,  int? targetCount,  String? timeLabel,  String? medicineName,  double? progress)  $default,) {final _that = this;
switch (_that) {
case _TodayPriorityItem():
return $default(_that.id,_that.type,_that.count,_that.targetCount,_that.timeLabel,_that.medicineName,_that.progress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TodayPriorityItemType type,  int? count,  int? targetCount,  String? timeLabel,  String? medicineName,  double? progress)?  $default,) {final _that = this;
switch (_that) {
case _TodayPriorityItem() when $default != null:
return $default(_that.id,_that.type,_that.count,_that.targetCount,_that.timeLabel,_that.medicineName,_that.progress);case _:
  return null;

}
}

}

/// @nodoc


class _TodayPriorityItem implements TodayPriorityItem {
  const _TodayPriorityItem({required this.id, required this.type, this.count, this.targetCount, this.timeLabel, this.medicineName, this.progress});
  

@override final  String id;
@override final  TodayPriorityItemType type;
@override final  int? count;
@override final  int? targetCount;
@override final  String? timeLabel;
@override final  String? medicineName;
@override final  double? progress;

/// Create a copy of TodayPriorityItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayPriorityItemCopyWith<_TodayPriorityItem> get copyWith => __$TodayPriorityItemCopyWithImpl<_TodayPriorityItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayPriorityItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.count, count) || other.count == count)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.timeLabel, timeLabel) || other.timeLabel == timeLabel)&&(identical(other.medicineName, medicineName) || other.medicineName == medicineName)&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,count,targetCount,timeLabel,medicineName,progress);

@override
String toString() {
  return 'TodayPriorityItem(id: $id, type: $type, count: $count, targetCount: $targetCount, timeLabel: $timeLabel, medicineName: $medicineName, progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$TodayPriorityItemCopyWith<$Res> implements $TodayPriorityItemCopyWith<$Res> {
  factory _$TodayPriorityItemCopyWith(_TodayPriorityItem value, $Res Function(_TodayPriorityItem) _then) = __$TodayPriorityItemCopyWithImpl;
@override @useResult
$Res call({
 String id, TodayPriorityItemType type, int? count, int? targetCount, String? timeLabel, String? medicineName, double? progress
});




}
/// @nodoc
class __$TodayPriorityItemCopyWithImpl<$Res>
    implements _$TodayPriorityItemCopyWith<$Res> {
  __$TodayPriorityItemCopyWithImpl(this._self, this._then);

  final _TodayPriorityItem _self;
  final $Res Function(_TodayPriorityItem) _then;

/// Create a copy of TodayPriorityItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? count = freezed,Object? targetCount = freezed,Object? timeLabel = freezed,Object? medicineName = freezed,Object? progress = freezed,}) {
  return _then(_TodayPriorityItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TodayPriorityItemType,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,targetCount: freezed == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int?,timeLabel: freezed == timeLabel ? _self.timeLabel : timeLabel // ignore: cast_nullable_to_non_nullable
as String?,medicineName: freezed == medicineName ? _self.medicineName : medicineName // ignore: cast_nullable_to_non_nullable
as String?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
