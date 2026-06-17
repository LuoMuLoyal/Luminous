import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';

/// Fetches support resources filtered by [scope].
///
/// Backed by `GET /api/v1/public/support-resources?scope={scope}`.
final supportResourcesProvider = FutureProvider.autoDispose
    .family<List<SupportResourceDto>, String>((ref, scope) async {
  final api = ref.read(lucentSupportResourcesApiProvider);
  final response =
      await api.supportResourcesControllerGetResourcesV1(scope: scope);
  return response.data?.data.items ?? const <SupportResourceDto>[];
});

/// Fetches application metadata from `GET /api/v1/public/app-info`.
final appInfoProvider =
    FutureProvider.autoDispose<AppInfoDataDto?>((ref) async {
  final api = ref.read(lucentSupportResourcesApiProvider);
  final response =
      await api.supportResourcesControllerGetAppInfoV1();
  return response.data?.data;
});
