// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReportDashboard {

 ReportDashboardRange get range; String get startDate; String get endDate; ReportHealthScore get score; List<ReportMetric> get metrics; List<ReportTrendSeries> get trends; List<ReportFinding> get findings; List<ReportExportAction> get exportActions; List<ReportPatternCard> get patterns; bool get aiSummaryEnabled;
/// Create a copy of ReportDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDashboardCopyWith<ReportDashboard> get copyWith => _$ReportDashboardCopyWithImpl<ReportDashboard>(this as ReportDashboard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportDashboard&&(identical(other.range, range) || other.range == range)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.metrics, metrics)&&const DeepCollectionEquality().equals(other.trends, trends)&&const DeepCollectionEquality().equals(other.findings, findings)&&const DeepCollectionEquality().equals(other.exportActions, exportActions)&&const DeepCollectionEquality().equals(other.patterns, patterns)&&(identical(other.aiSummaryEnabled, aiSummaryEnabled) || other.aiSummaryEnabled == aiSummaryEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,range,startDate,endDate,score,const DeepCollectionEquality().hash(metrics),const DeepCollectionEquality().hash(trends),const DeepCollectionEquality().hash(findings),const DeepCollectionEquality().hash(exportActions),const DeepCollectionEquality().hash(patterns),aiSummaryEnabled);

@override
String toString() {
  return 'ReportDashboard(range: $range, startDate: $startDate, endDate: $endDate, score: $score, metrics: $metrics, trends: $trends, findings: $findings, exportActions: $exportActions, patterns: $patterns, aiSummaryEnabled: $aiSummaryEnabled)';
}


}

/// @nodoc
abstract mixin class $ReportDashboardCopyWith<$Res>  {
  factory $ReportDashboardCopyWith(ReportDashboard value, $Res Function(ReportDashboard) _then) = _$ReportDashboardCopyWithImpl;
@useResult
$Res call({
 ReportDashboardRange range, String startDate, String endDate, ReportHealthScore score, List<ReportMetric> metrics, List<ReportTrendSeries> trends, List<ReportFinding> findings, List<ReportExportAction> exportActions, List<ReportPatternCard> patterns, bool aiSummaryEnabled
});


$ReportHealthScoreCopyWith<$Res> get score;

}
/// @nodoc
class _$ReportDashboardCopyWithImpl<$Res>
    implements $ReportDashboardCopyWith<$Res> {
  _$ReportDashboardCopyWithImpl(this._self, this._then);

  final ReportDashboard _self;
  final $Res Function(ReportDashboard) _then;

/// Create a copy of ReportDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? range = null,Object? startDate = null,Object? endDate = null,Object? score = null,Object? metrics = null,Object? trends = null,Object? findings = null,Object? exportActions = null,Object? patterns = null,Object? aiSummaryEnabled = null,}) {
  return _then(_self.copyWith(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as ReportDashboardRange,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as ReportHealthScore,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as List<ReportMetric>,trends: null == trends ? _self.trends : trends // ignore: cast_nullable_to_non_nullable
as List<ReportTrendSeries>,findings: null == findings ? _self.findings : findings // ignore: cast_nullable_to_non_nullable
as List<ReportFinding>,exportActions: null == exportActions ? _self.exportActions : exportActions // ignore: cast_nullable_to_non_nullable
as List<ReportExportAction>,patterns: null == patterns ? _self.patterns : patterns // ignore: cast_nullable_to_non_nullable
as List<ReportPatternCard>,aiSummaryEnabled: null == aiSummaryEnabled ? _self.aiSummaryEnabled : aiSummaryEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ReportDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportHealthScoreCopyWith<$Res> get score {
  
  return $ReportHealthScoreCopyWith<$Res>(_self.score, (value) {
    return _then(_self.copyWith(score: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportDashboard].
extension ReportDashboardPatterns on ReportDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportDashboard value)  $default,){
final _that = this;
switch (_that) {
case _ReportDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _ReportDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReportDashboardRange range,  String startDate,  String endDate,  ReportHealthScore score,  List<ReportMetric> metrics,  List<ReportTrendSeries> trends,  List<ReportFinding> findings,  List<ReportExportAction> exportActions,  List<ReportPatternCard> patterns,  bool aiSummaryEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportDashboard() when $default != null:
return $default(_that.range,_that.startDate,_that.endDate,_that.score,_that.metrics,_that.trends,_that.findings,_that.exportActions,_that.patterns,_that.aiSummaryEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReportDashboardRange range,  String startDate,  String endDate,  ReportHealthScore score,  List<ReportMetric> metrics,  List<ReportTrendSeries> trends,  List<ReportFinding> findings,  List<ReportExportAction> exportActions,  List<ReportPatternCard> patterns,  bool aiSummaryEnabled)  $default,) {final _that = this;
switch (_that) {
case _ReportDashboard():
return $default(_that.range,_that.startDate,_that.endDate,_that.score,_that.metrics,_that.trends,_that.findings,_that.exportActions,_that.patterns,_that.aiSummaryEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReportDashboardRange range,  String startDate,  String endDate,  ReportHealthScore score,  List<ReportMetric> metrics,  List<ReportTrendSeries> trends,  List<ReportFinding> findings,  List<ReportExportAction> exportActions,  List<ReportPatternCard> patterns,  bool aiSummaryEnabled)?  $default,) {final _that = this;
switch (_that) {
case _ReportDashboard() when $default != null:
return $default(_that.range,_that.startDate,_that.endDate,_that.score,_that.metrics,_that.trends,_that.findings,_that.exportActions,_that.patterns,_that.aiSummaryEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _ReportDashboard implements ReportDashboard {
  const _ReportDashboard({required this.range, required this.startDate, required this.endDate, required this.score, required final  List<ReportMetric> metrics, required final  List<ReportTrendSeries> trends, required final  List<ReportFinding> findings, required final  List<ReportExportAction> exportActions, required final  List<ReportPatternCard> patterns, required this.aiSummaryEnabled}): _metrics = metrics,_trends = trends,_findings = findings,_exportActions = exportActions,_patterns = patterns;
  

@override final  ReportDashboardRange range;
@override final  String startDate;
@override final  String endDate;
@override final  ReportHealthScore score;
 final  List<ReportMetric> _metrics;
@override List<ReportMetric> get metrics {
  if (_metrics is EqualUnmodifiableListView) return _metrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_metrics);
}

 final  List<ReportTrendSeries> _trends;
@override List<ReportTrendSeries> get trends {
  if (_trends is EqualUnmodifiableListView) return _trends;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trends);
}

 final  List<ReportFinding> _findings;
@override List<ReportFinding> get findings {
  if (_findings is EqualUnmodifiableListView) return _findings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_findings);
}

 final  List<ReportExportAction> _exportActions;
@override List<ReportExportAction> get exportActions {
  if (_exportActions is EqualUnmodifiableListView) return _exportActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exportActions);
}

 final  List<ReportPatternCard> _patterns;
@override List<ReportPatternCard> get patterns {
  if (_patterns is EqualUnmodifiableListView) return _patterns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_patterns);
}

@override final  bool aiSummaryEnabled;

/// Create a copy of ReportDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDashboardCopyWith<_ReportDashboard> get copyWith => __$ReportDashboardCopyWithImpl<_ReportDashboard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportDashboard&&(identical(other.range, range) || other.range == range)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other._metrics, _metrics)&&const DeepCollectionEquality().equals(other._trends, _trends)&&const DeepCollectionEquality().equals(other._findings, _findings)&&const DeepCollectionEquality().equals(other._exportActions, _exportActions)&&const DeepCollectionEquality().equals(other._patterns, _patterns)&&(identical(other.aiSummaryEnabled, aiSummaryEnabled) || other.aiSummaryEnabled == aiSummaryEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,range,startDate,endDate,score,const DeepCollectionEquality().hash(_metrics),const DeepCollectionEquality().hash(_trends),const DeepCollectionEquality().hash(_findings),const DeepCollectionEquality().hash(_exportActions),const DeepCollectionEquality().hash(_patterns),aiSummaryEnabled);

@override
String toString() {
  return 'ReportDashboard(range: $range, startDate: $startDate, endDate: $endDate, score: $score, metrics: $metrics, trends: $trends, findings: $findings, exportActions: $exportActions, patterns: $patterns, aiSummaryEnabled: $aiSummaryEnabled)';
}


}

/// @nodoc
abstract mixin class _$ReportDashboardCopyWith<$Res> implements $ReportDashboardCopyWith<$Res> {
  factory _$ReportDashboardCopyWith(_ReportDashboard value, $Res Function(_ReportDashboard) _then) = __$ReportDashboardCopyWithImpl;
@override @useResult
$Res call({
 ReportDashboardRange range, String startDate, String endDate, ReportHealthScore score, List<ReportMetric> metrics, List<ReportTrendSeries> trends, List<ReportFinding> findings, List<ReportExportAction> exportActions, List<ReportPatternCard> patterns, bool aiSummaryEnabled
});


@override $ReportHealthScoreCopyWith<$Res> get score;

}
/// @nodoc
class __$ReportDashboardCopyWithImpl<$Res>
    implements _$ReportDashboardCopyWith<$Res> {
  __$ReportDashboardCopyWithImpl(this._self, this._then);

  final _ReportDashboard _self;
  final $Res Function(_ReportDashboard) _then;

/// Create a copy of ReportDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? range = null,Object? startDate = null,Object? endDate = null,Object? score = null,Object? metrics = null,Object? trends = null,Object? findings = null,Object? exportActions = null,Object? patterns = null,Object? aiSummaryEnabled = null,}) {
  return _then(_ReportDashboard(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as ReportDashboardRange,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as ReportHealthScore,metrics: null == metrics ? _self._metrics : metrics // ignore: cast_nullable_to_non_nullable
as List<ReportMetric>,trends: null == trends ? _self._trends : trends // ignore: cast_nullable_to_non_nullable
as List<ReportTrendSeries>,findings: null == findings ? _self._findings : findings // ignore: cast_nullable_to_non_nullable
as List<ReportFinding>,exportActions: null == exportActions ? _self._exportActions : exportActions // ignore: cast_nullable_to_non_nullable
as List<ReportExportAction>,patterns: null == patterns ? _self._patterns : patterns // ignore: cast_nullable_to_non_nullable
as List<ReportPatternCard>,aiSummaryEnabled: null == aiSummaryEnabled ? _self.aiSummaryEnabled : aiSummaryEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ReportDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportHealthScoreCopyWith<$Res> get score {
  
  return $ReportHealthScoreCopyWith<$Res>(_self.score, (value) {
    return _then(_self.copyWith(score: value));
  });
}
}

/// @nodoc
mixin _$ReportHealthScore {

 int get value; int get maxValue; ReportStatus get status; String get summary;
/// Create a copy of ReportHealthScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportHealthScoreCopyWith<ReportHealthScore> get copyWith => _$ReportHealthScoreCopyWithImpl<ReportHealthScore>(this as ReportHealthScore, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportHealthScore&&(identical(other.value, value) || other.value == value)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&(identical(other.status, status) || other.status == status)&&(identical(other.summary, summary) || other.summary == summary));
}


@override
int get hashCode => Object.hash(runtimeType,value,maxValue,status,summary);

@override
String toString() {
  return 'ReportHealthScore(value: $value, maxValue: $maxValue, status: $status, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $ReportHealthScoreCopyWith<$Res>  {
  factory $ReportHealthScoreCopyWith(ReportHealthScore value, $Res Function(ReportHealthScore) _then) = _$ReportHealthScoreCopyWithImpl;
@useResult
$Res call({
 int value, int maxValue, ReportStatus status, String summary
});




}
/// @nodoc
class _$ReportHealthScoreCopyWithImpl<$Res>
    implements $ReportHealthScoreCopyWith<$Res> {
  _$ReportHealthScoreCopyWithImpl(this._self, this._then);

  final ReportHealthScore _self;
  final $Res Function(ReportHealthScore) _then;

/// Create a copy of ReportHealthScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? maxValue = null,Object? status = null,Object? summary = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,maxValue: null == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportHealthScore].
extension ReportHealthScorePatterns on ReportHealthScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportHealthScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportHealthScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportHealthScore value)  $default,){
final _that = this;
switch (_that) {
case _ReportHealthScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportHealthScore value)?  $default,){
final _that = this;
switch (_that) {
case _ReportHealthScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int value,  int maxValue,  ReportStatus status,  String summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportHealthScore() when $default != null:
return $default(_that.value,_that.maxValue,_that.status,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int value,  int maxValue,  ReportStatus status,  String summary)  $default,) {final _that = this;
switch (_that) {
case _ReportHealthScore():
return $default(_that.value,_that.maxValue,_that.status,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int value,  int maxValue,  ReportStatus status,  String summary)?  $default,) {final _that = this;
switch (_that) {
case _ReportHealthScore() when $default != null:
return $default(_that.value,_that.maxValue,_that.status,_that.summary);case _:
  return null;

}
}

}

/// @nodoc


class _ReportHealthScore implements ReportHealthScore {
  const _ReportHealthScore({required this.value, required this.maxValue, required this.status, required this.summary});
  

@override final  int value;
@override final  int maxValue;
@override final  ReportStatus status;
@override final  String summary;

/// Create a copy of ReportHealthScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportHealthScoreCopyWith<_ReportHealthScore> get copyWith => __$ReportHealthScoreCopyWithImpl<_ReportHealthScore>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportHealthScore&&(identical(other.value, value) || other.value == value)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&(identical(other.status, status) || other.status == status)&&(identical(other.summary, summary) || other.summary == summary));
}


@override
int get hashCode => Object.hash(runtimeType,value,maxValue,status,summary);

@override
String toString() {
  return 'ReportHealthScore(value: $value, maxValue: $maxValue, status: $status, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$ReportHealthScoreCopyWith<$Res> implements $ReportHealthScoreCopyWith<$Res> {
  factory _$ReportHealthScoreCopyWith(_ReportHealthScore value, $Res Function(_ReportHealthScore) _then) = __$ReportHealthScoreCopyWithImpl;
@override @useResult
$Res call({
 int value, int maxValue, ReportStatus status, String summary
});




}
/// @nodoc
class __$ReportHealthScoreCopyWithImpl<$Res>
    implements _$ReportHealthScoreCopyWith<$Res> {
  __$ReportHealthScoreCopyWithImpl(this._self, this._then);

  final _ReportHealthScore _self;
  final $Res Function(_ReportHealthScore) _then;

/// Create a copy of ReportHealthScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? maxValue = null,Object? status = null,Object? summary = null,}) {
  return _then(_ReportHealthScore(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,maxValue: null == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ReportMetric {

 ReportDataKind get kind; IconData get icon; Color get color; String get value; String get unit; ReportStatus get status; String get delta; ReportMetricDirection get direction; List<double> get sparkline;
/// Create a copy of ReportMetric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportMetricCopyWith<ReportMetric> get copyWith => _$ReportMetricCopyWithImpl<ReportMetric>(this as ReportMetric, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportMetric&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.status, status) || other.status == status)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.direction, direction) || other.direction == direction)&&const DeepCollectionEquality().equals(other.sparkline, sparkline));
}


@override
int get hashCode => Object.hash(runtimeType,kind,icon,color,value,unit,status,delta,direction,const DeepCollectionEquality().hash(sparkline));

@override
String toString() {
  return 'ReportMetric(kind: $kind, icon: $icon, color: $color, value: $value, unit: $unit, status: $status, delta: $delta, direction: $direction, sparkline: $sparkline)';
}


}

/// @nodoc
abstract mixin class $ReportMetricCopyWith<$Res>  {
  factory $ReportMetricCopyWith(ReportMetric value, $Res Function(ReportMetric) _then) = _$ReportMetricCopyWithImpl;
@useResult
$Res call({
 ReportDataKind kind, IconData icon, Color color, String value, String unit, ReportStatus status, String delta, ReportMetricDirection direction, List<double> sparkline
});




}
/// @nodoc
class _$ReportMetricCopyWithImpl<$Res>
    implements $ReportMetricCopyWith<$Res> {
  _$ReportMetricCopyWithImpl(this._self, this._then);

  final ReportMetric _self;
  final $Res Function(ReportMetric) _then;

/// Create a copy of ReportMetric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? icon = null,Object? color = null,Object? value = null,Object? unit = null,Object? status = null,Object? delta = null,Object? direction = null,Object? sparkline = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportDataKind,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as ReportMetricDirection,sparkline: null == sparkline ? _self.sparkline : sparkline // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportMetric].
extension ReportMetricPatterns on ReportMetric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportMetric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportMetric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportMetric value)  $default,){
final _that = this;
switch (_that) {
case _ReportMetric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportMetric value)?  $default,){
final _that = this;
switch (_that) {
case _ReportMetric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReportDataKind kind,  IconData icon,  Color color,  String value,  String unit,  ReportStatus status,  String delta,  ReportMetricDirection direction,  List<double> sparkline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportMetric() when $default != null:
return $default(_that.kind,_that.icon,_that.color,_that.value,_that.unit,_that.status,_that.delta,_that.direction,_that.sparkline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReportDataKind kind,  IconData icon,  Color color,  String value,  String unit,  ReportStatus status,  String delta,  ReportMetricDirection direction,  List<double> sparkline)  $default,) {final _that = this;
switch (_that) {
case _ReportMetric():
return $default(_that.kind,_that.icon,_that.color,_that.value,_that.unit,_that.status,_that.delta,_that.direction,_that.sparkline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReportDataKind kind,  IconData icon,  Color color,  String value,  String unit,  ReportStatus status,  String delta,  ReportMetricDirection direction,  List<double> sparkline)?  $default,) {final _that = this;
switch (_that) {
case _ReportMetric() when $default != null:
return $default(_that.kind,_that.icon,_that.color,_that.value,_that.unit,_that.status,_that.delta,_that.direction,_that.sparkline);case _:
  return null;

}
}

}

/// @nodoc


class _ReportMetric implements ReportMetric {
  const _ReportMetric({required this.kind, required this.icon, required this.color, required this.value, required this.unit, required this.status, required this.delta, required this.direction, required final  List<double> sparkline}): _sparkline = sparkline;
  

@override final  ReportDataKind kind;
@override final  IconData icon;
@override final  Color color;
@override final  String value;
@override final  String unit;
@override final  ReportStatus status;
@override final  String delta;
@override final  ReportMetricDirection direction;
 final  List<double> _sparkline;
@override List<double> get sparkline {
  if (_sparkline is EqualUnmodifiableListView) return _sparkline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sparkline);
}


/// Create a copy of ReportMetric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportMetricCopyWith<_ReportMetric> get copyWith => __$ReportMetricCopyWithImpl<_ReportMetric>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportMetric&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.status, status) || other.status == status)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.direction, direction) || other.direction == direction)&&const DeepCollectionEquality().equals(other._sparkline, _sparkline));
}


@override
int get hashCode => Object.hash(runtimeType,kind,icon,color,value,unit,status,delta,direction,const DeepCollectionEquality().hash(_sparkline));

@override
String toString() {
  return 'ReportMetric(kind: $kind, icon: $icon, color: $color, value: $value, unit: $unit, status: $status, delta: $delta, direction: $direction, sparkline: $sparkline)';
}


}

/// @nodoc
abstract mixin class _$ReportMetricCopyWith<$Res> implements $ReportMetricCopyWith<$Res> {
  factory _$ReportMetricCopyWith(_ReportMetric value, $Res Function(_ReportMetric) _then) = __$ReportMetricCopyWithImpl;
@override @useResult
$Res call({
 ReportDataKind kind, IconData icon, Color color, String value, String unit, ReportStatus status, String delta, ReportMetricDirection direction, List<double> sparkline
});




}
/// @nodoc
class __$ReportMetricCopyWithImpl<$Res>
    implements _$ReportMetricCopyWith<$Res> {
  __$ReportMetricCopyWithImpl(this._self, this._then);

  final _ReportMetric _self;
  final $Res Function(_ReportMetric) _then;

/// Create a copy of ReportMetric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? icon = null,Object? color = null,Object? value = null,Object? unit = null,Object? status = null,Object? delta = null,Object? direction = null,Object? sparkline = null,}) {
  return _then(_ReportMetric(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportDataKind,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as ReportMetricDirection,sparkline: null == sparkline ? _self._sparkline : sparkline // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

/// @nodoc
mixin _$ReportTrendSeries {

 ReportDataKind get kind; Color get color; String get unit; List<double> get values; String get currentValue;
/// Create a copy of ReportTrendSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportTrendSeriesCopyWith<ReportTrendSeries> get copyWith => _$ReportTrendSeriesCopyWithImpl<ReportTrendSeries>(this as ReportTrendSeries, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportTrendSeries&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.color, color) || other.color == color)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.values, values)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue));
}


@override
int get hashCode => Object.hash(runtimeType,kind,color,unit,const DeepCollectionEquality().hash(values),currentValue);

@override
String toString() {
  return 'ReportTrendSeries(kind: $kind, color: $color, unit: $unit, values: $values, currentValue: $currentValue)';
}


}

/// @nodoc
abstract mixin class $ReportTrendSeriesCopyWith<$Res>  {
  factory $ReportTrendSeriesCopyWith(ReportTrendSeries value, $Res Function(ReportTrendSeries) _then) = _$ReportTrendSeriesCopyWithImpl;
@useResult
$Res call({
 ReportDataKind kind, Color color, String unit, List<double> values, String currentValue
});




}
/// @nodoc
class _$ReportTrendSeriesCopyWithImpl<$Res>
    implements $ReportTrendSeriesCopyWith<$Res> {
  _$ReportTrendSeriesCopyWithImpl(this._self, this._then);

  final ReportTrendSeries _self;
  final $Res Function(ReportTrendSeries) _then;

/// Create a copy of ReportTrendSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? color = null,Object? unit = null,Object? values = null,Object? currentValue = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportDataKind,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<double>,currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportTrendSeries].
extension ReportTrendSeriesPatterns on ReportTrendSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportTrendSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportTrendSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportTrendSeries value)  $default,){
final _that = this;
switch (_that) {
case _ReportTrendSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportTrendSeries value)?  $default,){
final _that = this;
switch (_that) {
case _ReportTrendSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReportDataKind kind,  Color color,  String unit,  List<double> values,  String currentValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportTrendSeries() when $default != null:
return $default(_that.kind,_that.color,_that.unit,_that.values,_that.currentValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReportDataKind kind,  Color color,  String unit,  List<double> values,  String currentValue)  $default,) {final _that = this;
switch (_that) {
case _ReportTrendSeries():
return $default(_that.kind,_that.color,_that.unit,_that.values,_that.currentValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReportDataKind kind,  Color color,  String unit,  List<double> values,  String currentValue)?  $default,) {final _that = this;
switch (_that) {
case _ReportTrendSeries() when $default != null:
return $default(_that.kind,_that.color,_that.unit,_that.values,_that.currentValue);case _:
  return null;

}
}

}

/// @nodoc


class _ReportTrendSeries implements ReportTrendSeries {
  const _ReportTrendSeries({required this.kind, required this.color, required this.unit, required final  List<double> values, required this.currentValue}): _values = values;
  

@override final  ReportDataKind kind;
@override final  Color color;
@override final  String unit;
 final  List<double> _values;
@override List<double> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}

@override final  String currentValue;

/// Create a copy of ReportTrendSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportTrendSeriesCopyWith<_ReportTrendSeries> get copyWith => __$ReportTrendSeriesCopyWithImpl<_ReportTrendSeries>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportTrendSeries&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.color, color) || other.color == color)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other._values, _values)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue));
}


@override
int get hashCode => Object.hash(runtimeType,kind,color,unit,const DeepCollectionEquality().hash(_values),currentValue);

@override
String toString() {
  return 'ReportTrendSeries(kind: $kind, color: $color, unit: $unit, values: $values, currentValue: $currentValue)';
}


}

/// @nodoc
abstract mixin class _$ReportTrendSeriesCopyWith<$Res> implements $ReportTrendSeriesCopyWith<$Res> {
  factory _$ReportTrendSeriesCopyWith(_ReportTrendSeries value, $Res Function(_ReportTrendSeries) _then) = __$ReportTrendSeriesCopyWithImpl;
@override @useResult
$Res call({
 ReportDataKind kind, Color color, String unit, List<double> values, String currentValue
});




}
/// @nodoc
class __$ReportTrendSeriesCopyWithImpl<$Res>
    implements _$ReportTrendSeriesCopyWith<$Res> {
  __$ReportTrendSeriesCopyWithImpl(this._self, this._then);

  final _ReportTrendSeries _self;
  final $Res Function(_ReportTrendSeries) _then;

/// Create a copy of ReportTrendSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? color = null,Object? unit = null,Object? values = null,Object? currentValue = null,}) {
  return _then(_ReportTrendSeries(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportDataKind,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<double>,currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ReportFinding {

 ReportInsightKind get kind; IconData get icon; Color get color; String get title; String get body;
/// Create a copy of ReportFinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportFindingCopyWith<ReportFinding> get copyWith => _$ReportFindingCopyWithImpl<ReportFinding>(this as ReportFinding, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportFinding&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body));
}


@override
int get hashCode => Object.hash(runtimeType,kind,icon,color,title,body);

@override
String toString() {
  return 'ReportFinding(kind: $kind, icon: $icon, color: $color, title: $title, body: $body)';
}


}

/// @nodoc
abstract mixin class $ReportFindingCopyWith<$Res>  {
  factory $ReportFindingCopyWith(ReportFinding value, $Res Function(ReportFinding) _then) = _$ReportFindingCopyWithImpl;
@useResult
$Res call({
 ReportInsightKind kind, IconData icon, Color color, String title, String body
});




}
/// @nodoc
class _$ReportFindingCopyWithImpl<$Res>
    implements $ReportFindingCopyWith<$Res> {
  _$ReportFindingCopyWithImpl(this._self, this._then);

  final ReportFinding _self;
  final $Res Function(ReportFinding) _then;

/// Create a copy of ReportFinding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? icon = null,Object? color = null,Object? title = null,Object? body = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportInsightKind,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportFinding].
extension ReportFindingPatterns on ReportFinding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportFinding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportFinding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportFinding value)  $default,){
final _that = this;
switch (_that) {
case _ReportFinding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportFinding value)?  $default,){
final _that = this;
switch (_that) {
case _ReportFinding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReportInsightKind kind,  IconData icon,  Color color,  String title,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportFinding() when $default != null:
return $default(_that.kind,_that.icon,_that.color,_that.title,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReportInsightKind kind,  IconData icon,  Color color,  String title,  String body)  $default,) {final _that = this;
switch (_that) {
case _ReportFinding():
return $default(_that.kind,_that.icon,_that.color,_that.title,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReportInsightKind kind,  IconData icon,  Color color,  String title,  String body)?  $default,) {final _that = this;
switch (_that) {
case _ReportFinding() when $default != null:
return $default(_that.kind,_that.icon,_that.color,_that.title,_that.body);case _:
  return null;

}
}

}

/// @nodoc


class _ReportFinding implements ReportFinding {
  const _ReportFinding({required this.kind, required this.icon, required this.color, required this.title, required this.body});
  

@override final  ReportInsightKind kind;
@override final  IconData icon;
@override final  Color color;
@override final  String title;
@override final  String body;

/// Create a copy of ReportFinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportFindingCopyWith<_ReportFinding> get copyWith => __$ReportFindingCopyWithImpl<_ReportFinding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportFinding&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body));
}


@override
int get hashCode => Object.hash(runtimeType,kind,icon,color,title,body);

@override
String toString() {
  return 'ReportFinding(kind: $kind, icon: $icon, color: $color, title: $title, body: $body)';
}


}

/// @nodoc
abstract mixin class _$ReportFindingCopyWith<$Res> implements $ReportFindingCopyWith<$Res> {
  factory _$ReportFindingCopyWith(_ReportFinding value, $Res Function(_ReportFinding) _then) = __$ReportFindingCopyWithImpl;
@override @useResult
$Res call({
 ReportInsightKind kind, IconData icon, Color color, String title, String body
});




}
/// @nodoc
class __$ReportFindingCopyWithImpl<$Res>
    implements _$ReportFindingCopyWith<$Res> {
  __$ReportFindingCopyWithImpl(this._self, this._then);

  final _ReportFinding _self;
  final $Res Function(_ReportFinding) _then;

/// Create a copy of ReportFinding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? icon = null,Object? color = null,Object? title = null,Object? body = null,}) {
  return _then(_ReportFinding(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportInsightKind,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ReportExportAction {

 ReportExportKind get kind; IconData get icon; Color get color;
/// Create a copy of ReportExportAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportExportActionCopyWith<ReportExportAction> get copyWith => _$ReportExportActionCopyWithImpl<ReportExportAction>(this as ReportExportAction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportExportAction&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,kind,icon,color);

@override
String toString() {
  return 'ReportExportAction(kind: $kind, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $ReportExportActionCopyWith<$Res>  {
  factory $ReportExportActionCopyWith(ReportExportAction value, $Res Function(ReportExportAction) _then) = _$ReportExportActionCopyWithImpl;
@useResult
$Res call({
 ReportExportKind kind, IconData icon, Color color
});




}
/// @nodoc
class _$ReportExportActionCopyWithImpl<$Res>
    implements $ReportExportActionCopyWith<$Res> {
  _$ReportExportActionCopyWithImpl(this._self, this._then);

  final ReportExportAction _self;
  final $Res Function(ReportExportAction) _then;

/// Create a copy of ReportExportAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? icon = null,Object? color = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportExportKind,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportExportAction].
extension ReportExportActionPatterns on ReportExportAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportExportAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportExportAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportExportAction value)  $default,){
final _that = this;
switch (_that) {
case _ReportExportAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportExportAction value)?  $default,){
final _that = this;
switch (_that) {
case _ReportExportAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReportExportKind kind,  IconData icon,  Color color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportExportAction() when $default != null:
return $default(_that.kind,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReportExportKind kind,  IconData icon,  Color color)  $default,) {final _that = this;
switch (_that) {
case _ReportExportAction():
return $default(_that.kind,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReportExportKind kind,  IconData icon,  Color color)?  $default,) {final _that = this;
switch (_that) {
case _ReportExportAction() when $default != null:
return $default(_that.kind,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _ReportExportAction implements ReportExportAction {
  const _ReportExportAction({required this.kind, required this.icon, required this.color});
  

@override final  ReportExportKind kind;
@override final  IconData icon;
@override final  Color color;

/// Create a copy of ReportExportAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportExportActionCopyWith<_ReportExportAction> get copyWith => __$ReportExportActionCopyWithImpl<_ReportExportAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportExportAction&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,kind,icon,color);

@override
String toString() {
  return 'ReportExportAction(kind: $kind, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$ReportExportActionCopyWith<$Res> implements $ReportExportActionCopyWith<$Res> {
  factory _$ReportExportActionCopyWith(_ReportExportAction value, $Res Function(_ReportExportAction) _then) = __$ReportExportActionCopyWithImpl;
@override @useResult
$Res call({
 ReportExportKind kind, IconData icon, Color color
});




}
/// @nodoc
class __$ReportExportActionCopyWithImpl<$Res>
    implements _$ReportExportActionCopyWith<$Res> {
  __$ReportExportActionCopyWithImpl(this._self, this._then);

  final _ReportExportAction _self;
  final $Res Function(_ReportExportAction) _then;

/// Create a copy of ReportExportAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? icon = null,Object? color = null,}) {
  return _then(_ReportExportAction(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportExportKind,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

/// @nodoc
mixin _$ReportPatternCard {

 ReportInsightKind get kind; IconData get icon; Color get color; String get title; ReportStatus get status; String get body; List<double> get sparkline;
/// Create a copy of ReportPatternCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportPatternCardCopyWith<ReportPatternCard> get copyWith => _$ReportPatternCardCopyWithImpl<ReportPatternCard>(this as ReportPatternCard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportPatternCard&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.sparkline, sparkline));
}


@override
int get hashCode => Object.hash(runtimeType,kind,icon,color,title,status,body,const DeepCollectionEquality().hash(sparkline));

@override
String toString() {
  return 'ReportPatternCard(kind: $kind, icon: $icon, color: $color, title: $title, status: $status, body: $body, sparkline: $sparkline)';
}


}

/// @nodoc
abstract mixin class $ReportPatternCardCopyWith<$Res>  {
  factory $ReportPatternCardCopyWith(ReportPatternCard value, $Res Function(ReportPatternCard) _then) = _$ReportPatternCardCopyWithImpl;
@useResult
$Res call({
 ReportInsightKind kind, IconData icon, Color color, String title, ReportStatus status, String body, List<double> sparkline
});




}
/// @nodoc
class _$ReportPatternCardCopyWithImpl<$Res>
    implements $ReportPatternCardCopyWith<$Res> {
  _$ReportPatternCardCopyWithImpl(this._self, this._then);

  final ReportPatternCard _self;
  final $Res Function(ReportPatternCard) _then;

/// Create a copy of ReportPatternCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? icon = null,Object? color = null,Object? title = null,Object? status = null,Object? body = null,Object? sparkline = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportInsightKind,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sparkline: null == sparkline ? _self.sparkline : sparkline // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportPatternCard].
extension ReportPatternCardPatterns on ReportPatternCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportPatternCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportPatternCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportPatternCard value)  $default,){
final _that = this;
switch (_that) {
case _ReportPatternCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportPatternCard value)?  $default,){
final _that = this;
switch (_that) {
case _ReportPatternCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReportInsightKind kind,  IconData icon,  Color color,  String title,  ReportStatus status,  String body,  List<double> sparkline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportPatternCard() when $default != null:
return $default(_that.kind,_that.icon,_that.color,_that.title,_that.status,_that.body,_that.sparkline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReportInsightKind kind,  IconData icon,  Color color,  String title,  ReportStatus status,  String body,  List<double> sparkline)  $default,) {final _that = this;
switch (_that) {
case _ReportPatternCard():
return $default(_that.kind,_that.icon,_that.color,_that.title,_that.status,_that.body,_that.sparkline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReportInsightKind kind,  IconData icon,  Color color,  String title,  ReportStatus status,  String body,  List<double> sparkline)?  $default,) {final _that = this;
switch (_that) {
case _ReportPatternCard() when $default != null:
return $default(_that.kind,_that.icon,_that.color,_that.title,_that.status,_that.body,_that.sparkline);case _:
  return null;

}
}

}

/// @nodoc


class _ReportPatternCard implements ReportPatternCard {
  const _ReportPatternCard({required this.kind, required this.icon, required this.color, required this.title, required this.status, required this.body, required final  List<double> sparkline}): _sparkline = sparkline;
  

@override final  ReportInsightKind kind;
@override final  IconData icon;
@override final  Color color;
@override final  String title;
@override final  ReportStatus status;
@override final  String body;
 final  List<double> _sparkline;
@override List<double> get sparkline {
  if (_sparkline is EqualUnmodifiableListView) return _sparkline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sparkline);
}


/// Create a copy of ReportPatternCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportPatternCardCopyWith<_ReportPatternCard> get copyWith => __$ReportPatternCardCopyWithImpl<_ReportPatternCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportPatternCard&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other._sparkline, _sparkline));
}


@override
int get hashCode => Object.hash(runtimeType,kind,icon,color,title,status,body,const DeepCollectionEquality().hash(_sparkline));

@override
String toString() {
  return 'ReportPatternCard(kind: $kind, icon: $icon, color: $color, title: $title, status: $status, body: $body, sparkline: $sparkline)';
}


}

/// @nodoc
abstract mixin class _$ReportPatternCardCopyWith<$Res> implements $ReportPatternCardCopyWith<$Res> {
  factory _$ReportPatternCardCopyWith(_ReportPatternCard value, $Res Function(_ReportPatternCard) _then) = __$ReportPatternCardCopyWithImpl;
@override @useResult
$Res call({
 ReportInsightKind kind, IconData icon, Color color, String title, ReportStatus status, String body, List<double> sparkline
});




}
/// @nodoc
class __$ReportPatternCardCopyWithImpl<$Res>
    implements _$ReportPatternCardCopyWith<$Res> {
  __$ReportPatternCardCopyWithImpl(this._self, this._then);

  final _ReportPatternCard _self;
  final $Res Function(_ReportPatternCard) _then;

/// Create a copy of ReportPatternCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? icon = null,Object? color = null,Object? title = null,Object? status = null,Object? body = null,Object? sparkline = null,}) {
  return _then(_ReportPatternCard(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReportInsightKind,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sparkline: null == sparkline ? _self._sparkline : sparkline // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

// dart format on
