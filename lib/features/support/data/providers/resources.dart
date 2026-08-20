import 'package:luminous/features/support/data/repositories/lucent.dart';
import 'package:luminous/features/support/domain/entities/app_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resources.g.dart';

/// Fetches application metadata from `GET /api/v1/public/app-info`.
@riverpod
Future<AppInfo?> appInfo(Ref ref) async {
  return ref.watch(supportRepositoryProvider).getAppInfo();
}
