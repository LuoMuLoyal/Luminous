import 'package:luminous/features/support/data/repositories/lucent.dart';
import 'package:luminous/features/support/domain/entities/app_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resources.g.dart';

/// Fetches application metadata from `GET /api/v1/public/app-info`.
@riverpod
Future<AppInfo?> appInfo(Ref ref) async {
  final repo = ref.watch(supportRepositoryProvider);
  final result = await repo.getAppInfo().run();
  // Left 投影到 AsyncValue.error（Riverpod 捕获重抛的 failure）。
  return result.fold((failure) => throw failure, (info) => info);
}
