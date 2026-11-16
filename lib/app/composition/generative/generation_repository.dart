import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/generative/data/datasources/generation_cache.dart';
import 'package:luminous/features/generative/data/datasources/generation_remote.dart';
import 'package:luminous/features/generative/data/repositories/cached_generation.dart';
import 'package:luminous/features/generative/data/repositories/cached_slot_spec.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/features/generative/domain/repositories/slot_spec.dart';

/// 生成式 UI 的远端数据源装配。
///
/// 它需要 `Dio`（SSE 走裸 dio，生成客户端表达不了事件流）——那是 `core/`
/// 基础设施，`presentation/` 与 `data/` 都不该自己去看它，所以装配落在组合根。
final generationRemoteProvider = Provider<GenerationRemote>((ref) {
  return LucentGenerationRemote(dio: ref.watch(lucentDioClientProvider).dio);
});

/// 生成结果仓储的装配点：远端 + 本地缓存。
///
/// 与 `customizer` 的 `layoutRepositoryProvider` 同构——`application/` 只声明
/// 「需要一个 [GenerationRepository]」，谁来实现由这里决定（分层门禁 R3 不允许
/// `application/` import `data/` 与 `core/`）。
final generationRepositoryProvider = Provider<GenerationRepository>((ref) {
  return CachedGenerationRepository(
    GenerativeMessageCache(KvStore.instance),
    ref.watch(generationRemoteProvider),
  );
});

/// 自定义 genui 区块声明的仓储装配点（只在 `KvStore` 上读写）。
///
/// 与 [generationRepositoryProvider] 并列而不是合一：声明与生成结果的生命周期
/// 相反——清生成结果不动声明，清声明才连带作废结果。
final slotSpecRepositoryProvider = Provider<SlotSpecRepository>((ref) {
  return CachedSlotSpecRepository(KvStore.instance);
});
