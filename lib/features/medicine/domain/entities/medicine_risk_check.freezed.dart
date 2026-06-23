// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medicine_risk_check.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicineRiskCheckResult {

 int get currentMedicineCount; int get checkedMedicineCount; List<MedicineRiskFinding> get findings; List<MedicineRiskCoverageIssue> get coverageIssues; String get coverageSummary;
/// Create a copy of MedicineRiskCheckResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineRiskCheckResultCopyWith<MedicineRiskCheckResult> get copyWith => _$MedicineRiskCheckResultCopyWithImpl<MedicineRiskCheckResult>(this as MedicineRiskCheckResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineRiskCheckResult&&(identical(other.currentMedicineCount, currentMedicineCount) || other.currentMedicineCount == currentMedicineCount)&&(identical(other.checkedMedicineCount, checkedMedicineCount) || other.checkedMedicineCount == checkedMedicineCount)&&const DeepCollectionEquality().equals(other.findings, findings)&&const DeepCollectionEquality().equals(other.coverageIssues, coverageIssues)&&(identical(other.coverageSummary, coverageSummary) || other.coverageSummary == coverageSummary));
}


@override
int get hashCode => Object.hash(runtimeType,currentMedicineCount,checkedMedicineCount,const DeepCollectionEquality().hash(findings),const DeepCollectionEquality().hash(coverageIssues),coverageSummary);

@override
String toString() {
  return 'MedicineRiskCheckResult(currentMedicineCount: $currentMedicineCount, checkedMedicineCount: $checkedMedicineCount, findings: $findings, coverageIssues: $coverageIssues, coverageSummary: $coverageSummary)';
}


}

/// @nodoc
abstract mixin class $MedicineRiskCheckResultCopyWith<$Res>  {
  factory $MedicineRiskCheckResultCopyWith(MedicineRiskCheckResult value, $Res Function(MedicineRiskCheckResult) _then) = _$MedicineRiskCheckResultCopyWithImpl;
@useResult
$Res call({
 int currentMedicineCount, int checkedMedicineCount, List<MedicineRiskFinding> findings, List<MedicineRiskCoverageIssue> coverageIssues, String coverageSummary
});




}
/// @nodoc
class _$MedicineRiskCheckResultCopyWithImpl<$Res>
    implements $MedicineRiskCheckResultCopyWith<$Res> {
  _$MedicineRiskCheckResultCopyWithImpl(this._self, this._then);

  final MedicineRiskCheckResult _self;
  final $Res Function(MedicineRiskCheckResult) _then;

/// Create a copy of MedicineRiskCheckResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentMedicineCount = null,Object? checkedMedicineCount = null,Object? findings = null,Object? coverageIssues = null,Object? coverageSummary = null,}) {
  return _then(_self.copyWith(
currentMedicineCount: null == currentMedicineCount ? _self.currentMedicineCount : currentMedicineCount // ignore: cast_nullable_to_non_nullable
as int,checkedMedicineCount: null == checkedMedicineCount ? _self.checkedMedicineCount : checkedMedicineCount // ignore: cast_nullable_to_non_nullable
as int,findings: null == findings ? _self.findings : findings // ignore: cast_nullable_to_non_nullable
as List<MedicineRiskFinding>,coverageIssues: null == coverageIssues ? _self.coverageIssues : coverageIssues // ignore: cast_nullable_to_non_nullable
as List<MedicineRiskCoverageIssue>,coverageSummary: null == coverageSummary ? _self.coverageSummary : coverageSummary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineRiskCheckResult].
extension MedicineRiskCheckResultPatterns on MedicineRiskCheckResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineRiskCheckResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineRiskCheckResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineRiskCheckResult value)  $default,){
final _that = this;
switch (_that) {
case _MedicineRiskCheckResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineRiskCheckResult value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineRiskCheckResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentMedicineCount,  int checkedMedicineCount,  List<MedicineRiskFinding> findings,  List<MedicineRiskCoverageIssue> coverageIssues,  String coverageSummary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineRiskCheckResult() when $default != null:
return $default(_that.currentMedicineCount,_that.checkedMedicineCount,_that.findings,_that.coverageIssues,_that.coverageSummary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentMedicineCount,  int checkedMedicineCount,  List<MedicineRiskFinding> findings,  List<MedicineRiskCoverageIssue> coverageIssues,  String coverageSummary)  $default,) {final _that = this;
switch (_that) {
case _MedicineRiskCheckResult():
return $default(_that.currentMedicineCount,_that.checkedMedicineCount,_that.findings,_that.coverageIssues,_that.coverageSummary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentMedicineCount,  int checkedMedicineCount,  List<MedicineRiskFinding> findings,  List<MedicineRiskCoverageIssue> coverageIssues,  String coverageSummary)?  $default,) {final _that = this;
switch (_that) {
case _MedicineRiskCheckResult() when $default != null:
return $default(_that.currentMedicineCount,_that.checkedMedicineCount,_that.findings,_that.coverageIssues,_that.coverageSummary);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineRiskCheckResult extends MedicineRiskCheckResult {
  const _MedicineRiskCheckResult({required this.currentMedicineCount, required this.checkedMedicineCount, required final  List<MedicineRiskFinding> findings, required final  List<MedicineRiskCoverageIssue> coverageIssues, this.coverageSummary = ''}): _findings = findings,_coverageIssues = coverageIssues,super._();
  

@override final  int currentMedicineCount;
@override final  int checkedMedicineCount;
 final  List<MedicineRiskFinding> _findings;
@override List<MedicineRiskFinding> get findings {
  if (_findings is EqualUnmodifiableListView) return _findings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_findings);
}

 final  List<MedicineRiskCoverageIssue> _coverageIssues;
@override List<MedicineRiskCoverageIssue> get coverageIssues {
  if (_coverageIssues is EqualUnmodifiableListView) return _coverageIssues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coverageIssues);
}

@override@JsonKey() final  String coverageSummary;

/// Create a copy of MedicineRiskCheckResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineRiskCheckResultCopyWith<_MedicineRiskCheckResult> get copyWith => __$MedicineRiskCheckResultCopyWithImpl<_MedicineRiskCheckResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineRiskCheckResult&&(identical(other.currentMedicineCount, currentMedicineCount) || other.currentMedicineCount == currentMedicineCount)&&(identical(other.checkedMedicineCount, checkedMedicineCount) || other.checkedMedicineCount == checkedMedicineCount)&&const DeepCollectionEquality().equals(other._findings, _findings)&&const DeepCollectionEquality().equals(other._coverageIssues, _coverageIssues)&&(identical(other.coverageSummary, coverageSummary) || other.coverageSummary == coverageSummary));
}


@override
int get hashCode => Object.hash(runtimeType,currentMedicineCount,checkedMedicineCount,const DeepCollectionEquality().hash(_findings),const DeepCollectionEquality().hash(_coverageIssues),coverageSummary);

@override
String toString() {
  return 'MedicineRiskCheckResult(currentMedicineCount: $currentMedicineCount, checkedMedicineCount: $checkedMedicineCount, findings: $findings, coverageIssues: $coverageIssues, coverageSummary: $coverageSummary)';
}


}

/// @nodoc
abstract mixin class _$MedicineRiskCheckResultCopyWith<$Res> implements $MedicineRiskCheckResultCopyWith<$Res> {
  factory _$MedicineRiskCheckResultCopyWith(_MedicineRiskCheckResult value, $Res Function(_MedicineRiskCheckResult) _then) = __$MedicineRiskCheckResultCopyWithImpl;
@override @useResult
$Res call({
 int currentMedicineCount, int checkedMedicineCount, List<MedicineRiskFinding> findings, List<MedicineRiskCoverageIssue> coverageIssues, String coverageSummary
});




}
/// @nodoc
class __$MedicineRiskCheckResultCopyWithImpl<$Res>
    implements _$MedicineRiskCheckResultCopyWith<$Res> {
  __$MedicineRiskCheckResultCopyWithImpl(this._self, this._then);

  final _MedicineRiskCheckResult _self;
  final $Res Function(_MedicineRiskCheckResult) _then;

/// Create a copy of MedicineRiskCheckResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentMedicineCount = null,Object? checkedMedicineCount = null,Object? findings = null,Object? coverageIssues = null,Object? coverageSummary = null,}) {
  return _then(_MedicineRiskCheckResult(
currentMedicineCount: null == currentMedicineCount ? _self.currentMedicineCount : currentMedicineCount // ignore: cast_nullable_to_non_nullable
as int,checkedMedicineCount: null == checkedMedicineCount ? _self.checkedMedicineCount : checkedMedicineCount // ignore: cast_nullable_to_non_nullable
as int,findings: null == findings ? _self._findings : findings // ignore: cast_nullable_to_non_nullable
as List<MedicineRiskFinding>,coverageIssues: null == coverageIssues ? _self._coverageIssues : coverageIssues // ignore: cast_nullable_to_non_nullable
as List<MedicineRiskCoverageIssue>,coverageSummary: null == coverageSummary ? _self.coverageSummary : coverageSummary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$MedicineRiskFinding {

 MedicineRiskFindingType get type; MedicineRiskSeverity get severity; MedicineRiskFindingContext get context; String get primaryMedicineName; String? get secondaryMedicineName; String? get relatedLabel; String? get evidence;/// Non-null only when [type] is [MedicineRiskFindingType.specialGroup]
/// and the source text was classified into a structured conclusion.
/// Carries the classified risk level for UI two-layer display
/// (conclusion label + evidence source text).
 SpecialPopulationConclusion? get specialPopulationConclusion;
/// Create a copy of MedicineRiskFinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineRiskFindingCopyWith<MedicineRiskFinding> get copyWith => _$MedicineRiskFindingCopyWithImpl<MedicineRiskFinding>(this as MedicineRiskFinding, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineRiskFinding&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.context, context) || other.context == context)&&(identical(other.primaryMedicineName, primaryMedicineName) || other.primaryMedicineName == primaryMedicineName)&&(identical(other.secondaryMedicineName, secondaryMedicineName) || other.secondaryMedicineName == secondaryMedicineName)&&(identical(other.relatedLabel, relatedLabel) || other.relatedLabel == relatedLabel)&&(identical(other.evidence, evidence) || other.evidence == evidence)&&(identical(other.specialPopulationConclusion, specialPopulationConclusion) || other.specialPopulationConclusion == specialPopulationConclusion));
}


@override
int get hashCode => Object.hash(runtimeType,type,severity,context,primaryMedicineName,secondaryMedicineName,relatedLabel,evidence,specialPopulationConclusion);

@override
String toString() {
  return 'MedicineRiskFinding(type: $type, severity: $severity, context: $context, primaryMedicineName: $primaryMedicineName, secondaryMedicineName: $secondaryMedicineName, relatedLabel: $relatedLabel, evidence: $evidence, specialPopulationConclusion: $specialPopulationConclusion)';
}


}

/// @nodoc
abstract mixin class $MedicineRiskFindingCopyWith<$Res>  {
  factory $MedicineRiskFindingCopyWith(MedicineRiskFinding value, $Res Function(MedicineRiskFinding) _then) = _$MedicineRiskFindingCopyWithImpl;
@useResult
$Res call({
 MedicineRiskFindingType type, MedicineRiskSeverity severity, MedicineRiskFindingContext context, String primaryMedicineName, String? secondaryMedicineName, String? relatedLabel, String? evidence, SpecialPopulationConclusion? specialPopulationConclusion
});




}
/// @nodoc
class _$MedicineRiskFindingCopyWithImpl<$Res>
    implements $MedicineRiskFindingCopyWith<$Res> {
  _$MedicineRiskFindingCopyWithImpl(this._self, this._then);

  final MedicineRiskFinding _self;
  final $Res Function(MedicineRiskFinding) _then;

/// Create a copy of MedicineRiskFinding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? severity = null,Object? context = null,Object? primaryMedicineName = null,Object? secondaryMedicineName = freezed,Object? relatedLabel = freezed,Object? evidence = freezed,Object? specialPopulationConclusion = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicineRiskFindingType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as MedicineRiskSeverity,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as MedicineRiskFindingContext,primaryMedicineName: null == primaryMedicineName ? _self.primaryMedicineName : primaryMedicineName // ignore: cast_nullable_to_non_nullable
as String,secondaryMedicineName: freezed == secondaryMedicineName ? _self.secondaryMedicineName : secondaryMedicineName // ignore: cast_nullable_to_non_nullable
as String?,relatedLabel: freezed == relatedLabel ? _self.relatedLabel : relatedLabel // ignore: cast_nullable_to_non_nullable
as String?,evidence: freezed == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as String?,specialPopulationConclusion: freezed == specialPopulationConclusion ? _self.specialPopulationConclusion : specialPopulationConclusion // ignore: cast_nullable_to_non_nullable
as SpecialPopulationConclusion?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineRiskFinding].
extension MedicineRiskFindingPatterns on MedicineRiskFinding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineRiskFinding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineRiskFinding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineRiskFinding value)  $default,){
final _that = this;
switch (_that) {
case _MedicineRiskFinding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineRiskFinding value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineRiskFinding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MedicineRiskFindingType type,  MedicineRiskSeverity severity,  MedicineRiskFindingContext context,  String primaryMedicineName,  String? secondaryMedicineName,  String? relatedLabel,  String? evidence,  SpecialPopulationConclusion? specialPopulationConclusion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineRiskFinding() when $default != null:
return $default(_that.type,_that.severity,_that.context,_that.primaryMedicineName,_that.secondaryMedicineName,_that.relatedLabel,_that.evidence,_that.specialPopulationConclusion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MedicineRiskFindingType type,  MedicineRiskSeverity severity,  MedicineRiskFindingContext context,  String primaryMedicineName,  String? secondaryMedicineName,  String? relatedLabel,  String? evidence,  SpecialPopulationConclusion? specialPopulationConclusion)  $default,) {final _that = this;
switch (_that) {
case _MedicineRiskFinding():
return $default(_that.type,_that.severity,_that.context,_that.primaryMedicineName,_that.secondaryMedicineName,_that.relatedLabel,_that.evidence,_that.specialPopulationConclusion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MedicineRiskFindingType type,  MedicineRiskSeverity severity,  MedicineRiskFindingContext context,  String primaryMedicineName,  String? secondaryMedicineName,  String? relatedLabel,  String? evidence,  SpecialPopulationConclusion? specialPopulationConclusion)?  $default,) {final _that = this;
switch (_that) {
case _MedicineRiskFinding() when $default != null:
return $default(_that.type,_that.severity,_that.context,_that.primaryMedicineName,_that.secondaryMedicineName,_that.relatedLabel,_that.evidence,_that.specialPopulationConclusion);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineRiskFinding implements MedicineRiskFinding {
  const _MedicineRiskFinding({required this.type, required this.severity, required this.context, required this.primaryMedicineName, this.secondaryMedicineName, this.relatedLabel, this.evidence, this.specialPopulationConclusion});
  

@override final  MedicineRiskFindingType type;
@override final  MedicineRiskSeverity severity;
@override final  MedicineRiskFindingContext context;
@override final  String primaryMedicineName;
@override final  String? secondaryMedicineName;
@override final  String? relatedLabel;
@override final  String? evidence;
/// Non-null only when [type] is [MedicineRiskFindingType.specialGroup]
/// and the source text was classified into a structured conclusion.
/// Carries the classified risk level for UI two-layer display
/// (conclusion label + evidence source text).
@override final  SpecialPopulationConclusion? specialPopulationConclusion;

/// Create a copy of MedicineRiskFinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineRiskFindingCopyWith<_MedicineRiskFinding> get copyWith => __$MedicineRiskFindingCopyWithImpl<_MedicineRiskFinding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineRiskFinding&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.context, context) || other.context == context)&&(identical(other.primaryMedicineName, primaryMedicineName) || other.primaryMedicineName == primaryMedicineName)&&(identical(other.secondaryMedicineName, secondaryMedicineName) || other.secondaryMedicineName == secondaryMedicineName)&&(identical(other.relatedLabel, relatedLabel) || other.relatedLabel == relatedLabel)&&(identical(other.evidence, evidence) || other.evidence == evidence)&&(identical(other.specialPopulationConclusion, specialPopulationConclusion) || other.specialPopulationConclusion == specialPopulationConclusion));
}


@override
int get hashCode => Object.hash(runtimeType,type,severity,context,primaryMedicineName,secondaryMedicineName,relatedLabel,evidence,specialPopulationConclusion);

@override
String toString() {
  return 'MedicineRiskFinding(type: $type, severity: $severity, context: $context, primaryMedicineName: $primaryMedicineName, secondaryMedicineName: $secondaryMedicineName, relatedLabel: $relatedLabel, evidence: $evidence, specialPopulationConclusion: $specialPopulationConclusion)';
}


}

/// @nodoc
abstract mixin class _$MedicineRiskFindingCopyWith<$Res> implements $MedicineRiskFindingCopyWith<$Res> {
  factory _$MedicineRiskFindingCopyWith(_MedicineRiskFinding value, $Res Function(_MedicineRiskFinding) _then) = __$MedicineRiskFindingCopyWithImpl;
@override @useResult
$Res call({
 MedicineRiskFindingType type, MedicineRiskSeverity severity, MedicineRiskFindingContext context, String primaryMedicineName, String? secondaryMedicineName, String? relatedLabel, String? evidence, SpecialPopulationConclusion? specialPopulationConclusion
});




}
/// @nodoc
class __$MedicineRiskFindingCopyWithImpl<$Res>
    implements _$MedicineRiskFindingCopyWith<$Res> {
  __$MedicineRiskFindingCopyWithImpl(this._self, this._then);

  final _MedicineRiskFinding _self;
  final $Res Function(_MedicineRiskFinding) _then;

/// Create a copy of MedicineRiskFinding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? severity = null,Object? context = null,Object? primaryMedicineName = null,Object? secondaryMedicineName = freezed,Object? relatedLabel = freezed,Object? evidence = freezed,Object? specialPopulationConclusion = freezed,}) {
  return _then(_MedicineRiskFinding(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicineRiskFindingType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as MedicineRiskSeverity,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as MedicineRiskFindingContext,primaryMedicineName: null == primaryMedicineName ? _self.primaryMedicineName : primaryMedicineName // ignore: cast_nullable_to_non_nullable
as String,secondaryMedicineName: freezed == secondaryMedicineName ? _self.secondaryMedicineName : secondaryMedicineName // ignore: cast_nullable_to_non_nullable
as String?,relatedLabel: freezed == relatedLabel ? _self.relatedLabel : relatedLabel // ignore: cast_nullable_to_non_nullable
as String?,evidence: freezed == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as String?,specialPopulationConclusion: freezed == specialPopulationConclusion ? _self.specialPopulationConclusion : specialPopulationConclusion // ignore: cast_nullable_to_non_nullable
as SpecialPopulationConclusion?,
  ));
}


}

/// @nodoc
mixin _$MedicineRiskCoverageIssue {

 String get medicineName; MedicineRiskCoverageReason get reason;
/// Create a copy of MedicineRiskCoverageIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineRiskCoverageIssueCopyWith<MedicineRiskCoverageIssue> get copyWith => _$MedicineRiskCoverageIssueCopyWithImpl<MedicineRiskCoverageIssue>(this as MedicineRiskCoverageIssue, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineRiskCoverageIssue&&(identical(other.medicineName, medicineName) || other.medicineName == medicineName)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,medicineName,reason);

@override
String toString() {
  return 'MedicineRiskCoverageIssue(medicineName: $medicineName, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $MedicineRiskCoverageIssueCopyWith<$Res>  {
  factory $MedicineRiskCoverageIssueCopyWith(MedicineRiskCoverageIssue value, $Res Function(MedicineRiskCoverageIssue) _then) = _$MedicineRiskCoverageIssueCopyWithImpl;
@useResult
$Res call({
 String medicineName, MedicineRiskCoverageReason reason
});




}
/// @nodoc
class _$MedicineRiskCoverageIssueCopyWithImpl<$Res>
    implements $MedicineRiskCoverageIssueCopyWith<$Res> {
  _$MedicineRiskCoverageIssueCopyWithImpl(this._self, this._then);

  final MedicineRiskCoverageIssue _self;
  final $Res Function(MedicineRiskCoverageIssue) _then;

/// Create a copy of MedicineRiskCoverageIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? medicineName = null,Object? reason = null,}) {
  return _then(_self.copyWith(
medicineName: null == medicineName ? _self.medicineName : medicineName // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as MedicineRiskCoverageReason,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineRiskCoverageIssue].
extension MedicineRiskCoverageIssuePatterns on MedicineRiskCoverageIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineRiskCoverageIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineRiskCoverageIssue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineRiskCoverageIssue value)  $default,){
final _that = this;
switch (_that) {
case _MedicineRiskCoverageIssue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineRiskCoverageIssue value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineRiskCoverageIssue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String medicineName,  MedicineRiskCoverageReason reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineRiskCoverageIssue() when $default != null:
return $default(_that.medicineName,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String medicineName,  MedicineRiskCoverageReason reason)  $default,) {final _that = this;
switch (_that) {
case _MedicineRiskCoverageIssue():
return $default(_that.medicineName,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String medicineName,  MedicineRiskCoverageReason reason)?  $default,) {final _that = this;
switch (_that) {
case _MedicineRiskCoverageIssue() when $default != null:
return $default(_that.medicineName,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _MedicineRiskCoverageIssue implements MedicineRiskCoverageIssue {
  const _MedicineRiskCoverageIssue({required this.medicineName, required this.reason});
  

@override final  String medicineName;
@override final  MedicineRiskCoverageReason reason;

/// Create a copy of MedicineRiskCoverageIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineRiskCoverageIssueCopyWith<_MedicineRiskCoverageIssue> get copyWith => __$MedicineRiskCoverageIssueCopyWithImpl<_MedicineRiskCoverageIssue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineRiskCoverageIssue&&(identical(other.medicineName, medicineName) || other.medicineName == medicineName)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,medicineName,reason);

@override
String toString() {
  return 'MedicineRiskCoverageIssue(medicineName: $medicineName, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$MedicineRiskCoverageIssueCopyWith<$Res> implements $MedicineRiskCoverageIssueCopyWith<$Res> {
  factory _$MedicineRiskCoverageIssueCopyWith(_MedicineRiskCoverageIssue value, $Res Function(_MedicineRiskCoverageIssue) _then) = __$MedicineRiskCoverageIssueCopyWithImpl;
@override @useResult
$Res call({
 String medicineName, MedicineRiskCoverageReason reason
});




}
/// @nodoc
class __$MedicineRiskCoverageIssueCopyWithImpl<$Res>
    implements _$MedicineRiskCoverageIssueCopyWith<$Res> {
  __$MedicineRiskCoverageIssueCopyWithImpl(this._self, this._then);

  final _MedicineRiskCoverageIssue _self;
  final $Res Function(_MedicineRiskCoverageIssue) _then;

/// Create a copy of MedicineRiskCoverageIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? medicineName = null,Object? reason = null,}) {
  return _then(_MedicineRiskCoverageIssue(
medicineName: null == medicineName ? _self.medicineName : medicineName // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as MedicineRiskCoverageReason,
  ));
}


}

/// @nodoc
mixin _$RedFlagAlert {

 RedFlagRule get rule; String get primaryMedicineName; String? get relatedLabel;/// Matches a support-resource id (e.g. 'campus-emergency', 'campus-hospital').
 String? get resourceId;
/// Create a copy of RedFlagAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RedFlagAlertCopyWith<RedFlagAlert> get copyWith => _$RedFlagAlertCopyWithImpl<RedFlagAlert>(this as RedFlagAlert, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RedFlagAlert&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.primaryMedicineName, primaryMedicineName) || other.primaryMedicineName == primaryMedicineName)&&(identical(other.relatedLabel, relatedLabel) || other.relatedLabel == relatedLabel)&&(identical(other.resourceId, resourceId) || other.resourceId == resourceId));
}


@override
int get hashCode => Object.hash(runtimeType,rule,primaryMedicineName,relatedLabel,resourceId);

@override
String toString() {
  return 'RedFlagAlert(rule: $rule, primaryMedicineName: $primaryMedicineName, relatedLabel: $relatedLabel, resourceId: $resourceId)';
}


}

/// @nodoc
abstract mixin class $RedFlagAlertCopyWith<$Res>  {
  factory $RedFlagAlertCopyWith(RedFlagAlert value, $Res Function(RedFlagAlert) _then) = _$RedFlagAlertCopyWithImpl;
@useResult
$Res call({
 RedFlagRule rule, String primaryMedicineName, String? relatedLabel, String? resourceId
});




}
/// @nodoc
class _$RedFlagAlertCopyWithImpl<$Res>
    implements $RedFlagAlertCopyWith<$Res> {
  _$RedFlagAlertCopyWithImpl(this._self, this._then);

  final RedFlagAlert _self;
  final $Res Function(RedFlagAlert) _then;

/// Create a copy of RedFlagAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rule = null,Object? primaryMedicineName = null,Object? relatedLabel = freezed,Object? resourceId = freezed,}) {
  return _then(_self.copyWith(
rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as RedFlagRule,primaryMedicineName: null == primaryMedicineName ? _self.primaryMedicineName : primaryMedicineName // ignore: cast_nullable_to_non_nullable
as String,relatedLabel: freezed == relatedLabel ? _self.relatedLabel : relatedLabel // ignore: cast_nullable_to_non_nullable
as String?,resourceId: freezed == resourceId ? _self.resourceId : resourceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RedFlagAlert].
extension RedFlagAlertPatterns on RedFlagAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RedFlagAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RedFlagAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RedFlagAlert value)  $default,){
final _that = this;
switch (_that) {
case _RedFlagAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RedFlagAlert value)?  $default,){
final _that = this;
switch (_that) {
case _RedFlagAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RedFlagRule rule,  String primaryMedicineName,  String? relatedLabel,  String? resourceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RedFlagAlert() when $default != null:
return $default(_that.rule,_that.primaryMedicineName,_that.relatedLabel,_that.resourceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RedFlagRule rule,  String primaryMedicineName,  String? relatedLabel,  String? resourceId)  $default,) {final _that = this;
switch (_that) {
case _RedFlagAlert():
return $default(_that.rule,_that.primaryMedicineName,_that.relatedLabel,_that.resourceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RedFlagRule rule,  String primaryMedicineName,  String? relatedLabel,  String? resourceId)?  $default,) {final _that = this;
switch (_that) {
case _RedFlagAlert() when $default != null:
return $default(_that.rule,_that.primaryMedicineName,_that.relatedLabel,_that.resourceId);case _:
  return null;

}
}

}

/// @nodoc


class _RedFlagAlert implements RedFlagAlert {
  const _RedFlagAlert({required this.rule, required this.primaryMedicineName, this.relatedLabel, this.resourceId});
  

@override final  RedFlagRule rule;
@override final  String primaryMedicineName;
@override final  String? relatedLabel;
/// Matches a support-resource id (e.g. 'campus-emergency', 'campus-hospital').
@override final  String? resourceId;

/// Create a copy of RedFlagAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RedFlagAlertCopyWith<_RedFlagAlert> get copyWith => __$RedFlagAlertCopyWithImpl<_RedFlagAlert>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RedFlagAlert&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.primaryMedicineName, primaryMedicineName) || other.primaryMedicineName == primaryMedicineName)&&(identical(other.relatedLabel, relatedLabel) || other.relatedLabel == relatedLabel)&&(identical(other.resourceId, resourceId) || other.resourceId == resourceId));
}


@override
int get hashCode => Object.hash(runtimeType,rule,primaryMedicineName,relatedLabel,resourceId);

@override
String toString() {
  return 'RedFlagAlert(rule: $rule, primaryMedicineName: $primaryMedicineName, relatedLabel: $relatedLabel, resourceId: $resourceId)';
}


}

/// @nodoc
abstract mixin class _$RedFlagAlertCopyWith<$Res> implements $RedFlagAlertCopyWith<$Res> {
  factory _$RedFlagAlertCopyWith(_RedFlagAlert value, $Res Function(_RedFlagAlert) _then) = __$RedFlagAlertCopyWithImpl;
@override @useResult
$Res call({
 RedFlagRule rule, String primaryMedicineName, String? relatedLabel, String? resourceId
});




}
/// @nodoc
class __$RedFlagAlertCopyWithImpl<$Res>
    implements _$RedFlagAlertCopyWith<$Res> {
  __$RedFlagAlertCopyWithImpl(this._self, this._then);

  final _RedFlagAlert _self;
  final $Res Function(_RedFlagAlert) _then;

/// Create a copy of RedFlagAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rule = null,Object? primaryMedicineName = null,Object? relatedLabel = freezed,Object? resourceId = freezed,}) {
  return _then(_RedFlagAlert(
rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as RedFlagRule,primaryMedicineName: null == primaryMedicineName ? _self.primaryMedicineName : primaryMedicineName // ignore: cast_nullable_to_non_nullable
as String,relatedLabel: freezed == relatedLabel ? _self.relatedLabel : relatedLabel // ignore: cast_nullable_to_non_nullable
as String?,resourceId: freezed == resourceId ? _self.resourceId : resourceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
