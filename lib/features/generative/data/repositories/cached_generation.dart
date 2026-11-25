import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/generative/data/datasources/generation_cache.dart';
import 'package:luminous/features/generative/data/datasources/generation_remote.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 生成结果的仓储实现：远端生成 + 本地缓存。
///
/// 两条腿各管一件事，**不混在一起**：
/// - `generate` / `turn` 走远端（一次 LLM 调用，可能很慢，只能流式）；
/// - `read` / `write` / `clear` 走本地 `KvStore`（冷启动重放，零网络）。
///
/// 生成结果不落库，服务端只负责「一次生成」这个动作，持久化是客户端自己的事。
/// 所以这里不存在「远端读回历史结果」的分支。
///
/// 它不做校验：结构合法性由 `a2ui_core` 在渲染前判定（A2UI 1.0 取消了客户端的
/// 内容准入规则）。
final class CachedGenerationRepository implements GenerationRepository {
  CachedGenerationRepository(this._cache, this._remote);

  final GenerativeMessageCache _cache;
  final GenerationRemote _remote;

  @override
  Future<Either<LucentFailure, GenerativeSurfaceDocument?>> read(
    SurfaceId surface,
  ) => _cache.read(surface);

  @override
  Future<Either<LucentFailure, Unit>> write(
    GenerativeSurfaceDocument document,
  ) => _cache.write(document);

  @override
  Future<Either<LucentFailure, Unit>> clear(SurfaceId surface) =>
      _cache.clear(surface);

  /// 把远端事件流翻译成应用层的值。
  ///
  /// 两个 `GenerationRemoteEvent` 变体一一对应，没有兜底分支：`sealed` 让新增
  /// 变体变成编译错误，而不是运行期被静默丢掉的 chunk。
  @override
  Stream<GenerationStreamEvent> generate(GenerationRequest request) async* {
    final events = _remote.stream(
      surface: request.surface,
      prompt: request.prompt.text,
      range: request.range,
      capabilities: request.capabilities,
    );

    yield* _translate(events);
  }

  @override
  Stream<GenerationStreamEvent> turn(GenerationTurn turn) async* {
    yield* _translate(_remote.turn(turn));
  }

  Stream<GenerationStreamEvent> _translate(
    Stream<GenerationRemoteEvent> events,
  ) async* {
    await for (final event in events) {
      switch (event) {
        case GenerationRemoteChunk(:final message):
          yield GenerationStreamChunk(message);
        case GenerationRemoteResult(:final messages, :final dataModel):
          yield GenerationStreamResult(messages, dataModel: dataModel);
      }
    }
  }
}
