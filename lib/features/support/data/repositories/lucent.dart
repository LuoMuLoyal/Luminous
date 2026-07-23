import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/support/domain/entities/support_resource.dart';
import 'package:luminous/features/support/domain/repositories/support.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent.g.dart';

@riverpod
SupportRepository supportRepository(Ref ref) {
  return LucentSupportRepository(
    api: ref.watch(lucentClientProvider).supportResources,
  );
}

/// Lucent-backed implementation of [SupportRepository].
class LucentSupportRepository implements SupportRepository {
  LucentSupportRepository({required this.api});

  final SupportResourcesApi api;

  @override
  Future<List<SupportResource>> getResources(String scope) async {
    final response = await api.supportResourcesControllerGetResourcesV1(
      scope: Scope.fromJson(scope),
    );
    return response.data.items.map(_mapResource).toList();
  }

  @override
  Future<AppInfo?> getAppInfo() async {
    final response = await api.supportResourcesControllerGetAppInfoV1();
    final d = response.data;
    return AppInfo(
      name: d.name,
      version: d.version,
      description: d.description,
      buildDate: d.buildDate,
      minClientVersion: d.minClientVersion,
      supportEmail: d.supportEmail,
    );
  }

  SupportResource _mapResource(SupportResourceDto dto) {
    return SupportResource(
      id: dto.id,
      title: dto.title,
      titleKey: dto.titleKey,
      subtitle: dto.subtitle,
      subtitleKey: dto.subtitleKey,
      icon: dto.icon,
      actionUrl: dto.actionUrl,
      actionType: SupportResourceAction.fromJson(dto.actionType?.json),
      available: dto.available,
    );
  }
}
