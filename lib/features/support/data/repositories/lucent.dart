import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/response_body.dart';
import 'package:luminous/features/support/domain/entities/app_info.dart';
import 'package:luminous/features/support/domain/repositories/support.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent.g.dart';

@riverpod
SupportRepository supportRepository(Ref ref) {
  return LucentSupportRepository(api: ref.watch(lucentClientProvider).appInfo);
}

/// Lucent-backed implementation of [SupportRepository].
class LucentSupportRepository implements SupportRepository {
  LucentSupportRepository({required this.api});

  final AppInfoApi api;

  @override
  Future<AppInfo?> getAppInfo() async {
    final response = await api.appInfoControllerGetAppInfoV1();
    final d = requireData(response.data, operation: 'getAppInfo');
    return AppInfo(
      minClientVersion: d.minClientVersion,
      latestVersion: d.latestVersion,
      downloadUrl: d.downloadUrl,
      supportEmail: d.supportEmail,
    );
  }
}
