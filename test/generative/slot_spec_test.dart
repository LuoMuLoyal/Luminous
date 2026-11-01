import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/generative/domain/entities/slot_spec.dart';
import 'package:luminous/features/generative/presentation/providers/slot_spec.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

import '../helpers/kv_test_store.dart';

/// 自定义生成式区块的**声明**持久化。
///
/// 这条链路要保证的是「用户填一次，之后一直在」：声明独立于布局与生成结果
/// 存盘，恢复默认布局、清掉结果都不该把它带走。否则每次进编排页都要重打
/// 一遍标题与意图，那这个区块就等于没有配置能力。
void main() {
  setUpAll(() => KvTestStore.install(seed: const <String, Object>{}));

  late ProviderContainer container;

  setUp(() async {
    await KvStore.instance.clear();
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  GenerativeSlotSpecController controller(SurfaceId s) =>
      container.read(generativeSlotSpecProvider(s).notifier);

  GenerativeSlotSpec? read(SurfaceId s) =>
      container.read(generativeSlotSpecProvider(s));

  test('starts unconfigured', () {
    expect(read(SurfaceId.today), isNull);
  });

  test('save persists across a fresh container', () async {
    await controller(
      SurfaceId.today,
    ).save(const GenerativeSlotSpec(title: '本周饮水', prompt: '两张并排的小卡'));

    // 新容器模拟冷启动：只靠 KV 也要读得回来。
    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    expect(
      fresh.read(generativeSlotSpecProvider(SurfaceId.today)),
      const GenerativeSlotSpec(title: '本周饮水', prompt: '两张并排的小卡'),
    );
  });

  test('per-surface isolation', () async {
    await controller(
      SurfaceId.today,
    ).save(const GenerativeSlotSpec(title: 'A', prompt: 'a'));

    expect(read(SurfaceId.review), isNull);
  });

  test('clear removes the declaration', () async {
    await controller(
      SurfaceId.today,
    ).save(const GenerativeSlotSpec(title: 'A', prompt: 'a'));
    await controller(SurfaceId.today).clear();

    expect(read(SurfaceId.today), isNull);

    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    expect(fresh.read(generativeSlotSpecProvider(SurfaceId.today)), isNull);
  });

  test('empty title or prompt is not a usable declaration', () {
    expect(
      const GenerativeSlotSpec(title: '  ', prompt: 'x').isUsable,
      isFalse,
    );
    expect(const GenerativeSlotSpec(title: 'x', prompt: ' ').isUsable, isFalse);
    expect(GenerativeSlotSpec.fromJson({'title': '', 'prompt': 'x'}), isNull);
  });

  test('corrupt payload reads as unconfigured, not a crash', () async {
    // 坏掉的一份声明不该让编排页打不开。
    await KvStore.instance.set('genui.today.spec', '{not json');
    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    expect(fresh.read(generativeSlotSpecProvider(SurfaceId.today)), isNull);
  });
}
