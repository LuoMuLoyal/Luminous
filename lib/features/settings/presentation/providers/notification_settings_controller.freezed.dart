// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationSettingsState {

 bool get medicationReminders; bool get healthAlerts; bool get weeklySummary; bool get waterReminders; bool get sleepReminders; bool get sleepReminderEnabled; TimeOfDay? get sleepBedtime; TimeOfDay? get sleepWakeTime; NotificationPermissionState get permissionState;
/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsStateCopyWith<NotificationSettingsState> get copyWith => _$NotificationSettingsStateCopyWithImpl<NotificationSettingsState>(this as NotificationSettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettingsState&&(identical(other.medicationReminders, medicationReminders) || other.medicationReminders == medicationReminders)&&(identical(other.healthAlerts, healthAlerts) || other.healthAlerts == healthAlerts)&&(identical(other.weeklySummary, weeklySummary) || other.weeklySummary == weeklySummary)&&(identical(other.waterReminders, waterReminders) || other.waterReminders == waterReminders)&&(identical(other.sleepReminders, sleepReminders) || other.sleepReminders == sleepReminders)&&(identical(other.sleepReminderEnabled, sleepReminderEnabled) || other.sleepReminderEnabled == sleepReminderEnabled)&&(identical(other.sleepBedtime, sleepBedtime) || other.sleepBedtime == sleepBedtime)&&(identical(other.sleepWakeTime, sleepWakeTime) || other.sleepWakeTime == sleepWakeTime)&&(identical(other.permissionState, permissionState) || other.permissionState == permissionState));
}


@override
int get hashCode => Object.hash(runtimeType,medicationReminders,healthAlerts,weeklySummary,waterReminders,sleepReminders,sleepReminderEnabled,sleepBedtime,sleepWakeTime,permissionState);

@override
String toString() {
  return 'NotificationSettingsState(medicationReminders: $medicationReminders, healthAlerts: $healthAlerts, weeklySummary: $weeklySummary, waterReminders: $waterReminders, sleepReminders: $sleepReminders, sleepReminderEnabled: $sleepReminderEnabled, sleepBedtime: $sleepBedtime, sleepWakeTime: $sleepWakeTime, permissionState: $permissionState)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsStateCopyWith<$Res>  {
  factory $NotificationSettingsStateCopyWith(NotificationSettingsState value, $Res Function(NotificationSettingsState) _then) = _$NotificationSettingsStateCopyWithImpl;
@useResult
$Res call({
 bool medicationReminders, bool healthAlerts, bool weeklySummary, bool waterReminders, bool sleepReminders, bool sleepReminderEnabled, TimeOfDay? sleepBedtime, TimeOfDay? sleepWakeTime, NotificationPermissionState permissionState
});




}
/// @nodoc
class _$NotificationSettingsStateCopyWithImpl<$Res>
    implements $NotificationSettingsStateCopyWith<$Res> {
  _$NotificationSettingsStateCopyWithImpl(this._self, this._then);

  final NotificationSettingsState _self;
  final $Res Function(NotificationSettingsState) _then;

/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? medicationReminders = null,Object? healthAlerts = null,Object? weeklySummary = null,Object? waterReminders = null,Object? sleepReminders = null,Object? sleepReminderEnabled = null,Object? sleepBedtime = freezed,Object? sleepWakeTime = freezed,Object? permissionState = null,}) {
  return _then(_self.copyWith(
medicationReminders: null == medicationReminders ? _self.medicationReminders : medicationReminders // ignore: cast_nullable_to_non_nullable
as bool,healthAlerts: null == healthAlerts ? _self.healthAlerts : healthAlerts // ignore: cast_nullable_to_non_nullable
as bool,weeklySummary: null == weeklySummary ? _self.weeklySummary : weeklySummary // ignore: cast_nullable_to_non_nullable
as bool,waterReminders: null == waterReminders ? _self.waterReminders : waterReminders // ignore: cast_nullable_to_non_nullable
as bool,sleepReminders: null == sleepReminders ? _self.sleepReminders : sleepReminders // ignore: cast_nullable_to_non_nullable
as bool,sleepReminderEnabled: null == sleepReminderEnabled ? _self.sleepReminderEnabled : sleepReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,sleepBedtime: freezed == sleepBedtime ? _self.sleepBedtime : sleepBedtime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,sleepWakeTime: freezed == sleepWakeTime ? _self.sleepWakeTime : sleepWakeTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,permissionState: null == permissionState ? _self.permissionState : permissionState // ignore: cast_nullable_to_non_nullable
as NotificationPermissionState,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettingsState].
extension NotificationSettingsStatePatterns on NotificationSettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettingsState value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool medicationReminders,  bool healthAlerts,  bool weeklySummary,  bool waterReminders,  bool sleepReminders,  bool sleepReminderEnabled,  TimeOfDay? sleepBedtime,  TimeOfDay? sleepWakeTime,  NotificationPermissionState permissionState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
return $default(_that.medicationReminders,_that.healthAlerts,_that.weeklySummary,_that.waterReminders,_that.sleepReminders,_that.sleepReminderEnabled,_that.sleepBedtime,_that.sleepWakeTime,_that.permissionState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool medicationReminders,  bool healthAlerts,  bool weeklySummary,  bool waterReminders,  bool sleepReminders,  bool sleepReminderEnabled,  TimeOfDay? sleepBedtime,  TimeOfDay? sleepWakeTime,  NotificationPermissionState permissionState)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsState():
return $default(_that.medicationReminders,_that.healthAlerts,_that.weeklySummary,_that.waterReminders,_that.sleepReminders,_that.sleepReminderEnabled,_that.sleepBedtime,_that.sleepWakeTime,_that.permissionState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool medicationReminders,  bool healthAlerts,  bool weeklySummary,  bool waterReminders,  bool sleepReminders,  bool sleepReminderEnabled,  TimeOfDay? sleepBedtime,  TimeOfDay? sleepWakeTime,  NotificationPermissionState permissionState)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsState() when $default != null:
return $default(_that.medicationReminders,_that.healthAlerts,_that.weeklySummary,_that.waterReminders,_that.sleepReminders,_that.sleepReminderEnabled,_that.sleepBedtime,_that.sleepWakeTime,_that.permissionState);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationSettingsState implements NotificationSettingsState {
  const _NotificationSettingsState({this.medicationReminders = true, this.healthAlerts = true, this.weeklySummary = false, this.waterReminders = true, this.sleepReminders = true, this.sleepReminderEnabled = false, this.sleepBedtime = const TimeOfDay(hour: 23, minute: 0), this.sleepWakeTime = const TimeOfDay(hour: 7, minute: 0), this.permissionState = NotificationPermissionState.unsupported});
  

@override@JsonKey() final  bool medicationReminders;
@override@JsonKey() final  bool healthAlerts;
@override@JsonKey() final  bool weeklySummary;
@override@JsonKey() final  bool waterReminders;
@override@JsonKey() final  bool sleepReminders;
@override@JsonKey() final  bool sleepReminderEnabled;
@override@JsonKey() final  TimeOfDay? sleepBedtime;
@override@JsonKey() final  TimeOfDay? sleepWakeTime;
@override@JsonKey() final  NotificationPermissionState permissionState;

/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsStateCopyWith<_NotificationSettingsState> get copyWith => __$NotificationSettingsStateCopyWithImpl<_NotificationSettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettingsState&&(identical(other.medicationReminders, medicationReminders) || other.medicationReminders == medicationReminders)&&(identical(other.healthAlerts, healthAlerts) || other.healthAlerts == healthAlerts)&&(identical(other.weeklySummary, weeklySummary) || other.weeklySummary == weeklySummary)&&(identical(other.waterReminders, waterReminders) || other.waterReminders == waterReminders)&&(identical(other.sleepReminders, sleepReminders) || other.sleepReminders == sleepReminders)&&(identical(other.sleepReminderEnabled, sleepReminderEnabled) || other.sleepReminderEnabled == sleepReminderEnabled)&&(identical(other.sleepBedtime, sleepBedtime) || other.sleepBedtime == sleepBedtime)&&(identical(other.sleepWakeTime, sleepWakeTime) || other.sleepWakeTime == sleepWakeTime)&&(identical(other.permissionState, permissionState) || other.permissionState == permissionState));
}


@override
int get hashCode => Object.hash(runtimeType,medicationReminders,healthAlerts,weeklySummary,waterReminders,sleepReminders,sleepReminderEnabled,sleepBedtime,sleepWakeTime,permissionState);

@override
String toString() {
  return 'NotificationSettingsState(medicationReminders: $medicationReminders, healthAlerts: $healthAlerts, weeklySummary: $weeklySummary, waterReminders: $waterReminders, sleepReminders: $sleepReminders, sleepReminderEnabled: $sleepReminderEnabled, sleepBedtime: $sleepBedtime, sleepWakeTime: $sleepWakeTime, permissionState: $permissionState)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsStateCopyWith<$Res> implements $NotificationSettingsStateCopyWith<$Res> {
  factory _$NotificationSettingsStateCopyWith(_NotificationSettingsState value, $Res Function(_NotificationSettingsState) _then) = __$NotificationSettingsStateCopyWithImpl;
@override @useResult
$Res call({
 bool medicationReminders, bool healthAlerts, bool weeklySummary, bool waterReminders, bool sleepReminders, bool sleepReminderEnabled, TimeOfDay? sleepBedtime, TimeOfDay? sleepWakeTime, NotificationPermissionState permissionState
});




}
/// @nodoc
class __$NotificationSettingsStateCopyWithImpl<$Res>
    implements _$NotificationSettingsStateCopyWith<$Res> {
  __$NotificationSettingsStateCopyWithImpl(this._self, this._then);

  final _NotificationSettingsState _self;
  final $Res Function(_NotificationSettingsState) _then;

/// Create a copy of NotificationSettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? medicationReminders = null,Object? healthAlerts = null,Object? weeklySummary = null,Object? waterReminders = null,Object? sleepReminders = null,Object? sleepReminderEnabled = null,Object? sleepBedtime = freezed,Object? sleepWakeTime = freezed,Object? permissionState = null,}) {
  return _then(_NotificationSettingsState(
medicationReminders: null == medicationReminders ? _self.medicationReminders : medicationReminders // ignore: cast_nullable_to_non_nullable
as bool,healthAlerts: null == healthAlerts ? _self.healthAlerts : healthAlerts // ignore: cast_nullable_to_non_nullable
as bool,weeklySummary: null == weeklySummary ? _self.weeklySummary : weeklySummary // ignore: cast_nullable_to_non_nullable
as bool,waterReminders: null == waterReminders ? _self.waterReminders : waterReminders // ignore: cast_nullable_to_non_nullable
as bool,sleepReminders: null == sleepReminders ? _self.sleepReminders : sleepReminders // ignore: cast_nullable_to_non_nullable
as bool,sleepReminderEnabled: null == sleepReminderEnabled ? _self.sleepReminderEnabled : sleepReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,sleepBedtime: freezed == sleepBedtime ? _self.sleepBedtime : sleepBedtime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,sleepWakeTime: freezed == sleepWakeTime ? _self.sleepWakeTime : sleepWakeTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,permissionState: null == permissionState ? _self.permissionState : permissionState // ignore: cast_nullable_to_non_nullable
as NotificationPermissionState,
  ));
}


}

// dart format on
