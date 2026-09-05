import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/app_info.dart';
import '../../domain/repositories/support.dart';

part 'lucent.g.dart';

@riverpod
SupportRepository supportRepository(Ref ref) {
  return LucentSupportRepository(api: ref.watch(lucentClientProvider).appInfo);
}

/// Lucent-backed implementation of [SupportRepository].
///
/// Every expected recoverable failure (network, server business failure) is a
/// `TaskEither` Left produced via `LucentErrorMapper.fromObject`; a successful
/// response is a Right. The endpoint returns an object whose fields may all be
/// unconfigured (env driven) — that is a Right carrying an [AppInfo] with null
/// fields, not a failure. An empty success response body is a
/// `LucentFailure.network(emptyResponse)` (settings / notification
/// `_requireData` precedent). Protocol violations (non `problem+json` error
/// bodies) keep the mapper's `FormatException` which propagates from
/// `.run()`.
class LucentSupportRepository implements SupportRepository {
  LucentSupportRepository({required this.api});

  final AppInfoApi api;

  @override
  TaskEither<LucentFailure, AppInfo?> getAppInfo() {
    return TaskEither.tryCatch(() async {
      final response = await api.getAppInfo();
      final d = _requireData(response.data, operation: 'getAppInfo');
      return AppInfo(
        minClientVersion: d.minClientVersion,
        latestVersion: d.latestVersion,
        downloadUrl: d.downloadUrl,
        supportEmail: d.supportEmail,
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// Extracts a non-null generated-client payload, throwing
  /// [LucentFailure.network] (emptyResponse) when the success body is absent
  /// (settings / notification `_requireData` precedent).
  T _requireData<T>(T? data, {String? operation}) {
    if (data == null) {
      final context = operation != null ? ' ($operation)' : '';
      throw LucentFailure.network(
        message: 'Empty response body$context',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
  }
}
