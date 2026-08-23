import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/auth/domain/entities/device_session.dart';
import 'package:luminous/features/auth/domain/repositories/sessions.dart';

class LucentAuthSessionsRepository implements AuthSessionsRepository {
  const LucentAuthSessionsRepository({required this.dio});

  final Dio dio;

  @override
  TaskEither<LucentFailure, List<AuthDeviceSession>> listSessions() {
    return TaskEither.tryCatch(() async {
      final response = await dio.get<Object>(LucentApiPaths.authSessions);
      final raw = response.data;
      if (raw is! List) {
        throw StateError('登录会话响应不是数组');
      }
      final items = raw as List<Object?>;
      return items
          .map((item) {
            if (item is! Map) {
              throw StateError('登录会话条目格式无效');
            }
            return AuthDeviceSession.fromJson(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> revokeSession(String sessionId) {
    return TaskEither.tryCatch(() async {
      await dio.delete<Object>(LucentApiPaths.authSession(sessionId));
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }
}
