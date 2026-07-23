import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/data/datasources/safety_tips_remote.dart';
import 'package:luminous/features/medicine/domain/entities/safety_tip.dart';
import 'package:luminous/features/medicine/presentation/providers/safety_tips.dart';
import 'package:mocktail/mocktail.dart';

class _MockSafetyTipsRemoteDataSource extends Mock
    implements SafetyTipsRemoteDataSource {}

void main() {
  late _MockSafetyTipsRemoteDataSource mockDataSource;

  const tipA = MedicineSafetyTip(id: 'a', text: 'Tip A', category: 'c1');
  const tipB = MedicineSafetyTip(id: 'b', text: 'Tip B', category: 'c2');
  const tipC = MedicineSafetyTip(id: 'c', text: 'Tip C', category: 'c1');

  ProviderContainer buildContainer() {
    final c = ProviderContainer(
      overrides: [
        safetyTipsRemoteDataSourceProvider.overrideWithValue(mockDataSource),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    mockDataSource = _MockSafetyTipsRemoteDataSource();
  });

  group('MedicineSafetyTipListNotifier', () {
    test('build fetches tips with empty excludeIds', () async {
      when(
        () => mockDataSource.fetchTips(excludeIds: any(named: 'excludeIds')),
      ).thenAnswer((_) async => [tipA, tipB]);

      final c = buildContainer();
      final tips = await c.read(medicineSafetyTipListProvider.future);

      expect(tips.length, 2);
      expect(tips[0].id, 'a');
      expect(tips[1].id, 'b');

      verify(() => mockDataSource.fetchTips(excludeIds: [])).called(1);
    });

    test('refresh passes current tip ids as excludeIds', () async {
      // First fetch
      when(
        () => mockDataSource.fetchTips(excludeIds: any(named: 'excludeIds')),
      ).thenAnswer((_) async => [tipA, tipB]);

      final c = buildContainer();
      await c.read(medicineSafetyTipListProvider.future);

      // Second fetch on refresh — should exclude 'a' and 'b'
      when(
        () => mockDataSource.fetchTips(excludeIds: any(named: 'excludeIds')),
      ).thenAnswer((_) async => [tipC]);

      await c.read(medicineSafetyTipListProvider.notifier).refresh();

      final tips = c.read(medicineSafetyTipListProvider).value!;
      expect(tips.length, 1);
      expect(tips[0].id, 'c');

      verify(() => mockDataSource.fetchTips(excludeIds: ['a', 'b'])).called(1);
    });

    test('refresh with no previous tips uses empty excludeIds', () async {
      when(
        () => mockDataSource.fetchTips(excludeIds: any(named: 'excludeIds')),
      ).thenAnswer((_) async => []);

      final c = buildContainer();
      await c.read(medicineSafetyTipListProvider.future);

      when(
        () => mockDataSource.fetchTips(excludeIds: any(named: 'excludeIds')),
      ).thenAnswer((_) async => [tipA]);

      await c.read(medicineSafetyTipListProvider.notifier).refresh();

      final tips = c.read(medicineSafetyTipListProvider).value!;
      expect(tips.length, 1);
      expect(tips[0].id, 'a');

      verify(() => mockDataSource.fetchTips(excludeIds: [])).called(2);
    });

    test('state transitions to loading then data on refresh', () async {
      when(
        () => mockDataSource.fetchTips(excludeIds: any(named: 'excludeIds')),
      ).thenAnswer((_) async => [tipA]);

      final c = buildContainer();
      await c.read(medicineSafetyTipListProvider.future);

      // Start refresh — don't await yet
      final refreshFuture = c
          .read(medicineSafetyTipListProvider.notifier)
          .refresh();

      // Should be loading
      expect(c.read(medicineSafetyTipListProvider).isLoading, isTrue);

      await refreshFuture;

      // Should have data
      expect(c.read(medicineSafetyTipListProvider).hasValue, isTrue);
      expect(c.read(medicineSafetyTipListProvider).value!.length, 1);
    });

    test('handles fetch error gracefully', () async {
      when(
        () => mockDataSource.fetchTips(excludeIds: any(named: 'excludeIds')),
      ).thenThrow(Exception('Network error'));

      final c = buildContainer();

      // Read the provider — should end up in error state
      c.read(medicineSafetyTipListProvider);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = c.read(medicineSafetyTipListProvider);
      expect(state.hasError, isTrue);
    });
  });
}
