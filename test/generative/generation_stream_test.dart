import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/composition/a2ui/a2ui.dart';
import 'package:luminous/features/generative/application/orchestrators/generation_session.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:luminous/shared/domain/generative/range_key.dart';

/// SSE 事件流 → 生成态。
///
/// 这里**不触网**：`GenerationRepository` 是接口，替身直接产出事件流，正好隔离
/// 「远端把帧映射成值」与「应用层怎么消费这些值」两件事。真正的 SSE 帧解析
/// （`event:` / `data:` 切分）由 `core/network/client/sse.dart` 负责，已有它自己
/// 的测试；本文件验的是**在它之上**的分派语义。
void main() {
  group('生成流 → 状态迁移', () {
    test('chunk 逐条到达、result 落地 → Ready 且写缓存', () async {
      final repository = _ScriptedRepository(
        events: [
          const GenerationStreamChunk({
            'version': '1.0',
            'updateComponents': {
              'surfaceId': 'generative.review',
              'components': [
                {'id': 'root', 'component': 'Text', 'text': '进度反馈'},
              ],
            },
          }),
          GenerationStreamResult(_validMessages()),
        ],
      );
      final session = _session(repository);

      expect(session.state, isA<GenerationIdle>(), reason: '未开始前是 Idle');

      session.begin();
      expect(session.state, isA<GenerationInFlight>());

      var chunkCount = 0;
      await for (final event in repository.generate(_request())) {
        switch (event) {
          case GenerationStreamChunk():
            chunkCount++;
          case GenerationStreamResult(:final messages):
            await session.commit(messages);
        }
      }

      expect(chunkCount, 1, reason: '每个 chunk 事件都该被消费到');
      expect(session.state, isA<GenerationReady>());
      expect(repository.writeCount, 1, reason: 'Ready 的结果必须写缓存供冷启动重放');
    });

    test('result 的形状错误 → 本次失败，保留上一份结果', () async {
      final previous = GenerativeSurfaceDocument(
        surface: SurfaceId.review,
        messages: _validMessages(),
        generatedAt: DateTime(2026),
      );
      final repository = _ScriptedRepository(
        events: [GenerationStreamResult(_validMessages())],
        seed: previous,
      );
      final session = _session(repository);

      await session.restore();
      expect(session.state, isA<GenerationReady>());

      final failed = session.fail(const FormatException('result 形状不对'));

      expect(failed, isA<GenerationFailed>());
      expect(
        (failed as GenerationFailed).document,
        same(previous),
        reason: '失败必须保留上一份，渲染层据此继续显示旧内容',
      );
    });

    test('流在 result 之前结束 → 不得停留在 InFlight', () async {
      final repository = _ScriptedRepository(
        events: [
          const GenerationStreamChunk({'version': '1.0'}),
        ],
      );
      final session = _session(repository);
      session.begin();

      var sawResult = false;
      await for (final event in repository.generate(_request())) {
        if (event is GenerationStreamResult) sawResult = true;
      }

      expect(sawResult, isFalse);
      // 应用层必须显式收尾，否则页面永远停在骨架。
      final settled = session.fail(const _StreamEnded());
      expect(settled, isA<GenerationFailed>());
    });

    test('result 带回 dataModel → 一并落地', () async {
      final repository = _ScriptedRepository(
        events: [
          GenerationStreamResult(
            _validMessages(),
            dataModel: const {
              'generative.review': {'dose': 2},
            },
          ),
        ],
      );
      final session = _session(repository);

      await for (final event in repository.generate(_request())) {
        if (event case GenerationStreamResult(
          :final messages,
          :final dataModel,
        )) {
          await session.commit(messages, dataModel: dataModel);
        }
      }

      expect(session.state, isA<GenerationReady>());
      expect(repository.seed?.dataModel, isNotNull);
    });

    test('交互回合与生成走同一条事件流形状', () async {
      final repository = _ScriptedRepository(
        events: [
          // 用户点了 agent 下发的 Button：渲染端上行一条 action。
          const GenerationStreamChunk({
            'version': '1.0',
            'updateDataModel': {
              'surfaceId': 'generative.review',
              'path': '/confirmed',
              'value': true,
            },
          }),
          GenerationStreamResult(_validMessages()),
        ],
      );
      final session = _session(repository);
      await session.commit(_validMessages());

      await for (final event in repository.turn(_turn())) {
        if (event case GenerationStreamResult(:final messages)) {
          await session.commit(messages);
        }
      }

      expect(session.state, isA<GenerationReady>());
      expect(repository.turnCount, 1);
    });
  });
}

/// 按脚本产出事件流的仓储替身。
final class _ScriptedRepository implements GenerationRepository {
  _ScriptedRepository({required this.events, this.seed});

  final List<GenerationStreamEvent> events;
  GenerativeSurfaceDocument? seed;
  int writeCount = 0;
  int turnCount = 0;

  @override
  Future<Either<LucentFailure, GenerativeSurfaceDocument?>> read(
    SurfaceId surface,
  ) async => Right(seed);

  @override
  Future<Either<LucentFailure, Unit>> write(
    GenerativeSurfaceDocument document,
  ) async {
    writeCount++;
    seed = document;
    return const Right(unit);
  }

  @override
  Future<Either<LucentFailure, Unit>> clear(SurfaceId surface) async {
    seed = null;
    return const Right(unit);
  }

  @override
  Stream<GenerationStreamEvent> generate(GenerationRequest request) async* {
    for (final event in events) {
      yield event;
    }
  }

  @override
  Stream<GenerationStreamEvent> turn(GenerationTurn turn) async* {
    turnCount++;
    for (final event in events) {
      yield event;
    }
  }
}

GenerationSession _session(_ScriptedRepository repository) =>
    GenerationSession(surface: SurfaceId.review, repository: repository);

GenerationRequest _request() => const GenerationRequest(
  surface: SurfaceId.review,
  prompt: GenerationPrompt(text: '把饮水做成三张卡'),
  range: RangeKey.last7Days,
);

GenerationTurn _turn() => GenerationTurn(
  surface: SurfaceId.review,
  messages: const [
    {
      'version': '1.0',
      'action': {'name': 'confirm', 'surfaceId': 'generative.review'},
    },
  ],
  document: GenerativeSurfaceDocument(
    surface: SurfaceId.review,
    messages: _validMessages(),
    generatedAt: DateTime(2026),
  ),
);

/// 一条最小的合法 v1.0 序列：建 surface + 一棵 Text 树。
List<Map<String, Object?>> _validMessages() => [
  {
    'version': '1.0',
    'createSurface': {
      'surfaceId': 'generative.review',
      'catalogId': GenerativeCatalog.defaultCatalogId,
      'sendDataModel': true,
    },
  },
  {
    'version': '1.0',
    'updateComponents': {
      'surfaceId': 'generative.review',
      'components': [
        {
          'id': 'root',
          'component': 'Column',
          'children': ['water'],
        },
        {'id': 'water', 'component': 'Text', 'text': '饮水 1800ml'},
      ],
    },
  },
];

/// 流在收到 `result` 前结束。
final class _StreamEnded implements Exception {
  const _StreamEnded();
}
