import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/error_code.dart';
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
        throw LucentFailure.network(
          message: 'Session list response is not an array.',
          networkErrorCode: NetworkErrorCode.emptyResponse,
        );
      }
      final items = raw as List<Object?>;
      return items
          .map((item) {
            if (item is! Map) {
              throw LucentFailure.network(
                message: 'Session list item is not an object.',
                networkErrorCode: NetworkErrorCode.emptyResponse,
              );
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
