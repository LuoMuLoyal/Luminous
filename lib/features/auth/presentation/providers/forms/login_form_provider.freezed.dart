// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_form_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginFormState {

 String get email; String get password; String get code; String get wechatCallbackInput; AuthLoginMode get mode; bool get isSubmitting; bool get isSendingCode; bool get isStartingWechatLogin; bool get isCompletingWechatLogin; int? get cooldownSeconds; String? get emailError; String? get passwordError; String? get codeError; String? get wechatAuthorizeUrl; String? get wechatState; String? get errorMessage;
/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginFormStateCopyWith<LoginFormState> get copyWith => _$LoginFormStateCopyWithImpl<LoginFormState>(this as LoginFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginFormState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.code, code) || other.code == code)&&(identical(other.wechatCallbackInput, wechatCallbackInput) || other.wechatCallbackInput == wechatCallbackInput)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.isSendingCode, isSendingCode) || other.isSendingCode == isSendingCode)&&(identical(other.isStartingWechatLogin, isStartingWechatLogin) || other.isStartingWechatLogin == isStartingWechatLogin)&&(identical(other.isCompletingWechatLogin, isCompletingWechatLogin) || other.isCompletingWechatLogin == isCompletingWechatLogin)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.codeError, codeError) || other.codeError == codeError)&&(identical(other.wechatAuthorizeUrl, wechatAuthorizeUrl) || other.wechatAuthorizeUrl == wechatAuthorizeUrl)&&(identical(other.wechatState, wechatState) || other.wechatState == wechatState)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,code,wechatCallbackInput,mode,isSubmitting,isSendingCode,isStartingWechatLogin,isCompletingWechatLogin,cooldownSeconds,emailError,passwordError,codeError,wechatAuthorizeUrl,wechatState,errorMessage);

@override
String toString() {
  return 'LoginFormState(email: $email, password: $password, code: $code, wechatCallbackInput: $wechatCallbackInput, mode: $mode, isSubmitting: $isSubmitting, isSendingCode: $isSendingCode, isStartingWechatLogin: $isStartingWechatLogin, isCompletingWechatLogin: $isCompletingWechatLogin, cooldownSeconds: $cooldownSeconds, emailError: $emailError, passwordError: $passwordError, codeError: $codeError, wechatAuthorizeUrl: $wechatAuthorizeUrl, wechatState: $wechatState, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $LoginFormStateCopyWith<$Res>  {
  factory $LoginFormStateCopyWith(LoginFormState value, $Res Function(LoginFormState) _then) = _$LoginFormStateCopyWithImpl;
@useResult
$Res call({
 String email, String password, String code, String wechatCallbackInput, AuthLoginMode mode, bool isSubmitting, bool isSendingCode, bool isStartingWechatLogin, bool isCompletingWechatLogin, int? cooldownSeconds, String? emailError, String? passwordError, String? codeError, String? wechatAuthorizeUrl, String? wechatState, String? errorMessage
});




}
/// @nodoc
class _$LoginFormStateCopyWithImpl<$Res>
    implements $LoginFormStateCopyWith<$Res> {
  _$LoginFormStateCopyWithImpl(this._self, this._then);

  final LoginFormState _self;
  final $Res Function(LoginFormState) _then;

/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? code = null,Object? wechatCallbackInput = null,Object? mode = null,Object? isSubmitting = null,Object? isSendingCode = null,Object? isStartingWechatLogin = null,Object? isCompletingWechatLogin = null,Object? cooldownSeconds = freezed,Object? emailError = freezed,Object? passwordError = freezed,Object? codeError = freezed,Object? wechatAuthorizeUrl = freezed,Object? wechatState = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,wechatCallbackInput: null == wechatCallbackInput ? _self.wechatCallbackInput : wechatCallbackInput // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AuthLoginMode,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,isSendingCode: null == isSendingCode ? _self.isSendingCode : isSendingCode // ignore: cast_nullable_to_non_nullable
as bool,isStartingWechatLogin: null == isStartingWechatLogin ? _self.isStartingWechatLogin : isStartingWechatLogin // ignore: cast_nullable_to_non_nullable
as bool,isCompletingWechatLogin: null == isCompletingWechatLogin ? _self.isCompletingWechatLogin : isCompletingWechatLogin // ignore: cast_nullable_to_non_nullable
as bool,cooldownSeconds: freezed == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,codeError: freezed == codeError ? _self.codeError : codeError // ignore: cast_nullable_to_non_nullable
as String?,wechatAuthorizeUrl: freezed == wechatAuthorizeUrl ? _self.wechatAuthorizeUrl : wechatAuthorizeUrl // ignore: cast_nullable_to_non_nullable
as String?,wechatState: freezed == wechatState ? _self.wechatState : wechatState // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginFormState].
extension LoginFormStatePatterns on LoginFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginFormState value)  $default,){
final _that = this;
switch (_that) {
case _LoginFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginFormState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String code,  String wechatCallbackInput,  AuthLoginMode mode,  bool isSubmitting,  bool isSendingCode,  bool isStartingWechatLogin,  bool isCompletingWechatLogin,  int? cooldownSeconds,  String? emailError,  String? passwordError,  String? codeError,  String? wechatAuthorizeUrl,  String? wechatState,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
return $default(_that.email,_that.password,_that.code,_that.wechatCallbackInput,_that.mode,_that.isSubmitting,_that.isSendingCode,_that.isStartingWechatLogin,_that.isCompletingWechatLogin,_that.cooldownSeconds,_that.emailError,_that.passwordError,_that.codeError,_that.wechatAuthorizeUrl,_that.wechatState,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String code,  String wechatCallbackInput,  AuthLoginMode mode,  bool isSubmitting,  bool isSendingCode,  bool isStartingWechatLogin,  bool isCompletingWechatLogin,  int? cooldownSeconds,  String? emailError,  String? passwordError,  String? codeError,  String? wechatAuthorizeUrl,  String? wechatState,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _LoginFormState():
return $default(_that.email,_that.password,_that.code,_that.wechatCallbackInput,_that.mode,_that.isSubmitting,_that.isSendingCode,_that.isStartingWechatLogin,_that.isCompletingWechatLogin,_that.cooldownSeconds,_that.emailError,_that.passwordError,_that.codeError,_that.wechatAuthorizeUrl,_that.wechatState,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String code,  String wechatCallbackInput,  AuthLoginMode mode,  bool isSubmitting,  bool isSendingCode,  bool isStartingWechatLogin,  bool isCompletingWechatLogin,  int? cooldownSeconds,  String? emailError,  String? passwordError,  String? codeError,  String? wechatAuthorizeUrl,  String? wechatState,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
return $default(_that.email,_that.password,_that.code,_that.wechatCallbackInput,_that.mode,_that.isSubmitting,_that.isSendingCode,_that.isStartingWechatLogin,_that.isCompletingWechatLogin,_that.cooldownSeconds,_that.emailError,_that.passwordError,_that.codeError,_that.wechatAuthorizeUrl,_that.wechatState,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _LoginFormState implements LoginFormState {
  const _LoginFormState({this.email = '', this.password = '', this.code = '', this.wechatCallbackInput = '', this.mode = AuthLoginMode.password, this.isSubmitting = false, this.isSendingCode = false, this.isStartingWechatLogin = false, this.isCompletingWechatLogin = false, this.cooldownSeconds, this.emailError, this.passwordError, this.codeError, this.wechatAuthorizeUrl, this.wechatState, this.errorMessage});
  

@override@JsonKey() final  String email;
@override@JsonKey() final  String password;
@override@JsonKey() final  String code;
@override@JsonKey() final  String wechatCallbackInput;
@override@JsonKey() final  AuthLoginMode mode;
@override@JsonKey() final  bool isSubmitting;
@override@JsonKey() final  bool isSendingCode;
@override@JsonKey() final  bool isStartingWechatLogin;
@override@JsonKey() final  bool isCompletingWechatLogin;
@override final  int? cooldownSeconds;
@override final  String? emailError;
@override final  String? passwordError;
@override final  String? codeError;
@override final  String? wechatAuthorizeUrl;
@override final  String? wechatState;
@override final  String? errorMessage;

/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginFormStateCopyWith<_LoginFormState> get copyWith => __$LoginFormStateCopyWithImpl<_LoginFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginFormState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.code, code) || other.code == code)&&(identical(other.wechatCallbackInput, wechatCallbackInput) || other.wechatCallbackInput == wechatCallbackInput)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.isSendingCode, isSendingCode) || other.isSendingCode == isSendingCode)&&(identical(other.isStartingWechatLogin, isStartingWechatLogin) || other.isStartingWechatLogin == isStartingWechatLogin)&&(identical(other.isCompletingWechatLogin, isCompletingWechatLogin) || other.isCompletingWechatLogin == isCompletingWechatLogin)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.codeError, codeError) || other.codeError == codeError)&&(identical(other.wechatAuthorizeUrl, wechatAuthorizeUrl) || other.wechatAuthorizeUrl == wechatAuthorizeUrl)&&(identical(other.wechatState, wechatState) || other.wechatState == wechatState)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,code,wechatCallbackInput,mode,isSubmitting,isSendingCode,isStartingWechatLogin,isCompletingWechatLogin,cooldownSeconds,emailError,passwordError,codeError,wechatAuthorizeUrl,wechatState,errorMessage);

@override
String toString() {
  return 'LoginFormState(email: $email, password: $password, code: $code, wechatCallbackInput: $wechatCallbackInput, mode: $mode, isSubmitting: $isSubmitting, isSendingCode: $isSendingCode, isStartingWechatLogin: $isStartingWechatLogin, isCompletingWechatLogin: $isCompletingWechatLogin, cooldownSeconds: $cooldownSeconds, emailError: $emailError, passwordError: $passwordError, codeError: $codeError, wechatAuthorizeUrl: $wechatAuthorizeUrl, wechatState: $wechatState, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$LoginFormStateCopyWith<$Res> implements $LoginFormStateCopyWith<$Res> {
  factory _$LoginFormStateCopyWith(_LoginFormState value, $Res Function(_LoginFormState) _then) = __$LoginFormStateCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String code, String wechatCallbackInput, AuthLoginMode mode, bool isSubmitting, bool isSendingCode, bool isStartingWechatLogin, bool isCompletingWechatLogin, int? cooldownSeconds, String? emailError, String? passwordError, String? codeError, String? wechatAuthorizeUrl, String? wechatState, String? errorMessage
});




}
/// @nodoc
class __$LoginFormStateCopyWithImpl<$Res>
    implements _$LoginFormStateCopyWith<$Res> {
  __$LoginFormStateCopyWithImpl(this._self, this._then);

  final _LoginFormState _self;
  final $Res Function(_LoginFormState) _then;

/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? code = null,Object? wechatCallbackInput = null,Object? mode = null,Object? isSubmitting = null,Object? isSendingCode = null,Object? isStartingWechatLogin = null,Object? isCompletingWechatLogin = null,Object? cooldownSeconds = freezed,Object? emailError = freezed,Object? passwordError = freezed,Object? codeError = freezed,Object? wechatAuthorizeUrl = freezed,Object? wechatState = freezed,Object? errorMessage = freezed,}) {
  return _then(_LoginFormState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,wechatCallbackInput: null == wechatCallbackInput ? _self.wechatCallbackInput : wechatCallbackInput // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AuthLoginMode,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,isSendingCode: null == isSendingCode ? _self.isSendingCode : isSendingCode // ignore: cast_nullable_to_non_nullable
as bool,isStartingWechatLogin: null == isStartingWechatLogin ? _self.isStartingWechatLogin : isStartingWechatLogin // ignore: cast_nullable_to_non_nullable
as bool,isCompletingWechatLogin: null == isCompletingWechatLogin ? _self.isCompletingWechatLogin : isCompletingWechatLogin // ignore: cast_nullable_to_non_nullable
as bool,cooldownSeconds: freezed == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,codeError: freezed == codeError ? _self.codeError : codeError // ignore: cast_nullable_to_non_nullable
as String?,wechatAuthorizeUrl: freezed == wechatAuthorizeUrl ? _self.wechatAuthorizeUrl : wechatAuthorizeUrl // ignore: cast_nullable_to_non_nullable
as String?,wechatState: freezed == wechatState ? _self.wechatState : wechatState // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
