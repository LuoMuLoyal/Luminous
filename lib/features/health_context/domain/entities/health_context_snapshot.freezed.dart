// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_context_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HealthContextSnapshot {

 HealthSummary get summary; HealthProfile get profile; List<AllergyItem> get allergies; List<ConditionItem> get conditions; List<CurrentMedicineItem> get currentMedicines;
/// Create a copy of HealthContextSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthContextSnapshotCopyWith<HealthContextSnapshot> get copyWith => _$HealthContextSnapshotCopyWithImpl<HealthContextSnapshot>(this as HealthContextSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthContextSnapshot&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.allergies, allergies)&&const DeepCollectionEquality().equals(other.conditions, conditions)&&const DeepCollectionEquality().equals(other.currentMedicines, currentMedicines));
}


@override
int get hashCode => Object.hash(runtimeType,summary,profile,const DeepCollectionEquality().hash(allergies),const DeepCollectionEquality().hash(conditions),const DeepCollectionEquality().hash(currentMedicines));

@override
String toString() {
  return 'HealthContextSnapshot(summary: $summary, profile: $profile, allergies: $allergies, conditions: $conditions, currentMedicines: $currentMedicines)';
}


}

/// @nodoc
abstract mixin class $HealthContextSnapshotCopyWith<$Res>  {
  factory $HealthContextSnapshotCopyWith(HealthContextSnapshot value, $Res Function(HealthContextSnapshot) _then) = _$HealthContextSnapshotCopyWithImpl;
@useResult
$Res call({
 HealthSummary summary, HealthProfile profile, List<AllergyItem> allergies, List<ConditionItem> conditions, List<CurrentMedicineItem> currentMedicines
});


$HealthSummaryCopyWith<$Res> get summary;$HealthProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$HealthContextSnapshotCopyWithImpl<$Res>
    implements $HealthContextSnapshotCopyWith<$Res> {
  _$HealthContextSnapshotCopyWithImpl(this._self, this._then);

  final HealthContextSnapshot _self;
  final $Res Function(HealthContextSnapshot) _then;

/// Create a copy of HealthContextSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? profile = null,Object? allergies = null,Object? conditions = null,Object? currentMedicines = null,}) {
  return _then(_self.copyWith(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as HealthSummary,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as HealthProfile,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<AllergyItem>,conditions: null == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<ConditionItem>,currentMedicines: null == currentMedicines ? _self.currentMedicines : currentMedicines // ignore: cast_nullable_to_non_nullable
as List<CurrentMedicineItem>,
  ));
}
/// Create a copy of HealthContextSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthSummaryCopyWith<$Res> get summary {
  
  return $HealthSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of HealthContextSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthProfileCopyWith<$Res> get profile {
  
  return $HealthProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [HealthContextSnapshot].
extension HealthContextSnapshotPatterns on HealthContextSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthContextSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthContextSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthContextSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _HealthContextSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthContextSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _HealthContextSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HealthSummary summary,  HealthProfile profile,  List<AllergyItem> allergies,  List<ConditionItem> conditions,  List<CurrentMedicineItem> currentMedicines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthContextSnapshot() when $default != null:
return $default(_that.summary,_that.profile,_that.allergies,_that.conditions,_that.currentMedicines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HealthSummary summary,  HealthProfile profile,  List<AllergyItem> allergies,  List<ConditionItem> conditions,  List<CurrentMedicineItem> currentMedicines)  $default,) {final _that = this;
switch (_that) {
case _HealthContextSnapshot():
return $default(_that.summary,_that.profile,_that.allergies,_that.conditions,_that.currentMedicines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HealthSummary summary,  HealthProfile profile,  List<AllergyItem> allergies,  List<ConditionItem> conditions,  List<CurrentMedicineItem> currentMedicines)?  $default,) {final _that = this;
switch (_that) {
case _HealthContextSnapshot() when $default != null:
return $default(_that.summary,_that.profile,_that.allergies,_that.conditions,_that.currentMedicines);case _:
  return null;

}
}

}

/// @nodoc


class _HealthContextSnapshot implements HealthContextSnapshot {
  const _HealthContextSnapshot({required this.summary, required this.profile, required final  List<AllergyItem> allergies, required final  List<ConditionItem> conditions, required final  List<CurrentMedicineItem> currentMedicines}): _allergies = allergies,_conditions = conditions,_currentMedicines = currentMedicines;
  

@override final  HealthSummary summary;
@override final  HealthProfile profile;
 final  List<AllergyItem> _allergies;
@override List<AllergyItem> get allergies {
  if (_allergies is EqualUnmodifiableListView) return _allergies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergies);
}

 final  List<ConditionItem> _conditions;
@override List<ConditionItem> get conditions {
  if (_conditions is EqualUnmodifiableListView) return _conditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conditions);
}

 final  List<CurrentMedicineItem> _currentMedicines;
@override List<CurrentMedicineItem> get currentMedicines {
  if (_currentMedicines is EqualUnmodifiableListView) return _currentMedicines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currentMedicines);
}


/// Create a copy of HealthContextSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthContextSnapshotCopyWith<_HealthContextSnapshot> get copyWith => __$HealthContextSnapshotCopyWithImpl<_HealthContextSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthContextSnapshot&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._allergies, _allergies)&&const DeepCollectionEquality().equals(other._conditions, _conditions)&&const DeepCollectionEquality().equals(other._currentMedicines, _currentMedicines));
}


@override
int get hashCode => Object.hash(runtimeType,summary,profile,const DeepCollectionEquality().hash(_allergies),const DeepCollectionEquality().hash(_conditions),const DeepCollectionEquality().hash(_currentMedicines));

@override
String toString() {
  return 'HealthContextSnapshot(summary: $summary, profile: $profile, allergies: $allergies, conditions: $conditions, currentMedicines: $currentMedicines)';
}


}

/// @nodoc
abstract mixin class _$HealthContextSnapshotCopyWith<$Res> implements $HealthContextSnapshotCopyWith<$Res> {
  factory _$HealthContextSnapshotCopyWith(_HealthContextSnapshot value, $Res Function(_HealthContextSnapshot) _then) = __$HealthContextSnapshotCopyWithImpl;
@override @useResult
$Res call({
 HealthSummary summary, HealthProfile profile, List<AllergyItem> allergies, List<ConditionItem> conditions, List<CurrentMedicineItem> currentMedicines
});


@override $HealthSummaryCopyWith<$Res> get summary;@override $HealthProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$HealthContextSnapshotCopyWithImpl<$Res>
    implements _$HealthContextSnapshotCopyWith<$Res> {
  __$HealthContextSnapshotCopyWithImpl(this._self, this._then);

  final _HealthContextSnapshot _self;
  final $Res Function(_HealthContextSnapshot) _then;

/// Create a copy of HealthContextSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? profile = null,Object? allergies = null,Object? conditions = null,Object? currentMedicines = null,}) {
  return _then(_HealthContextSnapshot(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as HealthSummary,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as HealthProfile,allergies: null == allergies ? _self._allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<AllergyItem>,conditions: null == conditions ? _self._conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<ConditionItem>,currentMedicines: null == currentMedicines ? _self._currentMedicines : currentMedicines // ignore: cast_nullable_to_non_nullable
as List<CurrentMedicineItem>,
  ));
}

/// Create a copy of HealthContextSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthSummaryCopyWith<$Res> get summary {
  
  return $HealthSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of HealthContextSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthProfileCopyWith<$Res> get profile {
  
  return $HealthProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

/// @nodoc
mixin _$HealthSummary {

 int? get age; bool get onboardingCompleted; int get activeAllergyCount; int get conditionCount; int get currentMedicineCount; List<String> get missingCoreProfileFields;
/// Create a copy of HealthSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthSummaryCopyWith<HealthSummary> get copyWith => _$HealthSummaryCopyWithImpl<HealthSummary>(this as HealthSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthSummary&&(identical(other.age, age) || other.age == age)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.activeAllergyCount, activeAllergyCount) || other.activeAllergyCount == activeAllergyCount)&&(identical(other.conditionCount, conditionCount) || other.conditionCount == conditionCount)&&(identical(other.currentMedicineCount, currentMedicineCount) || other.currentMedicineCount == currentMedicineCount)&&const DeepCollectionEquality().equals(other.missingCoreProfileFields, missingCoreProfileFields));
}


@override
int get hashCode => Object.hash(runtimeType,age,onboardingCompleted,activeAllergyCount,conditionCount,currentMedicineCount,const DeepCollectionEquality().hash(missingCoreProfileFields));

@override
String toString() {
  return 'HealthSummary(age: $age, onboardingCompleted: $onboardingCompleted, activeAllergyCount: $activeAllergyCount, conditionCount: $conditionCount, currentMedicineCount: $currentMedicineCount, missingCoreProfileFields: $missingCoreProfileFields)';
}


}

/// @nodoc
abstract mixin class $HealthSummaryCopyWith<$Res>  {
  factory $HealthSummaryCopyWith(HealthSummary value, $Res Function(HealthSummary) _then) = _$HealthSummaryCopyWithImpl;
@useResult
$Res call({
 int? age, bool onboardingCompleted, int activeAllergyCount, int conditionCount, int currentMedicineCount, List<String> missingCoreProfileFields
});




}
/// @nodoc
class _$HealthSummaryCopyWithImpl<$Res>
    implements $HealthSummaryCopyWith<$Res> {
  _$HealthSummaryCopyWithImpl(this._self, this._then);

  final HealthSummary _self;
  final $Res Function(HealthSummary) _then;

/// Create a copy of HealthSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? age = freezed,Object? onboardingCompleted = null,Object? activeAllergyCount = null,Object? conditionCount = null,Object? currentMedicineCount = null,Object? missingCoreProfileFields = null,}) {
  return _then(_self.copyWith(
age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,activeAllergyCount: null == activeAllergyCount ? _self.activeAllergyCount : activeAllergyCount // ignore: cast_nullable_to_non_nullable
as int,conditionCount: null == conditionCount ? _self.conditionCount : conditionCount // ignore: cast_nullable_to_non_nullable
as int,currentMedicineCount: null == currentMedicineCount ? _self.currentMedicineCount : currentMedicineCount // ignore: cast_nullable_to_non_nullable
as int,missingCoreProfileFields: null == missingCoreProfileFields ? _self.missingCoreProfileFields : missingCoreProfileFields // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthSummary].
extension HealthSummaryPatterns on HealthSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthSummary value)  $default,){
final _that = this;
switch (_that) {
case _HealthSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthSummary value)?  $default,){
final _that = this;
switch (_that) {
case _HealthSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? age,  bool onboardingCompleted,  int activeAllergyCount,  int conditionCount,  int currentMedicineCount,  List<String> missingCoreProfileFields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthSummary() when $default != null:
return $default(_that.age,_that.onboardingCompleted,_that.activeAllergyCount,_that.conditionCount,_that.currentMedicineCount,_that.missingCoreProfileFields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? age,  bool onboardingCompleted,  int activeAllergyCount,  int conditionCount,  int currentMedicineCount,  List<String> missingCoreProfileFields)  $default,) {final _that = this;
switch (_that) {
case _HealthSummary():
return $default(_that.age,_that.onboardingCompleted,_that.activeAllergyCount,_that.conditionCount,_that.currentMedicineCount,_that.missingCoreProfileFields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? age,  bool onboardingCompleted,  int activeAllergyCount,  int conditionCount,  int currentMedicineCount,  List<String> missingCoreProfileFields)?  $default,) {final _that = this;
switch (_that) {
case _HealthSummary() when $default != null:
return $default(_that.age,_that.onboardingCompleted,_that.activeAllergyCount,_that.conditionCount,_that.currentMedicineCount,_that.missingCoreProfileFields);case _:
  return null;

}
}

}

/// @nodoc


class _HealthSummary implements HealthSummary {
  const _HealthSummary({required this.age, required this.onboardingCompleted, required this.activeAllergyCount, required this.conditionCount, required this.currentMedicineCount, required final  List<String> missingCoreProfileFields}): _missingCoreProfileFields = missingCoreProfileFields;
  

@override final  int? age;
@override final  bool onboardingCompleted;
@override final  int activeAllergyCount;
@override final  int conditionCount;
@override final  int currentMedicineCount;
 final  List<String> _missingCoreProfileFields;
@override List<String> get missingCoreProfileFields {
  if (_missingCoreProfileFields is EqualUnmodifiableListView) return _missingCoreProfileFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingCoreProfileFields);
}


/// Create a copy of HealthSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthSummaryCopyWith<_HealthSummary> get copyWith => __$HealthSummaryCopyWithImpl<_HealthSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthSummary&&(identical(other.age, age) || other.age == age)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.activeAllergyCount, activeAllergyCount) || other.activeAllergyCount == activeAllergyCount)&&(identical(other.conditionCount, conditionCount) || other.conditionCount == conditionCount)&&(identical(other.currentMedicineCount, currentMedicineCount) || other.currentMedicineCount == currentMedicineCount)&&const DeepCollectionEquality().equals(other._missingCoreProfileFields, _missingCoreProfileFields));
}


@override
int get hashCode => Object.hash(runtimeType,age,onboardingCompleted,activeAllergyCount,conditionCount,currentMedicineCount,const DeepCollectionEquality().hash(_missingCoreProfileFields));

@override
String toString() {
  return 'HealthSummary(age: $age, onboardingCompleted: $onboardingCompleted, activeAllergyCount: $activeAllergyCount, conditionCount: $conditionCount, currentMedicineCount: $currentMedicineCount, missingCoreProfileFields: $missingCoreProfileFields)';
}


}

/// @nodoc
abstract mixin class _$HealthSummaryCopyWith<$Res> implements $HealthSummaryCopyWith<$Res> {
  factory _$HealthSummaryCopyWith(_HealthSummary value, $Res Function(_HealthSummary) _then) = __$HealthSummaryCopyWithImpl;
@override @useResult
$Res call({
 int? age, bool onboardingCompleted, int activeAllergyCount, int conditionCount, int currentMedicineCount, List<String> missingCoreProfileFields
});




}
/// @nodoc
class __$HealthSummaryCopyWithImpl<$Res>
    implements _$HealthSummaryCopyWith<$Res> {
  __$HealthSummaryCopyWithImpl(this._self, this._then);

  final _HealthSummary _self;
  final $Res Function(_HealthSummary) _then;

/// Create a copy of HealthSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? age = freezed,Object? onboardingCompleted = null,Object? activeAllergyCount = null,Object? conditionCount = null,Object? currentMedicineCount = null,Object? missingCoreProfileFields = null,}) {
  return _then(_HealthSummary(
age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,activeAllergyCount: null == activeAllergyCount ? _self.activeAllergyCount : activeAllergyCount // ignore: cast_nullable_to_non_nullable
as int,conditionCount: null == conditionCount ? _self.conditionCount : conditionCount // ignore: cast_nullable_to_non_nullable
as int,currentMedicineCount: null == currentMedicineCount ? _self.currentMedicineCount : currentMedicineCount // ignore: cast_nullable_to_non_nullable
as int,missingCoreProfileFields: null == missingCoreProfileFields ? _self._missingCoreProfileFields : missingCoreProfileFields // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$HealthProfile {

 String? get birthDate; String? get sexAtBirth; double? get heightCm; String? get bloodType; String? get locale; String? get timezone; String? get unitSystem; String? get onboardingCompletedAt; Map<String, dynamic> get extras;
/// Create a copy of HealthProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthProfileCopyWith<HealthProfile> get copyWith => _$HealthProfileCopyWithImpl<HealthProfile>(this as HealthProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthProfile&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.sexAtBirth, sexAtBirth) || other.sexAtBirth == sexAtBirth)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.bloodType, bloodType) || other.bloodType == bloodType)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.unitSystem, unitSystem) || other.unitSystem == unitSystem)&&(identical(other.onboardingCompletedAt, onboardingCompletedAt) || other.onboardingCompletedAt == onboardingCompletedAt)&&const DeepCollectionEquality().equals(other.extras, extras));
}


@override
int get hashCode => Object.hash(runtimeType,birthDate,sexAtBirth,heightCm,bloodType,locale,timezone,unitSystem,onboardingCompletedAt,const DeepCollectionEquality().hash(extras));

@override
String toString() {
  return 'HealthProfile(birthDate: $birthDate, sexAtBirth: $sexAtBirth, heightCm: $heightCm, bloodType: $bloodType, locale: $locale, timezone: $timezone, unitSystem: $unitSystem, onboardingCompletedAt: $onboardingCompletedAt, extras: $extras)';
}


}

/// @nodoc
abstract mixin class $HealthProfileCopyWith<$Res>  {
  factory $HealthProfileCopyWith(HealthProfile value, $Res Function(HealthProfile) _then) = _$HealthProfileCopyWithImpl;
@useResult
$Res call({
 String? birthDate, String? sexAtBirth, double? heightCm, String? bloodType, String? locale, String? timezone, String? unitSystem, String? onboardingCompletedAt, Map<String, dynamic> extras
});




}
/// @nodoc
class _$HealthProfileCopyWithImpl<$Res>
    implements $HealthProfileCopyWith<$Res> {
  _$HealthProfileCopyWithImpl(this._self, this._then);

  final HealthProfile _self;
  final $Res Function(HealthProfile) _then;

/// Create a copy of HealthProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? birthDate = freezed,Object? sexAtBirth = freezed,Object? heightCm = freezed,Object? bloodType = freezed,Object? locale = freezed,Object? timezone = freezed,Object? unitSystem = freezed,Object? onboardingCompletedAt = freezed,Object? extras = null,}) {
  return _then(_self.copyWith(
birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,sexAtBirth: freezed == sexAtBirth ? _self.sexAtBirth : sexAtBirth // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,bloodType: freezed == bloodType ? _self.bloodType : bloodType // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,unitSystem: freezed == unitSystem ? _self.unitSystem : unitSystem // ignore: cast_nullable_to_non_nullable
as String?,onboardingCompletedAt: freezed == onboardingCompletedAt ? _self.onboardingCompletedAt : onboardingCompletedAt // ignore: cast_nullable_to_non_nullable
as String?,extras: null == extras ? _self.extras : extras // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthProfile].
extension HealthProfilePatterns on HealthProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthProfile value)  $default,){
final _that = this;
switch (_that) {
case _HealthProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthProfile value)?  $default,){
final _that = this;
switch (_that) {
case _HealthProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? birthDate,  String? sexAtBirth,  double? heightCm,  String? bloodType,  String? locale,  String? timezone,  String? unitSystem,  String? onboardingCompletedAt,  Map<String, dynamic> extras)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthProfile() when $default != null:
return $default(_that.birthDate,_that.sexAtBirth,_that.heightCm,_that.bloodType,_that.locale,_that.timezone,_that.unitSystem,_that.onboardingCompletedAt,_that.extras);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? birthDate,  String? sexAtBirth,  double? heightCm,  String? bloodType,  String? locale,  String? timezone,  String? unitSystem,  String? onboardingCompletedAt,  Map<String, dynamic> extras)  $default,) {final _that = this;
switch (_that) {
case _HealthProfile():
return $default(_that.birthDate,_that.sexAtBirth,_that.heightCm,_that.bloodType,_that.locale,_that.timezone,_that.unitSystem,_that.onboardingCompletedAt,_that.extras);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? birthDate,  String? sexAtBirth,  double? heightCm,  String? bloodType,  String? locale,  String? timezone,  String? unitSystem,  String? onboardingCompletedAt,  Map<String, dynamic> extras)?  $default,) {final _that = this;
switch (_that) {
case _HealthProfile() when $default != null:
return $default(_that.birthDate,_that.sexAtBirth,_that.heightCm,_that.bloodType,_that.locale,_that.timezone,_that.unitSystem,_that.onboardingCompletedAt,_that.extras);case _:
  return null;

}
}

}

/// @nodoc


class _HealthProfile implements HealthProfile {
  const _HealthProfile({required this.birthDate, required this.sexAtBirth, required this.heightCm, required this.bloodType, required this.locale, required this.timezone, required this.unitSystem, required this.onboardingCompletedAt, required final  Map<String, dynamic> extras}): _extras = extras;
  

@override final  String? birthDate;
@override final  String? sexAtBirth;
@override final  double? heightCm;
@override final  String? bloodType;
@override final  String? locale;
@override final  String? timezone;
@override final  String? unitSystem;
@override final  String? onboardingCompletedAt;
 final  Map<String, dynamic> _extras;
@override Map<String, dynamic> get extras {
  if (_extras is EqualUnmodifiableMapView) return _extras;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extras);
}


/// Create a copy of HealthProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthProfileCopyWith<_HealthProfile> get copyWith => __$HealthProfileCopyWithImpl<_HealthProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthProfile&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.sexAtBirth, sexAtBirth) || other.sexAtBirth == sexAtBirth)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.bloodType, bloodType) || other.bloodType == bloodType)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.unitSystem, unitSystem) || other.unitSystem == unitSystem)&&(identical(other.onboardingCompletedAt, onboardingCompletedAt) || other.onboardingCompletedAt == onboardingCompletedAt)&&const DeepCollectionEquality().equals(other._extras, _extras));
}


@override
int get hashCode => Object.hash(runtimeType,birthDate,sexAtBirth,heightCm,bloodType,locale,timezone,unitSystem,onboardingCompletedAt,const DeepCollectionEquality().hash(_extras));

@override
String toString() {
  return 'HealthProfile(birthDate: $birthDate, sexAtBirth: $sexAtBirth, heightCm: $heightCm, bloodType: $bloodType, locale: $locale, timezone: $timezone, unitSystem: $unitSystem, onboardingCompletedAt: $onboardingCompletedAt, extras: $extras)';
}


}

/// @nodoc
abstract mixin class _$HealthProfileCopyWith<$Res> implements $HealthProfileCopyWith<$Res> {
  factory _$HealthProfileCopyWith(_HealthProfile value, $Res Function(_HealthProfile) _then) = __$HealthProfileCopyWithImpl;
@override @useResult
$Res call({
 String? birthDate, String? sexAtBirth, double? heightCm, String? bloodType, String? locale, String? timezone, String? unitSystem, String? onboardingCompletedAt, Map<String, dynamic> extras
});




}
/// @nodoc
class __$HealthProfileCopyWithImpl<$Res>
    implements _$HealthProfileCopyWith<$Res> {
  __$HealthProfileCopyWithImpl(this._self, this._then);

  final _HealthProfile _self;
  final $Res Function(_HealthProfile) _then;

/// Create a copy of HealthProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? birthDate = freezed,Object? sexAtBirth = freezed,Object? heightCm = freezed,Object? bloodType = freezed,Object? locale = freezed,Object? timezone = freezed,Object? unitSystem = freezed,Object? onboardingCompletedAt = freezed,Object? extras = null,}) {
  return _then(_HealthProfile(
birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,sexAtBirth: freezed == sexAtBirth ? _self.sexAtBirth : sexAtBirth // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,bloodType: freezed == bloodType ? _self.bloodType : bloodType // ignore: cast_nullable_to_non_nullable
as String?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,unitSystem: freezed == unitSystem ? _self.unitSystem : unitSystem // ignore: cast_nullable_to_non_nullable
as String?,onboardingCompletedAt: freezed == onboardingCompletedAt ? _self.onboardingCompletedAt : onboardingCompletedAt // ignore: cast_nullable_to_non_nullable
as String?,extras: null == extras ? _self._extras : extras // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
mixin _$AllergyItem {

 String get id; String get kind; String get label; String? get reaction; String? get severity; bool get isActive; String? get note; String get createdAt; String get updatedAt;
/// Create a copy of AllergyItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllergyItemCopyWith<AllergyItem> get copyWith => _$AllergyItemCopyWithImpl<AllergyItem>(this as AllergyItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllergyItem&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.label, label) || other.label == label)&&(identical(other.reaction, reaction) || other.reaction == reaction)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,label,reaction,severity,isActive,note,createdAt,updatedAt);

@override
String toString() {
  return 'AllergyItem(id: $id, kind: $kind, label: $label, reaction: $reaction, severity: $severity, isActive: $isActive, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AllergyItemCopyWith<$Res>  {
  factory $AllergyItemCopyWith(AllergyItem value, $Res Function(AllergyItem) _then) = _$AllergyItemCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String label, String? reaction, String? severity, bool isActive, String? note, String createdAt, String updatedAt
});




}
/// @nodoc
class _$AllergyItemCopyWithImpl<$Res>
    implements $AllergyItemCopyWith<$Res> {
  _$AllergyItemCopyWithImpl(this._self, this._then);

  final AllergyItem _self;
  final $Res Function(AllergyItem) _then;

/// Create a copy of AllergyItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? label = null,Object? reaction = freezed,Object? severity = freezed,Object? isActive = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,reaction: freezed == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as String?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AllergyItem].
extension AllergyItemPatterns on AllergyItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllergyItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllergyItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllergyItem value)  $default,){
final _that = this;
switch (_that) {
case _AllergyItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllergyItem value)?  $default,){
final _that = this;
switch (_that) {
case _AllergyItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String label,  String? reaction,  String? severity,  bool isActive,  String? note,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllergyItem() when $default != null:
return $default(_that.id,_that.kind,_that.label,_that.reaction,_that.severity,_that.isActive,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String label,  String? reaction,  String? severity,  bool isActive,  String? note,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AllergyItem():
return $default(_that.id,_that.kind,_that.label,_that.reaction,_that.severity,_that.isActive,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String label,  String? reaction,  String? severity,  bool isActive,  String? note,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AllergyItem() when $default != null:
return $default(_that.id,_that.kind,_that.label,_that.reaction,_that.severity,_that.isActive,_that.note,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AllergyItem implements AllergyItem {
  const _AllergyItem({required this.id, required this.kind, required this.label, required this.reaction, required this.severity, required this.isActive, required this.note, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String kind;
@override final  String label;
@override final  String? reaction;
@override final  String? severity;
@override final  bool isActive;
@override final  String? note;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of AllergyItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllergyItemCopyWith<_AllergyItem> get copyWith => __$AllergyItemCopyWithImpl<_AllergyItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllergyItem&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.label, label) || other.label == label)&&(identical(other.reaction, reaction) || other.reaction == reaction)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,label,reaction,severity,isActive,note,createdAt,updatedAt);

@override
String toString() {
  return 'AllergyItem(id: $id, kind: $kind, label: $label, reaction: $reaction, severity: $severity, isActive: $isActive, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AllergyItemCopyWith<$Res> implements $AllergyItemCopyWith<$Res> {
  factory _$AllergyItemCopyWith(_AllergyItem value, $Res Function(_AllergyItem) _then) = __$AllergyItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String label, String? reaction, String? severity, bool isActive, String? note, String createdAt, String updatedAt
});




}
/// @nodoc
class __$AllergyItemCopyWithImpl<$Res>
    implements _$AllergyItemCopyWith<$Res> {
  __$AllergyItemCopyWithImpl(this._self, this._then);

  final _AllergyItem _self;
  final $Res Function(_AllergyItem) _then;

/// Create a copy of AllergyItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? label = null,Object? reaction = freezed,Object? severity = freezed,Object? isActive = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AllergyItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,reaction: freezed == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as String?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ConditionItem {

 String get id; String get label; String get status; String? get diagnosedAt; String? get resolvedAt; String? get note; String get createdAt; String get updatedAt;
/// Create a copy of ConditionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConditionItemCopyWith<ConditionItem> get copyWith => _$ConditionItemCopyWithImpl<ConditionItem>(this as ConditionItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConditionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status)&&(identical(other.diagnosedAt, diagnosedAt) || other.diagnosedAt == diagnosedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,status,diagnosedAt,resolvedAt,note,createdAt,updatedAt);

@override
String toString() {
  return 'ConditionItem(id: $id, label: $label, status: $status, diagnosedAt: $diagnosedAt, resolvedAt: $resolvedAt, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ConditionItemCopyWith<$Res>  {
  factory $ConditionItemCopyWith(ConditionItem value, $Res Function(ConditionItem) _then) = _$ConditionItemCopyWithImpl;
@useResult
$Res call({
 String id, String label, String status, String? diagnosedAt, String? resolvedAt, String? note, String createdAt, String updatedAt
});




}
/// @nodoc
class _$ConditionItemCopyWithImpl<$Res>
    implements $ConditionItemCopyWith<$Res> {
  _$ConditionItemCopyWithImpl(this._self, this._then);

  final ConditionItem _self;
  final $Res Function(ConditionItem) _then;

/// Create a copy of ConditionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? status = null,Object? diagnosedAt = freezed,Object? resolvedAt = freezed,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,diagnosedAt: freezed == diagnosedAt ? _self.diagnosedAt : diagnosedAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConditionItem].
extension ConditionItemPatterns on ConditionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConditionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConditionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConditionItem value)  $default,){
final _that = this;
switch (_that) {
case _ConditionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConditionItem value)?  $default,){
final _that = this;
switch (_that) {
case _ConditionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String status,  String? diagnosedAt,  String? resolvedAt,  String? note,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConditionItem() when $default != null:
return $default(_that.id,_that.label,_that.status,_that.diagnosedAt,_that.resolvedAt,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String status,  String? diagnosedAt,  String? resolvedAt,  String? note,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ConditionItem():
return $default(_that.id,_that.label,_that.status,_that.diagnosedAt,_that.resolvedAt,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String status,  String? diagnosedAt,  String? resolvedAt,  String? note,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConditionItem() when $default != null:
return $default(_that.id,_that.label,_that.status,_that.diagnosedAt,_that.resolvedAt,_that.note,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ConditionItem implements ConditionItem {
  const _ConditionItem({required this.id, required this.label, required this.status, required this.diagnosedAt, required this.resolvedAt, required this.note, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String label;
@override final  String status;
@override final  String? diagnosedAt;
@override final  String? resolvedAt;
@override final  String? note;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of ConditionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConditionItemCopyWith<_ConditionItem> get copyWith => __$ConditionItemCopyWithImpl<_ConditionItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConditionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status)&&(identical(other.diagnosedAt, diagnosedAt) || other.diagnosedAt == diagnosedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,status,diagnosedAt,resolvedAt,note,createdAt,updatedAt);

@override
String toString() {
  return 'ConditionItem(id: $id, label: $label, status: $status, diagnosedAt: $diagnosedAt, resolvedAt: $resolvedAt, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ConditionItemCopyWith<$Res> implements $ConditionItemCopyWith<$Res> {
  factory _$ConditionItemCopyWith(_ConditionItem value, $Res Function(_ConditionItem) _then) = __$ConditionItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String status, String? diagnosedAt, String? resolvedAt, String? note, String createdAt, String updatedAt
});




}
/// @nodoc
class __$ConditionItemCopyWithImpl<$Res>
    implements _$ConditionItemCopyWith<$Res> {
  __$ConditionItemCopyWithImpl(this._self, this._then);

  final _ConditionItem _self;
  final $Res Function(_ConditionItem) _then;

/// Create a copy of ConditionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? status = null,Object? diagnosedAt = freezed,Object? resolvedAt = freezed,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ConditionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,diagnosedAt: freezed == diagnosedAt ? _self.diagnosedAt : diagnosedAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CurrentMedicineItem {

 String get id; String get source; String? get sourceRefId; String get displayName; String? get strengthText; String? get doseText; String? get route; String? get startedAt; String? get endedAt; bool get isCurrent; String? get note; String get createdAt; String get updatedAt;
/// Create a copy of CurrentMedicineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentMedicineItemCopyWith<CurrentMedicineItem> get copyWith => _$CurrentMedicineItemCopyWithImpl<CurrentMedicineItem>(this as CurrentMedicineItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentMedicineItem&&(identical(other.id, id) || other.id == id)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceRefId, sourceRefId) || other.sourceRefId == sourceRefId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.strengthText, strengthText) || other.strengthText == strengthText)&&(identical(other.doseText, doseText) || other.doseText == doseText)&&(identical(other.route, route) || other.route == route)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,source,sourceRefId,displayName,strengthText,doseText,route,startedAt,endedAt,isCurrent,note,createdAt,updatedAt);

@override
String toString() {
  return 'CurrentMedicineItem(id: $id, source: $source, sourceRefId: $sourceRefId, displayName: $displayName, strengthText: $strengthText, doseText: $doseText, route: $route, startedAt: $startedAt, endedAt: $endedAt, isCurrent: $isCurrent, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CurrentMedicineItemCopyWith<$Res>  {
  factory $CurrentMedicineItemCopyWith(CurrentMedicineItem value, $Res Function(CurrentMedicineItem) _then) = _$CurrentMedicineItemCopyWithImpl;
@useResult
$Res call({
 String id, String source, String? sourceRefId, String displayName, String? strengthText, String? doseText, String? route, String? startedAt, String? endedAt, bool isCurrent, String? note, String createdAt, String updatedAt
});




}
/// @nodoc
class _$CurrentMedicineItemCopyWithImpl<$Res>
    implements $CurrentMedicineItemCopyWith<$Res> {
  _$CurrentMedicineItemCopyWithImpl(this._self, this._then);

  final CurrentMedicineItem _self;
  final $Res Function(CurrentMedicineItem) _then;

/// Create a copy of CurrentMedicineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? source = null,Object? sourceRefId = freezed,Object? displayName = null,Object? strengthText = freezed,Object? doseText = freezed,Object? route = freezed,Object? startedAt = freezed,Object? endedAt = freezed,Object? isCurrent = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,sourceRefId: freezed == sourceRefId ? _self.sourceRefId : sourceRefId // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,strengthText: freezed == strengthText ? _self.strengthText : strengthText // ignore: cast_nullable_to_non_nullable
as String?,doseText: freezed == doseText ? _self.doseText : doseText // ignore: cast_nullable_to_non_nullable
as String?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as String?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentMedicineItem].
extension CurrentMedicineItemPatterns on CurrentMedicineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentMedicineItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentMedicineItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentMedicineItem value)  $default,){
final _that = this;
switch (_that) {
case _CurrentMedicineItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentMedicineItem value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentMedicineItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String source,  String? sourceRefId,  String displayName,  String? strengthText,  String? doseText,  String? route,  String? startedAt,  String? endedAt,  bool isCurrent,  String? note,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentMedicineItem() when $default != null:
return $default(_that.id,_that.source,_that.sourceRefId,_that.displayName,_that.strengthText,_that.doseText,_that.route,_that.startedAt,_that.endedAt,_that.isCurrent,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String source,  String? sourceRefId,  String displayName,  String? strengthText,  String? doseText,  String? route,  String? startedAt,  String? endedAt,  bool isCurrent,  String? note,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CurrentMedicineItem():
return $default(_that.id,_that.source,_that.sourceRefId,_that.displayName,_that.strengthText,_that.doseText,_that.route,_that.startedAt,_that.endedAt,_that.isCurrent,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String source,  String? sourceRefId,  String displayName,  String? strengthText,  String? doseText,  String? route,  String? startedAt,  String? endedAt,  bool isCurrent,  String? note,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CurrentMedicineItem() when $default != null:
return $default(_that.id,_that.source,_that.sourceRefId,_that.displayName,_that.strengthText,_that.doseText,_that.route,_that.startedAt,_that.endedAt,_that.isCurrent,_that.note,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CurrentMedicineItem implements CurrentMedicineItem {
  const _CurrentMedicineItem({required this.id, required this.source, required this.sourceRefId, required this.displayName, required this.strengthText, required this.doseText, required this.route, required this.startedAt, required this.endedAt, required this.isCurrent, required this.note, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String source;
@override final  String? sourceRefId;
@override final  String displayName;
@override final  String? strengthText;
@override final  String? doseText;
@override final  String? route;
@override final  String? startedAt;
@override final  String? endedAt;
@override final  bool isCurrent;
@override final  String? note;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of CurrentMedicineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentMedicineItemCopyWith<_CurrentMedicineItem> get copyWith => __$CurrentMedicineItemCopyWithImpl<_CurrentMedicineItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentMedicineItem&&(identical(other.id, id) || other.id == id)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceRefId, sourceRefId) || other.sourceRefId == sourceRefId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.strengthText, strengthText) || other.strengthText == strengthText)&&(identical(other.doseText, doseText) || other.doseText == doseText)&&(identical(other.route, route) || other.route == route)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,source,sourceRefId,displayName,strengthText,doseText,route,startedAt,endedAt,isCurrent,note,createdAt,updatedAt);

@override
String toString() {
  return 'CurrentMedicineItem(id: $id, source: $source, sourceRefId: $sourceRefId, displayName: $displayName, strengthText: $strengthText, doseText: $doseText, route: $route, startedAt: $startedAt, endedAt: $endedAt, isCurrent: $isCurrent, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CurrentMedicineItemCopyWith<$Res> implements $CurrentMedicineItemCopyWith<$Res> {
  factory _$CurrentMedicineItemCopyWith(_CurrentMedicineItem value, $Res Function(_CurrentMedicineItem) _then) = __$CurrentMedicineItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String source, String? sourceRefId, String displayName, String? strengthText, String? doseText, String? route, String? startedAt, String? endedAt, bool isCurrent, String? note, String createdAt, String updatedAt
});




}
/// @nodoc
class __$CurrentMedicineItemCopyWithImpl<$Res>
    implements _$CurrentMedicineItemCopyWith<$Res> {
  __$CurrentMedicineItemCopyWithImpl(this._self, this._then);

  final _CurrentMedicineItem _self;
  final $Res Function(_CurrentMedicineItem) _then;

/// Create a copy of CurrentMedicineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? source = null,Object? sourceRefId = freezed,Object? displayName = null,Object? strengthText = freezed,Object? doseText = freezed,Object? route = freezed,Object? startedAt = freezed,Object? endedAt = freezed,Object? isCurrent = null,Object? note = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CurrentMedicineItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,sourceRefId: freezed == sourceRefId ? _self.sourceRefId : sourceRefId // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,strengthText: freezed == strengthText ? _self.strengthText : strengthText // ignore: cast_nullable_to_non_nullable
as String?,doseText: freezed == doseText ? _self.doseText : doseText // ignore: cast_nullable_to_non_nullable
as String?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as String?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
