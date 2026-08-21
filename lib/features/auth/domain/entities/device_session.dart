import 'package:flutter/foundation.dart';

@immutable
class AuthDeviceSession {
  const AuthDeviceSession({
    required this.id,
    required this.deviceType,
    required this.deviceName,
    required this.platform,
    required this.lastUsedAt,
    required this.createdAt,
    required this.expiresAt,
    required this.isCurrent,
  });

  factory AuthDeviceSession.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String key) {
      final value = DateTime.tryParse(json[key]?.toString() ?? '');
      if (value == null) {
        throw FormatException('Invalid session date: $key');
      }
      return value;
    }

    return AuthDeviceSession(
      id:
          json['id']?.toString() ??
          (throw const FormatException('Missing session id')),
      deviceType: json['deviceType']?.toString(),
      deviceName: json['deviceName']?.toString(),
      platform: json['platform']?.toString(),
      // lastUsedAt is intentionally nullable: a freshly created session
      // may not have been used yet, so the API omits or nulls this field.
      // Unlike createdAt/expiresAt which are always present and throwing
      // on their absence is correct, lastUsedAt absence is a valid state.
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.tryParse(json['lastUsedAt'].toString()),
      createdAt: parseDate('createdAt'),
      expiresAt: parseDate('expiresAt'),
      isCurrent: json['isCurrent'] == true,
    );
  }

  final String id;
  final String? deviceType;
  final String? deviceName;
  final String? platform;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isCurrent;
}
