// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mine_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MineDashboard {

 MineAccount get account; MineCompletion get completion; MineProfileSnapshot get profile; List<MineStatusCard> get alerts; List<MineArchiveEntry> get archiveEntries; List<MineActionEntry> get campusServices; MinePrivacyNotice get privacyNotice;
/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MineDashboardCopyWith<MineDashboard> get copyWith => _$MineDashboardCopyWithImpl<MineDashboard>(this as MineDashboard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MineDashboard&&(identical(other.account, account) || other.account == account)&&(identical(other.completion, completion) || other.completion == completion)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.alerts, alerts)&&const DeepCollectionEquality().equals(other.archiveEntries, archiveEntries)&&const DeepCollectionEquality().equals(other.campusServices, campusServices)&&(identical(other.privacyNotice, privacyNotice) || other.privacyNotice == privacyNotice));
}


@override
int get hashCode => Object.hash(runtimeType,account,completion,profile,const DeepCollectionEquality().hash(alerts),const DeepCollectionEquality().hash(archiveEntries),const DeepCollectionEquality().hash(campusServices),privacyNotice);

@override
String toString() {
  return 'MineDashboard(account: $account, completion: $completion, profile: $profile, alerts: $alerts, archiveEntries: $archiveEntries, campusServices: $campusServices, privacyNotice: $privacyNotice)';
}


}

/// @nodoc
abstract mixin class $MineDashboardCopyWith<$Res>  {
  factory $MineDashboardCopyWith(MineDashboard value, $Res Function(MineDashboard) _then) = _$MineDashboardCopyWithImpl;
@useResult
$Res call({
 MineAccount account, MineCompletion completion, MineProfileSnapshot profile, List<MineStatusCard> alerts, List<MineArchiveEntry> archiveEntries, List<MineActionEntry> campusServices, MinePrivacyNotice privacyNotice
});


$MineAccountCopyWith<$Res> get account;$MineCompletionCopyWith<$Res> get completion;$MineProfileSnapshotCopyWith<$Res> get profile;$MinePrivacyNoticeCopyWith<$Res> get privacyNotice;

}
/// @nodoc
class _$MineDashboardCopyWithImpl<$Res>
    implements $MineDashboardCopyWith<$Res> {
  _$MineDashboardCopyWithImpl(this._self, this._then);

  final MineDashboard _self;
  final $Res Function(MineDashboard) _then;

/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? account = null,Object? completion = null,Object? profile = null,Object? alerts = null,Object? archiveEntries = null,Object? campusServices = null,Object? privacyNotice = null,}) {
  return _then(_self.copyWith(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as MineAccount,completion: null == completion ? _self.completion : completion // ignore: cast_nullable_to_non_nullable
as MineCompletion,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as MineProfileSnapshot,alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<MineStatusCard>,archiveEntries: null == archiveEntries ? _self.archiveEntries : archiveEntries // ignore: cast_nullable_to_non_nullable
as List<MineArchiveEntry>,campusServices: null == campusServices ? _self.campusServices : campusServices // ignore: cast_nullable_to_non_nullable
as List<MineActionEntry>,privacyNotice: null == privacyNotice ? _self.privacyNotice : privacyNotice // ignore: cast_nullable_to_non_nullable
as MinePrivacyNotice,
  ));
}
/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MineAccountCopyWith<$Res> get account {
  
  return $MineAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MineCompletionCopyWith<$Res> get completion {
  
  return $MineCompletionCopyWith<$Res>(_self.completion, (value) {
    return _then(_self.copyWith(completion: value));
  });
}/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MineProfileSnapshotCopyWith<$Res> get profile {
  
  return $MineProfileSnapshotCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MinePrivacyNoticeCopyWith<$Res> get privacyNotice {
  
  return $MinePrivacyNoticeCopyWith<$Res>(_self.privacyNotice, (value) {
    return _then(_self.copyWith(privacyNotice: value));
  });
}
}


/// Adds pattern-matching-related methods to [MineDashboard].
extension MineDashboardPatterns on MineDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MineDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MineDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MineDashboard value)  $default,){
final _that = this;
switch (_that) {
case _MineDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MineDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _MineDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MineAccount account,  MineCompletion completion,  MineProfileSnapshot profile,  List<MineStatusCard> alerts,  List<MineArchiveEntry> archiveEntries,  List<MineActionEntry> campusServices,  MinePrivacyNotice privacyNotice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MineDashboard() when $default != null:
return $default(_that.account,_that.completion,_that.profile,_that.alerts,_that.archiveEntries,_that.campusServices,_that.privacyNotice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MineAccount account,  MineCompletion completion,  MineProfileSnapshot profile,  List<MineStatusCard> alerts,  List<MineArchiveEntry> archiveEntries,  List<MineActionEntry> campusServices,  MinePrivacyNotice privacyNotice)  $default,) {final _that = this;
switch (_that) {
case _MineDashboard():
return $default(_that.account,_that.completion,_that.profile,_that.alerts,_that.archiveEntries,_that.campusServices,_that.privacyNotice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MineAccount account,  MineCompletion completion,  MineProfileSnapshot profile,  List<MineStatusCard> alerts,  List<MineArchiveEntry> archiveEntries,  List<MineActionEntry> campusServices,  MinePrivacyNotice privacyNotice)?  $default,) {final _that = this;
switch (_that) {
case _MineDashboard() when $default != null:
return $default(_that.account,_that.completion,_that.profile,_that.alerts,_that.archiveEntries,_that.campusServices,_that.privacyNotice);case _:
  return null;

}
}

}

/// @nodoc


class _MineDashboard implements MineDashboard {
  const _MineDashboard({required this.account, required this.completion, required this.profile, required final  List<MineStatusCard> alerts, required final  List<MineArchiveEntry> archiveEntries, required final  List<MineActionEntry> campusServices, required this.privacyNotice}): _alerts = alerts,_archiveEntries = archiveEntries,_campusServices = campusServices;
  

@override final  MineAccount account;
@override final  MineCompletion completion;
@override final  MineProfileSnapshot profile;
 final  List<MineStatusCard> _alerts;
@override List<MineStatusCard> get alerts {
  if (_alerts is EqualUnmodifiableListView) return _alerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alerts);
}

 final  List<MineArchiveEntry> _archiveEntries;
@override List<MineArchiveEntry> get archiveEntries {
  if (_archiveEntries is EqualUnmodifiableListView) return _archiveEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_archiveEntries);
}

 final  List<MineActionEntry> _campusServices;
@override List<MineActionEntry> get campusServices {
  if (_campusServices is EqualUnmodifiableListView) return _campusServices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_campusServices);
}

@override final  MinePrivacyNotice privacyNotice;

/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MineDashboardCopyWith<_MineDashboard> get copyWith => __$MineDashboardCopyWithImpl<_MineDashboard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MineDashboard&&(identical(other.account, account) || other.account == account)&&(identical(other.completion, completion) || other.completion == completion)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._alerts, _alerts)&&const DeepCollectionEquality().equals(other._archiveEntries, _archiveEntries)&&const DeepCollectionEquality().equals(other._campusServices, _campusServices)&&(identical(other.privacyNotice, privacyNotice) || other.privacyNotice == privacyNotice));
}


@override
int get hashCode => Object.hash(runtimeType,account,completion,profile,const DeepCollectionEquality().hash(_alerts),const DeepCollectionEquality().hash(_archiveEntries),const DeepCollectionEquality().hash(_campusServices),privacyNotice);

@override
String toString() {
  return 'MineDashboard(account: $account, completion: $completion, profile: $profile, alerts: $alerts, archiveEntries: $archiveEntries, campusServices: $campusServices, privacyNotice: $privacyNotice)';
}


}

/// @nodoc
abstract mixin class _$MineDashboardCopyWith<$Res> implements $MineDashboardCopyWith<$Res> {
  factory _$MineDashboardCopyWith(_MineDashboard value, $Res Function(_MineDashboard) _then) = __$MineDashboardCopyWithImpl;
@override @useResult
$Res call({
 MineAccount account, MineCompletion completion, MineProfileSnapshot profile, List<MineStatusCard> alerts, List<MineArchiveEntry> archiveEntries, List<MineActionEntry> campusServices, MinePrivacyNotice privacyNotice
});


@override $MineAccountCopyWith<$Res> get account;@override $MineCompletionCopyWith<$Res> get completion;@override $MineProfileSnapshotCopyWith<$Res> get profile;@override $MinePrivacyNoticeCopyWith<$Res> get privacyNotice;

}
/// @nodoc
class __$MineDashboardCopyWithImpl<$Res>
    implements _$MineDashboardCopyWith<$Res> {
  __$MineDashboardCopyWithImpl(this._self, this._then);

  final _MineDashboard _self;
  final $Res Function(_MineDashboard) _then;

/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? account = null,Object? completion = null,Object? profile = null,Object? alerts = null,Object? archiveEntries = null,Object? campusServices = null,Object? privacyNotice = null,}) {
  return _then(_MineDashboard(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as MineAccount,completion: null == completion ? _self.completion : completion // ignore: cast_nullable_to_non_nullable
as MineCompletion,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as MineProfileSnapshot,alerts: null == alerts ? _self._alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<MineStatusCard>,archiveEntries: null == archiveEntries ? _self._archiveEntries : archiveEntries // ignore: cast_nullable_to_non_nullable
as List<MineArchiveEntry>,campusServices: null == campusServices ? _self._campusServices : campusServices // ignore: cast_nullable_to_non_nullable
as List<MineActionEntry>,privacyNotice: null == privacyNotice ? _self.privacyNotice : privacyNotice // ignore: cast_nullable_to_non_nullable
as MinePrivacyNotice,
  ));
}

/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MineAccountCopyWith<$Res> get account {
  
  return $MineAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MineCompletionCopyWith<$Res> get completion {
  
  return $MineCompletionCopyWith<$Res>(_self.completion, (value) {
    return _then(_self.copyWith(completion: value));
  });
}/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MineProfileSnapshotCopyWith<$Res> get profile {
  
  return $MineProfileSnapshotCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of MineDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MinePrivacyNoticeCopyWith<$Res> get privacyNotice {
  
  return $MinePrivacyNoticeCopyWith<$Res>(_self.privacyNotice, (value) {
    return _then(_self.copyWith(privacyNotice: value));
  });
}
}

/// @nodoc
mixin _$MineProfileSnapshot {

 int? get age; double? get heightCm; int get allergyCount; int get conditionCount; int get currentMedicineCount; bool get basicInfoCompleted;
/// Create a copy of MineProfileSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MineProfileSnapshotCopyWith<MineProfileSnapshot> get copyWith => _$MineProfileSnapshotCopyWithImpl<MineProfileSnapshot>(this as MineProfileSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MineProfileSnapshot&&(identical(other.age, age) || other.age == age)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.allergyCount, allergyCount) || other.allergyCount == allergyCount)&&(identical(other.conditionCount, conditionCount) || other.conditionCount == conditionCount)&&(identical(other.currentMedicineCount, currentMedicineCount) || other.currentMedicineCount == currentMedicineCount)&&(identical(other.basicInfoCompleted, basicInfoCompleted) || other.basicInfoCompleted == basicInfoCompleted));
}


@override
int get hashCode => Object.hash(runtimeType,age,heightCm,allergyCount,conditionCount,currentMedicineCount,basicInfoCompleted);

@override
String toString() {
  return 'MineProfileSnapshot(age: $age, heightCm: $heightCm, allergyCount: $allergyCount, conditionCount: $conditionCount, currentMedicineCount: $currentMedicineCount, basicInfoCompleted: $basicInfoCompleted)';
}


}

/// @nodoc
abstract mixin class $MineProfileSnapshotCopyWith<$Res>  {
  factory $MineProfileSnapshotCopyWith(MineProfileSnapshot value, $Res Function(MineProfileSnapshot) _then) = _$MineProfileSnapshotCopyWithImpl;
@useResult
$Res call({
 int? age, double? heightCm, int allergyCount, int conditionCount, int currentMedicineCount, bool basicInfoCompleted
});




}
/// @nodoc
class _$MineProfileSnapshotCopyWithImpl<$Res>
    implements $MineProfileSnapshotCopyWith<$Res> {
  _$MineProfileSnapshotCopyWithImpl(this._self, this._then);

  final MineProfileSnapshot _self;
  final $Res Function(MineProfileSnapshot) _then;

/// Create a copy of MineProfileSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? age = freezed,Object? heightCm = freezed,Object? allergyCount = null,Object? conditionCount = null,Object? currentMedicineCount = null,Object? basicInfoCompleted = null,}) {
  return _then(_self.copyWith(
age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,allergyCount: null == allergyCount ? _self.allergyCount : allergyCount // ignore: cast_nullable_to_non_nullable
as int,conditionCount: null == conditionCount ? _self.conditionCount : conditionCount // ignore: cast_nullable_to_non_nullable
as int,currentMedicineCount: null == currentMedicineCount ? _self.currentMedicineCount : currentMedicineCount // ignore: cast_nullable_to_non_nullable
as int,basicInfoCompleted: null == basicInfoCompleted ? _self.basicInfoCompleted : basicInfoCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MineProfileSnapshot].
extension MineProfileSnapshotPatterns on MineProfileSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MineProfileSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MineProfileSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MineProfileSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _MineProfileSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MineProfileSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _MineProfileSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? age,  double? heightCm,  int allergyCount,  int conditionCount,  int currentMedicineCount,  bool basicInfoCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MineProfileSnapshot() when $default != null:
return $default(_that.age,_that.heightCm,_that.allergyCount,_that.conditionCount,_that.currentMedicineCount,_that.basicInfoCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? age,  double? heightCm,  int allergyCount,  int conditionCount,  int currentMedicineCount,  bool basicInfoCompleted)  $default,) {final _that = this;
switch (_that) {
case _MineProfileSnapshot():
return $default(_that.age,_that.heightCm,_that.allergyCount,_that.conditionCount,_that.currentMedicineCount,_that.basicInfoCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? age,  double? heightCm,  int allergyCount,  int conditionCount,  int currentMedicineCount,  bool basicInfoCompleted)?  $default,) {final _that = this;
switch (_that) {
case _MineProfileSnapshot() when $default != null:
return $default(_that.age,_that.heightCm,_that.allergyCount,_that.conditionCount,_that.currentMedicineCount,_that.basicInfoCompleted);case _:
  return null;

}
}

}

/// @nodoc


class _MineProfileSnapshot implements MineProfileSnapshot {
  const _MineProfileSnapshot({required this.age, required this.heightCm, required this.allergyCount, required this.conditionCount, required this.currentMedicineCount, required this.basicInfoCompleted});
  

@override final  int? age;
@override final  double? heightCm;
@override final  int allergyCount;
@override final  int conditionCount;
@override final  int currentMedicineCount;
@override final  bool basicInfoCompleted;

/// Create a copy of MineProfileSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MineProfileSnapshotCopyWith<_MineProfileSnapshot> get copyWith => __$MineProfileSnapshotCopyWithImpl<_MineProfileSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MineProfileSnapshot&&(identical(other.age, age) || other.age == age)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.allergyCount, allergyCount) || other.allergyCount == allergyCount)&&(identical(other.conditionCount, conditionCount) || other.conditionCount == conditionCount)&&(identical(other.currentMedicineCount, currentMedicineCount) || other.currentMedicineCount == currentMedicineCount)&&(identical(other.basicInfoCompleted, basicInfoCompleted) || other.basicInfoCompleted == basicInfoCompleted));
}


@override
int get hashCode => Object.hash(runtimeType,age,heightCm,allergyCount,conditionCount,currentMedicineCount,basicInfoCompleted);

@override
String toString() {
  return 'MineProfileSnapshot(age: $age, heightCm: $heightCm, allergyCount: $allergyCount, conditionCount: $conditionCount, currentMedicineCount: $currentMedicineCount, basicInfoCompleted: $basicInfoCompleted)';
}


}

/// @nodoc
abstract mixin class _$MineProfileSnapshotCopyWith<$Res> implements $MineProfileSnapshotCopyWith<$Res> {
  factory _$MineProfileSnapshotCopyWith(_MineProfileSnapshot value, $Res Function(_MineProfileSnapshot) _then) = __$MineProfileSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int? age, double? heightCm, int allergyCount, int conditionCount, int currentMedicineCount, bool basicInfoCompleted
});




}
/// @nodoc
class __$MineProfileSnapshotCopyWithImpl<$Res>
    implements _$MineProfileSnapshotCopyWith<$Res> {
  __$MineProfileSnapshotCopyWithImpl(this._self, this._then);

  final _MineProfileSnapshot _self;
  final $Res Function(_MineProfileSnapshot) _then;

/// Create a copy of MineProfileSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? age = freezed,Object? heightCm = freezed,Object? allergyCount = null,Object? conditionCount = null,Object? currentMedicineCount = null,Object? basicInfoCompleted = null,}) {
  return _then(_MineProfileSnapshot(
age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,allergyCount: null == allergyCount ? _self.allergyCount : allergyCount // ignore: cast_nullable_to_non_nullable
as int,conditionCount: null == conditionCount ? _self.conditionCount : conditionCount // ignore: cast_nullable_to_non_nullable
as int,currentMedicineCount: null == currentMedicineCount ? _self.currentMedicineCount : currentMedicineCount // ignore: cast_nullable_to_non_nullable
as int,basicInfoCompleted: null == basicInfoCompleted ? _self.basicInfoCompleted : basicInfoCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$MineAccount {

 bool get isAuthenticated; MineCopyKey get displayNameKey; String? get displayName; String get email; MineCopyKey get statusKey; MineCopyKey get roleKey; bool get emailVerified; bool get hasPassword; int get linkedIdentityCount; DateTime? get lastLoginAt;
/// Create a copy of MineAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MineAccountCopyWith<MineAccount> get copyWith => _$MineAccountCopyWithImpl<MineAccount>(this as MineAccount, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MineAccount&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated)&&(identical(other.displayNameKey, displayNameKey) || other.displayNameKey == displayNameKey)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.statusKey, statusKey) || other.statusKey == statusKey)&&(identical(other.roleKey, roleKey) || other.roleKey == roleKey)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.linkedIdentityCount, linkedIdentityCount) || other.linkedIdentityCount == linkedIdentityCount)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}


@override
int get hashCode => Object.hash(runtimeType,isAuthenticated,displayNameKey,displayName,email,statusKey,roleKey,emailVerified,hasPassword,linkedIdentityCount,lastLoginAt);

@override
String toString() {
  return 'MineAccount(isAuthenticated: $isAuthenticated, displayNameKey: $displayNameKey, displayName: $displayName, email: $email, statusKey: $statusKey, roleKey: $roleKey, emailVerified: $emailVerified, hasPassword: $hasPassword, linkedIdentityCount: $linkedIdentityCount, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class $MineAccountCopyWith<$Res>  {
  factory $MineAccountCopyWith(MineAccount value, $Res Function(MineAccount) _then) = _$MineAccountCopyWithImpl;
@useResult
$Res call({
 bool isAuthenticated, MineCopyKey displayNameKey, String? displayName, String email, MineCopyKey statusKey, MineCopyKey roleKey, bool emailVerified, bool hasPassword, int linkedIdentityCount, DateTime? lastLoginAt
});




}
/// @nodoc
class _$MineAccountCopyWithImpl<$Res>
    implements $MineAccountCopyWith<$Res> {
  _$MineAccountCopyWithImpl(this._self, this._then);

  final MineAccount _self;
  final $Res Function(MineAccount) _then;

/// Create a copy of MineAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isAuthenticated = null,Object? displayNameKey = null,Object? displayName = freezed,Object? email = null,Object? statusKey = null,Object? roleKey = null,Object? emailVerified = null,Object? hasPassword = null,Object? linkedIdentityCount = null,Object? lastLoginAt = freezed,}) {
  return _then(_self.copyWith(
isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,displayNameKey: null == displayNameKey ? _self.displayNameKey : displayNameKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,statusKey: null == statusKey ? _self.statusKey : statusKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,roleKey: null == roleKey ? _self.roleKey : roleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,linkedIdentityCount: null == linkedIdentityCount ? _self.linkedIdentityCount : linkedIdentityCount // ignore: cast_nullable_to_non_nullable
as int,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MineAccount].
extension MineAccountPatterns on MineAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MineAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MineAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MineAccount value)  $default,){
final _that = this;
switch (_that) {
case _MineAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MineAccount value)?  $default,){
final _that = this;
switch (_that) {
case _MineAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isAuthenticated,  MineCopyKey displayNameKey,  String? displayName,  String email,  MineCopyKey statusKey,  MineCopyKey roleKey,  bool emailVerified,  bool hasPassword,  int linkedIdentityCount,  DateTime? lastLoginAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MineAccount() when $default != null:
return $default(_that.isAuthenticated,_that.displayNameKey,_that.displayName,_that.email,_that.statusKey,_that.roleKey,_that.emailVerified,_that.hasPassword,_that.linkedIdentityCount,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isAuthenticated,  MineCopyKey displayNameKey,  String? displayName,  String email,  MineCopyKey statusKey,  MineCopyKey roleKey,  bool emailVerified,  bool hasPassword,  int linkedIdentityCount,  DateTime? lastLoginAt)  $default,) {final _that = this;
switch (_that) {
case _MineAccount():
return $default(_that.isAuthenticated,_that.displayNameKey,_that.displayName,_that.email,_that.statusKey,_that.roleKey,_that.emailVerified,_that.hasPassword,_that.linkedIdentityCount,_that.lastLoginAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isAuthenticated,  MineCopyKey displayNameKey,  String? displayName,  String email,  MineCopyKey statusKey,  MineCopyKey roleKey,  bool emailVerified,  bool hasPassword,  int linkedIdentityCount,  DateTime? lastLoginAt)?  $default,) {final _that = this;
switch (_that) {
case _MineAccount() when $default != null:
return $default(_that.isAuthenticated,_that.displayNameKey,_that.displayName,_that.email,_that.statusKey,_that.roleKey,_that.emailVerified,_that.hasPassword,_that.linkedIdentityCount,_that.lastLoginAt);case _:
  return null;

}
}

}

/// @nodoc


class _MineAccount implements MineAccount {
  const _MineAccount({required this.isAuthenticated, required this.displayNameKey, this.displayName, required this.email, required this.statusKey, required this.roleKey, this.emailVerified = false, this.hasPassword = false, this.linkedIdentityCount = 0, this.lastLoginAt});
  

@override final  bool isAuthenticated;
@override final  MineCopyKey displayNameKey;
@override final  String? displayName;
@override final  String email;
@override final  MineCopyKey statusKey;
@override final  MineCopyKey roleKey;
@override@JsonKey() final  bool emailVerified;
@override@JsonKey() final  bool hasPassword;
@override@JsonKey() final  int linkedIdentityCount;
@override final  DateTime? lastLoginAt;

/// Create a copy of MineAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MineAccountCopyWith<_MineAccount> get copyWith => __$MineAccountCopyWithImpl<_MineAccount>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MineAccount&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated)&&(identical(other.displayNameKey, displayNameKey) || other.displayNameKey == displayNameKey)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.statusKey, statusKey) || other.statusKey == statusKey)&&(identical(other.roleKey, roleKey) || other.roleKey == roleKey)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.linkedIdentityCount, linkedIdentityCount) || other.linkedIdentityCount == linkedIdentityCount)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}


@override
int get hashCode => Object.hash(runtimeType,isAuthenticated,displayNameKey,displayName,email,statusKey,roleKey,emailVerified,hasPassword,linkedIdentityCount,lastLoginAt);

@override
String toString() {
  return 'MineAccount(isAuthenticated: $isAuthenticated, displayNameKey: $displayNameKey, displayName: $displayName, email: $email, statusKey: $statusKey, roleKey: $roleKey, emailVerified: $emailVerified, hasPassword: $hasPassword, linkedIdentityCount: $linkedIdentityCount, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class _$MineAccountCopyWith<$Res> implements $MineAccountCopyWith<$Res> {
  factory _$MineAccountCopyWith(_MineAccount value, $Res Function(_MineAccount) _then) = __$MineAccountCopyWithImpl;
@override @useResult
$Res call({
 bool isAuthenticated, MineCopyKey displayNameKey, String? displayName, String email, MineCopyKey statusKey, MineCopyKey roleKey, bool emailVerified, bool hasPassword, int linkedIdentityCount, DateTime? lastLoginAt
});




}
/// @nodoc
class __$MineAccountCopyWithImpl<$Res>
    implements _$MineAccountCopyWith<$Res> {
  __$MineAccountCopyWithImpl(this._self, this._then);

  final _MineAccount _self;
  final $Res Function(_MineAccount) _then;

/// Create a copy of MineAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isAuthenticated = null,Object? displayNameKey = null,Object? displayName = freezed,Object? email = null,Object? statusKey = null,Object? roleKey = null,Object? emailVerified = null,Object? hasPassword = null,Object? linkedIdentityCount = null,Object? lastLoginAt = freezed,}) {
  return _then(_MineAccount(
isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,displayNameKey: null == displayNameKey ? _self.displayNameKey : displayNameKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,statusKey: null == statusKey ? _self.statusKey : statusKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,roleKey: null == roleKey ? _self.roleKey : roleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,linkedIdentityCount: null == linkedIdentityCount ? _self.linkedIdentityCount : linkedIdentityCount // ignore: cast_nullable_to_non_nullable
as int,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$MineCompletion {

 double get progress; String get percentLabel; MineCopyKey get titleKey;
/// Create a copy of MineCompletion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MineCompletionCopyWith<MineCompletion> get copyWith => _$MineCompletionCopyWithImpl<MineCompletion>(this as MineCompletion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MineCompletion&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.percentLabel, percentLabel) || other.percentLabel == percentLabel)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey));
}


@override
int get hashCode => Object.hash(runtimeType,progress,percentLabel,titleKey);

@override
String toString() {
  return 'MineCompletion(progress: $progress, percentLabel: $percentLabel, titleKey: $titleKey)';
}


}

/// @nodoc
abstract mixin class $MineCompletionCopyWith<$Res>  {
  factory $MineCompletionCopyWith(MineCompletion value, $Res Function(MineCompletion) _then) = _$MineCompletionCopyWithImpl;
@useResult
$Res call({
 double progress, String percentLabel, MineCopyKey titleKey
});




}
/// @nodoc
class _$MineCompletionCopyWithImpl<$Res>
    implements $MineCompletionCopyWith<$Res> {
  _$MineCompletionCopyWithImpl(this._self, this._then);

  final MineCompletion _self;
  final $Res Function(MineCompletion) _then;

/// Create a copy of MineCompletion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? progress = null,Object? percentLabel = null,Object? titleKey = null,}) {
  return _then(_self.copyWith(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,percentLabel: null == percentLabel ? _self.percentLabel : percentLabel // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,
  ));
}

}


/// Adds pattern-matching-related methods to [MineCompletion].
extension MineCompletionPatterns on MineCompletion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MineCompletion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MineCompletion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MineCompletion value)  $default,){
final _that = this;
switch (_that) {
case _MineCompletion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MineCompletion value)?  $default,){
final _that = this;
switch (_that) {
case _MineCompletion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double progress,  String percentLabel,  MineCopyKey titleKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MineCompletion() when $default != null:
return $default(_that.progress,_that.percentLabel,_that.titleKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double progress,  String percentLabel,  MineCopyKey titleKey)  $default,) {final _that = this;
switch (_that) {
case _MineCompletion():
return $default(_that.progress,_that.percentLabel,_that.titleKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double progress,  String percentLabel,  MineCopyKey titleKey)?  $default,) {final _that = this;
switch (_that) {
case _MineCompletion() when $default != null:
return $default(_that.progress,_that.percentLabel,_that.titleKey);case _:
  return null;

}
}

}

/// @nodoc


class _MineCompletion implements MineCompletion {
  const _MineCompletion({required this.progress, required this.percentLabel, required this.titleKey});
  

@override final  double progress;
@override final  String percentLabel;
@override final  MineCopyKey titleKey;

/// Create a copy of MineCompletion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MineCompletionCopyWith<_MineCompletion> get copyWith => __$MineCompletionCopyWithImpl<_MineCompletion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MineCompletion&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.percentLabel, percentLabel) || other.percentLabel == percentLabel)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey));
}


@override
int get hashCode => Object.hash(runtimeType,progress,percentLabel,titleKey);

@override
String toString() {
  return 'MineCompletion(progress: $progress, percentLabel: $percentLabel, titleKey: $titleKey)';
}


}

/// @nodoc
abstract mixin class _$MineCompletionCopyWith<$Res> implements $MineCompletionCopyWith<$Res> {
  factory _$MineCompletionCopyWith(_MineCompletion value, $Res Function(_MineCompletion) _then) = __$MineCompletionCopyWithImpl;
@override @useResult
$Res call({
 double progress, String percentLabel, MineCopyKey titleKey
});




}
/// @nodoc
class __$MineCompletionCopyWithImpl<$Res>
    implements _$MineCompletionCopyWith<$Res> {
  __$MineCompletionCopyWithImpl(this._self, this._then);

  final _MineCompletion _self;
  final $Res Function(_MineCompletion) _then;

/// Create a copy of MineCompletion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? progress = null,Object? percentLabel = null,Object? titleKey = null,}) {
  return _then(_MineCompletion(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,percentLabel: null == percentLabel ? _self.percentLabel : percentLabel // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,
  ));
}


}

/// @nodoc
mixin _$MineStatusCard {

 IconData get icon; Color get accent; MineCopyKey get titleKey; MineCopyKey get subtitleKey; MineCopyKey get badgeKey;
/// Create a copy of MineStatusCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MineStatusCardCopyWith<MineStatusCard> get copyWith => _$MineStatusCardCopyWithImpl<MineStatusCard>(this as MineStatusCard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MineStatusCard&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.badgeKey, badgeKey) || other.badgeKey == badgeKey));
}


@override
int get hashCode => Object.hash(runtimeType,icon,accent,titleKey,subtitleKey,badgeKey);

@override
String toString() {
  return 'MineStatusCard(icon: $icon, accent: $accent, titleKey: $titleKey, subtitleKey: $subtitleKey, badgeKey: $badgeKey)';
}


}

/// @nodoc
abstract mixin class $MineStatusCardCopyWith<$Res>  {
  factory $MineStatusCardCopyWith(MineStatusCard value, $Res Function(MineStatusCard) _then) = _$MineStatusCardCopyWithImpl;
@useResult
$Res call({
 IconData icon, Color accent, MineCopyKey titleKey, MineCopyKey subtitleKey, MineCopyKey badgeKey
});




}
/// @nodoc
class _$MineStatusCardCopyWithImpl<$Res>
    implements $MineStatusCardCopyWith<$Res> {
  _$MineStatusCardCopyWithImpl(this._self, this._then);

  final MineStatusCard _self;
  final $Res Function(MineStatusCard) _then;

/// Create a copy of MineStatusCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? accent = null,Object? titleKey = null,Object? subtitleKey = null,Object? badgeKey = null,}) {
  return _then(_self.copyWith(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,badgeKey: null == badgeKey ? _self.badgeKey : badgeKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,
  ));
}

}


/// Adds pattern-matching-related methods to [MineStatusCard].
extension MineStatusCardPatterns on MineStatusCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MineStatusCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MineStatusCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MineStatusCard value)  $default,){
final _that = this;
switch (_that) {
case _MineStatusCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MineStatusCard value)?  $default,){
final _that = this;
switch (_that) {
case _MineStatusCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IconData icon,  Color accent,  MineCopyKey titleKey,  MineCopyKey subtitleKey,  MineCopyKey badgeKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MineStatusCard() when $default != null:
return $default(_that.icon,_that.accent,_that.titleKey,_that.subtitleKey,_that.badgeKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IconData icon,  Color accent,  MineCopyKey titleKey,  MineCopyKey subtitleKey,  MineCopyKey badgeKey)  $default,) {final _that = this;
switch (_that) {
case _MineStatusCard():
return $default(_that.icon,_that.accent,_that.titleKey,_that.subtitleKey,_that.badgeKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IconData icon,  Color accent,  MineCopyKey titleKey,  MineCopyKey subtitleKey,  MineCopyKey badgeKey)?  $default,) {final _that = this;
switch (_that) {
case _MineStatusCard() when $default != null:
return $default(_that.icon,_that.accent,_that.titleKey,_that.subtitleKey,_that.badgeKey);case _:
  return null;

}
}

}

/// @nodoc


class _MineStatusCard implements MineStatusCard {
  const _MineStatusCard({required this.icon, required this.accent, required this.titleKey, required this.subtitleKey, required this.badgeKey});
  

@override final  IconData icon;
@override final  Color accent;
@override final  MineCopyKey titleKey;
@override final  MineCopyKey subtitleKey;
@override final  MineCopyKey badgeKey;

/// Create a copy of MineStatusCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MineStatusCardCopyWith<_MineStatusCard> get copyWith => __$MineStatusCardCopyWithImpl<_MineStatusCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MineStatusCard&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.badgeKey, badgeKey) || other.badgeKey == badgeKey));
}


@override
int get hashCode => Object.hash(runtimeType,icon,accent,titleKey,subtitleKey,badgeKey);

@override
String toString() {
  return 'MineStatusCard(icon: $icon, accent: $accent, titleKey: $titleKey, subtitleKey: $subtitleKey, badgeKey: $badgeKey)';
}


}

/// @nodoc
abstract mixin class _$MineStatusCardCopyWith<$Res> implements $MineStatusCardCopyWith<$Res> {
  factory _$MineStatusCardCopyWith(_MineStatusCard value, $Res Function(_MineStatusCard) _then) = __$MineStatusCardCopyWithImpl;
@override @useResult
$Res call({
 IconData icon, Color accent, MineCopyKey titleKey, MineCopyKey subtitleKey, MineCopyKey badgeKey
});




}
/// @nodoc
class __$MineStatusCardCopyWithImpl<$Res>
    implements _$MineStatusCardCopyWith<$Res> {
  __$MineStatusCardCopyWithImpl(this._self, this._then);

  final _MineStatusCard _self;
  final $Res Function(_MineStatusCard) _then;

/// Create a copy of MineStatusCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? accent = null,Object? titleKey = null,Object? subtitleKey = null,Object? badgeKey = null,}) {
  return _then(_MineStatusCard(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,badgeKey: null == badgeKey ? _self.badgeKey : badgeKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,
  ));
}


}

/// @nodoc
mixin _$MineArchiveEntry {

 IconData get icon; Color get accent; MineCopyKey get titleKey; MineCopyKey get subtitleKey; MineCopyKey? get statusKey; String? get route;
/// Create a copy of MineArchiveEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MineArchiveEntryCopyWith<MineArchiveEntry> get copyWith => _$MineArchiveEntryCopyWithImpl<MineArchiveEntry>(this as MineArchiveEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MineArchiveEntry&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.statusKey, statusKey) || other.statusKey == statusKey)&&(identical(other.route, route) || other.route == route));
}


@override
int get hashCode => Object.hash(runtimeType,icon,accent,titleKey,subtitleKey,statusKey,route);

@override
String toString() {
  return 'MineArchiveEntry(icon: $icon, accent: $accent, titleKey: $titleKey, subtitleKey: $subtitleKey, statusKey: $statusKey, route: $route)';
}


}

/// @nodoc
abstract mixin class $MineArchiveEntryCopyWith<$Res>  {
  factory $MineArchiveEntryCopyWith(MineArchiveEntry value, $Res Function(MineArchiveEntry) _then) = _$MineArchiveEntryCopyWithImpl;
@useResult
$Res call({
 IconData icon, Color accent, MineCopyKey titleKey, MineCopyKey subtitleKey, MineCopyKey? statusKey, String? route
});




}
/// @nodoc
class _$MineArchiveEntryCopyWithImpl<$Res>
    implements $MineArchiveEntryCopyWith<$Res> {
  _$MineArchiveEntryCopyWithImpl(this._self, this._then);

  final MineArchiveEntry _self;
  final $Res Function(MineArchiveEntry) _then;

/// Create a copy of MineArchiveEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? accent = null,Object? titleKey = null,Object? subtitleKey = null,Object? statusKey = freezed,Object? route = freezed,}) {
  return _then(_self.copyWith(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,statusKey: freezed == statusKey ? _self.statusKey : statusKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MineArchiveEntry].
extension MineArchiveEntryPatterns on MineArchiveEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MineArchiveEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MineArchiveEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MineArchiveEntry value)  $default,){
final _that = this;
switch (_that) {
case _MineArchiveEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MineArchiveEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MineArchiveEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IconData icon,  Color accent,  MineCopyKey titleKey,  MineCopyKey subtitleKey,  MineCopyKey? statusKey,  String? route)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MineArchiveEntry() when $default != null:
return $default(_that.icon,_that.accent,_that.titleKey,_that.subtitleKey,_that.statusKey,_that.route);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IconData icon,  Color accent,  MineCopyKey titleKey,  MineCopyKey subtitleKey,  MineCopyKey? statusKey,  String? route)  $default,) {final _that = this;
switch (_that) {
case _MineArchiveEntry():
return $default(_that.icon,_that.accent,_that.titleKey,_that.subtitleKey,_that.statusKey,_that.route);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IconData icon,  Color accent,  MineCopyKey titleKey,  MineCopyKey subtitleKey,  MineCopyKey? statusKey,  String? route)?  $default,) {final _that = this;
switch (_that) {
case _MineArchiveEntry() when $default != null:
return $default(_that.icon,_that.accent,_that.titleKey,_that.subtitleKey,_that.statusKey,_that.route);case _:
  return null;

}
}

}

/// @nodoc


class _MineArchiveEntry implements MineArchiveEntry {
  const _MineArchiveEntry({required this.icon, required this.accent, required this.titleKey, required this.subtitleKey, this.statusKey, this.route});
  

@override final  IconData icon;
@override final  Color accent;
@override final  MineCopyKey titleKey;
@override final  MineCopyKey subtitleKey;
@override final  MineCopyKey? statusKey;
@override final  String? route;

/// Create a copy of MineArchiveEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MineArchiveEntryCopyWith<_MineArchiveEntry> get copyWith => __$MineArchiveEntryCopyWithImpl<_MineArchiveEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MineArchiveEntry&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.statusKey, statusKey) || other.statusKey == statusKey)&&(identical(other.route, route) || other.route == route));
}


@override
int get hashCode => Object.hash(runtimeType,icon,accent,titleKey,subtitleKey,statusKey,route);

@override
String toString() {
  return 'MineArchiveEntry(icon: $icon, accent: $accent, titleKey: $titleKey, subtitleKey: $subtitleKey, statusKey: $statusKey, route: $route)';
}


}

/// @nodoc
abstract mixin class _$MineArchiveEntryCopyWith<$Res> implements $MineArchiveEntryCopyWith<$Res> {
  factory _$MineArchiveEntryCopyWith(_MineArchiveEntry value, $Res Function(_MineArchiveEntry) _then) = __$MineArchiveEntryCopyWithImpl;
@override @useResult
$Res call({
 IconData icon, Color accent, MineCopyKey titleKey, MineCopyKey subtitleKey, MineCopyKey? statusKey, String? route
});




}
/// @nodoc
class __$MineArchiveEntryCopyWithImpl<$Res>
    implements _$MineArchiveEntryCopyWith<$Res> {
  __$MineArchiveEntryCopyWithImpl(this._self, this._then);

  final _MineArchiveEntry _self;
  final $Res Function(_MineArchiveEntry) _then;

/// Create a copy of MineArchiveEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? accent = null,Object? titleKey = null,Object? subtitleKey = null,Object? statusKey = freezed,Object? route = freezed,}) {
  return _then(_MineArchiveEntry(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,statusKey: freezed == statusKey ? _self.statusKey : statusKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey?,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MineActionEntry {

 IconData get icon; Color get accent; MineCopyKey get titleKey; MineCopyKey get subtitleKey;/// Server-provided display title; takes precedence over [titleKey] when set.
 String? get rawTitle;/// Server-provided display subtitle; takes precedence over [subtitleKey].
 String? get rawSubtitle; MineActionTargetType? get actionType; String? get actionTarget;
/// Create a copy of MineActionEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MineActionEntryCopyWith<MineActionEntry> get copyWith => _$MineActionEntryCopyWithImpl<MineActionEntry>(this as MineActionEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MineActionEntry&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.rawTitle, rawTitle) || other.rawTitle == rawTitle)&&(identical(other.rawSubtitle, rawSubtitle) || other.rawSubtitle == rawSubtitle)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actionTarget, actionTarget) || other.actionTarget == actionTarget));
}


@override
int get hashCode => Object.hash(runtimeType,icon,accent,titleKey,subtitleKey,rawTitle,rawSubtitle,actionType,actionTarget);

@override
String toString() {
  return 'MineActionEntry(icon: $icon, accent: $accent, titleKey: $titleKey, subtitleKey: $subtitleKey, rawTitle: $rawTitle, rawSubtitle: $rawSubtitle, actionType: $actionType, actionTarget: $actionTarget)';
}


}

/// @nodoc
abstract mixin class $MineActionEntryCopyWith<$Res>  {
  factory $MineActionEntryCopyWith(MineActionEntry value, $Res Function(MineActionEntry) _then) = _$MineActionEntryCopyWithImpl;
@useResult
$Res call({
 IconData icon, Color accent, MineCopyKey titleKey, MineCopyKey subtitleKey, String? rawTitle, String? rawSubtitle, MineActionTargetType? actionType, String? actionTarget
});




}
/// @nodoc
class _$MineActionEntryCopyWithImpl<$Res>
    implements $MineActionEntryCopyWith<$Res> {
  _$MineActionEntryCopyWithImpl(this._self, this._then);

  final MineActionEntry _self;
  final $Res Function(MineActionEntry) _then;

/// Create a copy of MineActionEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? accent = null,Object? titleKey = null,Object? subtitleKey = null,Object? rawTitle = freezed,Object? rawSubtitle = freezed,Object? actionType = freezed,Object? actionTarget = freezed,}) {
  return _then(_self.copyWith(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,rawTitle: freezed == rawTitle ? _self.rawTitle : rawTitle // ignore: cast_nullable_to_non_nullable
as String?,rawSubtitle: freezed == rawSubtitle ? _self.rawSubtitle : rawSubtitle // ignore: cast_nullable_to_non_nullable
as String?,actionType: freezed == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as MineActionTargetType?,actionTarget: freezed == actionTarget ? _self.actionTarget : actionTarget // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MineActionEntry].
extension MineActionEntryPatterns on MineActionEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MineActionEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MineActionEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MineActionEntry value)  $default,){
final _that = this;
switch (_that) {
case _MineActionEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MineActionEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MineActionEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IconData icon,  Color accent,  MineCopyKey titleKey,  MineCopyKey subtitleKey,  String? rawTitle,  String? rawSubtitle,  MineActionTargetType? actionType,  String? actionTarget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MineActionEntry() when $default != null:
return $default(_that.icon,_that.accent,_that.titleKey,_that.subtitleKey,_that.rawTitle,_that.rawSubtitle,_that.actionType,_that.actionTarget);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IconData icon,  Color accent,  MineCopyKey titleKey,  MineCopyKey subtitleKey,  String? rawTitle,  String? rawSubtitle,  MineActionTargetType? actionType,  String? actionTarget)  $default,) {final _that = this;
switch (_that) {
case _MineActionEntry():
return $default(_that.icon,_that.accent,_that.titleKey,_that.subtitleKey,_that.rawTitle,_that.rawSubtitle,_that.actionType,_that.actionTarget);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IconData icon,  Color accent,  MineCopyKey titleKey,  MineCopyKey subtitleKey,  String? rawTitle,  String? rawSubtitle,  MineActionTargetType? actionType,  String? actionTarget)?  $default,) {final _that = this;
switch (_that) {
case _MineActionEntry() when $default != null:
return $default(_that.icon,_that.accent,_that.titleKey,_that.subtitleKey,_that.rawTitle,_that.rawSubtitle,_that.actionType,_that.actionTarget);case _:
  return null;

}
}

}

/// @nodoc


class _MineActionEntry implements MineActionEntry {
  const _MineActionEntry({required this.icon, required this.accent, required this.titleKey, required this.subtitleKey, this.rawTitle, this.rawSubtitle, this.actionType, this.actionTarget});
  

@override final  IconData icon;
@override final  Color accent;
@override final  MineCopyKey titleKey;
@override final  MineCopyKey subtitleKey;
/// Server-provided display title; takes precedence over [titleKey] when set.
@override final  String? rawTitle;
/// Server-provided display subtitle; takes precedence over [subtitleKey].
@override final  String? rawSubtitle;
@override final  MineActionTargetType? actionType;
@override final  String? actionTarget;

/// Create a copy of MineActionEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MineActionEntryCopyWith<_MineActionEntry> get copyWith => __$MineActionEntryCopyWithImpl<_MineActionEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MineActionEntry&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.rawTitle, rawTitle) || other.rawTitle == rawTitle)&&(identical(other.rawSubtitle, rawSubtitle) || other.rawSubtitle == rawSubtitle)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actionTarget, actionTarget) || other.actionTarget == actionTarget));
}


@override
int get hashCode => Object.hash(runtimeType,icon,accent,titleKey,subtitleKey,rawTitle,rawSubtitle,actionType,actionTarget);

@override
String toString() {
  return 'MineActionEntry(icon: $icon, accent: $accent, titleKey: $titleKey, subtitleKey: $subtitleKey, rawTitle: $rawTitle, rawSubtitle: $rawSubtitle, actionType: $actionType, actionTarget: $actionTarget)';
}


}

/// @nodoc
abstract mixin class _$MineActionEntryCopyWith<$Res> implements $MineActionEntryCopyWith<$Res> {
  factory _$MineActionEntryCopyWith(_MineActionEntry value, $Res Function(_MineActionEntry) _then) = __$MineActionEntryCopyWithImpl;
@override @useResult
$Res call({
 IconData icon, Color accent, MineCopyKey titleKey, MineCopyKey subtitleKey, String? rawTitle, String? rawSubtitle, MineActionTargetType? actionType, String? actionTarget
});




}
/// @nodoc
class __$MineActionEntryCopyWithImpl<$Res>
    implements _$MineActionEntryCopyWith<$Res> {
  __$MineActionEntryCopyWithImpl(this._self, this._then);

  final _MineActionEntry _self;
  final $Res Function(_MineActionEntry) _then;

/// Create a copy of MineActionEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? accent = null,Object? titleKey = null,Object? subtitleKey = null,Object? rawTitle = freezed,Object? rawSubtitle = freezed,Object? actionType = freezed,Object? actionTarget = freezed,}) {
  return _then(_MineActionEntry(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,rawTitle: freezed == rawTitle ? _self.rawTitle : rawTitle // ignore: cast_nullable_to_non_nullable
as String?,rawSubtitle: freezed == rawSubtitle ? _self.rawSubtitle : rawSubtitle // ignore: cast_nullable_to_non_nullable
as String?,actionType: freezed == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as MineActionTargetType?,actionTarget: freezed == actionTarget ? _self.actionTarget : actionTarget // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MinePrivacyNotice {

 IconData get icon; MineCopyKey get titleKey; MineCopyKey get actionKey;
/// Create a copy of MinePrivacyNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MinePrivacyNoticeCopyWith<MinePrivacyNotice> get copyWith => _$MinePrivacyNoticeCopyWithImpl<MinePrivacyNotice>(this as MinePrivacyNotice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MinePrivacyNotice&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.actionKey, actionKey) || other.actionKey == actionKey));
}


@override
int get hashCode => Object.hash(runtimeType,icon,titleKey,actionKey);

@override
String toString() {
  return 'MinePrivacyNotice(icon: $icon, titleKey: $titleKey, actionKey: $actionKey)';
}


}

/// @nodoc
abstract mixin class $MinePrivacyNoticeCopyWith<$Res>  {
  factory $MinePrivacyNoticeCopyWith(MinePrivacyNotice value, $Res Function(MinePrivacyNotice) _then) = _$MinePrivacyNoticeCopyWithImpl;
@useResult
$Res call({
 IconData icon, MineCopyKey titleKey, MineCopyKey actionKey
});




}
/// @nodoc
class _$MinePrivacyNoticeCopyWithImpl<$Res>
    implements $MinePrivacyNoticeCopyWith<$Res> {
  _$MinePrivacyNoticeCopyWithImpl(this._self, this._then);

  final MinePrivacyNotice _self;
  final $Res Function(MinePrivacyNotice) _then;

/// Create a copy of MinePrivacyNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? titleKey = null,Object? actionKey = null,}) {
  return _then(_self.copyWith(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,actionKey: null == actionKey ? _self.actionKey : actionKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,
  ));
}

}


/// Adds pattern-matching-related methods to [MinePrivacyNotice].
extension MinePrivacyNoticePatterns on MinePrivacyNotice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MinePrivacyNotice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MinePrivacyNotice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MinePrivacyNotice value)  $default,){
final _that = this;
switch (_that) {
case _MinePrivacyNotice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MinePrivacyNotice value)?  $default,){
final _that = this;
switch (_that) {
case _MinePrivacyNotice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IconData icon,  MineCopyKey titleKey,  MineCopyKey actionKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MinePrivacyNotice() when $default != null:
return $default(_that.icon,_that.titleKey,_that.actionKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IconData icon,  MineCopyKey titleKey,  MineCopyKey actionKey)  $default,) {final _that = this;
switch (_that) {
case _MinePrivacyNotice():
return $default(_that.icon,_that.titleKey,_that.actionKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IconData icon,  MineCopyKey titleKey,  MineCopyKey actionKey)?  $default,) {final _that = this;
switch (_that) {
case _MinePrivacyNotice() when $default != null:
return $default(_that.icon,_that.titleKey,_that.actionKey);case _:
  return null;

}
}

}

/// @nodoc


class _MinePrivacyNotice implements MinePrivacyNotice {
  const _MinePrivacyNotice({required this.icon, required this.titleKey, required this.actionKey});
  

@override final  IconData icon;
@override final  MineCopyKey titleKey;
@override final  MineCopyKey actionKey;

/// Create a copy of MinePrivacyNotice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MinePrivacyNoticeCopyWith<_MinePrivacyNotice> get copyWith => __$MinePrivacyNoticeCopyWithImpl<_MinePrivacyNotice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MinePrivacyNotice&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.actionKey, actionKey) || other.actionKey == actionKey));
}


@override
int get hashCode => Object.hash(runtimeType,icon,titleKey,actionKey);

@override
String toString() {
  return 'MinePrivacyNotice(icon: $icon, titleKey: $titleKey, actionKey: $actionKey)';
}


}

/// @nodoc
abstract mixin class _$MinePrivacyNoticeCopyWith<$Res> implements $MinePrivacyNoticeCopyWith<$Res> {
  factory _$MinePrivacyNoticeCopyWith(_MinePrivacyNotice value, $Res Function(_MinePrivacyNotice) _then) = __$MinePrivacyNoticeCopyWithImpl;
@override @useResult
$Res call({
 IconData icon, MineCopyKey titleKey, MineCopyKey actionKey
});




}
/// @nodoc
class __$MinePrivacyNoticeCopyWithImpl<$Res>
    implements _$MinePrivacyNoticeCopyWith<$Res> {
  __$MinePrivacyNoticeCopyWithImpl(this._self, this._then);

  final _MinePrivacyNotice _self;
  final $Res Function(_MinePrivacyNotice) _then;

/// Create a copy of MinePrivacyNotice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? titleKey = null,Object? actionKey = null,}) {
  return _then(_MinePrivacyNotice(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,actionKey: null == actionKey ? _self.actionKey : actionKey // ignore: cast_nullable_to_non_nullable
as MineCopyKey,
  ));
}


}

// dart format on
