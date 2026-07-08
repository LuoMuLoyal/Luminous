import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/network_providers.dart';

/// Cross-feature data adapter for public support resources and app metadata.
///
/// `features/support` intentionally has no domain or presentation layer: it
/// only exposes Riverpod providers that wrap generated Lucent APIs. These
/// providers are consumed by `mine`, `settings`, and `medicine`.

/// Fetches support resources filtered by [scope].
///
/// Backed by `GET /api/v1/public/support-resources?scope={scope}`.
final supportResourcesProvider = FutureProvider.autoDispose
    .family<List<SupportResourceDto>, String>((ref, scope) async {
      final api = ref.read(lucentSupportResourcesApiProvider);
      final response = await api.supportResourcesControllerGetResourcesV1(
        scope: Scope.fromJson(scope),
      );
      return response.data.items;
    });

/// Fetches application metadata from `GET /api/v1/public/app-info`.
final appInfoProvider = FutureProvider.autoDispose<AppInfoDataDto?>((
  ref,
) async {
  final api = ref.read(lucentSupportResourcesApiProvider);
  final response = await api.supportResourcesControllerGetAppInfoV1();
  return response.data;
});
