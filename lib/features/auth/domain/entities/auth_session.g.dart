// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  id: json['id'] as String,
  email: json['email'] as String?,
  nickname: json['nickname'] as String?,
  avatar: json['avatar'] as String?,
  emailVerifiedAt: json['emailVerifiedAt'] == null
      ? null
      : DateTime.parse(json['emailVerifiedAt'] as String),
  hasPassword: json['hasPassword'] as bool? ?? false,
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  linkedIdentities:
      (json['linkedIdentities'] as List<dynamic>?)
          ?.map((e) => AuthLinkedIdentity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AuthLinkedIdentity>[],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'nickname': instance.nickname,
  'avatar': instance.avatar,
  'emailVerifiedAt': instance.emailVerifiedAt?.toIso8601String(),
  'hasPassword': instance.hasPassword,
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'linkedIdentities': instance.linkedIdentities,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_AuthLinkedIdentity _$AuthLinkedIdentityFromJson(Map<String, dynamic> json) =>
    _AuthLinkedIdentity(
      provider: json['provider'] as String,
      email: json['email'] as String?,
      emailVerifiedAt: json['emailVerifiedAt'] == null
          ? null
          : DateTime.parse(json['emailVerifiedAt'] as String),
      linkedAt: DateTime.parse(json['linkedAt'] as String),
    );

Map<String, dynamic> _$AuthLinkedIdentityToJson(_AuthLinkedIdentity instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'email': instance.email,
      'emailVerifiedAt': instance.emailVerifiedAt?.toIso8601String(),
      'linkedAt': instance.linkedAt.toIso8601String(),
    };

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresInSeconds: (json['expiresInSeconds'] as num).toInt(),
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresInSeconds': instance.expiresInSeconds,
    };
