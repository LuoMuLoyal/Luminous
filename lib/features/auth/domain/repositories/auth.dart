import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/oauth_authorize.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';

abstract interface class AuthRepository {
  TaskEither<LucentFailure, AuthSession> login({
    required String email,
    String? password,
    String? code,
  });

  TaskEither<LucentFailure, AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  });

  TaskEither<LucentFailure, void> logout();

  TaskEither<LucentFailure, AuthUser> fetchAccount();

  TaskEither<LucentFailure, AuthSession> refreshSession({
    required String refreshToken,
  });

  TaskEither<LucentFailure, OAuthAuthorizeData> createWechatWebAuthorizeUrl({
    String? callbackUri,
  });

  TaskEither<LucentFailure, OAuthAuthorizeData>
  createWechatWebIdentityLinkAuthorizeUrl({String? callbackUri});

  TaskEither<LucentFailure, AuthSession> loginWithWechatWeb({
    required String code,
    required String state,
  });

  TaskEither<LucentFailure, AuthSession> loginWithWechatMobile({
    required String code,
  });

  TaskEither<LucentFailure, AuthSession> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  });

  TaskEither<LucentFailure, OAuthAuthorizeData> createQqAuthorizeUrl({
    String? callbackUri,
  });

  TaskEither<LucentFailure, AuthSession> loginWithQq({
    required String code,
    required String state,
  });

  TaskEither<LucentFailure, OAuthAuthorizeData> createWeiboAuthorizeUrl({
    String? callbackUri,
  });

  TaskEither<LucentFailure, AuthSession> loginWithWeibo({
    required String code,
    required String state,
  });

  TaskEither<LucentFailure, OAuthAuthorizeData> createGoogleAuthorizeUrl({
    String? callbackUri,
  });

  TaskEither<LucentFailure, AuthSession> loginWithGoogle({
    required String code,
    required String state,
  });

  TaskEither<LucentFailure, AuthUser> linkWechatWebIdentity({
    required String code,
    required String state,
  });

  TaskEither<LucentFailure, AuthUser> linkWechatMobileIdentity({
    required String code,
  });

  TaskEither<LucentFailure, VerificationCooldown> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  });

  TaskEither<LucentFailure, void> resetPassword({
    required String token,
    required String password,
  });

  TaskEither<LucentFailure, VerificationCooldown> forgotPassword({
    required String email,
  });

  TaskEither<LucentFailure, void> verifyEmail({required String token});

  TaskEither<LucentFailure, AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  });

  TaskEither<LucentFailure, void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  TaskEither<LucentFailure, AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  });

  TaskEither<LucentFailure, void> deleteAccount({
    String? password,
    String? code,
  });

  TaskEither<LucentFailure, AuthUser> unlinkIdentity({
    required String identityId,
  });
}
