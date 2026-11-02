import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/generative/application/orchestrators/generation_session.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/features/generative/domain/services/item_catalog.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:luminous/shared/domain/generative/data_scope.dart';

/// A7b 数据/状态层验收：SSE 事件流 → 生成态。
///
/// 这里**不触网**：`GenerationRepository` 是接口，替身直接产出事件流，正好隔离
/// 「远端把帧映射成值」与「应用层怎么消费这些值」两件事。真正的 SSE 帧解析
/// （`event:` / `data:` 切分）由 `core/network/client/sse.dart` 负责，已有它
/// 自己的测试；本文件验的是**在它之上**的分派语义。
void main() {
  group('生成流 → 状态迁移', () {
    test('chunk 逐条到达、result 落地 → Ready 且写缓存', () async {
      final repository = _ScriptedRepository(
        events: [
          const GenerationStreamChunk({
            'version': 'v0.9',
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

    test('result 缺失消息序列 → 本次生成失败，保留上一份结果', () async {
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
      // 模拟「服务端中途关连接」：repository 只给 chunk，没有 result。
      final repository = _ScriptedRepository(
        events: [
          const GenerationStreamChunk({'version': 'v0.9'}),
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

    test('违规消息 → 整次失败，不写缓存', () async {
      final repository = _ScriptedRepository(events: const []);
      final session = _session(repository);

      // `metric_card` 带数值是安全边界的红线：整次失败而不是剔除。
      final state = await session.commit([
        {
          'version': 'v0.9',
          'createSurface': {
            'surfaceId': 'generative.review',
            'catalogId': 'com.luminous.generative',
          },
        },
        {
          'version': 'v0.9',
          'updateComponents': {
            'surfaceId': 'generative.review',
            'components': [
              {
                'id': 'root',
                'component': 'metric_card',
                'kind': 'water',
                'value': 1800,
              },
            ],
          },
        },
      ]);

      expect(state, isA<GenerationFailed>());
      expect(repository.writeCount, 0, reason: '被拒的结果不能进缓存，否则冷启动会重放一棵违规的树');
    });

    test('被拒的 chunk 可跳过，但最终 result 仍然生效', () async {
      // 一条坏 chunk 不该判死整次生成：result 是权威序列，会完整重放。
      final repository = _ScriptedRepository(
        events: [
          // 不是合法的 A2UI 消息（缺 version / 变体键）。
          const GenerationStreamChunk({'foo': 'bar'}),
          GenerationStreamResult(_validMessages()),
        ],
      );
      final session = _session(repository);

      GenerationState? settled;
      await for (final event in repository.generate(_request())) {
        if (event is GenerationStreamResult) {
          settled = await session.commit(event.messages);
        }
      }

      expect(settled, isA<GenerationReady>());
    });
  });
}

/// 按脚本产出事件流的仓储替身。
final class _ScriptedRepository implements GenerationRepository {
  _ScriptedRepository({required this.events, this.seed});

  final List<GenerationStreamEvent> events;
  GenerativeSurfaceDocument? seed;
  int writeCount = 0;

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
}

const _scope = DataScope(
  surface: SurfaceId.review,
  entries: [
    DataScopeEntry(
      key: 'water',
      kind: DataScopeKind.metric,
      description: 'Water intake.',
      allowedRanges: [RangeKey.last7Days, RangeKey.last30Days],
    ),
  ],
);

GenerationSession _session(_ScriptedRepository repository) => GenerationSession(
  surface: SurfaceId.review,
  repository: repository,
  scope: _scope,
  policyVariants: buildPolicyVariants(),
);

GenerationRequest _request() => const GenerationRequest(
  surface: SurfaceId.review,
  prompt: GenerationPrompt(text: '把饮水做成三张卡'),
  scope: _scope,
);

/// 一条最小的合法序列：建 surface + 一个合法 `metric_card`。
List<Map<String, Object?>> _validMessages() => [
  {
    'version': 'v0.9',
    'createSurface': {
      'surfaceId': 'generative.review',
      'catalogId': 'com.luminous.generative',
      'sendDataModel': false,
    },
  },
  {
    'version': 'v0.9',
    'updateComponents': {
      'surfaceId': 'generative.review',
      'components': [
        {
          'id': 'root',
          'component': 'Column',
          'children': ['water'],
        },
        {'id': 'water', 'component': 'metric_card', 'kind': 'water'},
      ],
    },
  },
];

/// 流在收到 `result` 前结束。
final class _StreamEnded implements Exception {
  const _StreamEnded();
}
