// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyRecordItem {

 String get id; DailyRecordKind get kind; String get occurredAt; String? get occurredTime; String? get title; String? get value; String? get unit; String? get note; String? get source; Map<String, dynamic>? get payload; List<DailyRecordAttachment> get attachments; String get createdAt; String get updatedAt;
/// Create a copy of DailyRecordItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordItemCopyWith<DailyRecordItem> get copyWith => _$DailyRecordItemCopyWithImpl<DailyRecordItem>(this as DailyRecordItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordItem&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.occurredTime, occurredTime) || other.occurredTime == occurredTime)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.note, note) || other.note == note)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.payload, payload)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,occurredAt,occurredTime,title,value,unit,note,source,const DeepCollectionEquality().hash(payload),const DeepCollectionEquality().hash(attachments),createdAt,updatedAt);

@override
String toString() {
  return 'DailyRecordItem(id: $id, kind: $kind, occurredAt: $occurredAt, occurredTime: $occurredTime, title: $title, value: $value, unit: $unit, note: $note, source: $source, payload: $payload, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DailyRecordItemCopyWith<$Res>  {
  factory $DailyRecordItemCopyWith(DailyRecordItem value, $Res Function(DailyRecordItem) _then) = _$DailyRecordItemCopyWithImpl;
@useResult
$Res call({
 String id, DailyRecordKind kind, String occurredAt, String? occurredTime, String? title, String? value, String? unit, String? note, String? source, Map<String, dynamic>? payload, List<DailyRecordAttachment> attachments, String createdAt, String updatedAt
});




}
/// @nodoc
class _$DailyRecordItemCopyWithImpl<$Res>
    implements $DailyRecordItemCopyWith<$Res> {
  _$DailyRecordItemCopyWithImpl(this._self, this._then);

  final DailyRecordItem _self;
  final $Res Function(DailyRecordItem) _then;

/// Create a copy of DailyRecordItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? occurredAt = null,Object? occurredTime = freezed,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? source = freezed,Object? payload = freezed,Object? attachments = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,occurredTime: freezed == occurredTime ? _self.occurredTime : occurredTime // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<DailyRecordAttachment>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordItem].
extension DailyRecordItemPatterns on DailyRecordItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordItem value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordItem value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DailyRecordKind kind,  String occurredAt,  String? occurredTime,  String? title,  String? value,  String? unit,  String? note,  String? source,  Map<String, dynamic>? payload,  List<DailyRecordAttachment> attachments,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordItem() when $default != null:
return $default(_that.id,_that.kind,_that.occurredAt,_that.occurredTime,_that.title,_that.value,_that.unit,_that.note,_that.source,_that.payload,_that.attachments,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DailyRecordKind kind,  String occurredAt,  String? occurredTime,  String? title,  String? value,  String? unit,  String? note,  String? source,  Map<String, dynamic>? payload,  List<DailyRecordAttachment> attachments,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordItem():
return $default(_that.id,_that.kind,_that.occurredAt,_that.occurredTime,_that.title,_that.value,_that.unit,_that.note,_that.source,_that.payload,_that.attachments,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DailyRecordKind kind,  String occurredAt,  String? occurredTime,  String? title,  String? value,  String? unit,  String? note,  String? source,  Map<String, dynamic>? payload,  List<DailyRecordAttachment> attachments,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordItem() when $default != null:
return $default(_that.id,_that.kind,_that.occurredAt,_that.occurredTime,_that.title,_that.value,_that.unit,_that.note,_that.source,_that.payload,_that.attachments,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordItem implements DailyRecordItem {
  const _DailyRecordItem({required this.id, required this.kind, required this.occurredAt, this.occurredTime, this.title, this.value, this.unit, this.note, this.source, final  Map<String, dynamic>? payload, final  List<DailyRecordAttachment> attachments = const [], required this.createdAt, required this.updatedAt}): _payload = payload,_attachments = attachments;
  

@override final  String id;
@override final  DailyRecordKind kind;
@override final  String occurredAt;
@override final  String? occurredTime;
@override final  String? title;
@override final  String? value;
@override final  String? unit;
@override final  String? note;
@override final  String? source;
 final  Map<String, dynamic>? _payload;
@override Map<String, dynamic>? get payload {
  final value = _payload;
  if (value == null) return null;
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<DailyRecordAttachment> _attachments;
@override@JsonKey() List<DailyRecordAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of DailyRecordItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordItemCopyWith<_DailyRecordItem> get copyWith => __$DailyRecordItemCopyWithImpl<_DailyRecordItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordItem&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.occurredTime, occurredTime) || other.occurredTime == occurredTime)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.note, note) || other.note == note)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other._payload, _payload)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,occurredAt,occurredTime,title,value,unit,note,source,const DeepCollectionEquality().hash(_payload),const DeepCollectionEquality().hash(_attachments),createdAt,updatedAt);

@override
String toString() {
  return 'DailyRecordItem(id: $id, kind: $kind, occurredAt: $occurredAt, occurredTime: $occurredTime, title: $title, value: $value, unit: $unit, note: $note, source: $source, payload: $payload, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordItemCopyWith<$Res> implements $DailyRecordItemCopyWith<$Res> {
  factory _$DailyRecordItemCopyWith(_DailyRecordItem value, $Res Function(_DailyRecordItem) _then) = __$DailyRecordItemCopyWithImpl;
@override @useResult
$Res call({
 String id, DailyRecordKind kind, String occurredAt, String? occurredTime, String? title, String? value, String? unit, String? note, String? source, Map<String, dynamic>? payload, List<DailyRecordAttachment> attachments, String createdAt, String updatedAt
});




}
/// @nodoc
class __$DailyRecordItemCopyWithImpl<$Res>
    implements _$DailyRecordItemCopyWith<$Res> {
  __$DailyRecordItemCopyWithImpl(this._self, this._then);

  final _DailyRecordItem _self;
  final $Res Function(_DailyRecordItem) _then;

/// Create a copy of DailyRecordItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? occurredAt = null,Object? occurredTime = freezed,Object? title = freezed,Object? value = freezed,Object? unit = freezed,Object? note = freezed,Object? source = freezed,Object? payload = freezed,Object? attachments = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_DailyRecordItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,occurredTime: freezed == occurredTime ? _self.occurredTime : occurredTime // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,payload: freezed == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<DailyRecordAttachment>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$DailyRecordAttachment {

 String get id; DailyRecordAttachmentKind get kind; String get objectKey; String? get bucket; String? get provider; String? get fileName; String? get contentType; int? get sizeBytes; int? get width; int? get height; String? get publicUrl; String get createdAt;
/// Create a copy of DailyRecordAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordAttachmentCopyWith<DailyRecordAttachment> get copyWith => _$DailyRecordAttachmentCopyWithImpl<DailyRecordAttachment>(this as DailyRecordAttachment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.publicUrl, publicUrl) || other.publicUrl == publicUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,objectKey,bucket,provider,fileName,contentType,sizeBytes,width,height,publicUrl,createdAt);

@override
String toString() {
  return 'DailyRecordAttachment(id: $id, kind: $kind, objectKey: $objectKey, bucket: $bucket, provider: $provider, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, width: $width, height: $height, publicUrl: $publicUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DailyRecordAttachmentCopyWith<$Res>  {
  factory $DailyRecordAttachmentCopyWith(DailyRecordAttachment value, $Res Function(DailyRecordAttachment) _then) = _$DailyRecordAttachmentCopyWithImpl;
@useResult
$Res call({
 String id, DailyRecordAttachmentKind kind, String objectKey, String? bucket, String? provider, String? fileName, String? contentType, int? sizeBytes, int? width, int? height, String? publicUrl, String createdAt
});




}
/// @nodoc
class _$DailyRecordAttachmentCopyWithImpl<$Res>
    implements $DailyRecordAttachmentCopyWith<$Res> {
  _$DailyRecordAttachmentCopyWithImpl(this._self, this._then);

  final DailyRecordAttachment _self;
  final $Res Function(DailyRecordAttachment) _then;

/// Create a copy of DailyRecordAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? objectKey = null,Object? bucket = freezed,Object? provider = freezed,Object? fileName = freezed,Object? contentType = freezed,Object? sizeBytes = freezed,Object? width = freezed,Object? height = freezed,Object? publicUrl = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordAttachmentKind,objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,publicUrl: freezed == publicUrl ? _self.publicUrl : publicUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordAttachment].
extension DailyRecordAttachmentPatterns on DailyRecordAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordAttachment value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DailyRecordAttachmentKind kind,  String objectKey,  String? bucket,  String? provider,  String? fileName,  String? contentType,  int? sizeBytes,  int? width,  int? height,  String? publicUrl,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordAttachment() when $default != null:
return $default(_that.id,_that.kind,_that.objectKey,_that.bucket,_that.provider,_that.fileName,_that.contentType,_that.sizeBytes,_that.width,_that.height,_that.publicUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DailyRecordAttachmentKind kind,  String objectKey,  String? bucket,  String? provider,  String? fileName,  String? contentType,  int? sizeBytes,  int? width,  int? height,  String? publicUrl,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordAttachment():
return $default(_that.id,_that.kind,_that.objectKey,_that.bucket,_that.provider,_that.fileName,_that.contentType,_that.sizeBytes,_that.width,_that.height,_that.publicUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DailyRecordAttachmentKind kind,  String objectKey,  String? bucket,  String? provider,  String? fileName,  String? contentType,  int? sizeBytes,  int? width,  int? height,  String? publicUrl,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordAttachment() when $default != null:
return $default(_that.id,_that.kind,_that.objectKey,_that.bucket,_that.provider,_that.fileName,_that.contentType,_that.sizeBytes,_that.width,_that.height,_that.publicUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordAttachment extends DailyRecordAttachment {
  const _DailyRecordAttachment({required this.id, required this.kind, required this.objectKey, this.bucket, this.provider, this.fileName, this.contentType, this.sizeBytes, this.width, this.height, this.publicUrl, required this.createdAt}): super._();
  

@override final  String id;
@override final  DailyRecordAttachmentKind kind;
@override final  String objectKey;
@override final  String? bucket;
@override final  String? provider;
@override final  String? fileName;
@override final  String? contentType;
@override final  int? sizeBytes;
@override final  int? width;
@override final  int? height;
@override final  String? publicUrl;
@override final  String createdAt;

/// Create a copy of DailyRecordAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordAttachmentCopyWith<_DailyRecordAttachment> get copyWith => __$DailyRecordAttachmentCopyWithImpl<_DailyRecordAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.objectKey, objectKey) || other.objectKey == objectKey)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.publicUrl, publicUrl) || other.publicUrl == publicUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,objectKey,bucket,provider,fileName,contentType,sizeBytes,width,height,publicUrl,createdAt);

@override
String toString() {
  return 'DailyRecordAttachment(id: $id, kind: $kind, objectKey: $objectKey, bucket: $bucket, provider: $provider, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, width: $width, height: $height, publicUrl: $publicUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordAttachmentCopyWith<$Res> implements $DailyRecordAttachmentCopyWith<$Res> {
  factory _$DailyRecordAttachmentCopyWith(_DailyRecordAttachment value, $Res Function(_DailyRecordAttachment) _then) = __$DailyRecordAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String id, DailyRecordAttachmentKind kind, String objectKey, String? bucket, String? provider, String? fileName, String? contentType, int? sizeBytes, int? width, int? height, String? publicUrl, String createdAt
});




}
/// @nodoc
class __$DailyRecordAttachmentCopyWithImpl<$Res>
    implements _$DailyRecordAttachmentCopyWith<$Res> {
  __$DailyRecordAttachmentCopyWithImpl(this._self, this._then);

  final _DailyRecordAttachment _self;
  final $Res Function(_DailyRecordAttachment) _then;

/// Create a copy of DailyRecordAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? objectKey = null,Object? bucket = freezed,Object? provider = freezed,Object? fileName = freezed,Object? contentType = freezed,Object? sizeBytes = freezed,Object? width = freezed,Object? height = freezed,Object? publicUrl = freezed,Object? createdAt = null,}) {
  return _then(_DailyRecordAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordAttachmentKind,objectKey: null == objectKey ? _self.objectKey : objectKey // ignore: cast_nullable_to_non_nullable
as String,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,publicUrl: freezed == publicUrl ? _self.publicUrl : publicUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$DailyRecordSummary {

 DailyRecordKind get kind; num get count; DailyRecordItem? get latest;
/// Create a copy of DailyRecordSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordSummaryCopyWith<DailyRecordSummary> get copyWith => _$DailyRecordSummaryCopyWithImpl<DailyRecordSummary>(this as DailyRecordSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordSummary&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.count, count) || other.count == count)&&(identical(other.latest, latest) || other.latest == latest));
}


@override
int get hashCode => Object.hash(runtimeType,kind,count,latest);

@override
String toString() {
  return 'DailyRecordSummary(kind: $kind, count: $count, latest: $latest)';
}


}

/// @nodoc
abstract mixin class $DailyRecordSummaryCopyWith<$Res>  {
  factory $DailyRecordSummaryCopyWith(DailyRecordSummary value, $Res Function(DailyRecordSummary) _then) = _$DailyRecordSummaryCopyWithImpl;
@useResult
$Res call({
 DailyRecordKind kind, num count, DailyRecordItem? latest
});


$DailyRecordItemCopyWith<$Res>? get latest;

}
/// @nodoc
class _$DailyRecordSummaryCopyWithImpl<$Res>
    implements $DailyRecordSummaryCopyWith<$Res> {
  _$DailyRecordSummaryCopyWithImpl(this._self, this._then);

  final DailyRecordSummary _self;
  final $Res Function(DailyRecordSummary) _then;

/// Create a copy of DailyRecordSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? count = null,Object? latest = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as DailyRecordItem?,
  ));
}
/// Create a copy of DailyRecordSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyRecordItemCopyWith<$Res>? get latest {
    if (_self.latest == null) {
    return null;
  }

  return $DailyRecordItemCopyWith<$Res>(_self.latest!, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}


/// Adds pattern-matching-related methods to [DailyRecordSummary].
extension DailyRecordSummaryPatterns on DailyRecordSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordSummary value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DailyRecordKind kind,  num count,  DailyRecordItem? latest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordSummary() when $default != null:
return $default(_that.kind,_that.count,_that.latest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DailyRecordKind kind,  num count,  DailyRecordItem? latest)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordSummary():
return $default(_that.kind,_that.count,_that.latest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DailyRecordKind kind,  num count,  DailyRecordItem? latest)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordSummary() when $default != null:
return $default(_that.kind,_that.count,_that.latest);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordSummary implements DailyRecordSummary {
  const _DailyRecordSummary({required this.kind, required this.count, this.latest});
  

@override final  DailyRecordKind kind;
@override final  num count;
@override final  DailyRecordItem? latest;

/// Create a copy of DailyRecordSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordSummaryCopyWith<_DailyRecordSummary> get copyWith => __$DailyRecordSummaryCopyWithImpl<_DailyRecordSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordSummary&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.count, count) || other.count == count)&&(identical(other.latest, latest) || other.latest == latest));
}


@override
int get hashCode => Object.hash(runtimeType,kind,count,latest);

@override
String toString() {
  return 'DailyRecordSummary(kind: $kind, count: $count, latest: $latest)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordSummaryCopyWith<$Res> implements $DailyRecordSummaryCopyWith<$Res> {
  factory _$DailyRecordSummaryCopyWith(_DailyRecordSummary value, $Res Function(_DailyRecordSummary) _then) = __$DailyRecordSummaryCopyWithImpl;
@override @useResult
$Res call({
 DailyRecordKind kind, num count, DailyRecordItem? latest
});


@override $DailyRecordItemCopyWith<$Res>? get latest;

}
/// @nodoc
class __$DailyRecordSummaryCopyWithImpl<$Res>
    implements _$DailyRecordSummaryCopyWith<$Res> {
  __$DailyRecordSummaryCopyWithImpl(this._self, this._then);

  final _DailyRecordSummary _self;
  final $Res Function(_DailyRecordSummary) _then;

/// Create a copy of DailyRecordSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? count = null,Object? latest = freezed,}) {
  return _then(_DailyRecordSummary(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DailyRecordKind,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as num,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as DailyRecordItem?,
  ));
}

/// Create a copy of DailyRecordSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyRecordItemCopyWith<$Res>? get latest {
    if (_self.latest == null) {
    return null;
  }

  return $DailyRecordItemCopyWith<$Res>(_self.latest!, (value) {
    return _then(_self.copyWith(latest: value));
  });
}
}

/// @nodoc
mixin _$DailyRecordListData {

 List<DailyRecordItem> get items; num get total;
/// Create a copy of DailyRecordListData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordListDataCopyWith<DailyRecordListData> get copyWith => _$DailyRecordListDataCopyWithImpl<DailyRecordListData>(this as DailyRecordListData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordListData&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total);

@override
String toString() {
  return 'DailyRecordListData(items: $items, total: $total)';
}


}

/// @nodoc
abstract mixin class $DailyRecordListDataCopyWith<$Res>  {
  factory $DailyRecordListDataCopyWith(DailyRecordListData value, $Res Function(DailyRecordListData) _then) = _$DailyRecordListDataCopyWithImpl;
@useResult
$Res call({
 List<DailyRecordItem> items, num total
});




}
/// @nodoc
class _$DailyRecordListDataCopyWithImpl<$Res>
    implements $DailyRecordListDataCopyWith<$Res> {
  _$DailyRecordListDataCopyWithImpl(this._self, this._then);

  final DailyRecordListData _self;
  final $Res Function(DailyRecordListData) _then;

/// Create a copy of DailyRecordListData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<DailyRecordItem>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordListData].
extension DailyRecordListDataPatterns on DailyRecordListData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordListData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordListData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordListData value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordListData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordListData value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordListData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DailyRecordItem> items,  num total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordListData() when $default != null:
return $default(_that.items,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DailyRecordItem> items,  num total)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordListData():
return $default(_that.items,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DailyRecordItem> items,  num total)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordListData() when $default != null:
return $default(_that.items,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordListData implements DailyRecordListData {
  const _DailyRecordListData({required final  List<DailyRecordItem> items, required this.total}): _items = items;
  

 final  List<DailyRecordItem> _items;
@override List<DailyRecordItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  num total;

/// Create a copy of DailyRecordListData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordListDataCopyWith<_DailyRecordListData> get copyWith => __$DailyRecordListDataCopyWithImpl<_DailyRecordListData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordListData&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total);

@override
String toString() {
  return 'DailyRecordListData(items: $items, total: $total)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordListDataCopyWith<$Res> implements $DailyRecordListDataCopyWith<$Res> {
  factory _$DailyRecordListDataCopyWith(_DailyRecordListData value, $Res Function(_DailyRecordListData) _then) = __$DailyRecordListDataCopyWithImpl;
@override @useResult
$Res call({
 List<DailyRecordItem> items, num total
});




}
/// @nodoc
class __$DailyRecordListDataCopyWithImpl<$Res>
    implements _$DailyRecordListDataCopyWith<$Res> {
  __$DailyRecordListDataCopyWithImpl(this._self, this._then);

  final _DailyRecordListData _self;
  final $Res Function(_DailyRecordListData) _then;

/// Create a copy of DailyRecordListData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,}) {
  return _then(_DailyRecordListData(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<DailyRecordItem>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

/// @nodoc
mixin _$DailyRecordSummaryData {

 List<DailyRecordSummary> get summaries;
/// Create a copy of DailyRecordSummaryData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRecordSummaryDataCopyWith<DailyRecordSummaryData> get copyWith => _$DailyRecordSummaryDataCopyWithImpl<DailyRecordSummaryData>(this as DailyRecordSummaryData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRecordSummaryData&&const DeepCollectionEquality().equals(other.summaries, summaries));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(summaries));

@override
String toString() {
  return 'DailyRecordSummaryData(summaries: $summaries)';
}


}

/// @nodoc
abstract mixin class $DailyRecordSummaryDataCopyWith<$Res>  {
  factory $DailyRecordSummaryDataCopyWith(DailyRecordSummaryData value, $Res Function(DailyRecordSummaryData) _then) = _$DailyRecordSummaryDataCopyWithImpl;
@useResult
$Res call({
 List<DailyRecordSummary> summaries
});




}
/// @nodoc
class _$DailyRecordSummaryDataCopyWithImpl<$Res>
    implements $DailyRecordSummaryDataCopyWith<$Res> {
  _$DailyRecordSummaryDataCopyWithImpl(this._self, this._then);

  final DailyRecordSummaryData _self;
  final $Res Function(DailyRecordSummaryData) _then;

/// Create a copy of DailyRecordSummaryData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summaries = null,}) {
  return _then(_self.copyWith(
summaries: null == summaries ? _self.summaries : summaries // ignore: cast_nullable_to_non_nullable
as List<DailyRecordSummary>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyRecordSummaryData].
extension DailyRecordSummaryDataPatterns on DailyRecordSummaryData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyRecordSummaryData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyRecordSummaryData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyRecordSummaryData value)  $default,){
final _that = this;
switch (_that) {
case _DailyRecordSummaryData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyRecordSummaryData value)?  $default,){
final _that = this;
switch (_that) {
case _DailyRecordSummaryData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DailyRecordSummary> summaries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyRecordSummaryData() when $default != null:
return $default(_that.summaries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DailyRecordSummary> summaries)  $default,) {final _that = this;
switch (_that) {
case _DailyRecordSummaryData():
return $default(_that.summaries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DailyRecordSummary> summaries)?  $default,) {final _that = this;
switch (_that) {
case _DailyRecordSummaryData() when $default != null:
return $default(_that.summaries);case _:
  return null;

}
}

}

/// @nodoc


class _DailyRecordSummaryData implements DailyRecordSummaryData {
  const _DailyRecordSummaryData({required final  List<DailyRecordSummary> summaries}): _summaries = summaries;
  

 final  List<DailyRecordSummary> _summaries;
@override List<DailyRecordSummary> get summaries {
  if (_summaries is EqualUnmodifiableListView) return _summaries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_summaries);
}


/// Create a copy of DailyRecordSummaryData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyRecordSummaryDataCopyWith<_DailyRecordSummaryData> get copyWith => __$DailyRecordSummaryDataCopyWithImpl<_DailyRecordSummaryData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyRecordSummaryData&&const DeepCollectionEquality().equals(other._summaries, _summaries));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_summaries));

@override
String toString() {
  return 'DailyRecordSummaryData(summaries: $summaries)';
}


}

/// @nodoc
abstract mixin class _$DailyRecordSummaryDataCopyWith<$Res> implements $DailyRecordSummaryDataCopyWith<$Res> {
  factory _$DailyRecordSummaryDataCopyWith(_DailyRecordSummaryData value, $Res Function(_DailyRecordSummaryData) _then) = __$DailyRecordSummaryDataCopyWithImpl;
@override @useResult
$Res call({
 List<DailyRecordSummary> summaries
});




}
/// @nodoc
class __$DailyRecordSummaryDataCopyWithImpl<$Res>
    implements _$DailyRecordSummaryDataCopyWith<$Res> {
  __$DailyRecordSummaryDataCopyWithImpl(this._self, this._then);

  final _DailyRecordSummaryData _self;
  final $Res Function(_DailyRecordSummaryData) _then;

/// Create a copy of DailyRecordSummaryData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summaries = null,}) {
  return _then(_DailyRecordSummaryData(
summaries: null == summaries ? _self._summaries : summaries // ignore: cast_nullable_to_non_nullable
as List<DailyRecordSummary>,
  ));
}


}

// dart format on
