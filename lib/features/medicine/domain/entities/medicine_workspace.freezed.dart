// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medicine_workspace.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicineWorkspace {

 MedicineHero get hero; List<MedicineQuickAction> get quickActions; MedicinePlanSurface get plan; List<MedicineAlert> get alerts; List<MedicinePromisePoint> get promisePoints; MedicineRiskCheckResult? get riskCheckResult;
/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineWorkspaceCopyWith<MedicineWorkspace> get copyWith => _$MedicineWorkspaceCopyWithImpl<MedicineWorkspace>(this as MedicineWorkspace, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineWorkspace&&(identical(other.hero, hero) || other.hero == hero)&&const DeepCollectionEquality().equals(other.quickActions, quickActions)&&(identical(other.plan, plan) || other.plan == plan)&&const DeepCollectionEquality().equals(other.alerts, alerts)&&const DeepCollectionEquality().equals(other.promisePoints, promisePoints)&&(identical(other.riskCheckResult, riskCheckResult) || other.riskCheckResult == riskCheckResult));
}


@override
int get hashCode => Object.hash(runtimeType,hero,const DeepCollectionEquality().hash(quickActions),plan,const DeepCollectionEquality().hash(alerts),const DeepCollectionEquality().hash(promisePoints),riskCheckResult);

@override
String toString() {
  return 'MedicineWorkspace(hero: $hero, quickActions: $quickActions, plan: $plan, alerts: $alerts, promisePoints: $promisePoints, riskCheckResult: $riskCheckResult)';
}


}

/// @nodoc
abstract mixin class $MedicineWorkspaceCopyWith<$Res>  {
  factory $MedicineWorkspaceCopyWith(MedicineWorkspace value, $Res Function(MedicineWorkspace) _then) = _$MedicineWorkspaceCopyWithImpl;
@useResult
$Res call({
 MedicineHero hero, List<MedicineQuickAction> quickActions, MedicinePlanSurface plan, List<MedicineAlert> alerts, List<MedicinePromisePoint> promisePoints, MedicineRiskCheckResult? riskCheckResult
});


$MedicineHeroCopyWith<$Res> get hero;$MedicinePlanSurfaceCopyWith<$Res> get plan;$MedicineRiskCheckResultCopyWith<$Res>? get riskCheckResult;

}
/// @nodoc
class _$MedicineWorkspaceCopyWithImpl<$Res>
    implements $MedicineWorkspaceCopyWith<$Res> {
  _$MedicineWorkspaceCopyWithImpl(this._self, this._then);

  final MedicineWorkspace _self;
  final $Res Function(MedicineWorkspace) _then;

/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hero = null,Object? quickActions = null,Object? plan = null,Object? alerts = null,Object? promisePoints = null,Object? riskCheckResult = freezed,}) {
  return _then(_self.copyWith(
hero: null == hero ? _self.hero : hero // ignore: cast_nullable_to_non_nullable
as MedicineHero,quickActions: null == quickActions ? _self.quickActions : quickActions // ignore: cast_nullable_to_non_nullable
as List<MedicineQuickAction>,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as MedicinePlanSurface,alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<MedicineAlert>,promisePoints: null == promisePoints ? _self.promisePoints : promisePoints // ignore: cast_nullable_to_non_nullable
as List<MedicinePromisePoint>,riskCheckResult: freezed == riskCheckResult ? _self.riskCheckResult : riskCheckResult // ignore: cast_nullable_to_non_nullable
as MedicineRiskCheckResult?,
  ));
}
/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicineHeroCopyWith<$Res> get hero {
  
  return $MedicineHeroCopyWith<$Res>(_self.hero, (value) {
    return _then(_self.copyWith(hero: value));
  });
}/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicinePlanSurfaceCopyWith<$Res> get plan {
  
  return $MedicinePlanSurfaceCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicineRiskCheckResultCopyWith<$Res>? get riskCheckResult {
    if (_self.riskCheckResult == null) {
    return null;
  }

  return $MedicineRiskCheckResultCopyWith<$Res>(_self.riskCheckResult!, (value) {
    return _then(_self.copyWith(riskCheckResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicineWorkspace].
extension MedicineWorkspacePatterns on MedicineWorkspace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineWorkspace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineWorkspace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineWorkspace value)  $default,){
final _that = this;
switch (_that) {
case _MedicineWorkspace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineWorkspace value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineWorkspace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MedicineHero hero,  List<MedicineQuickAction> quickActions,  MedicinePlanSurface plan,  List<MedicineAlert> alerts,  List<MedicinePromisePoint> promisePoints,  MedicineRiskCheckResult? riskCheckResult)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineWorkspace() when $default != null:
return $default(_that.hero,_that.quickActions,_that.plan,_that.alerts,_that.promisePoints,_that.riskCheckResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MedicineHero hero,  List<MedicineQuickAction> quickActions,  MedicinePlanSurface plan,  List<MedicineAlert> alerts,  List<MedicinePromisePoint> promisePoints,  MedicineRiskCheckResult? riskCheckResult)  $default,) {final _that = this;
switch (_that) {
case _MedicineWorkspace():
return $default(_that.hero,_that.quickActions,_that.plan,_that.alerts,_that.promisePoints,_that.riskCheckResult);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MedicineHero hero,  List<MedicineQuickAction> quickActions,  MedicinePlanSurface plan,  List<MedicineAlert> alerts,  List<MedicinePromisePoint> promisePoints,  MedicineRiskCheckResult? riskCheckResult)?  $default,) {final _that = this;
switch (_that) {
case _MedicineWorkspace() when $default != null:
return $default(_that.hero,_that.quickActions,_that.plan,_that.alerts,_that.promisePoints,_that.riskCheckResult);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineWorkspace implements MedicineWorkspace {
  const _MedicineWorkspace({required this.hero, required final  List<MedicineQuickAction> quickActions, required this.plan, required final  List<MedicineAlert> alerts, required final  List<MedicinePromisePoint> promisePoints, this.riskCheckResult}): _quickActions = quickActions,_alerts = alerts,_promisePoints = promisePoints;
  

@override final  MedicineHero hero;
 final  List<MedicineQuickAction> _quickActions;
@override List<MedicineQuickAction> get quickActions {
  if (_quickActions is EqualUnmodifiableListView) return _quickActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quickActions);
}

@override final  MedicinePlanSurface plan;
 final  List<MedicineAlert> _alerts;
@override List<MedicineAlert> get alerts {
  if (_alerts is EqualUnmodifiableListView) return _alerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alerts);
}

 final  List<MedicinePromisePoint> _promisePoints;
@override List<MedicinePromisePoint> get promisePoints {
  if (_promisePoints is EqualUnmodifiableListView) return _promisePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_promisePoints);
}

@override final  MedicineRiskCheckResult? riskCheckResult;

/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineWorkspaceCopyWith<_MedicineWorkspace> get copyWith => __$MedicineWorkspaceCopyWithImpl<_MedicineWorkspace>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineWorkspace&&(identical(other.hero, hero) || other.hero == hero)&&const DeepCollectionEquality().equals(other._quickActions, _quickActions)&&(identical(other.plan, plan) || other.plan == plan)&&const DeepCollectionEquality().equals(other._alerts, _alerts)&&const DeepCollectionEquality().equals(other._promisePoints, _promisePoints)&&(identical(other.riskCheckResult, riskCheckResult) || other.riskCheckResult == riskCheckResult));
}


@override
int get hashCode => Object.hash(runtimeType,hero,const DeepCollectionEquality().hash(_quickActions),plan,const DeepCollectionEquality().hash(_alerts),const DeepCollectionEquality().hash(_promisePoints),riskCheckResult);

@override
String toString() {
  return 'MedicineWorkspace(hero: $hero, quickActions: $quickActions, plan: $plan, alerts: $alerts, promisePoints: $promisePoints, riskCheckResult: $riskCheckResult)';
}


}

/// @nodoc
abstract mixin class _$MedicineWorkspaceCopyWith<$Res> implements $MedicineWorkspaceCopyWith<$Res> {
  factory _$MedicineWorkspaceCopyWith(_MedicineWorkspace value, $Res Function(_MedicineWorkspace) _then) = __$MedicineWorkspaceCopyWithImpl;
@override @useResult
$Res call({
 MedicineHero hero, List<MedicineQuickAction> quickActions, MedicinePlanSurface plan, List<MedicineAlert> alerts, List<MedicinePromisePoint> promisePoints, MedicineRiskCheckResult? riskCheckResult
});


@override $MedicineHeroCopyWith<$Res> get hero;@override $MedicinePlanSurfaceCopyWith<$Res> get plan;@override $MedicineRiskCheckResultCopyWith<$Res>? get riskCheckResult;

}
/// @nodoc
class __$MedicineWorkspaceCopyWithImpl<$Res>
    implements _$MedicineWorkspaceCopyWith<$Res> {
  __$MedicineWorkspaceCopyWithImpl(this._self, this._then);

  final _MedicineWorkspace _self;
  final $Res Function(_MedicineWorkspace) _then;

/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hero = null,Object? quickActions = null,Object? plan = null,Object? alerts = null,Object? promisePoints = null,Object? riskCheckResult = freezed,}) {
  return _then(_MedicineWorkspace(
hero: null == hero ? _self.hero : hero // ignore: cast_nullable_to_non_nullable
as MedicineHero,quickActions: null == quickActions ? _self._quickActions : quickActions // ignore: cast_nullable_to_non_nullable
as List<MedicineQuickAction>,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as MedicinePlanSurface,alerts: null == alerts ? _self._alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<MedicineAlert>,promisePoints: null == promisePoints ? _self._promisePoints : promisePoints // ignore: cast_nullable_to_non_nullable
as List<MedicinePromisePoint>,riskCheckResult: freezed == riskCheckResult ? _self.riskCheckResult : riskCheckResult // ignore: cast_nullable_to_non_nullable
as MedicineRiskCheckResult?,
  ));
}

/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicineHeroCopyWith<$Res> get hero {
  
  return $MedicineHeroCopyWith<$Res>(_self.hero, (value) {
    return _then(_self.copyWith(hero: value));
  });
}/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicinePlanSurfaceCopyWith<$Res> get plan {
  
  return $MedicinePlanSurfaceCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of MedicineWorkspace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicineRiskCheckResultCopyWith<$Res>? get riskCheckResult {
    if (_self.riskCheckResult == null) {
    return null;
  }

  return $MedicineRiskCheckResultCopyWith<$Res>(_self.riskCheckResult!, (value) {
    return _then(_self.copyWith(riskCheckResult: value));
  });
}
}

/// @nodoc
mixin _$MedicineHero {

 String get metricDosesToday; String get metricAdherence; String get metricNextDose;
/// Create a copy of MedicineHero
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineHeroCopyWith<MedicineHero> get copyWith => _$MedicineHeroCopyWithImpl<MedicineHero>(this as MedicineHero, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineHero&&(identical(other.metricDosesToday, metricDosesToday) || other.metricDosesToday == metricDosesToday)&&(identical(other.metricAdherence, metricAdherence) || other.metricAdherence == metricAdherence)&&(identical(other.metricNextDose, metricNextDose) || other.metricNextDose == metricNextDose));
}


@override
int get hashCode => Object.hash(runtimeType,metricDosesToday,metricAdherence,metricNextDose);

@override
String toString() {
  return 'MedicineHero(metricDosesToday: $metricDosesToday, metricAdherence: $metricAdherence, metricNextDose: $metricNextDose)';
}


}

/// @nodoc
abstract mixin class $MedicineHeroCopyWith<$Res>  {
  factory $MedicineHeroCopyWith(MedicineHero value, $Res Function(MedicineHero) _then) = _$MedicineHeroCopyWithImpl;
@useResult
$Res call({
 String metricDosesToday, String metricAdherence, String metricNextDose
});




}
/// @nodoc
class _$MedicineHeroCopyWithImpl<$Res>
    implements $MedicineHeroCopyWith<$Res> {
  _$MedicineHeroCopyWithImpl(this._self, this._then);

  final MedicineHero _self;
  final $Res Function(MedicineHero) _then;

/// Create a copy of MedicineHero
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metricDosesToday = null,Object? metricAdherence = null,Object? metricNextDose = null,}) {
  return _then(_self.copyWith(
metricDosesToday: null == metricDosesToday ? _self.metricDosesToday : metricDosesToday // ignore: cast_nullable_to_non_nullable
as String,metricAdherence: null == metricAdherence ? _self.metricAdherence : metricAdherence // ignore: cast_nullable_to_non_nullable
as String,metricNextDose: null == metricNextDose ? _self.metricNextDose : metricNextDose // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineHero].
extension MedicineHeroPatterns on MedicineHero {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineHero value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineHero() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineHero value)  $default,){
final _that = this;
switch (_that) {
case _MedicineHero():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineHero value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineHero() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String metricDosesToday,  String metricAdherence,  String metricNextDose)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineHero() when $default != null:
return $default(_that.metricDosesToday,_that.metricAdherence,_that.metricNextDose);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String metricDosesToday,  String metricAdherence,  String metricNextDose)  $default,) {final _that = this;
switch (_that) {
case _MedicineHero():
return $default(_that.metricDosesToday,_that.metricAdherence,_that.metricNextDose);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String metricDosesToday,  String metricAdherence,  String metricNextDose)?  $default,) {final _that = this;
switch (_that) {
case _MedicineHero() when $default != null:
return $default(_that.metricDosesToday,_that.metricAdherence,_that.metricNextDose);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineHero implements MedicineHero {
  const _MedicineHero({required this.metricDosesToday, required this.metricAdherence, required this.metricNextDose});
  

@override final  String metricDosesToday;
@override final  String metricAdherence;
@override final  String metricNextDose;

/// Create a copy of MedicineHero
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineHeroCopyWith<_MedicineHero> get copyWith => __$MedicineHeroCopyWithImpl<_MedicineHero>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineHero&&(identical(other.metricDosesToday, metricDosesToday) || other.metricDosesToday == metricDosesToday)&&(identical(other.metricAdherence, metricAdherence) || other.metricAdherence == metricAdherence)&&(identical(other.metricNextDose, metricNextDose) || other.metricNextDose == metricNextDose));
}


@override
int get hashCode => Object.hash(runtimeType,metricDosesToday,metricAdherence,metricNextDose);

@override
String toString() {
  return 'MedicineHero(metricDosesToday: $metricDosesToday, metricAdherence: $metricAdherence, metricNextDose: $metricNextDose)';
}


}

/// @nodoc
abstract mixin class _$MedicineHeroCopyWith<$Res> implements $MedicineHeroCopyWith<$Res> {
  factory _$MedicineHeroCopyWith(_MedicineHero value, $Res Function(_MedicineHero) _then) = __$MedicineHeroCopyWithImpl;
@override @useResult
$Res call({
 String metricDosesToday, String metricAdherence, String metricNextDose
});




}
/// @nodoc
class __$MedicineHeroCopyWithImpl<$Res>
    implements _$MedicineHeroCopyWith<$Res> {
  __$MedicineHeroCopyWithImpl(this._self, this._then);

  final _MedicineHero _self;
  final $Res Function(_MedicineHero) _then;

/// Create a copy of MedicineHero
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metricDosesToday = null,Object? metricAdherence = null,Object? metricNextDose = null,}) {
  return _then(_MedicineHero(
metricDosesToday: null == metricDosesToday ? _self.metricDosesToday : metricDosesToday // ignore: cast_nullable_to_non_nullable
as String,metricAdherence: null == metricAdherence ? _self.metricAdherence : metricAdherence // ignore: cast_nullable_to_non_nullable
as String,metricNextDose: null == metricNextDose ? _self.metricNextDose : metricNextDose // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$MedicineQuickAction {

 IconData get icon; MedicineCopyKey get titleKey; MedicineCopyKey get subtitleKey; Color get accent;
/// Create a copy of MedicineQuickAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineQuickActionCopyWith<MedicineQuickAction> get copyWith => _$MedicineQuickActionCopyWithImpl<MedicineQuickAction>(this as MedicineQuickAction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineQuickAction&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.accent, accent) || other.accent == accent));
}


@override
int get hashCode => Object.hash(runtimeType,icon,titleKey,subtitleKey,accent);

@override
String toString() {
  return 'MedicineQuickAction(icon: $icon, titleKey: $titleKey, subtitleKey: $subtitleKey, accent: $accent)';
}


}

/// @nodoc
abstract mixin class $MedicineQuickActionCopyWith<$Res>  {
  factory $MedicineQuickActionCopyWith(MedicineQuickAction value, $Res Function(MedicineQuickAction) _then) = _$MedicineQuickActionCopyWithImpl;
@useResult
$Res call({
 IconData icon, MedicineCopyKey titleKey, MedicineCopyKey subtitleKey, Color accent
});




}
/// @nodoc
class _$MedicineQuickActionCopyWithImpl<$Res>
    implements $MedicineQuickActionCopyWith<$Res> {
  _$MedicineQuickActionCopyWithImpl(this._self, this._then);

  final MedicineQuickAction _self;
  final $Res Function(MedicineQuickAction) _then;

/// Create a copy of MedicineQuickAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? titleKey = null,Object? subtitleKey = null,Object? accent = null,}) {
  return _then(_self.copyWith(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineQuickAction].
extension MedicineQuickActionPatterns on MedicineQuickAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineQuickAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineQuickAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineQuickAction value)  $default,){
final _that = this;
switch (_that) {
case _MedicineQuickAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineQuickAction value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineQuickAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IconData icon,  MedicineCopyKey titleKey,  MedicineCopyKey subtitleKey,  Color accent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineQuickAction() when $default != null:
return $default(_that.icon,_that.titleKey,_that.subtitleKey,_that.accent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IconData icon,  MedicineCopyKey titleKey,  MedicineCopyKey subtitleKey,  Color accent)  $default,) {final _that = this;
switch (_that) {
case _MedicineQuickAction():
return $default(_that.icon,_that.titleKey,_that.subtitleKey,_that.accent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IconData icon,  MedicineCopyKey titleKey,  MedicineCopyKey subtitleKey,  Color accent)?  $default,) {final _that = this;
switch (_that) {
case _MedicineQuickAction() when $default != null:
return $default(_that.icon,_that.titleKey,_that.subtitleKey,_that.accent);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineQuickAction implements MedicineQuickAction {
  const _MedicineQuickAction({required this.icon, required this.titleKey, required this.subtitleKey, required this.accent});
  

@override final  IconData icon;
@override final  MedicineCopyKey titleKey;
@override final  MedicineCopyKey subtitleKey;
@override final  Color accent;

/// Create a copy of MedicineQuickAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineQuickActionCopyWith<_MedicineQuickAction> get copyWith => __$MedicineQuickActionCopyWithImpl<_MedicineQuickAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineQuickAction&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.accent, accent) || other.accent == accent));
}


@override
int get hashCode => Object.hash(runtimeType,icon,titleKey,subtitleKey,accent);

@override
String toString() {
  return 'MedicineQuickAction(icon: $icon, titleKey: $titleKey, subtitleKey: $subtitleKey, accent: $accent)';
}


}

/// @nodoc
abstract mixin class _$MedicineQuickActionCopyWith<$Res> implements $MedicineQuickActionCopyWith<$Res> {
  factory _$MedicineQuickActionCopyWith(_MedicineQuickAction value, $Res Function(_MedicineQuickAction) _then) = __$MedicineQuickActionCopyWithImpl;
@override @useResult
$Res call({
 IconData icon, MedicineCopyKey titleKey, MedicineCopyKey subtitleKey, Color accent
});




}
/// @nodoc
class __$MedicineQuickActionCopyWithImpl<$Res>
    implements _$MedicineQuickActionCopyWith<$Res> {
  __$MedicineQuickActionCopyWithImpl(this._self, this._then);

  final _MedicineQuickAction _self;
  final $Res Function(_MedicineQuickAction) _then;

/// Create a copy of MedicineQuickAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? titleKey = null,Object? subtitleKey = null,Object? accent = null,}) {
  return _then(_MedicineQuickAction(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

/// @nodoc
mixin _$MedicinePlanSurface {

 List<MedicinePlanItem> get items;
/// Create a copy of MedicinePlanSurface
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicinePlanSurfaceCopyWith<MedicinePlanSurface> get copyWith => _$MedicinePlanSurfaceCopyWithImpl<MedicinePlanSurface>(this as MedicinePlanSurface, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicinePlanSurface&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MedicinePlanSurface(items: $items)';
}


}

/// @nodoc
abstract mixin class $MedicinePlanSurfaceCopyWith<$Res>  {
  factory $MedicinePlanSurfaceCopyWith(MedicinePlanSurface value, $Res Function(MedicinePlanSurface) _then) = _$MedicinePlanSurfaceCopyWithImpl;
@useResult
$Res call({
 List<MedicinePlanItem> items
});




}
/// @nodoc
class _$MedicinePlanSurfaceCopyWithImpl<$Res>
    implements $MedicinePlanSurfaceCopyWith<$Res> {
  _$MedicinePlanSurfaceCopyWithImpl(this._self, this._then);

  final MedicinePlanSurface _self;
  final $Res Function(MedicinePlanSurface) _then;

/// Create a copy of MedicinePlanSurface
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MedicinePlanItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicinePlanSurface].
extension MedicinePlanSurfacePatterns on MedicinePlanSurface {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicinePlanSurface value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicinePlanSurface() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicinePlanSurface value)  $default,){
final _that = this;
switch (_that) {
case _MedicinePlanSurface():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicinePlanSurface value)?  $default,){
final _that = this;
switch (_that) {
case _MedicinePlanSurface() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MedicinePlanItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicinePlanSurface() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MedicinePlanItem> items)  $default,) {final _that = this;
switch (_that) {
case _MedicinePlanSurface():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MedicinePlanItem> items)?  $default,) {final _that = this;
switch (_that) {
case _MedicinePlanSurface() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _MedicinePlanSurface implements MedicinePlanSurface {
  const _MedicinePlanSurface({required final  List<MedicinePlanItem> items}): _items = items;
  

 final  List<MedicinePlanItem> _items;
@override List<MedicinePlanItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MedicinePlanSurface
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicinePlanSurfaceCopyWith<_MedicinePlanSurface> get copyWith => __$MedicinePlanSurfaceCopyWithImpl<_MedicinePlanSurface>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicinePlanSurface&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MedicinePlanSurface(items: $items)';
}


}

/// @nodoc
abstract mixin class _$MedicinePlanSurfaceCopyWith<$Res> implements $MedicinePlanSurfaceCopyWith<$Res> {
  factory _$MedicinePlanSurfaceCopyWith(_MedicinePlanSurface value, $Res Function(_MedicinePlanSurface) _then) = __$MedicinePlanSurfaceCopyWithImpl;
@override @useResult
$Res call({
 List<MedicinePlanItem> items
});




}
/// @nodoc
class __$MedicinePlanSurfaceCopyWithImpl<$Res>
    implements _$MedicinePlanSurfaceCopyWith<$Res> {
  __$MedicinePlanSurfaceCopyWithImpl(this._self, this._then);

  final _MedicinePlanSurface _self;
  final $Res Function(_MedicinePlanSurface) _then;

/// Create a copy of MedicinePlanSurface
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_MedicinePlanSurface(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MedicinePlanItem>,
  ));
}


}

/// @nodoc
mixin _$MedicinePlanItem {

 Color get color; MedicineCopyKey get nameKey; MedicineCopyKey get dosageKey; MedicineCopyKey get scheduleKey; List<MedicineDoseSlot> get slots; MedicineCopyKey get stateKey; Color get stateColor; MedicineDoseStatus? get todayStatus;/// When non-null, the view should use these raw strings instead of
/// resolving [nameKey]/[dosageKey]/[scheduleKey]/[stateKey] through
/// [medicineCopy].
 String? get rawName; String? get rawDosage; String? get rawSchedule; String? get rawState; String? get currentMedicineId;
/// Create a copy of MedicinePlanItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicinePlanItemCopyWith<MedicinePlanItem> get copyWith => _$MedicinePlanItemCopyWithImpl<MedicinePlanItem>(this as MedicinePlanItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicinePlanItem&&(identical(other.color, color) || other.color == color)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.dosageKey, dosageKey) || other.dosageKey == dosageKey)&&(identical(other.scheduleKey, scheduleKey) || other.scheduleKey == scheduleKey)&&const DeepCollectionEquality().equals(other.slots, slots)&&(identical(other.stateKey, stateKey) || other.stateKey == stateKey)&&(identical(other.stateColor, stateColor) || other.stateColor == stateColor)&&(identical(other.todayStatus, todayStatus) || other.todayStatus == todayStatus)&&(identical(other.rawName, rawName) || other.rawName == rawName)&&(identical(other.rawDosage, rawDosage) || other.rawDosage == rawDosage)&&(identical(other.rawSchedule, rawSchedule) || other.rawSchedule == rawSchedule)&&(identical(other.rawState, rawState) || other.rawState == rawState)&&(identical(other.currentMedicineId, currentMedicineId) || other.currentMedicineId == currentMedicineId));
}


@override
int get hashCode => Object.hash(runtimeType,color,nameKey,dosageKey,scheduleKey,const DeepCollectionEquality().hash(slots),stateKey,stateColor,todayStatus,rawName,rawDosage,rawSchedule,rawState,currentMedicineId);

@override
String toString() {
  return 'MedicinePlanItem(color: $color, nameKey: $nameKey, dosageKey: $dosageKey, scheduleKey: $scheduleKey, slots: $slots, stateKey: $stateKey, stateColor: $stateColor, todayStatus: $todayStatus, rawName: $rawName, rawDosage: $rawDosage, rawSchedule: $rawSchedule, rawState: $rawState, currentMedicineId: $currentMedicineId)';
}


}

/// @nodoc
abstract mixin class $MedicinePlanItemCopyWith<$Res>  {
  factory $MedicinePlanItemCopyWith(MedicinePlanItem value, $Res Function(MedicinePlanItem) _then) = _$MedicinePlanItemCopyWithImpl;
@useResult
$Res call({
 Color color, MedicineCopyKey nameKey, MedicineCopyKey dosageKey, MedicineCopyKey scheduleKey, List<MedicineDoseSlot> slots, MedicineCopyKey stateKey, Color stateColor, MedicineDoseStatus? todayStatus, String? rawName, String? rawDosage, String? rawSchedule, String? rawState, String? currentMedicineId
});




}
/// @nodoc
class _$MedicinePlanItemCopyWithImpl<$Res>
    implements $MedicinePlanItemCopyWith<$Res> {
  _$MedicinePlanItemCopyWithImpl(this._self, this._then);

  final MedicinePlanItem _self;
  final $Res Function(MedicinePlanItem) _then;

/// Create a copy of MedicinePlanItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? nameKey = null,Object? dosageKey = null,Object? scheduleKey = null,Object? slots = null,Object? stateKey = null,Object? stateColor = null,Object? todayStatus = freezed,Object? rawName = freezed,Object? rawDosage = freezed,Object? rawSchedule = freezed,Object? rawState = freezed,Object? currentMedicineId = freezed,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,dosageKey: null == dosageKey ? _self.dosageKey : dosageKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,scheduleKey: null == scheduleKey ? _self.scheduleKey : scheduleKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as List<MedicineDoseSlot>,stateKey: null == stateKey ? _self.stateKey : stateKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,stateColor: null == stateColor ? _self.stateColor : stateColor // ignore: cast_nullable_to_non_nullable
as Color,todayStatus: freezed == todayStatus ? _self.todayStatus : todayStatus // ignore: cast_nullable_to_non_nullable
as MedicineDoseStatus?,rawName: freezed == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String?,rawDosage: freezed == rawDosage ? _self.rawDosage : rawDosage // ignore: cast_nullable_to_non_nullable
as String?,rawSchedule: freezed == rawSchedule ? _self.rawSchedule : rawSchedule // ignore: cast_nullable_to_non_nullable
as String?,rawState: freezed == rawState ? _self.rawState : rawState // ignore: cast_nullable_to_non_nullable
as String?,currentMedicineId: freezed == currentMedicineId ? _self.currentMedicineId : currentMedicineId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicinePlanItem].
extension MedicinePlanItemPatterns on MedicinePlanItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicinePlanItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicinePlanItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicinePlanItem value)  $default,){
final _that = this;
switch (_that) {
case _MedicinePlanItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicinePlanItem value)?  $default,){
final _that = this;
switch (_that) {
case _MedicinePlanItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Color color,  MedicineCopyKey nameKey,  MedicineCopyKey dosageKey,  MedicineCopyKey scheduleKey,  List<MedicineDoseSlot> slots,  MedicineCopyKey stateKey,  Color stateColor,  MedicineDoseStatus? todayStatus,  String? rawName,  String? rawDosage,  String? rawSchedule,  String? rawState,  String? currentMedicineId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicinePlanItem() when $default != null:
return $default(_that.color,_that.nameKey,_that.dosageKey,_that.scheduleKey,_that.slots,_that.stateKey,_that.stateColor,_that.todayStatus,_that.rawName,_that.rawDosage,_that.rawSchedule,_that.rawState,_that.currentMedicineId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Color color,  MedicineCopyKey nameKey,  MedicineCopyKey dosageKey,  MedicineCopyKey scheduleKey,  List<MedicineDoseSlot> slots,  MedicineCopyKey stateKey,  Color stateColor,  MedicineDoseStatus? todayStatus,  String? rawName,  String? rawDosage,  String? rawSchedule,  String? rawState,  String? currentMedicineId)  $default,) {final _that = this;
switch (_that) {
case _MedicinePlanItem():
return $default(_that.color,_that.nameKey,_that.dosageKey,_that.scheduleKey,_that.slots,_that.stateKey,_that.stateColor,_that.todayStatus,_that.rawName,_that.rawDosage,_that.rawSchedule,_that.rawState,_that.currentMedicineId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Color color,  MedicineCopyKey nameKey,  MedicineCopyKey dosageKey,  MedicineCopyKey scheduleKey,  List<MedicineDoseSlot> slots,  MedicineCopyKey stateKey,  Color stateColor,  MedicineDoseStatus? todayStatus,  String? rawName,  String? rawDosage,  String? rawSchedule,  String? rawState,  String? currentMedicineId)?  $default,) {final _that = this;
switch (_that) {
case _MedicinePlanItem() when $default != null:
return $default(_that.color,_that.nameKey,_that.dosageKey,_that.scheduleKey,_that.slots,_that.stateKey,_that.stateColor,_that.todayStatus,_that.rawName,_that.rawDosage,_that.rawSchedule,_that.rawState,_that.currentMedicineId);case _:
  return null;

}
}

}

/// @nodoc


class _MedicinePlanItem implements MedicinePlanItem {
  const _MedicinePlanItem({required this.color, required this.nameKey, required this.dosageKey, required this.scheduleKey, required final  List<MedicineDoseSlot> slots, required this.stateKey, required this.stateColor, this.todayStatus, this.rawName, this.rawDosage, this.rawSchedule, this.rawState, this.currentMedicineId}): _slots = slots;
  

@override final  Color color;
@override final  MedicineCopyKey nameKey;
@override final  MedicineCopyKey dosageKey;
@override final  MedicineCopyKey scheduleKey;
 final  List<MedicineDoseSlot> _slots;
@override List<MedicineDoseSlot> get slots {
  if (_slots is EqualUnmodifiableListView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slots);
}

@override final  MedicineCopyKey stateKey;
@override final  Color stateColor;
@override final  MedicineDoseStatus? todayStatus;
/// When non-null, the view should use these raw strings instead of
/// resolving [nameKey]/[dosageKey]/[scheduleKey]/[stateKey] through
/// [medicineCopy].
@override final  String? rawName;
@override final  String? rawDosage;
@override final  String? rawSchedule;
@override final  String? rawState;
@override final  String? currentMedicineId;

/// Create a copy of MedicinePlanItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicinePlanItemCopyWith<_MedicinePlanItem> get copyWith => __$MedicinePlanItemCopyWithImpl<_MedicinePlanItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicinePlanItem&&(identical(other.color, color) || other.color == color)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.dosageKey, dosageKey) || other.dosageKey == dosageKey)&&(identical(other.scheduleKey, scheduleKey) || other.scheduleKey == scheduleKey)&&const DeepCollectionEquality().equals(other._slots, _slots)&&(identical(other.stateKey, stateKey) || other.stateKey == stateKey)&&(identical(other.stateColor, stateColor) || other.stateColor == stateColor)&&(identical(other.todayStatus, todayStatus) || other.todayStatus == todayStatus)&&(identical(other.rawName, rawName) || other.rawName == rawName)&&(identical(other.rawDosage, rawDosage) || other.rawDosage == rawDosage)&&(identical(other.rawSchedule, rawSchedule) || other.rawSchedule == rawSchedule)&&(identical(other.rawState, rawState) || other.rawState == rawState)&&(identical(other.currentMedicineId, currentMedicineId) || other.currentMedicineId == currentMedicineId));
}


@override
int get hashCode => Object.hash(runtimeType,color,nameKey,dosageKey,scheduleKey,const DeepCollectionEquality().hash(_slots),stateKey,stateColor,todayStatus,rawName,rawDosage,rawSchedule,rawState,currentMedicineId);

@override
String toString() {
  return 'MedicinePlanItem(color: $color, nameKey: $nameKey, dosageKey: $dosageKey, scheduleKey: $scheduleKey, slots: $slots, stateKey: $stateKey, stateColor: $stateColor, todayStatus: $todayStatus, rawName: $rawName, rawDosage: $rawDosage, rawSchedule: $rawSchedule, rawState: $rawState, currentMedicineId: $currentMedicineId)';
}


}

/// @nodoc
abstract mixin class _$MedicinePlanItemCopyWith<$Res> implements $MedicinePlanItemCopyWith<$Res> {
  factory _$MedicinePlanItemCopyWith(_MedicinePlanItem value, $Res Function(_MedicinePlanItem) _then) = __$MedicinePlanItemCopyWithImpl;
@override @useResult
$Res call({
 Color color, MedicineCopyKey nameKey, MedicineCopyKey dosageKey, MedicineCopyKey scheduleKey, List<MedicineDoseSlot> slots, MedicineCopyKey stateKey, Color stateColor, MedicineDoseStatus? todayStatus, String? rawName, String? rawDosage, String? rawSchedule, String? rawState, String? currentMedicineId
});




}
/// @nodoc
class __$MedicinePlanItemCopyWithImpl<$Res>
    implements _$MedicinePlanItemCopyWith<$Res> {
  __$MedicinePlanItemCopyWithImpl(this._self, this._then);

  final _MedicinePlanItem _self;
  final $Res Function(_MedicinePlanItem) _then;

/// Create a copy of MedicinePlanItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? nameKey = null,Object? dosageKey = null,Object? scheduleKey = null,Object? slots = null,Object? stateKey = null,Object? stateColor = null,Object? todayStatus = freezed,Object? rawName = freezed,Object? rawDosage = freezed,Object? rawSchedule = freezed,Object? rawState = freezed,Object? currentMedicineId = freezed,}) {
  return _then(_MedicinePlanItem(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,dosageKey: null == dosageKey ? _self.dosageKey : dosageKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,scheduleKey: null == scheduleKey ? _self.scheduleKey : scheduleKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as List<MedicineDoseSlot>,stateKey: null == stateKey ? _self.stateKey : stateKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,stateColor: null == stateColor ? _self.stateColor : stateColor // ignore: cast_nullable_to_non_nullable
as Color,todayStatus: freezed == todayStatus ? _self.todayStatus : todayStatus // ignore: cast_nullable_to_non_nullable
as MedicineDoseStatus?,rawName: freezed == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String?,rawDosage: freezed == rawDosage ? _self.rawDosage : rawDosage // ignore: cast_nullable_to_non_nullable
as String?,rawSchedule: freezed == rawSchedule ? _self.rawSchedule : rawSchedule // ignore: cast_nullable_to_non_nullable
as String?,rawState: freezed == rawState ? _self.rawState : rawState // ignore: cast_nullable_to_non_nullable
as String?,currentMedicineId: freezed == currentMedicineId ? _self.currentMedicineId : currentMedicineId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MedicineDoseSlot {

 MedicineCopyKey? get timeKey; String? get rawTime; MedicineCopyKey get statusKey; MedicineDoseStatus get status;
/// Create a copy of MedicineDoseSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineDoseSlotCopyWith<MedicineDoseSlot> get copyWith => _$MedicineDoseSlotCopyWithImpl<MedicineDoseSlot>(this as MedicineDoseSlot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineDoseSlot&&(identical(other.timeKey, timeKey) || other.timeKey == timeKey)&&(identical(other.rawTime, rawTime) || other.rawTime == rawTime)&&(identical(other.statusKey, statusKey) || other.statusKey == statusKey)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,timeKey,rawTime,statusKey,status);

@override
String toString() {
  return 'MedicineDoseSlot(timeKey: $timeKey, rawTime: $rawTime, statusKey: $statusKey, status: $status)';
}


}

/// @nodoc
abstract mixin class $MedicineDoseSlotCopyWith<$Res>  {
  factory $MedicineDoseSlotCopyWith(MedicineDoseSlot value, $Res Function(MedicineDoseSlot) _then) = _$MedicineDoseSlotCopyWithImpl;
@useResult
$Res call({
 MedicineCopyKey? timeKey, String? rawTime, MedicineCopyKey statusKey, MedicineDoseStatus status
});




}
/// @nodoc
class _$MedicineDoseSlotCopyWithImpl<$Res>
    implements $MedicineDoseSlotCopyWith<$Res> {
  _$MedicineDoseSlotCopyWithImpl(this._self, this._then);

  final MedicineDoseSlot _self;
  final $Res Function(MedicineDoseSlot) _then;

/// Create a copy of MedicineDoseSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeKey = freezed,Object? rawTime = freezed,Object? statusKey = null,Object? status = null,}) {
  return _then(_self.copyWith(
timeKey: freezed == timeKey ? _self.timeKey : timeKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,rawTime: freezed == rawTime ? _self.rawTime : rawTime // ignore: cast_nullable_to_non_nullable
as String?,statusKey: null == statusKey ? _self.statusKey : statusKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MedicineDoseStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineDoseSlot].
extension MedicineDoseSlotPatterns on MedicineDoseSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineDoseSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineDoseSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineDoseSlot value)  $default,){
final _that = this;
switch (_that) {
case _MedicineDoseSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineDoseSlot value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineDoseSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MedicineCopyKey? timeKey,  String? rawTime,  MedicineCopyKey statusKey,  MedicineDoseStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineDoseSlot() when $default != null:
return $default(_that.timeKey,_that.rawTime,_that.statusKey,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MedicineCopyKey? timeKey,  String? rawTime,  MedicineCopyKey statusKey,  MedicineDoseStatus status)  $default,) {final _that = this;
switch (_that) {
case _MedicineDoseSlot():
return $default(_that.timeKey,_that.rawTime,_that.statusKey,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MedicineCopyKey? timeKey,  String? rawTime,  MedicineCopyKey statusKey,  MedicineDoseStatus status)?  $default,) {final _that = this;
switch (_that) {
case _MedicineDoseSlot() when $default != null:
return $default(_that.timeKey,_that.rawTime,_that.statusKey,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineDoseSlot implements MedicineDoseSlot {
  const _MedicineDoseSlot({this.timeKey, this.rawTime, required this.statusKey, required this.status});
  

@override final  MedicineCopyKey? timeKey;
@override final  String? rawTime;
@override final  MedicineCopyKey statusKey;
@override final  MedicineDoseStatus status;

/// Create a copy of MedicineDoseSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineDoseSlotCopyWith<_MedicineDoseSlot> get copyWith => __$MedicineDoseSlotCopyWithImpl<_MedicineDoseSlot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineDoseSlot&&(identical(other.timeKey, timeKey) || other.timeKey == timeKey)&&(identical(other.rawTime, rawTime) || other.rawTime == rawTime)&&(identical(other.statusKey, statusKey) || other.statusKey == statusKey)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,timeKey,rawTime,statusKey,status);

@override
String toString() {
  return 'MedicineDoseSlot(timeKey: $timeKey, rawTime: $rawTime, statusKey: $statusKey, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MedicineDoseSlotCopyWith<$Res> implements $MedicineDoseSlotCopyWith<$Res> {
  factory _$MedicineDoseSlotCopyWith(_MedicineDoseSlot value, $Res Function(_MedicineDoseSlot) _then) = __$MedicineDoseSlotCopyWithImpl;
@override @useResult
$Res call({
 MedicineCopyKey? timeKey, String? rawTime, MedicineCopyKey statusKey, MedicineDoseStatus status
});




}
/// @nodoc
class __$MedicineDoseSlotCopyWithImpl<$Res>
    implements _$MedicineDoseSlotCopyWith<$Res> {
  __$MedicineDoseSlotCopyWithImpl(this._self, this._then);

  final _MedicineDoseSlot _self;
  final $Res Function(_MedicineDoseSlot) _then;

/// Create a copy of MedicineDoseSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeKey = freezed,Object? rawTime = freezed,Object? statusKey = null,Object? status = null,}) {
  return _then(_MedicineDoseSlot(
timeKey: freezed == timeKey ? _self.timeKey : timeKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,rawTime: freezed == rawTime ? _self.rawTime : rawTime // ignore: cast_nullable_to_non_nullable
as String?,statusKey: null == statusKey ? _self.statusKey : statusKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MedicineDoseStatus,
  ));
}


}

/// @nodoc
mixin _$MedicineAlert {

 IconData get icon; MedicineCopyKey? get titleKey; MedicineCopyKey? get bodyKey; MedicineCopyKey? get detailKey; MedicineCopyKey? get actionKey; Color get color; Color get softColor; String? get rawTitle; String? get rawBody; String? get rawDetail; String? get rawAction;
/// Create a copy of MedicineAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineAlertCopyWith<MedicineAlert> get copyWith => _$MedicineAlertCopyWithImpl<MedicineAlert>(this as MedicineAlert, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineAlert&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.bodyKey, bodyKey) || other.bodyKey == bodyKey)&&(identical(other.detailKey, detailKey) || other.detailKey == detailKey)&&(identical(other.actionKey, actionKey) || other.actionKey == actionKey)&&(identical(other.color, color) || other.color == color)&&(identical(other.softColor, softColor) || other.softColor == softColor)&&(identical(other.rawTitle, rawTitle) || other.rawTitle == rawTitle)&&(identical(other.rawBody, rawBody) || other.rawBody == rawBody)&&(identical(other.rawDetail, rawDetail) || other.rawDetail == rawDetail)&&(identical(other.rawAction, rawAction) || other.rawAction == rawAction));
}


@override
int get hashCode => Object.hash(runtimeType,icon,titleKey,bodyKey,detailKey,actionKey,color,softColor,rawTitle,rawBody,rawDetail,rawAction);

@override
String toString() {
  return 'MedicineAlert(icon: $icon, titleKey: $titleKey, bodyKey: $bodyKey, detailKey: $detailKey, actionKey: $actionKey, color: $color, softColor: $softColor, rawTitle: $rawTitle, rawBody: $rawBody, rawDetail: $rawDetail, rawAction: $rawAction)';
}


}

/// @nodoc
abstract mixin class $MedicineAlertCopyWith<$Res>  {
  factory $MedicineAlertCopyWith(MedicineAlert value, $Res Function(MedicineAlert) _then) = _$MedicineAlertCopyWithImpl;
@useResult
$Res call({
 IconData icon, MedicineCopyKey? titleKey, MedicineCopyKey? bodyKey, MedicineCopyKey? detailKey, MedicineCopyKey? actionKey, Color color, Color softColor, String? rawTitle, String? rawBody, String? rawDetail, String? rawAction
});




}
/// @nodoc
class _$MedicineAlertCopyWithImpl<$Res>
    implements $MedicineAlertCopyWith<$Res> {
  _$MedicineAlertCopyWithImpl(this._self, this._then);

  final MedicineAlert _self;
  final $Res Function(MedicineAlert) _then;

/// Create a copy of MedicineAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? titleKey = freezed,Object? bodyKey = freezed,Object? detailKey = freezed,Object? actionKey = freezed,Object? color = null,Object? softColor = null,Object? rawTitle = freezed,Object? rawBody = freezed,Object? rawDetail = freezed,Object? rawAction = freezed,}) {
  return _then(_self.copyWith(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: freezed == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,bodyKey: freezed == bodyKey ? _self.bodyKey : bodyKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,detailKey: freezed == detailKey ? _self.detailKey : detailKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,actionKey: freezed == actionKey ? _self.actionKey : actionKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,rawTitle: freezed == rawTitle ? _self.rawTitle : rawTitle // ignore: cast_nullable_to_non_nullable
as String?,rawBody: freezed == rawBody ? _self.rawBody : rawBody // ignore: cast_nullable_to_non_nullable
as String?,rawDetail: freezed == rawDetail ? _self.rawDetail : rawDetail // ignore: cast_nullable_to_non_nullable
as String?,rawAction: freezed == rawAction ? _self.rawAction : rawAction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineAlert].
extension MedicineAlertPatterns on MedicineAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineAlert value)  $default,){
final _that = this;
switch (_that) {
case _MedicineAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineAlert value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IconData icon,  MedicineCopyKey? titleKey,  MedicineCopyKey? bodyKey,  MedicineCopyKey? detailKey,  MedicineCopyKey? actionKey,  Color color,  Color softColor,  String? rawTitle,  String? rawBody,  String? rawDetail,  String? rawAction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineAlert() when $default != null:
return $default(_that.icon,_that.titleKey,_that.bodyKey,_that.detailKey,_that.actionKey,_that.color,_that.softColor,_that.rawTitle,_that.rawBody,_that.rawDetail,_that.rawAction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IconData icon,  MedicineCopyKey? titleKey,  MedicineCopyKey? bodyKey,  MedicineCopyKey? detailKey,  MedicineCopyKey? actionKey,  Color color,  Color softColor,  String? rawTitle,  String? rawBody,  String? rawDetail,  String? rawAction)  $default,) {final _that = this;
switch (_that) {
case _MedicineAlert():
return $default(_that.icon,_that.titleKey,_that.bodyKey,_that.detailKey,_that.actionKey,_that.color,_that.softColor,_that.rawTitle,_that.rawBody,_that.rawDetail,_that.rawAction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IconData icon,  MedicineCopyKey? titleKey,  MedicineCopyKey? bodyKey,  MedicineCopyKey? detailKey,  MedicineCopyKey? actionKey,  Color color,  Color softColor,  String? rawTitle,  String? rawBody,  String? rawDetail,  String? rawAction)?  $default,) {final _that = this;
switch (_that) {
case _MedicineAlert() when $default != null:
return $default(_that.icon,_that.titleKey,_that.bodyKey,_that.detailKey,_that.actionKey,_that.color,_that.softColor,_that.rawTitle,_that.rawBody,_that.rawDetail,_that.rawAction);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineAlert implements MedicineAlert {
  const _MedicineAlert({required this.icon, this.titleKey, this.bodyKey, this.detailKey, this.actionKey, required this.color, required this.softColor, this.rawTitle, this.rawBody, this.rawDetail, this.rawAction});
  

@override final  IconData icon;
@override final  MedicineCopyKey? titleKey;
@override final  MedicineCopyKey? bodyKey;
@override final  MedicineCopyKey? detailKey;
@override final  MedicineCopyKey? actionKey;
@override final  Color color;
@override final  Color softColor;
@override final  String? rawTitle;
@override final  String? rawBody;
@override final  String? rawDetail;
@override final  String? rawAction;

/// Create a copy of MedicineAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineAlertCopyWith<_MedicineAlert> get copyWith => __$MedicineAlertCopyWithImpl<_MedicineAlert>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineAlert&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.bodyKey, bodyKey) || other.bodyKey == bodyKey)&&(identical(other.detailKey, detailKey) || other.detailKey == detailKey)&&(identical(other.actionKey, actionKey) || other.actionKey == actionKey)&&(identical(other.color, color) || other.color == color)&&(identical(other.softColor, softColor) || other.softColor == softColor)&&(identical(other.rawTitle, rawTitle) || other.rawTitle == rawTitle)&&(identical(other.rawBody, rawBody) || other.rawBody == rawBody)&&(identical(other.rawDetail, rawDetail) || other.rawDetail == rawDetail)&&(identical(other.rawAction, rawAction) || other.rawAction == rawAction));
}


@override
int get hashCode => Object.hash(runtimeType,icon,titleKey,bodyKey,detailKey,actionKey,color,softColor,rawTitle,rawBody,rawDetail,rawAction);

@override
String toString() {
  return 'MedicineAlert(icon: $icon, titleKey: $titleKey, bodyKey: $bodyKey, detailKey: $detailKey, actionKey: $actionKey, color: $color, softColor: $softColor, rawTitle: $rawTitle, rawBody: $rawBody, rawDetail: $rawDetail, rawAction: $rawAction)';
}


}

/// @nodoc
abstract mixin class _$MedicineAlertCopyWith<$Res> implements $MedicineAlertCopyWith<$Res> {
  factory _$MedicineAlertCopyWith(_MedicineAlert value, $Res Function(_MedicineAlert) _then) = __$MedicineAlertCopyWithImpl;
@override @useResult
$Res call({
 IconData icon, MedicineCopyKey? titleKey, MedicineCopyKey? bodyKey, MedicineCopyKey? detailKey, MedicineCopyKey? actionKey, Color color, Color softColor, String? rawTitle, String? rawBody, String? rawDetail, String? rawAction
});




}
/// @nodoc
class __$MedicineAlertCopyWithImpl<$Res>
    implements _$MedicineAlertCopyWith<$Res> {
  __$MedicineAlertCopyWithImpl(this._self, this._then);

  final _MedicineAlert _self;
  final $Res Function(_MedicineAlert) _then;

/// Create a copy of MedicineAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? titleKey = freezed,Object? bodyKey = freezed,Object? detailKey = freezed,Object? actionKey = freezed,Object? color = null,Object? softColor = null,Object? rawTitle = freezed,Object? rawBody = freezed,Object? rawDetail = freezed,Object? rawAction = freezed,}) {
  return _then(_MedicineAlert(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: freezed == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,bodyKey: freezed == bodyKey ? _self.bodyKey : bodyKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,detailKey: freezed == detailKey ? _self.detailKey : detailKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,actionKey: freezed == actionKey ? _self.actionKey : actionKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,rawTitle: freezed == rawTitle ? _self.rawTitle : rawTitle // ignore: cast_nullable_to_non_nullable
as String?,rawBody: freezed == rawBody ? _self.rawBody : rawBody // ignore: cast_nullable_to_non_nullable
as String?,rawDetail: freezed == rawDetail ? _self.rawDetail : rawDetail // ignore: cast_nullable_to_non_nullable
as String?,rawAction: freezed == rawAction ? _self.rawAction : rawAction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MedicinePromisePoint {

 MedicineCopyKey get copyKey;
/// Create a copy of MedicinePromisePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicinePromisePointCopyWith<MedicinePromisePoint> get copyWith => _$MedicinePromisePointCopyWithImpl<MedicinePromisePoint>(this as MedicinePromisePoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicinePromisePoint&&(identical(other.copyKey, copyKey) || other.copyKey == copyKey));
}


@override
int get hashCode => Object.hash(runtimeType,copyKey);

@override
String toString() {
  return 'MedicinePromisePoint(copyKey: $copyKey)';
}


}

/// @nodoc
abstract mixin class $MedicinePromisePointCopyWith<$Res>  {
  factory $MedicinePromisePointCopyWith(MedicinePromisePoint value, $Res Function(MedicinePromisePoint) _then) = _$MedicinePromisePointCopyWithImpl;
@useResult
$Res call({
 MedicineCopyKey copyKey
});




}
/// @nodoc
class _$MedicinePromisePointCopyWithImpl<$Res>
    implements $MedicinePromisePointCopyWith<$Res> {
  _$MedicinePromisePointCopyWithImpl(this._self, this._then);

  final MedicinePromisePoint _self;
  final $Res Function(MedicinePromisePoint) _then;

/// Create a copy of MedicinePromisePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? copyKey = null,}) {
  return _then(_self.copyWith(
copyKey: null == copyKey ? _self.copyKey : copyKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicinePromisePoint].
extension MedicinePromisePointPatterns on MedicinePromisePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicinePromisePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicinePromisePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicinePromisePoint value)  $default,){
final _that = this;
switch (_that) {
case _MedicinePromisePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicinePromisePoint value)?  $default,){
final _that = this;
switch (_that) {
case _MedicinePromisePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MedicineCopyKey copyKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicinePromisePoint() when $default != null:
return $default(_that.copyKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MedicineCopyKey copyKey)  $default,) {final _that = this;
switch (_that) {
case _MedicinePromisePoint():
return $default(_that.copyKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MedicineCopyKey copyKey)?  $default,) {final _that = this;
switch (_that) {
case _MedicinePromisePoint() when $default != null:
return $default(_that.copyKey);case _:
  return null;

}
}

}

/// @nodoc


class _MedicinePromisePoint implements MedicinePromisePoint {
  const _MedicinePromisePoint({required this.copyKey});
  

@override final  MedicineCopyKey copyKey;

/// Create a copy of MedicinePromisePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicinePromisePointCopyWith<_MedicinePromisePoint> get copyWith => __$MedicinePromisePointCopyWithImpl<_MedicinePromisePoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicinePromisePoint&&(identical(other.copyKey, copyKey) || other.copyKey == copyKey));
}


@override
int get hashCode => Object.hash(runtimeType,copyKey);

@override
String toString() {
  return 'MedicinePromisePoint(copyKey: $copyKey)';
}


}

/// @nodoc
abstract mixin class _$MedicinePromisePointCopyWith<$Res> implements $MedicinePromisePointCopyWith<$Res> {
  factory _$MedicinePromisePointCopyWith(_MedicinePromisePoint value, $Res Function(_MedicinePromisePoint) _then) = __$MedicinePromisePointCopyWithImpl;
@override @useResult
$Res call({
 MedicineCopyKey copyKey
});




}
/// @nodoc
class __$MedicinePromisePointCopyWithImpl<$Res>
    implements _$MedicinePromisePointCopyWith<$Res> {
  __$MedicinePromisePointCopyWithImpl(this._self, this._then);

  final _MedicinePromisePoint _self;
  final $Res Function(_MedicinePromisePoint) _then;

/// Create a copy of MedicinePromisePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? copyKey = null,}) {
  return _then(_MedicinePromisePoint(
copyKey: null == copyKey ? _self.copyKey : copyKey // ignore: cast_nullable_to_non_nullable
as MedicineCopyKey,
  ));
}


}

// dart format on
