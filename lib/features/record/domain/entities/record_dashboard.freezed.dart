// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'record_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecordDashboard {

 DateTime get selectedDate; int get selectedDay; List<RecordWeekDay> get weekDays; List<RecordCalendarDay> get monthDays; List<RecordQuickAction> get quickActions; RecordDaySummary get summary; List<RecordFilter> get filters; List<RecordTimelineEntry> get timeline; List<RecordTrend> get trends;
/// Create a copy of RecordDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordDashboardCopyWith<RecordDashboard> get copyWith => _$RecordDashboardCopyWithImpl<RecordDashboard>(this as RecordDashboard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordDashboard&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&const DeepCollectionEquality().equals(other.weekDays, weekDays)&&const DeepCollectionEquality().equals(other.monthDays, monthDays)&&const DeepCollectionEquality().equals(other.quickActions, quickActions)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.filters, filters)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&const DeepCollectionEquality().equals(other.trends, trends));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDate,selectedDay,const DeepCollectionEquality().hash(weekDays),const DeepCollectionEquality().hash(monthDays),const DeepCollectionEquality().hash(quickActions),summary,const DeepCollectionEquality().hash(filters),const DeepCollectionEquality().hash(timeline),const DeepCollectionEquality().hash(trends));

@override
String toString() {
  return 'RecordDashboard(selectedDate: $selectedDate, selectedDay: $selectedDay, weekDays: $weekDays, monthDays: $monthDays, quickActions: $quickActions, summary: $summary, filters: $filters, timeline: $timeline, trends: $trends)';
}


}

/// @nodoc
abstract mixin class $RecordDashboardCopyWith<$Res>  {
  factory $RecordDashboardCopyWith(RecordDashboard value, $Res Function(RecordDashboard) _then) = _$RecordDashboardCopyWithImpl;
@useResult
$Res call({
 DateTime selectedDate, int selectedDay, List<RecordWeekDay> weekDays, List<RecordCalendarDay> monthDays, List<RecordQuickAction> quickActions, RecordDaySummary summary, List<RecordFilter> filters, List<RecordTimelineEntry> timeline, List<RecordTrend> trends
});


$RecordDaySummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$RecordDashboardCopyWithImpl<$Res>
    implements $RecordDashboardCopyWith<$Res> {
  _$RecordDashboardCopyWithImpl(this._self, this._then);

  final RecordDashboard _self;
  final $Res Function(RecordDashboard) _then;

/// Create a copy of RecordDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedDate = null,Object? selectedDay = null,Object? weekDays = null,Object? monthDays = null,Object? quickActions = null,Object? summary = null,Object? filters = null,Object? timeline = null,Object? trends = null,}) {
  return _then(_self.copyWith(
selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as int,weekDays: null == weekDays ? _self.weekDays : weekDays // ignore: cast_nullable_to_non_nullable
as List<RecordWeekDay>,monthDays: null == monthDays ? _self.monthDays : monthDays // ignore: cast_nullable_to_non_nullable
as List<RecordCalendarDay>,quickActions: null == quickActions ? _self.quickActions : quickActions // ignore: cast_nullable_to_non_nullable
as List<RecordQuickAction>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as RecordDaySummary,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as List<RecordFilter>,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<RecordTimelineEntry>,trends: null == trends ? _self.trends : trends // ignore: cast_nullable_to_non_nullable
as List<RecordTrend>,
  ));
}
/// Create a copy of RecordDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordDaySummaryCopyWith<$Res> get summary {
  
  return $RecordDaySummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecordDashboard].
extension RecordDashboardPatterns on RecordDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordDashboard value)  $default,){
final _that = this;
switch (_that) {
case _RecordDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _RecordDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime selectedDate,  int selectedDay,  List<RecordWeekDay> weekDays,  List<RecordCalendarDay> monthDays,  List<RecordQuickAction> quickActions,  RecordDaySummary summary,  List<RecordFilter> filters,  List<RecordTimelineEntry> timeline,  List<RecordTrend> trends)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordDashboard() when $default != null:
return $default(_that.selectedDate,_that.selectedDay,_that.weekDays,_that.monthDays,_that.quickActions,_that.summary,_that.filters,_that.timeline,_that.trends);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime selectedDate,  int selectedDay,  List<RecordWeekDay> weekDays,  List<RecordCalendarDay> monthDays,  List<RecordQuickAction> quickActions,  RecordDaySummary summary,  List<RecordFilter> filters,  List<RecordTimelineEntry> timeline,  List<RecordTrend> trends)  $default,) {final _that = this;
switch (_that) {
case _RecordDashboard():
return $default(_that.selectedDate,_that.selectedDay,_that.weekDays,_that.monthDays,_that.quickActions,_that.summary,_that.filters,_that.timeline,_that.trends);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime selectedDate,  int selectedDay,  List<RecordWeekDay> weekDays,  List<RecordCalendarDay> monthDays,  List<RecordQuickAction> quickActions,  RecordDaySummary summary,  List<RecordFilter> filters,  List<RecordTimelineEntry> timeline,  List<RecordTrend> trends)?  $default,) {final _that = this;
switch (_that) {
case _RecordDashboard() when $default != null:
return $default(_that.selectedDate,_that.selectedDay,_that.weekDays,_that.monthDays,_that.quickActions,_that.summary,_that.filters,_that.timeline,_that.trends);case _:
  return null;

}
}

}

/// @nodoc


class _RecordDashboard implements RecordDashboard {
  const _RecordDashboard({required this.selectedDate, required this.selectedDay, required final  List<RecordWeekDay> weekDays, required final  List<RecordCalendarDay> monthDays, required final  List<RecordQuickAction> quickActions, required this.summary, required final  List<RecordFilter> filters, required final  List<RecordTimelineEntry> timeline, required final  List<RecordTrend> trends}): _weekDays = weekDays,_monthDays = monthDays,_quickActions = quickActions,_filters = filters,_timeline = timeline,_trends = trends;
  

@override final  DateTime selectedDate;
@override final  int selectedDay;
 final  List<RecordWeekDay> _weekDays;
@override List<RecordWeekDay> get weekDays {
  if (_weekDays is EqualUnmodifiableListView) return _weekDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weekDays);
}

 final  List<RecordCalendarDay> _monthDays;
@override List<RecordCalendarDay> get monthDays {
  if (_monthDays is EqualUnmodifiableListView) return _monthDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthDays);
}

 final  List<RecordQuickAction> _quickActions;
@override List<RecordQuickAction> get quickActions {
  if (_quickActions is EqualUnmodifiableListView) return _quickActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quickActions);
}

@override final  RecordDaySummary summary;
 final  List<RecordFilter> _filters;
@override List<RecordFilter> get filters {
  if (_filters is EqualUnmodifiableListView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filters);
}

 final  List<RecordTimelineEntry> _timeline;
@override List<RecordTimelineEntry> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

 final  List<RecordTrend> _trends;
@override List<RecordTrend> get trends {
  if (_trends is EqualUnmodifiableListView) return _trends;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trends);
}


/// Create a copy of RecordDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordDashboardCopyWith<_RecordDashboard> get copyWith => __$RecordDashboardCopyWithImpl<_RecordDashboard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordDashboard&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&const DeepCollectionEquality().equals(other._weekDays, _weekDays)&&const DeepCollectionEquality().equals(other._monthDays, _monthDays)&&const DeepCollectionEquality().equals(other._quickActions, _quickActions)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._filters, _filters)&&const DeepCollectionEquality().equals(other._timeline, _timeline)&&const DeepCollectionEquality().equals(other._trends, _trends));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDate,selectedDay,const DeepCollectionEquality().hash(_weekDays),const DeepCollectionEquality().hash(_monthDays),const DeepCollectionEquality().hash(_quickActions),summary,const DeepCollectionEquality().hash(_filters),const DeepCollectionEquality().hash(_timeline),const DeepCollectionEquality().hash(_trends));

@override
String toString() {
  return 'RecordDashboard(selectedDate: $selectedDate, selectedDay: $selectedDay, weekDays: $weekDays, monthDays: $monthDays, quickActions: $quickActions, summary: $summary, filters: $filters, timeline: $timeline, trends: $trends)';
}


}

/// @nodoc
abstract mixin class _$RecordDashboardCopyWith<$Res> implements $RecordDashboardCopyWith<$Res> {
  factory _$RecordDashboardCopyWith(_RecordDashboard value, $Res Function(_RecordDashboard) _then) = __$RecordDashboardCopyWithImpl;
@override @useResult
$Res call({
 DateTime selectedDate, int selectedDay, List<RecordWeekDay> weekDays, List<RecordCalendarDay> monthDays, List<RecordQuickAction> quickActions, RecordDaySummary summary, List<RecordFilter> filters, List<RecordTimelineEntry> timeline, List<RecordTrend> trends
});


@override $RecordDaySummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$RecordDashboardCopyWithImpl<$Res>
    implements _$RecordDashboardCopyWith<$Res> {
  __$RecordDashboardCopyWithImpl(this._self, this._then);

  final _RecordDashboard _self;
  final $Res Function(_RecordDashboard) _then;

/// Create a copy of RecordDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedDate = null,Object? selectedDay = null,Object? weekDays = null,Object? monthDays = null,Object? quickActions = null,Object? summary = null,Object? filters = null,Object? timeline = null,Object? trends = null,}) {
  return _then(_RecordDashboard(
selectedDate: null == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as int,weekDays: null == weekDays ? _self._weekDays : weekDays // ignore: cast_nullable_to_non_nullable
as List<RecordWeekDay>,monthDays: null == monthDays ? _self._monthDays : monthDays // ignore: cast_nullable_to_non_nullable
as List<RecordCalendarDay>,quickActions: null == quickActions ? _self._quickActions : quickActions // ignore: cast_nullable_to_non_nullable
as List<RecordQuickAction>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as RecordDaySummary,filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as List<RecordFilter>,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<RecordTimelineEntry>,trends: null == trends ? _self._trends : trends // ignore: cast_nullable_to_non_nullable
as List<RecordTrend>,
  ));
}

/// Create a copy of RecordDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordDaySummaryCopyWith<$Res> get summary {
  
  return $RecordDaySummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

/// @nodoc
mixin _$RecordWeekDay {

 DateTime get date; int get day; RecordCopyKey get weekdayKey; bool get selected; List<Color> get markers; bool get hasAlert;
/// Create a copy of RecordWeekDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordWeekDayCopyWith<RecordWeekDay> get copyWith => _$RecordWeekDayCopyWithImpl<RecordWeekDay>(this as RecordWeekDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordWeekDay&&(identical(other.date, date) || other.date == date)&&(identical(other.day, day) || other.day == day)&&(identical(other.weekdayKey, weekdayKey) || other.weekdayKey == weekdayKey)&&(identical(other.selected, selected) || other.selected == selected)&&const DeepCollectionEquality().equals(other.markers, markers)&&(identical(other.hasAlert, hasAlert) || other.hasAlert == hasAlert));
}


@override
int get hashCode => Object.hash(runtimeType,date,day,weekdayKey,selected,const DeepCollectionEquality().hash(markers),hasAlert);

@override
String toString() {
  return 'RecordWeekDay(date: $date, day: $day, weekdayKey: $weekdayKey, selected: $selected, markers: $markers, hasAlert: $hasAlert)';
}


}

/// @nodoc
abstract mixin class $RecordWeekDayCopyWith<$Res>  {
  factory $RecordWeekDayCopyWith(RecordWeekDay value, $Res Function(RecordWeekDay) _then) = _$RecordWeekDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, int day, RecordCopyKey weekdayKey, bool selected, List<Color> markers, bool hasAlert
});




}
/// @nodoc
class _$RecordWeekDayCopyWithImpl<$Res>
    implements $RecordWeekDayCopyWith<$Res> {
  _$RecordWeekDayCopyWithImpl(this._self, this._then);

  final RecordWeekDay _self;
  final $Res Function(RecordWeekDay) _then;

/// Create a copy of RecordWeekDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? day = null,Object? weekdayKey = null,Object? selected = null,Object? markers = null,Object? hasAlert = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,weekdayKey: null == weekdayKey ? _self.weekdayKey : weekdayKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,markers: null == markers ? _self.markers : markers // ignore: cast_nullable_to_non_nullable
as List<Color>,hasAlert: null == hasAlert ? _self.hasAlert : hasAlert // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordWeekDay].
extension RecordWeekDayPatterns on RecordWeekDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordWeekDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordWeekDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordWeekDay value)  $default,){
final _that = this;
switch (_that) {
case _RecordWeekDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordWeekDay value)?  $default,){
final _that = this;
switch (_that) {
case _RecordWeekDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int day,  RecordCopyKey weekdayKey,  bool selected,  List<Color> markers,  bool hasAlert)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordWeekDay() when $default != null:
return $default(_that.date,_that.day,_that.weekdayKey,_that.selected,_that.markers,_that.hasAlert);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int day,  RecordCopyKey weekdayKey,  bool selected,  List<Color> markers,  bool hasAlert)  $default,) {final _that = this;
switch (_that) {
case _RecordWeekDay():
return $default(_that.date,_that.day,_that.weekdayKey,_that.selected,_that.markers,_that.hasAlert);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int day,  RecordCopyKey weekdayKey,  bool selected,  List<Color> markers,  bool hasAlert)?  $default,) {final _that = this;
switch (_that) {
case _RecordWeekDay() when $default != null:
return $default(_that.date,_that.day,_that.weekdayKey,_that.selected,_that.markers,_that.hasAlert);case _:
  return null;

}
}

}

/// @nodoc


class _RecordWeekDay implements RecordWeekDay {
  const _RecordWeekDay({required this.date, required this.day, required this.weekdayKey, required this.selected, required final  List<Color> markers, this.hasAlert = false}): _markers = markers;
  

@override final  DateTime date;
@override final  int day;
@override final  RecordCopyKey weekdayKey;
@override final  bool selected;
 final  List<Color> _markers;
@override List<Color> get markers {
  if (_markers is EqualUnmodifiableListView) return _markers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_markers);
}

@override@JsonKey() final  bool hasAlert;

/// Create a copy of RecordWeekDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordWeekDayCopyWith<_RecordWeekDay> get copyWith => __$RecordWeekDayCopyWithImpl<_RecordWeekDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordWeekDay&&(identical(other.date, date) || other.date == date)&&(identical(other.day, day) || other.day == day)&&(identical(other.weekdayKey, weekdayKey) || other.weekdayKey == weekdayKey)&&(identical(other.selected, selected) || other.selected == selected)&&const DeepCollectionEquality().equals(other._markers, _markers)&&(identical(other.hasAlert, hasAlert) || other.hasAlert == hasAlert));
}


@override
int get hashCode => Object.hash(runtimeType,date,day,weekdayKey,selected,const DeepCollectionEquality().hash(_markers),hasAlert);

@override
String toString() {
  return 'RecordWeekDay(date: $date, day: $day, weekdayKey: $weekdayKey, selected: $selected, markers: $markers, hasAlert: $hasAlert)';
}


}

/// @nodoc
abstract mixin class _$RecordWeekDayCopyWith<$Res> implements $RecordWeekDayCopyWith<$Res> {
  factory _$RecordWeekDayCopyWith(_RecordWeekDay value, $Res Function(_RecordWeekDay) _then) = __$RecordWeekDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int day, RecordCopyKey weekdayKey, bool selected, List<Color> markers, bool hasAlert
});




}
/// @nodoc
class __$RecordWeekDayCopyWithImpl<$Res>
    implements _$RecordWeekDayCopyWith<$Res> {
  __$RecordWeekDayCopyWithImpl(this._self, this._then);

  final _RecordWeekDay _self;
  final $Res Function(_RecordWeekDay) _then;

/// Create a copy of RecordWeekDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? day = null,Object? weekdayKey = null,Object? selected = null,Object? markers = null,Object? hasAlert = null,}) {
  return _then(_RecordWeekDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,weekdayKey: null == weekdayKey ? _self.weekdayKey : weekdayKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,markers: null == markers ? _self._markers : markers // ignore: cast_nullable_to_non_nullable
as List<Color>,hasAlert: null == hasAlert ? _self.hasAlert : hasAlert // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RecordCalendarDay {

 int get day; bool get inMonth; bool get selected; List<Color> get markers; bool get hasAlert;
/// Create a copy of RecordCalendarDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordCalendarDayCopyWith<RecordCalendarDay> get copyWith => _$RecordCalendarDayCopyWithImpl<RecordCalendarDay>(this as RecordCalendarDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordCalendarDay&&(identical(other.day, day) || other.day == day)&&(identical(other.inMonth, inMonth) || other.inMonth == inMonth)&&(identical(other.selected, selected) || other.selected == selected)&&const DeepCollectionEquality().equals(other.markers, markers)&&(identical(other.hasAlert, hasAlert) || other.hasAlert == hasAlert));
}


@override
int get hashCode => Object.hash(runtimeType,day,inMonth,selected,const DeepCollectionEquality().hash(markers),hasAlert);

@override
String toString() {
  return 'RecordCalendarDay(day: $day, inMonth: $inMonth, selected: $selected, markers: $markers, hasAlert: $hasAlert)';
}


}

/// @nodoc
abstract mixin class $RecordCalendarDayCopyWith<$Res>  {
  factory $RecordCalendarDayCopyWith(RecordCalendarDay value, $Res Function(RecordCalendarDay) _then) = _$RecordCalendarDayCopyWithImpl;
@useResult
$Res call({
 int day, bool inMonth, bool selected, List<Color> markers, bool hasAlert
});




}
/// @nodoc
class _$RecordCalendarDayCopyWithImpl<$Res>
    implements $RecordCalendarDayCopyWith<$Res> {
  _$RecordCalendarDayCopyWithImpl(this._self, this._then);

  final RecordCalendarDay _self;
  final $Res Function(RecordCalendarDay) _then;

/// Create a copy of RecordCalendarDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? inMonth = null,Object? selected = null,Object? markers = null,Object? hasAlert = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,inMonth: null == inMonth ? _self.inMonth : inMonth // ignore: cast_nullable_to_non_nullable
as bool,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,markers: null == markers ? _self.markers : markers // ignore: cast_nullable_to_non_nullable
as List<Color>,hasAlert: null == hasAlert ? _self.hasAlert : hasAlert // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordCalendarDay].
extension RecordCalendarDayPatterns on RecordCalendarDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordCalendarDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordCalendarDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordCalendarDay value)  $default,){
final _that = this;
switch (_that) {
case _RecordCalendarDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordCalendarDay value)?  $default,){
final _that = this;
switch (_that) {
case _RecordCalendarDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int day,  bool inMonth,  bool selected,  List<Color> markers,  bool hasAlert)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordCalendarDay() when $default != null:
return $default(_that.day,_that.inMonth,_that.selected,_that.markers,_that.hasAlert);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int day,  bool inMonth,  bool selected,  List<Color> markers,  bool hasAlert)  $default,) {final _that = this;
switch (_that) {
case _RecordCalendarDay():
return $default(_that.day,_that.inMonth,_that.selected,_that.markers,_that.hasAlert);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int day,  bool inMonth,  bool selected,  List<Color> markers,  bool hasAlert)?  $default,) {final _that = this;
switch (_that) {
case _RecordCalendarDay() when $default != null:
return $default(_that.day,_that.inMonth,_that.selected,_that.markers,_that.hasAlert);case _:
  return null;

}
}

}

/// @nodoc


class _RecordCalendarDay implements RecordCalendarDay {
  const _RecordCalendarDay({required this.day, required this.inMonth, required this.selected, required final  List<Color> markers, this.hasAlert = false}): _markers = markers;
  

@override final  int day;
@override final  bool inMonth;
@override final  bool selected;
 final  List<Color> _markers;
@override List<Color> get markers {
  if (_markers is EqualUnmodifiableListView) return _markers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_markers);
}

@override@JsonKey() final  bool hasAlert;

/// Create a copy of RecordCalendarDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordCalendarDayCopyWith<_RecordCalendarDay> get copyWith => __$RecordCalendarDayCopyWithImpl<_RecordCalendarDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordCalendarDay&&(identical(other.day, day) || other.day == day)&&(identical(other.inMonth, inMonth) || other.inMonth == inMonth)&&(identical(other.selected, selected) || other.selected == selected)&&const DeepCollectionEquality().equals(other._markers, _markers)&&(identical(other.hasAlert, hasAlert) || other.hasAlert == hasAlert));
}


@override
int get hashCode => Object.hash(runtimeType,day,inMonth,selected,const DeepCollectionEquality().hash(_markers),hasAlert);

@override
String toString() {
  return 'RecordCalendarDay(day: $day, inMonth: $inMonth, selected: $selected, markers: $markers, hasAlert: $hasAlert)';
}


}

/// @nodoc
abstract mixin class _$RecordCalendarDayCopyWith<$Res> implements $RecordCalendarDayCopyWith<$Res> {
  factory _$RecordCalendarDayCopyWith(_RecordCalendarDay value, $Res Function(_RecordCalendarDay) _then) = __$RecordCalendarDayCopyWithImpl;
@override @useResult
$Res call({
 int day, bool inMonth, bool selected, List<Color> markers, bool hasAlert
});




}
/// @nodoc
class __$RecordCalendarDayCopyWithImpl<$Res>
    implements _$RecordCalendarDayCopyWith<$Res> {
  __$RecordCalendarDayCopyWithImpl(this._self, this._then);

  final _RecordCalendarDay _self;
  final $Res Function(_RecordCalendarDay) _then;

/// Create a copy of RecordCalendarDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? inMonth = null,Object? selected = null,Object? markers = null,Object? hasAlert = null,}) {
  return _then(_RecordCalendarDay(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,inMonth: null == inMonth ? _self.inMonth : inMonth // ignore: cast_nullable_to_non_nullable
as bool,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,markers: null == markers ? _self._markers : markers // ignore: cast_nullable_to_non_nullable
as List<Color>,hasAlert: null == hasAlert ? _self.hasAlert : hasAlert // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RecordQuickAction {

 RecordEntryType get type; IconData get icon; RecordCopyKey get titleKey; RecordCopyKey get subtitleKey; Color get accent; Color get softColor; bool get locked;
/// Create a copy of RecordQuickAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordQuickActionCopyWith<RecordQuickAction> get copyWith => _$RecordQuickActionCopyWithImpl<RecordQuickAction>(this as RecordQuickAction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordQuickAction&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.softColor, softColor) || other.softColor == softColor)&&(identical(other.locked, locked) || other.locked == locked));
}


@override
int get hashCode => Object.hash(runtimeType,type,icon,titleKey,subtitleKey,accent,softColor,locked);

@override
String toString() {
  return 'RecordQuickAction(type: $type, icon: $icon, titleKey: $titleKey, subtitleKey: $subtitleKey, accent: $accent, softColor: $softColor, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $RecordQuickActionCopyWith<$Res>  {
  factory $RecordQuickActionCopyWith(RecordQuickAction value, $Res Function(RecordQuickAction) _then) = _$RecordQuickActionCopyWithImpl;
@useResult
$Res call({
 RecordEntryType type, IconData icon, RecordCopyKey titleKey, RecordCopyKey subtitleKey, Color accent, Color softColor, bool locked
});




}
/// @nodoc
class _$RecordQuickActionCopyWithImpl<$Res>
    implements $RecordQuickActionCopyWith<$Res> {
  _$RecordQuickActionCopyWithImpl(this._self, this._then);

  final RecordQuickAction _self;
  final $Res Function(RecordQuickAction) _then;

/// Create a copy of RecordQuickAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? icon = null,Object? titleKey = null,Object? subtitleKey = null,Object? accent = null,Object? softColor = null,Object? locked = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordEntryType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordQuickAction].
extension RecordQuickActionPatterns on RecordQuickAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordQuickAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordQuickAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordQuickAction value)  $default,){
final _that = this;
switch (_that) {
case _RecordQuickAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordQuickAction value)?  $default,){
final _that = this;
switch (_that) {
case _RecordQuickAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordEntryType type,  IconData icon,  RecordCopyKey titleKey,  RecordCopyKey subtitleKey,  Color accent,  Color softColor,  bool locked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordQuickAction() when $default != null:
return $default(_that.type,_that.icon,_that.titleKey,_that.subtitleKey,_that.accent,_that.softColor,_that.locked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordEntryType type,  IconData icon,  RecordCopyKey titleKey,  RecordCopyKey subtitleKey,  Color accent,  Color softColor,  bool locked)  $default,) {final _that = this;
switch (_that) {
case _RecordQuickAction():
return $default(_that.type,_that.icon,_that.titleKey,_that.subtitleKey,_that.accent,_that.softColor,_that.locked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordEntryType type,  IconData icon,  RecordCopyKey titleKey,  RecordCopyKey subtitleKey,  Color accent,  Color softColor,  bool locked)?  $default,) {final _that = this;
switch (_that) {
case _RecordQuickAction() when $default != null:
return $default(_that.type,_that.icon,_that.titleKey,_that.subtitleKey,_that.accent,_that.softColor,_that.locked);case _:
  return null;

}
}

}

/// @nodoc


class _RecordQuickAction implements RecordQuickAction {
  const _RecordQuickAction({required this.type, required this.icon, required this.titleKey, required this.subtitleKey, required this.accent, required this.softColor, this.locked = false});
  

@override final  RecordEntryType type;
@override final  IconData icon;
@override final  RecordCopyKey titleKey;
@override final  RecordCopyKey subtitleKey;
@override final  Color accent;
@override final  Color softColor;
@override@JsonKey() final  bool locked;

/// Create a copy of RecordQuickAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordQuickActionCopyWith<_RecordQuickAction> get copyWith => __$RecordQuickActionCopyWithImpl<_RecordQuickAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordQuickAction&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.softColor, softColor) || other.softColor == softColor)&&(identical(other.locked, locked) || other.locked == locked));
}


@override
int get hashCode => Object.hash(runtimeType,type,icon,titleKey,subtitleKey,accent,softColor,locked);

@override
String toString() {
  return 'RecordQuickAction(type: $type, icon: $icon, titleKey: $titleKey, subtitleKey: $subtitleKey, accent: $accent, softColor: $softColor, locked: $locked)';
}


}

/// @nodoc
abstract mixin class _$RecordQuickActionCopyWith<$Res> implements $RecordQuickActionCopyWith<$Res> {
  factory _$RecordQuickActionCopyWith(_RecordQuickAction value, $Res Function(_RecordQuickAction) _then) = __$RecordQuickActionCopyWithImpl;
@override @useResult
$Res call({
 RecordEntryType type, IconData icon, RecordCopyKey titleKey, RecordCopyKey subtitleKey, Color accent, Color softColor, bool locked
});




}
/// @nodoc
class __$RecordQuickActionCopyWithImpl<$Res>
    implements _$RecordQuickActionCopyWith<$Res> {
  __$RecordQuickActionCopyWithImpl(this._self, this._then);

  final _RecordQuickAction _self;
  final $Res Function(_RecordQuickAction) _then;

/// Create a copy of RecordQuickAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? icon = null,Object? titleKey = null,Object? subtitleKey = null,Object? accent = null,Object? softColor = null,Object? locked = null,}) {
  return _then(_RecordQuickAction(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordEntryType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,subtitleKey: null == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RecordDaySummary {

 List<RecordSummaryItem> get items;
/// Create a copy of RecordDaySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordDaySummaryCopyWith<RecordDaySummary> get copyWith => _$RecordDaySummaryCopyWithImpl<RecordDaySummary>(this as RecordDaySummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordDaySummary&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'RecordDaySummary(items: $items)';
}


}

/// @nodoc
abstract mixin class $RecordDaySummaryCopyWith<$Res>  {
  factory $RecordDaySummaryCopyWith(RecordDaySummary value, $Res Function(RecordDaySummary) _then) = _$RecordDaySummaryCopyWithImpl;
@useResult
$Res call({
 List<RecordSummaryItem> items
});




}
/// @nodoc
class _$RecordDaySummaryCopyWithImpl<$Res>
    implements $RecordDaySummaryCopyWith<$Res> {
  _$RecordDaySummaryCopyWithImpl(this._self, this._then);

  final RecordDaySummary _self;
  final $Res Function(RecordDaySummary) _then;

/// Create a copy of RecordDaySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RecordSummaryItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordDaySummary].
extension RecordDaySummaryPatterns on RecordDaySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordDaySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordDaySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordDaySummary value)  $default,){
final _that = this;
switch (_that) {
case _RecordDaySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordDaySummary value)?  $default,){
final _that = this;
switch (_that) {
case _RecordDaySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecordSummaryItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordDaySummary() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecordSummaryItem> items)  $default,) {final _that = this;
switch (_that) {
case _RecordDaySummary():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecordSummaryItem> items)?  $default,) {final _that = this;
switch (_that) {
case _RecordDaySummary() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _RecordDaySummary implements RecordDaySummary {
  const _RecordDaySummary({required final  List<RecordSummaryItem> items}): _items = items;
  

 final  List<RecordSummaryItem> _items;
@override List<RecordSummaryItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of RecordDaySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordDaySummaryCopyWith<_RecordDaySummary> get copyWith => __$RecordDaySummaryCopyWithImpl<_RecordDaySummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordDaySummary&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'RecordDaySummary(items: $items)';
}


}

/// @nodoc
abstract mixin class _$RecordDaySummaryCopyWith<$Res> implements $RecordDaySummaryCopyWith<$Res> {
  factory _$RecordDaySummaryCopyWith(_RecordDaySummary value, $Res Function(_RecordDaySummary) _then) = __$RecordDaySummaryCopyWithImpl;
@override @useResult
$Res call({
 List<RecordSummaryItem> items
});




}
/// @nodoc
class __$RecordDaySummaryCopyWithImpl<$Res>
    implements _$RecordDaySummaryCopyWith<$Res> {
  __$RecordDaySummaryCopyWithImpl(this._self, this._then);

  final _RecordDaySummary _self;
  final $Res Function(_RecordDaySummary) _then;

/// Create a copy of RecordDaySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_RecordDaySummary(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RecordSummaryItem>,
  ));
}


}

/// @nodoc
mixin _$RecordSummaryItem {

 RecordEntryType get type; IconData get icon; RecordCopyKey get titleKey; String get value; RecordCopyKey? get unitKey; RecordCopyKey? get detailKey; Color get accent; Color get softColor;
/// Create a copy of RecordSummaryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordSummaryItemCopyWith<RecordSummaryItem> get copyWith => _$RecordSummaryItemCopyWithImpl<RecordSummaryItem>(this as RecordSummaryItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordSummaryItem&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.value, value) || other.value == value)&&(identical(other.unitKey, unitKey) || other.unitKey == unitKey)&&(identical(other.detailKey, detailKey) || other.detailKey == detailKey)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.softColor, softColor) || other.softColor == softColor));
}


@override
int get hashCode => Object.hash(runtimeType,type,icon,titleKey,value,unitKey,detailKey,accent,softColor);

@override
String toString() {
  return 'RecordSummaryItem(type: $type, icon: $icon, titleKey: $titleKey, value: $value, unitKey: $unitKey, detailKey: $detailKey, accent: $accent, softColor: $softColor)';
}


}

/// @nodoc
abstract mixin class $RecordSummaryItemCopyWith<$Res>  {
  factory $RecordSummaryItemCopyWith(RecordSummaryItem value, $Res Function(RecordSummaryItem) _then) = _$RecordSummaryItemCopyWithImpl;
@useResult
$Res call({
 RecordEntryType type, IconData icon, RecordCopyKey titleKey, String value, RecordCopyKey? unitKey, RecordCopyKey? detailKey, Color accent, Color softColor
});




}
/// @nodoc
class _$RecordSummaryItemCopyWithImpl<$Res>
    implements $RecordSummaryItemCopyWith<$Res> {
  _$RecordSummaryItemCopyWithImpl(this._self, this._then);

  final RecordSummaryItem _self;
  final $Res Function(RecordSummaryItem) _then;

/// Create a copy of RecordSummaryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? icon = null,Object? titleKey = null,Object? value = null,Object? unitKey = freezed,Object? detailKey = freezed,Object? accent = null,Object? softColor = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordEntryType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unitKey: freezed == unitKey ? _self.unitKey : unitKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,detailKey: freezed == detailKey ? _self.detailKey : detailKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordSummaryItem].
extension RecordSummaryItemPatterns on RecordSummaryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordSummaryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordSummaryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordSummaryItem value)  $default,){
final _that = this;
switch (_that) {
case _RecordSummaryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordSummaryItem value)?  $default,){
final _that = this;
switch (_that) {
case _RecordSummaryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordEntryType type,  IconData icon,  RecordCopyKey titleKey,  String value,  RecordCopyKey? unitKey,  RecordCopyKey? detailKey,  Color accent,  Color softColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordSummaryItem() when $default != null:
return $default(_that.type,_that.icon,_that.titleKey,_that.value,_that.unitKey,_that.detailKey,_that.accent,_that.softColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordEntryType type,  IconData icon,  RecordCopyKey titleKey,  String value,  RecordCopyKey? unitKey,  RecordCopyKey? detailKey,  Color accent,  Color softColor)  $default,) {final _that = this;
switch (_that) {
case _RecordSummaryItem():
return $default(_that.type,_that.icon,_that.titleKey,_that.value,_that.unitKey,_that.detailKey,_that.accent,_that.softColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordEntryType type,  IconData icon,  RecordCopyKey titleKey,  String value,  RecordCopyKey? unitKey,  RecordCopyKey? detailKey,  Color accent,  Color softColor)?  $default,) {final _that = this;
switch (_that) {
case _RecordSummaryItem() when $default != null:
return $default(_that.type,_that.icon,_that.titleKey,_that.value,_that.unitKey,_that.detailKey,_that.accent,_that.softColor);case _:
  return null;

}
}

}

/// @nodoc


class _RecordSummaryItem implements RecordSummaryItem {
  const _RecordSummaryItem({required this.type, required this.icon, required this.titleKey, required this.value, this.unitKey, this.detailKey, required this.accent, required this.softColor});
  

@override final  RecordEntryType type;
@override final  IconData icon;
@override final  RecordCopyKey titleKey;
@override final  String value;
@override final  RecordCopyKey? unitKey;
@override final  RecordCopyKey? detailKey;
@override final  Color accent;
@override final  Color softColor;

/// Create a copy of RecordSummaryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordSummaryItemCopyWith<_RecordSummaryItem> get copyWith => __$RecordSummaryItemCopyWithImpl<_RecordSummaryItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordSummaryItem&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.value, value) || other.value == value)&&(identical(other.unitKey, unitKey) || other.unitKey == unitKey)&&(identical(other.detailKey, detailKey) || other.detailKey == detailKey)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.softColor, softColor) || other.softColor == softColor));
}


@override
int get hashCode => Object.hash(runtimeType,type,icon,titleKey,value,unitKey,detailKey,accent,softColor);

@override
String toString() {
  return 'RecordSummaryItem(type: $type, icon: $icon, titleKey: $titleKey, value: $value, unitKey: $unitKey, detailKey: $detailKey, accent: $accent, softColor: $softColor)';
}


}

/// @nodoc
abstract mixin class _$RecordSummaryItemCopyWith<$Res> implements $RecordSummaryItemCopyWith<$Res> {
  factory _$RecordSummaryItemCopyWith(_RecordSummaryItem value, $Res Function(_RecordSummaryItem) _then) = __$RecordSummaryItemCopyWithImpl;
@override @useResult
$Res call({
 RecordEntryType type, IconData icon, RecordCopyKey titleKey, String value, RecordCopyKey? unitKey, RecordCopyKey? detailKey, Color accent, Color softColor
});




}
/// @nodoc
class __$RecordSummaryItemCopyWithImpl<$Res>
    implements _$RecordSummaryItemCopyWith<$Res> {
  __$RecordSummaryItemCopyWithImpl(this._self, this._then);

  final _RecordSummaryItem _self;
  final $Res Function(_RecordSummaryItem) _then;

/// Create a copy of RecordSummaryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? icon = null,Object? titleKey = null,Object? value = null,Object? unitKey = freezed,Object? detailKey = freezed,Object? accent = null,Object? softColor = null,}) {
  return _then(_RecordSummaryItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordEntryType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unitKey: freezed == unitKey ? _self.unitKey : unitKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,detailKey: freezed == detailKey ? _self.detailKey : detailKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

/// @nodoc
mixin _$RecordFilter {

 RecordEntryType get type; RecordCopyKey get titleKey; IconData get icon; Color get accent; bool get selected; bool get locked;
/// Create a copy of RecordFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordFilterCopyWith<RecordFilter> get copyWith => _$RecordFilterCopyWithImpl<RecordFilter>(this as RecordFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordFilter&&(identical(other.type, type) || other.type == type)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.locked, locked) || other.locked == locked));
}


@override
int get hashCode => Object.hash(runtimeType,type,titleKey,icon,accent,selected,locked);

@override
String toString() {
  return 'RecordFilter(type: $type, titleKey: $titleKey, icon: $icon, accent: $accent, selected: $selected, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $RecordFilterCopyWith<$Res>  {
  factory $RecordFilterCopyWith(RecordFilter value, $Res Function(RecordFilter) _then) = _$RecordFilterCopyWithImpl;
@useResult
$Res call({
 RecordEntryType type, RecordCopyKey titleKey, IconData icon, Color accent, bool selected, bool locked
});




}
/// @nodoc
class _$RecordFilterCopyWithImpl<$Res>
    implements $RecordFilterCopyWith<$Res> {
  _$RecordFilterCopyWithImpl(this._self, this._then);

  final RecordFilter _self;
  final $Res Function(RecordFilter) _then;

/// Create a copy of RecordFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? titleKey = null,Object? icon = null,Object? accent = null,Object? selected = null,Object? locked = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordEntryType,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordFilter].
extension RecordFilterPatterns on RecordFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordFilter value)  $default,){
final _that = this;
switch (_that) {
case _RecordFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordFilter value)?  $default,){
final _that = this;
switch (_that) {
case _RecordFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordEntryType type,  RecordCopyKey titleKey,  IconData icon,  Color accent,  bool selected,  bool locked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordFilter() when $default != null:
return $default(_that.type,_that.titleKey,_that.icon,_that.accent,_that.selected,_that.locked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordEntryType type,  RecordCopyKey titleKey,  IconData icon,  Color accent,  bool selected,  bool locked)  $default,) {final _that = this;
switch (_that) {
case _RecordFilter():
return $default(_that.type,_that.titleKey,_that.icon,_that.accent,_that.selected,_that.locked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordEntryType type,  RecordCopyKey titleKey,  IconData icon,  Color accent,  bool selected,  bool locked)?  $default,) {final _that = this;
switch (_that) {
case _RecordFilter() when $default != null:
return $default(_that.type,_that.titleKey,_that.icon,_that.accent,_that.selected,_that.locked);case _:
  return null;

}
}

}

/// @nodoc


class _RecordFilter implements RecordFilter {
  const _RecordFilter({required this.type, required this.titleKey, required this.icon, required this.accent, required this.selected, this.locked = false});
  

@override final  RecordEntryType type;
@override final  RecordCopyKey titleKey;
@override final  IconData icon;
@override final  Color accent;
@override final  bool selected;
@override@JsonKey() final  bool locked;

/// Create a copy of RecordFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordFilterCopyWith<_RecordFilter> get copyWith => __$RecordFilterCopyWithImpl<_RecordFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordFilter&&(identical(other.type, type) || other.type == type)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.locked, locked) || other.locked == locked));
}


@override
int get hashCode => Object.hash(runtimeType,type,titleKey,icon,accent,selected,locked);

@override
String toString() {
  return 'RecordFilter(type: $type, titleKey: $titleKey, icon: $icon, accent: $accent, selected: $selected, locked: $locked)';
}


}

/// @nodoc
abstract mixin class _$RecordFilterCopyWith<$Res> implements $RecordFilterCopyWith<$Res> {
  factory _$RecordFilterCopyWith(_RecordFilter value, $Res Function(_RecordFilter) _then) = __$RecordFilterCopyWithImpl;
@override @useResult
$Res call({
 RecordEntryType type, RecordCopyKey titleKey, IconData icon, Color accent, bool selected, bool locked
});




}
/// @nodoc
class __$RecordFilterCopyWithImpl<$Res>
    implements _$RecordFilterCopyWith<$Res> {
  __$RecordFilterCopyWithImpl(this._self, this._then);

  final _RecordFilter _self;
  final $Res Function(_RecordFilter) _then;

/// Create a copy of RecordFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? titleKey = null,Object? icon = null,Object? accent = null,Object? selected = null,Object? locked = null,}) {
  return _then(_RecordFilter(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordEntryType,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RecordTimelineEntry {

 String get time; RecordEntryType get type; IconData get icon; Color get accent; Color get softColor; RecordCopyKey get titleKey; String? get value; RecordCopyKey? get valueKey; RecordCopyKey? get unitKey; RecordCopyKey? get detailKey; RecordCopyKey? get badgeKey; RecordCopyKey? get imagePlaceholderKey; String? get imageUrl; IconData? get trailingIcon;/// When non-null, the view should use this raw string instead of resolving
/// [titleKey] through [recordCopy].
 String? get rawTitle;/// When non-null, this timeline entry represents a real daily record
/// that can be edited or deleted via the daily-record API.
 String? get recordId;
/// Create a copy of RecordTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordTimelineEntryCopyWith<RecordTimelineEntry> get copyWith => _$RecordTimelineEntryCopyWithImpl<RecordTimelineEntry>(this as RecordTimelineEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordTimelineEntry&&(identical(other.time, time) || other.time == time)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.softColor, softColor) || other.softColor == softColor)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.value, value) || other.value == value)&&(identical(other.valueKey, valueKey) || other.valueKey == valueKey)&&(identical(other.unitKey, unitKey) || other.unitKey == unitKey)&&(identical(other.detailKey, detailKey) || other.detailKey == detailKey)&&(identical(other.badgeKey, badgeKey) || other.badgeKey == badgeKey)&&(identical(other.imagePlaceholderKey, imagePlaceholderKey) || other.imagePlaceholderKey == imagePlaceholderKey)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.trailingIcon, trailingIcon) || other.trailingIcon == trailingIcon)&&(identical(other.rawTitle, rawTitle) || other.rawTitle == rawTitle)&&(identical(other.recordId, recordId) || other.recordId == recordId));
}


@override
int get hashCode => Object.hash(runtimeType,time,type,icon,accent,softColor,titleKey,value,valueKey,unitKey,detailKey,badgeKey,imagePlaceholderKey,imageUrl,trailingIcon,rawTitle,recordId);

@override
String toString() {
  return 'RecordTimelineEntry(time: $time, type: $type, icon: $icon, accent: $accent, softColor: $softColor, titleKey: $titleKey, value: $value, valueKey: $valueKey, unitKey: $unitKey, detailKey: $detailKey, badgeKey: $badgeKey, imagePlaceholderKey: $imagePlaceholderKey, imageUrl: $imageUrl, trailingIcon: $trailingIcon, rawTitle: $rawTitle, recordId: $recordId)';
}


}

/// @nodoc
abstract mixin class $RecordTimelineEntryCopyWith<$Res>  {
  factory $RecordTimelineEntryCopyWith(RecordTimelineEntry value, $Res Function(RecordTimelineEntry) _then) = _$RecordTimelineEntryCopyWithImpl;
@useResult
$Res call({
 String time, RecordEntryType type, IconData icon, Color accent, Color softColor, RecordCopyKey titleKey, String? value, RecordCopyKey? valueKey, RecordCopyKey? unitKey, RecordCopyKey? detailKey, RecordCopyKey? badgeKey, RecordCopyKey? imagePlaceholderKey, String? imageUrl, IconData? trailingIcon, String? rawTitle, String? recordId
});




}
/// @nodoc
class _$RecordTimelineEntryCopyWithImpl<$Res>
    implements $RecordTimelineEntryCopyWith<$Res> {
  _$RecordTimelineEntryCopyWithImpl(this._self, this._then);

  final RecordTimelineEntry _self;
  final $Res Function(RecordTimelineEntry) _then;

/// Create a copy of RecordTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? type = null,Object? icon = null,Object? accent = null,Object? softColor = null,Object? titleKey = null,Object? value = freezed,Object? valueKey = freezed,Object? unitKey = freezed,Object? detailKey = freezed,Object? badgeKey = freezed,Object? imagePlaceholderKey = freezed,Object? imageUrl = freezed,Object? trailingIcon = freezed,Object? rawTitle = freezed,Object? recordId = freezed,}) {
  return _then(_self.copyWith(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordEntryType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,valueKey: freezed == valueKey ? _self.valueKey : valueKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,unitKey: freezed == unitKey ? _self.unitKey : unitKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,detailKey: freezed == detailKey ? _self.detailKey : detailKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,badgeKey: freezed == badgeKey ? _self.badgeKey : badgeKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,imagePlaceholderKey: freezed == imagePlaceholderKey ? _self.imagePlaceholderKey : imagePlaceholderKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,trailingIcon: freezed == trailingIcon ? _self.trailingIcon : trailingIcon // ignore: cast_nullable_to_non_nullable
as IconData?,rawTitle: freezed == rawTitle ? _self.rawTitle : rawTitle // ignore: cast_nullable_to_non_nullable
as String?,recordId: freezed == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordTimelineEntry].
extension RecordTimelineEntryPatterns on RecordTimelineEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordTimelineEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordTimelineEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordTimelineEntry value)  $default,){
final _that = this;
switch (_that) {
case _RecordTimelineEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordTimelineEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RecordTimelineEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String time,  RecordEntryType type,  IconData icon,  Color accent,  Color softColor,  RecordCopyKey titleKey,  String? value,  RecordCopyKey? valueKey,  RecordCopyKey? unitKey,  RecordCopyKey? detailKey,  RecordCopyKey? badgeKey,  RecordCopyKey? imagePlaceholderKey,  String? imageUrl,  IconData? trailingIcon,  String? rawTitle,  String? recordId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordTimelineEntry() when $default != null:
return $default(_that.time,_that.type,_that.icon,_that.accent,_that.softColor,_that.titleKey,_that.value,_that.valueKey,_that.unitKey,_that.detailKey,_that.badgeKey,_that.imagePlaceholderKey,_that.imageUrl,_that.trailingIcon,_that.rawTitle,_that.recordId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String time,  RecordEntryType type,  IconData icon,  Color accent,  Color softColor,  RecordCopyKey titleKey,  String? value,  RecordCopyKey? valueKey,  RecordCopyKey? unitKey,  RecordCopyKey? detailKey,  RecordCopyKey? badgeKey,  RecordCopyKey? imagePlaceholderKey,  String? imageUrl,  IconData? trailingIcon,  String? rawTitle,  String? recordId)  $default,) {final _that = this;
switch (_that) {
case _RecordTimelineEntry():
return $default(_that.time,_that.type,_that.icon,_that.accent,_that.softColor,_that.titleKey,_that.value,_that.valueKey,_that.unitKey,_that.detailKey,_that.badgeKey,_that.imagePlaceholderKey,_that.imageUrl,_that.trailingIcon,_that.rawTitle,_that.recordId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String time,  RecordEntryType type,  IconData icon,  Color accent,  Color softColor,  RecordCopyKey titleKey,  String? value,  RecordCopyKey? valueKey,  RecordCopyKey? unitKey,  RecordCopyKey? detailKey,  RecordCopyKey? badgeKey,  RecordCopyKey? imagePlaceholderKey,  String? imageUrl,  IconData? trailingIcon,  String? rawTitle,  String? recordId)?  $default,) {final _that = this;
switch (_that) {
case _RecordTimelineEntry() when $default != null:
return $default(_that.time,_that.type,_that.icon,_that.accent,_that.softColor,_that.titleKey,_that.value,_that.valueKey,_that.unitKey,_that.detailKey,_that.badgeKey,_that.imagePlaceholderKey,_that.imageUrl,_that.trailingIcon,_that.rawTitle,_that.recordId);case _:
  return null;

}
}

}

/// @nodoc


class _RecordTimelineEntry implements RecordTimelineEntry {
  const _RecordTimelineEntry({required this.time, required this.type, required this.icon, required this.accent, required this.softColor, required this.titleKey, this.value, this.valueKey, this.unitKey, this.detailKey, this.badgeKey, this.imagePlaceholderKey, this.imageUrl, this.trailingIcon, this.rawTitle, this.recordId});
  

@override final  String time;
@override final  RecordEntryType type;
@override final  IconData icon;
@override final  Color accent;
@override final  Color softColor;
@override final  RecordCopyKey titleKey;
@override final  String? value;
@override final  RecordCopyKey? valueKey;
@override final  RecordCopyKey? unitKey;
@override final  RecordCopyKey? detailKey;
@override final  RecordCopyKey? badgeKey;
@override final  RecordCopyKey? imagePlaceholderKey;
@override final  String? imageUrl;
@override final  IconData? trailingIcon;
/// When non-null, the view should use this raw string instead of resolving
/// [titleKey] through [recordCopy].
@override final  String? rawTitle;
/// When non-null, this timeline entry represents a real daily record
/// that can be edited or deleted via the daily-record API.
@override final  String? recordId;

/// Create a copy of RecordTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordTimelineEntryCopyWith<_RecordTimelineEntry> get copyWith => __$RecordTimelineEntryCopyWithImpl<_RecordTimelineEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordTimelineEntry&&(identical(other.time, time) || other.time == time)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.softColor, softColor) || other.softColor == softColor)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.value, value) || other.value == value)&&(identical(other.valueKey, valueKey) || other.valueKey == valueKey)&&(identical(other.unitKey, unitKey) || other.unitKey == unitKey)&&(identical(other.detailKey, detailKey) || other.detailKey == detailKey)&&(identical(other.badgeKey, badgeKey) || other.badgeKey == badgeKey)&&(identical(other.imagePlaceholderKey, imagePlaceholderKey) || other.imagePlaceholderKey == imagePlaceholderKey)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.trailingIcon, trailingIcon) || other.trailingIcon == trailingIcon)&&(identical(other.rawTitle, rawTitle) || other.rawTitle == rawTitle)&&(identical(other.recordId, recordId) || other.recordId == recordId));
}


@override
int get hashCode => Object.hash(runtimeType,time,type,icon,accent,softColor,titleKey,value,valueKey,unitKey,detailKey,badgeKey,imagePlaceholderKey,imageUrl,trailingIcon,rawTitle,recordId);

@override
String toString() {
  return 'RecordTimelineEntry(time: $time, type: $type, icon: $icon, accent: $accent, softColor: $softColor, titleKey: $titleKey, value: $value, valueKey: $valueKey, unitKey: $unitKey, detailKey: $detailKey, badgeKey: $badgeKey, imagePlaceholderKey: $imagePlaceholderKey, imageUrl: $imageUrl, trailingIcon: $trailingIcon, rawTitle: $rawTitle, recordId: $recordId)';
}


}

/// @nodoc
abstract mixin class _$RecordTimelineEntryCopyWith<$Res> implements $RecordTimelineEntryCopyWith<$Res> {
  factory _$RecordTimelineEntryCopyWith(_RecordTimelineEntry value, $Res Function(_RecordTimelineEntry) _then) = __$RecordTimelineEntryCopyWithImpl;
@override @useResult
$Res call({
 String time, RecordEntryType type, IconData icon, Color accent, Color softColor, RecordCopyKey titleKey, String? value, RecordCopyKey? valueKey, RecordCopyKey? unitKey, RecordCopyKey? detailKey, RecordCopyKey? badgeKey, RecordCopyKey? imagePlaceholderKey, String? imageUrl, IconData? trailingIcon, String? rawTitle, String? recordId
});




}
/// @nodoc
class __$RecordTimelineEntryCopyWithImpl<$Res>
    implements _$RecordTimelineEntryCopyWith<$Res> {
  __$RecordTimelineEntryCopyWithImpl(this._self, this._then);

  final _RecordTimelineEntry _self;
  final $Res Function(_RecordTimelineEntry) _then;

/// Create a copy of RecordTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? type = null,Object? icon = null,Object? accent = null,Object? softColor = null,Object? titleKey = null,Object? value = freezed,Object? valueKey = freezed,Object? unitKey = freezed,Object? detailKey = freezed,Object? badgeKey = freezed,Object? imagePlaceholderKey = freezed,Object? imageUrl = freezed,Object? trailingIcon = freezed,Object? rawTitle = freezed,Object? recordId = freezed,}) {
  return _then(_RecordTimelineEntry(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordEntryType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color,softColor: null == softColor ? _self.softColor : softColor // ignore: cast_nullable_to_non_nullable
as Color,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,valueKey: freezed == valueKey ? _self.valueKey : valueKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,unitKey: freezed == unitKey ? _self.unitKey : unitKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,detailKey: freezed == detailKey ? _self.detailKey : detailKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,badgeKey: freezed == badgeKey ? _self.badgeKey : badgeKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,imagePlaceholderKey: freezed == imagePlaceholderKey ? _self.imagePlaceholderKey : imagePlaceholderKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,trailingIcon: freezed == trailingIcon ? _self.trailingIcon : trailingIcon // ignore: cast_nullable_to_non_nullable
as IconData?,rawTitle: freezed == rawTitle ? _self.rawTitle : rawTitle // ignore: cast_nullable_to_non_nullable
as String?,recordId: freezed == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$RecordTrend {

 RecordTrendKind get kind; RecordCopyKey get titleKey; RecordCopyKey get rangeKey; Color get color; List<double> get points; Color? get secondaryColor; List<double> get secondaryPoints; List<double> get bars; RecordCopyKey? get legendKey; RecordCopyKey? get secondaryLegendKey;
/// Create a copy of RecordTrend
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordTrendCopyWith<RecordTrend> get copyWith => _$RecordTrendCopyWithImpl<RecordTrend>(this as RecordTrend, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordTrend&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.rangeKey, rangeKey) || other.rangeKey == rangeKey)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&const DeepCollectionEquality().equals(other.secondaryPoints, secondaryPoints)&&const DeepCollectionEquality().equals(other.bars, bars)&&(identical(other.legendKey, legendKey) || other.legendKey == legendKey)&&(identical(other.secondaryLegendKey, secondaryLegendKey) || other.secondaryLegendKey == secondaryLegendKey));
}


@override
int get hashCode => Object.hash(runtimeType,kind,titleKey,rangeKey,color,const DeepCollectionEquality().hash(points),secondaryColor,const DeepCollectionEquality().hash(secondaryPoints),const DeepCollectionEquality().hash(bars),legendKey,secondaryLegendKey);

@override
String toString() {
  return 'RecordTrend(kind: $kind, titleKey: $titleKey, rangeKey: $rangeKey, color: $color, points: $points, secondaryColor: $secondaryColor, secondaryPoints: $secondaryPoints, bars: $bars, legendKey: $legendKey, secondaryLegendKey: $secondaryLegendKey)';
}


}

/// @nodoc
abstract mixin class $RecordTrendCopyWith<$Res>  {
  factory $RecordTrendCopyWith(RecordTrend value, $Res Function(RecordTrend) _then) = _$RecordTrendCopyWithImpl;
@useResult
$Res call({
 RecordTrendKind kind, RecordCopyKey titleKey, RecordCopyKey rangeKey, Color color, List<double> points, Color? secondaryColor, List<double> secondaryPoints, List<double> bars, RecordCopyKey? legendKey, RecordCopyKey? secondaryLegendKey
});




}
/// @nodoc
class _$RecordTrendCopyWithImpl<$Res>
    implements $RecordTrendCopyWith<$Res> {
  _$RecordTrendCopyWithImpl(this._self, this._then);

  final RecordTrend _self;
  final $Res Function(RecordTrend) _then;

/// Create a copy of RecordTrend
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? titleKey = null,Object? rangeKey = null,Object? color = null,Object? points = null,Object? secondaryColor = freezed,Object? secondaryPoints = null,Object? bars = null,Object? legendKey = freezed,Object? secondaryLegendKey = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as RecordTrendKind,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,rangeKey: null == rangeKey ? _self.rangeKey : rangeKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<double>,secondaryColor: freezed == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as Color?,secondaryPoints: null == secondaryPoints ? _self.secondaryPoints : secondaryPoints // ignore: cast_nullable_to_non_nullable
as List<double>,bars: null == bars ? _self.bars : bars // ignore: cast_nullable_to_non_nullable
as List<double>,legendKey: freezed == legendKey ? _self.legendKey : legendKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,secondaryLegendKey: freezed == secondaryLegendKey ? _self.secondaryLegendKey : secondaryLegendKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordTrend].
extension RecordTrendPatterns on RecordTrend {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordTrend value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordTrend() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordTrend value)  $default,){
final _that = this;
switch (_that) {
case _RecordTrend():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordTrend value)?  $default,){
final _that = this;
switch (_that) {
case _RecordTrend() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordTrendKind kind,  RecordCopyKey titleKey,  RecordCopyKey rangeKey,  Color color,  List<double> points,  Color? secondaryColor,  List<double> secondaryPoints,  List<double> bars,  RecordCopyKey? legendKey,  RecordCopyKey? secondaryLegendKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordTrend() when $default != null:
return $default(_that.kind,_that.titleKey,_that.rangeKey,_that.color,_that.points,_that.secondaryColor,_that.secondaryPoints,_that.bars,_that.legendKey,_that.secondaryLegendKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordTrendKind kind,  RecordCopyKey titleKey,  RecordCopyKey rangeKey,  Color color,  List<double> points,  Color? secondaryColor,  List<double> secondaryPoints,  List<double> bars,  RecordCopyKey? legendKey,  RecordCopyKey? secondaryLegendKey)  $default,) {final _that = this;
switch (_that) {
case _RecordTrend():
return $default(_that.kind,_that.titleKey,_that.rangeKey,_that.color,_that.points,_that.secondaryColor,_that.secondaryPoints,_that.bars,_that.legendKey,_that.secondaryLegendKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordTrendKind kind,  RecordCopyKey titleKey,  RecordCopyKey rangeKey,  Color color,  List<double> points,  Color? secondaryColor,  List<double> secondaryPoints,  List<double> bars,  RecordCopyKey? legendKey,  RecordCopyKey? secondaryLegendKey)?  $default,) {final _that = this;
switch (_that) {
case _RecordTrend() when $default != null:
return $default(_that.kind,_that.titleKey,_that.rangeKey,_that.color,_that.points,_that.secondaryColor,_that.secondaryPoints,_that.bars,_that.legendKey,_that.secondaryLegendKey);case _:
  return null;

}
}

}

/// @nodoc


class _RecordTrend implements RecordTrend {
  const _RecordTrend({required this.kind, required this.titleKey, required this.rangeKey, required this.color, required final  List<double> points, this.secondaryColor, final  List<double> secondaryPoints = const [], final  List<double> bars = const [], this.legendKey, this.secondaryLegendKey}): _points = points,_secondaryPoints = secondaryPoints,_bars = bars;
  

@override final  RecordTrendKind kind;
@override final  RecordCopyKey titleKey;
@override final  RecordCopyKey rangeKey;
@override final  Color color;
 final  List<double> _points;
@override List<double> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  Color? secondaryColor;
 final  List<double> _secondaryPoints;
@override@JsonKey() List<double> get secondaryPoints {
  if (_secondaryPoints is EqualUnmodifiableListView) return _secondaryPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryPoints);
}

 final  List<double> _bars;
@override@JsonKey() List<double> get bars {
  if (_bars is EqualUnmodifiableListView) return _bars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bars);
}

@override final  RecordCopyKey? legendKey;
@override final  RecordCopyKey? secondaryLegendKey;

/// Create a copy of RecordTrend
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordTrendCopyWith<_RecordTrend> get copyWith => __$RecordTrendCopyWithImpl<_RecordTrend>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordTrend&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.rangeKey, rangeKey) || other.rangeKey == rangeKey)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.secondaryColor, secondaryColor) || other.secondaryColor == secondaryColor)&&const DeepCollectionEquality().equals(other._secondaryPoints, _secondaryPoints)&&const DeepCollectionEquality().equals(other._bars, _bars)&&(identical(other.legendKey, legendKey) || other.legendKey == legendKey)&&(identical(other.secondaryLegendKey, secondaryLegendKey) || other.secondaryLegendKey == secondaryLegendKey));
}


@override
int get hashCode => Object.hash(runtimeType,kind,titleKey,rangeKey,color,const DeepCollectionEquality().hash(_points),secondaryColor,const DeepCollectionEquality().hash(_secondaryPoints),const DeepCollectionEquality().hash(_bars),legendKey,secondaryLegendKey);

@override
String toString() {
  return 'RecordTrend(kind: $kind, titleKey: $titleKey, rangeKey: $rangeKey, color: $color, points: $points, secondaryColor: $secondaryColor, secondaryPoints: $secondaryPoints, bars: $bars, legendKey: $legendKey, secondaryLegendKey: $secondaryLegendKey)';
}


}

/// @nodoc
abstract mixin class _$RecordTrendCopyWith<$Res> implements $RecordTrendCopyWith<$Res> {
  factory _$RecordTrendCopyWith(_RecordTrend value, $Res Function(_RecordTrend) _then) = __$RecordTrendCopyWithImpl;
@override @useResult
$Res call({
 RecordTrendKind kind, RecordCopyKey titleKey, RecordCopyKey rangeKey, Color color, List<double> points, Color? secondaryColor, List<double> secondaryPoints, List<double> bars, RecordCopyKey? legendKey, RecordCopyKey? secondaryLegendKey
});




}
/// @nodoc
class __$RecordTrendCopyWithImpl<$Res>
    implements _$RecordTrendCopyWith<$Res> {
  __$RecordTrendCopyWithImpl(this._self, this._then);

  final _RecordTrend _self;
  final $Res Function(_RecordTrend) _then;

/// Create a copy of RecordTrend
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? titleKey = null,Object? rangeKey = null,Object? color = null,Object? points = null,Object? secondaryColor = freezed,Object? secondaryPoints = null,Object? bars = null,Object? legendKey = freezed,Object? secondaryLegendKey = freezed,}) {
  return _then(_RecordTrend(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as RecordTrendKind,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,rangeKey: null == rangeKey ? _self.rangeKey : rangeKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<double>,secondaryColor: freezed == secondaryColor ? _self.secondaryColor : secondaryColor // ignore: cast_nullable_to_non_nullable
as Color?,secondaryPoints: null == secondaryPoints ? _self._secondaryPoints : secondaryPoints // ignore: cast_nullable_to_non_nullable
as List<double>,bars: null == bars ? _self._bars : bars // ignore: cast_nullable_to_non_nullable
as List<double>,legendKey: freezed == legendKey ? _self.legendKey : legendKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,secondaryLegendKey: freezed == secondaryLegendKey ? _self.secondaryLegendKey : secondaryLegendKey // ignore: cast_nullable_to_non_nullable
as RecordCopyKey?,
  ));
}


}

// dart format on
