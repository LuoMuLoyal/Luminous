// l10n/arb_tools.dart — ARB 文件拆分 / 合并工具
//
// NOTE: This script uses synchronous IO because it is designed to run
// from the command line only. Do not use these functions from a Flutter
// isolate/UI thread.
//
// 用法:
//   dart scripts/l10n/arb_tools.dart split   — 将 app_{zh,en}.arb 拆分到 lib/l10n/src/
//   dart scripts/l10n/arb_tools.dart merge   — 将 lib/l10n/src/*_{zh,en}.arb 合并为 app_{zh,en}.arb
//
// 拆分规则: 按 key 前缀分类，@ 开头的元数据键跟随对应值键。

import 'dart:convert';
import 'dart:io';

/// 分片名称 → 匹配前缀列表
///
/// 新增功能模块时，在此处添加一行即可。
const Map<String, List<String>> fragmentRules = {
  'common': ['app', 'tab', 'desktop', 'state', 'placeholder', 'legal'],
  'network': ['network'],
  'record': ['record'],
  'medicine': ['medicine', 'scan'],
  'today': ['today'],
  'review': ['review'],
  'settings': ['settings', 'sidebar'],
  'auth': ['auth'],
  'mine': ['mine'],
  'assistant': ['assistant'],
  'notification': ['notification'],
  'health_sync': ['health_sync'],
};

const List<String> locales = ['zh', 'en'];

const String l10nDir = 'lib/l10n';
const String srcDir = 'lib/l10n/src';

// ---------------------------------------------------------------------------
// split
// ---------------------------------------------------------------------------

Future<void> runSplit() async {
  print('Splitting ARB files…');

  // 确保目标目录存在
  final srcDirPath = Directory(srcDir);
  if (!srcDirPath.existsSync()) {
    await srcDirPath.create(recursive: true);
  }

  for (final locale in locales) {
    final inputFile = File('$l10nDir/app_$locale.arb');
    if (!inputFile.existsSync()) {
      print('  [skip] ${inputFile.path} not found');
      continue;
    }

    final raw = inputFile.readAsStringSync();
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;

    // 按分片名称分桶
    final Map<String, Map<String, dynamic>> buckets = {
      for (final name in fragmentRules.keys) name: <String, dynamic>{},
    };
    // 未匹配到任何规则的 key 放入 common
    final Map<String, dynamic> common = buckets['common']!;

    for (final entry in json.entries) {
      final key = entry.key;

      // @@locale 直接跳过，merge 时会重新添加
      if (key == '@@locale') continue;

      // @ 开头的元数据键跟随对应值键
      final baseKey = key.startsWith('@') ? key.substring(1) : key;

      // 查找匹配的分片
      String? matched;
      for (final rule in fragmentRules.entries) {
        for (final prefix in rule.value) {
          if (baseKey == prefix || baseKey.startsWith(prefix)) {
            matched = rule.key;
            break;
          }
        }
        if (matched != null) break;
      }

      final bucket = matched != null ? buckets[matched]! : common;
      bucket[key] = entry.value;
    }

    // 写入分片文件
    for (final entry in buckets.entries) {
      final name = entry.key;
      final data = entry.value;
      if (data.isEmpty) {
        print('  [skip] $name\_$locale.arb — empty');
        continue;
      }

      final outFile = File('$srcDir/${name}_$locale.arb');
      outFile.writeAsStringSync(_prettyJson(data, locale));
      print('  [ok] ${outFile.path} — ${data.length} entries');
    }
  }

  print('\nDone. Source ARB fragments are in $srcDir/');
}

// ---------------------------------------------------------------------------
// merge
// ---------------------------------------------------------------------------

Future<void> runMerge() async {
  print('Merging ARB fragments…');

  final srcDirPath = Directory(srcDir);
  if (!srcDirPath.existsSync()) {
    print('  [error] $srcDir does not exist. Run "split" first.');
    exit(1);
  }

  for (final locale in locales) {
    final Map<String, dynamic> merged = {};
    // 先放 @@locale
    merged['@@locale'] = locale;

    // 按分片名称的声明顺序读取，保证输出稳定
    int totalEntries = 0;

    for (final name in fragmentRules.keys) {
      final fragmentFile = File('$srcDir/${name}_$locale.arb');
      if (!fragmentFile.existsSync()) {
        print('  [skip] ${fragmentFile.path} not found');
        continue;
      }

      final raw = fragmentFile.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;

      for (final entry in data.entries) {
        if (entry.key == '@@locale') continue;
        if (merged.containsKey(entry.key)) {
          print(
            '  [warn] duplicate key "${entry.key}" in ${fragmentFile.path}',
          );
        }
        merged[entry.key] = entry.value;
        totalEntries++;
      }
    }

    final outFile = File('$l10nDir/app_$locale.arb');
    outFile.writeAsStringSync(_prettyJson(merged, locale));
    print('  [ok] ${outFile.path} — $totalEntries entries');
  }

  print('\nDone. Merged ARB files written to $l10nDir/');
  print('Now run: flutter gen-l10n');
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

String _prettyJson(Map<String, dynamic> data, String locale) {
  final buffer = StringBuffer();
  buffer.writeln('{');

  final entries = data.entries.toList();
  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    final key = jsonEncode(entry.key);
    final value = _encodeValue(entry.value, indent: '  ');
    buffer.writeln('  $key: $value${i < entries.length - 1 ? ',' : ''}');
  }

  buffer.writeln('}');
  return buffer.toString();
}

String _encodeValue(dynamic value, {required String indent}) {
  if (value is String) {
    return jsonEncode(value);
  } else if (value is Map<String, dynamic>) {
    if (value.isEmpty) return '{}';
    final buffer = StringBuffer('{');
    final entries = value.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final childIndent = '$indent  ';
      final key = jsonEncode(entry.key);
      final encodedValue = _encodeValue(entry.value, indent: childIndent);
      buffer.writeln();
      buffer.write(
        '$childIndent$key: $encodedValue${i < entries.length - 1 ? ',' : ''}',
      );
    }
    buffer.writeln();
    buffer.write('$indent}');
    return buffer.toString();
  } else {
    return jsonEncode(value);
  }
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

void main(List<String> args) async {
  final command = args.isNotEmpty ? args.first : '';

  switch (command) {
    case 'split':
      await runSplit();
      break;
    case 'merge':
      await runMerge();
      break;
    default:
      print('arb_tools.dart — ARB 文件拆分 / 合并工具\n');
      print('Usage:');
      print(
        '  dart scripts/l10n/arb_tools.dart split   — 将 app_{zh,en}.arb 拆分到 lib/l10n/src/',
      );
      print(
        '  dart scripts/l10n/arb_tools.dart merge   — 将 lib/l10n/src/*_{zh,en}.arb 合并为 app_{zh,en}.arb',
      );
      exit(1);
  }
}
