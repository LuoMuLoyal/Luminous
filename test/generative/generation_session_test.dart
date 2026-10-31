import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/generative/application/orchestrators/generation_session.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/features/generative/domain/services/item_catalog.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:luminous/shared/domain/generative/data_scope.dart';

/// 内存仓储替身：`GenerationSession` 是纯逻辑，落盘行为在这里可控。
final class _FakeRepository implements GenerationRepository {
  _FakeRepository({this.seed});

  GenerativeSurfaceDocument? seed;
  bool failReads = false;
  bool failWrites = false;
  int writeCount = 0;
  int clearCount = 0;

  @override
  Future<Either<LucentFailure, GenerativeSurfaceDocument?>> read(
    SurfaceId surface,
  ) async {
    if (failReads) {
      return Left(LucentFailure.business(message: 'read_failed'));
    }
    return Right(seed);
  }

  @override
  Future<Either<LucentFailure, Unit>> write(
    GenerativeSurfaceDocument document,
  ) async {
    writeCount++;
    if (failWrites) {
      return Left(LucentFailure.business(message: 'write_failed'));
    }
    seed = document;
    return const Right(unit);
  }

  @override
  Future<Either<LucentFailure, Unit>> clear(SurfaceId surface) async {
    clearCount++;
    seed = null;
    return const Right(unit);
  }
}

const _scope = DataScope(
  surface: SurfaceId.review,
  entries: [
    DataScopeEntry(
      key: 'water',
      kind: DataScopeKind.metric,
      description: 'Water intake.',
    ),
  ],
);

GenerationSession _session(_FakeRepository repository) => GenerationSession(
  surface: SurfaceId.review,
  repository: repository,
  scope: _scope,
  policyVariants: buildPolicyVariants(),
);

/// 一条最小的合法消息序列：createSurface + 一个合法 metric_card。
List<Map<String, Object?>> _messages({Object? kind = 'water'}) => [
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
          'component': 'Column',
          'children': ['card'],
        },
        {'id': 'card', 'component': 'metric_card', 'kind': kind},
      ],
    },
  },
];

void main() {
  group('冷启动恢复', () {
    test('没有缓存 → Idle（不渲染）', () async {
      final session = _session(_FakeRepository());
      expect(await session.restore(), isA<GenerationIdle>());
    });

    test('有缓存 → Ready 且带回文档', () async {
      final repository = _FakeRepository(
        seed: GenerativeSurfaceDocument(
          surface: SurfaceId.review,
          messages: _messages(),
          generatedAt: DateTime(2026),
        ),
      );
      final state = await _session(repository).restore();
      expect(state, isA<GenerationReady>());
      expect((state as GenerationReady).document.messages, hasLength(2));
    });

    test('空文档等同于没有生成过', () async {
      final repository = _FakeRepository(
        seed: GenerativeSurfaceDocument(
          surface: SurfaceId.review,
          messages: const [],
          generatedAt: DateTime(2026),
        ),
      );
      expect(await _session(repository).restore(), isA<GenerationIdle>());
    });

    test('缓存损坏 → 失败态但不抛', () async {
      final repository = _FakeRepository()..failReads = true;
      expect(await _session(repository).restore(), isA<GenerationFailed>());
    });
  });

  group('生成过程', () {
    test('begin 进入 InFlight', () {
      final session = _session(_FakeRepository());
      session.begin();
      expect(session.state, isA<GenerationInFlight>());
    });

    test('合法消息 → Ready，并写入仓储', () async {
      final repository = _FakeRepository();
      final session = _session(repository);

      session.begin();
      final state = await session.commit(_messages());

      expect(state, isA<GenerationReady>());
      expect(repository.writeCount, 1);
      expect(repository.seed, isNotNull);
    });

    test('违规消息 → Failed，且不写仓储', () async {
      final repository = _FakeRepository();
      final session = _session(repository);

      session.begin();
      // kind 是编造的数字：agent 想把数值直接塞进来。
      final state = await session.commit(_messages(kind: 1800));

      expect(state, isA<GenerationFailed>());
      expect(repository.writeCount, 0);
    });

    test('失败保留上一份结果', () async {
      final repository = _FakeRepository();
      final session = _session(repository);

      await session.commit(_messages());
      final failed = await session.commit(_messages(kind: 1800));

      expect(failed, isA<GenerationFailed>());
      expect((failed as GenerationFailed).document, isNotNull);
    });

    test('写缓存失败不影响本次展示', () async {
      final repository = _FakeRepository()..failWrites = true;
      final session = _session(repository);

      final state = await session.commit(_messages());
      expect(state, isA<GenerationReady>());
    });

    test('解析失败 → fail() 保留上一份', () async {
      final session = _session(_FakeRepository());
      await session.commit(_messages());

      final state = session.fail(StateError('bad json'));
      expect(state, isA<GenerationFailed>());
      expect((state as GenerationFailed).document, isNotNull);
    });
  });

  group('恢复默认', () {
    test('清掉生成结果并回到 Idle', () async {
      final repository = _FakeRepository();
      final session = _session(repository);
      await session.commit(_messages());

      final state = await session.reset();
      expect(state, isA<GenerationIdle>());
      expect(repository.clearCount, 1);
      expect(repository.seed, isNull);
    });

    test('组合根的结论是「恢复默认连带清生成结果」', () {
      expect(shouldClearGeneratedSurfaceAfterReset(), isTrue);
    });
  });
}
