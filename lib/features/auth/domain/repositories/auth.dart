import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/oauth_authorize.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String email,
    String? password,
    String? code,
  });

  Future<AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  });

  Future<void> logout();

  Future<AuthUser> fetchAccount();

  Future<AuthSession> refreshSession({required String refreshToken});

  Future<OAuthAuthorizeData> createWechatWebAuthorizeUrl({String? callbackUri});

  Future<OAuthAuthorizeData> createWechatWebIdentityLinkAuthorizeUrl({
    String? callbackUri,
  });

  Future<AuthSession> loginWithWechatWeb({
    required String code,
    required String state,
  });

  Future<AuthSession> loginWithWechatMobile({required String code});

  Future<AuthSession> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  });

  Future<OAuthAuthorizeData> createQqAuthorizeUrl({String? callbackUri});

  Future<AuthSession> loginWithQq({
    required String code,
    required String state,
  });

  Future<AuthUser> linkWechatWebIdentity({
    required String code,
    required String state,
  });

  Future<AuthUser> linkWechatMobileIdentity({required String code});

  Future<VerificationCooldown> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  });

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  });

  Future<VerificationCooldown> forgotPassword({required String email});

  Future<void> verifyEmail({required String email, required String code});

  Future<AuthUser> updateAccountProfile({String? nickname, String? avatar});

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  });

  Future<void> deleteAccount({String? password, String? code});

  Future<AuthUser> unlinkIdentity({required String identityId});
}
