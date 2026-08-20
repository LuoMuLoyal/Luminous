import 'package:dio/dio.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/features/auth/domain/entities/device_session.dart';
import 'package:luminous/features/auth/domain/repositories/sessions.dart';

class LucentAuthSessionsRepository implements AuthSessionsRepository {
  const LucentAuthSessionsRepository({required this.dio});

  final Dio dio;

  @override
  Future<List<AuthDeviceSession>> listSessions() async {
    final response = await dio.get<Object>(LucentApiPaths.authSessions);
    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      throw StateError('API 返回空的登录会话响应');
    }

    final envelope = LucentEnvelope<List<AuthDeviceSession>>.fromJson(
      raw,
      dataDecoder: (data) {
        if (data is! List) {
          throw StateError('登录会话响应不是数组');
        }
        return data
            .map((item) {
              if (item is! Map) {
                throw StateError('登录会话条目格式无效');
              }
              return AuthDeviceSession.fromJson(
                Map<String, dynamic>.from(item),
              );
            })
            .toList(growable: false);
      },
    );
    return envelope.unwrapOrThrow();
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    final response = await dio.delete<Object>(
      LucentApiPaths.authSession(sessionId),
    );
    final raw = response.data;
    if (raw is Map<String, dynamic> && raw.containsKey('code')) {
      LucentEnvelope<Object?>.fromJson(raw).throwIfFailed();
    }
  }
}
