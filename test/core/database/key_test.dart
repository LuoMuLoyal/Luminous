import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/key.dart';

/// [DatabaseKeyProvider] 的契约测试。
///
/// 关键不变量：
/// - 密钥是 32 字节原始随机量（SQLCipher 的 256-bit key），不是字符串再编码；
/// - 同一安装内重复读取返回同一把密钥（否则库会被写坏）；
/// - 存储不可用时抛错，绝不返回兜底明文密钥。
void main() {
  group('DatabaseKeyProvider', () {
    test('generates a 32-byte key on first use and persists it', () async {
      final storage = _MemorySecureStorage();
      final provider = DatabaseKeyProvider(storage: storage);

      final key = await provider.key();

      expect(key, hasLength(DatabaseKeyProvider.keyLength));
      expect(storage.values[DatabaseKeyProvider.storageKey], isNotNull);
    });

    test('returns the same key on subsequent reads', () async {
      final storage = _MemorySecureStorage();
      final provider = DatabaseKeyProvider(storage: storage);

      final first = await provider.key();
      final second = await DatabaseKeyProvider(storage: storage).key();

      expect(second, equals(first));
    });

    test('exists is false before the key is created', () async {
      final provider = DatabaseKeyProvider(storage: _MemorySecureStorage());
      expect(await provider.exists(), isFalse);
    });

    test('exists is true after the key is created', () async {
      final storage = _MemorySecureStorage();
      final provider = DatabaseKeyProvider(storage: storage);
      await provider.key();
      expect(await provider.exists(), isTrue);
    });

    test('distinct installs get distinct keys', () async {
      final a = await DatabaseKeyProvider(
        storage: _MemorySecureStorage(),
      ).key();
      final b = await DatabaseKeyProvider(
        storage: _MemorySecureStorage(),
      ).key();
      expect(a, isNot(equals(b)));
    });

    test(
      'throws instead of returning a fallback when storage read fails',
      () async {
        final provider = DatabaseKeyProvider(storage: _ThrowingSecureStorage());
        expect(provider.key(), throwsA(isA<DatabaseKeyException>()));
      },
    );

    test('spreads bytes across the range', () async {
      final provider = DatabaseKeyProvider(
        storage: _MemorySecureStorage(),
        random: Random(7),
      );
      final key = await provider.key();
      expect(key.toSet().length, greaterThan(1));
    });
  });

  group('sqlCipherKeyExpression', () {
    test('renders raw bytes as a hex blob literal', () {
      final key = Uint8List.fromList([0x00, 0x1f, 0xff, 0x80]);
      expect(sqlCipherKeyExpression(key), "x'001fff80'");
    });

    test('produces 64 hex chars for a 32-byte key', () {
      final key = Uint8List(DatabaseKeyProvider.keyLength);
      final expr = sqlCipherKeyExpression(key);
      expect(expr.length, 2 + DatabaseKeyProvider.keyLength * 2 + 1);
    });
  });
}

/// In-memory stand-in for [FlutterSecureStorage].
///
/// Only `read`/`write` are exercised; everything else falls through
/// `noSuchMethod`, which keeps the fake independent of the platform-specific
/// option types in the real signature.
class _MemorySecureStorage implements FlutterSecureStorage {
  final Map<String, String> values = {};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final args = invocation.namedArguments;
    final key = args[#key] as String?;
    if (key == null) return Future<dynamic>.value();

    if (invocation.memberName == #read) {
      return Future<String?>.value(values[key]);
    }
    if (invocation.memberName == #write) {
      final value = args[#value] as String?;
      if (value == null) {
        values.remove(key);
      } else {
        values[key] = value;
      }
      return Future<void>.value();
    }
    return Future<dynamic>.value();
  }
}

/// Storage whose reads always fail, standing in for an unavailable Keychain.
class _ThrowingSecureStorage implements FlutterSecureStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #read) {
      return Future<String?>.error(StateError('secure storage unavailable'));
    }
    return Future<dynamic>.value();
  }
}
