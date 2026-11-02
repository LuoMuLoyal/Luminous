import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/connection_io.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// `requireCipherEngine` 的契约：它回答的是「当前链接进来的 SQLite 能不能加密」。
///
/// 决定这条断言的是构建配置（`pubspec.yaml` 的
/// `hooks.user_defines.sqlite3.source`），不是运行时逻辑——所以测试断言的是
/// **它与真实引擎一致**，而不是某个写死的布尔值：
/// 引擎有 `cipher` pragma 时通过，没有时给出 failure 而不是抛异常。
void main() {
  test('reports the same answer as the loaded sqlite build', () {
    final db = sqlite3.sqlite3.openInMemory();
    addTearDown(db.close);

    final expected = _hasCipherPragma(db);
    final result = requireCipherEngine(db);

    expect(result.isRight(), expected);
    if (!expected) {
      expect(result.getLeft().toNullable()?.message, contains('sqlite3mc'));
    }
  });

  test('never throws, whatever the engine is', () {
    final db = sqlite3.sqlite3.openInMemory();
    addTearDown(db.close);

    expect(() => requireCipherEngine(db), returnsNormally);
  });
}

bool _hasCipherPragma(sqlite3.Database db) {
  try {
    db.select('PRAGMA cipher');
    return true;
  } on sqlite3.SqliteException {
    return false;
  }
}
