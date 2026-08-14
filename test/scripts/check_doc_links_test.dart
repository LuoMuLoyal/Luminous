import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../scripts/check_doc_links.dart';

void main() {
  group('checkDocFileLinks', () {
    test('reports broken wikilinks and relative links', () {
      final vault = _createVault({
        'a.md': '# A\nSee [[missing]] and [gone](gone.md).\n',
      });

      final problems = checkDocFileLinks(vault, vault.markdownFiles.single);

      expect(problems, hasLength(2));
      expect(problems[0], contains('[[missing]]'));
      expect(problems[1], contains('gone.md'));
    });

    test('resolves wikilinks and relative links inside the vault', () {
      final vault = _createVault({
        'a.md': '# A\nSee [[b]] and [b](b.md).\n',
        'b.md': '# B\n',
      });
      final aFile = vault.markdownFiles.firstWhere(
        (file) => vault.relativePath(file) == 'a.md',
      );

      expect(checkDocFileLinks(vault, aFile), isEmpty);
    });

    test('skips external URLs, anchors and inline code', () {
      final vault = _createVault({
        'a.md':
            '# A\nSee [web](https://example.com), [x](#anchor) '
            'and `[[not-a-link]]`.\n',
      });

      expect(checkDocFileLinks(vault, vault.markdownFiles.single), isEmpty);
    });

    test('skips links inside code fences', () {
      final vault = _createVault({'a.md': '# A\n```\n[[not-a-link]]\n```\n'});

      expect(checkDocFileLinks(vault, vault.markdownFiles.single), isEmpty);
    });
  });
}

/// Creates a temp vault with the given file name -> content map.
VaultIndex _createVault(Map<String, String> files) {
  final tempRoot = Directory.systemTemp.createTempSync(
    'luminous-doc-links-test-',
  );
  addTearDown(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });
  files.forEach((name, content) {
    File('${tempRoot.path}${Platform.pathSeparator}$name')
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  });
  return VaultIndex(tempRoot);
}
