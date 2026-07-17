import '../../data/repositories/lucent.dart';
import '../../domain/entities/support_resource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Re-export so consumers can import from one place.
export '../../data/repositories/lucent.dart' show supportRepositoryProvider;

part 'resources.g.dart';

/// Fetches support resources filtered by [scope].
///
/// Backed by `GET /api/v1/public/support-resources?scope={scope}`.
@riverpod
Future<List<SupportResource>> supportResources(Ref ref, String scope) async {
  return ref.watch(supportRepositoryProvider).getResources(scope);
}

/// Fetches application metadata from `GET /api/v1/public/app-info`.
@riverpod
Future<AppInfo?> appInfo(Ref ref) async {
  return ref.watch(supportRepositoryProvider).getAppInfo();
}
