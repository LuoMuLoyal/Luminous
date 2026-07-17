import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/lucent.dart';
import '../../domain/entities/support_resource.dart';

/// Re-export so consumers can import from one place.
export '../../data/repositories/lucent.dart' show supportRepositoryProvider;

/// Fetches support resources filtered by [scope].
///
/// Backed by `GET /api/v1/public/support-resources?scope={scope}`.
final supportResourcesProvider = FutureProvider.autoDispose
    .family<List<SupportResource>, String>((ref, scope) async {
      return ref.watch(supportRepositoryProvider).getResources(scope);
    });

/// Fetches application metadata from `GET /api/v1/public/app-info`.
final appInfoProvider = FutureProvider.autoDispose<AppInfo?>((ref) async {
  return ref.watch(supportRepositoryProvider).getAppInfo();
});
