import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/features/search/data/datasources/recent_searches.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const store = RecentSearchesLocalPreferences();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load returns an empty list when nothing is stored', () async {
    expect(await store.load(), isEmpty);
  });

  test('load returns persisted keywords latest-first', () async {
    SharedPreferences.setMockInitialValues({
      PrefKeys.medicineSearchRecentKeywords: ['布洛芬', '阿司匹林'],
    });

    expect(await store.load(), ['布洛芬', '阿司匹林']);
  });

  test('add persists the keyword at the front', () async {
    final updated = await store.add('布洛芬');

    expect(updated, ['布洛芬']);
    expect(await store.load(), ['布洛芬']);
  });

  test('add moves an existing keyword to the front (dedup)', () async {
    await store.add('阿司匹林');
    await store.add('布洛芬');
    final updated = await store.add('阿司匹林');

    expect(updated, ['阿司匹林', '布洛芬']);
    expect(updated, hasLength(2));
  });

  test('add caps the list at 10, dropping the oldest', () async {
    for (var i = 1; i <= 10; i++) {
      await store.add('keyword $i');
    }

    // 11th add must drop 'keyword 1' (the oldest).
    final updated = await store.add('keyword 11');

    expect(updated, hasLength(10));
    expect(updated.first, 'keyword 11');
    expect(updated, isNot(contains('keyword 1')));
    expect(updated.last, 'keyword 2');
  });

  test('clear removes all persisted keywords', () async {
    await store.add('布洛芬');
    await store.add('阿司匹林');

    await store.clear();

    expect(await store.load(), isEmpty);
  });

  test('persisted keywords survive across store instances', () async {
    await store.add('布洛芬');
    await store.add('阿司匹林');

    // A fresh instance must read back what the previous one wrote.
    final reloaded = await const RecentSearchesLocalPreferences().load();

    expect(reloaded, ['阿司匹林', '布洛芬']);
  });
}
