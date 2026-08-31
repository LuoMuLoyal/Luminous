import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../scripts/check_doc_links.dart';

void main() {
  group('filterChangedDocs', () {
    test('keeps vault markdown paths only, in vault-relative form', () {
      expect(
        filterChangedDocs([
          'docs/TODO.md',
          'docs/logs/migration-log/2026-08-14.md',
          'lib/features/auth/login_page.dart',
          'docs/README.md',
        ]),
        ['TODO.md', 'logs/migration-log/2026-08-14.md', 'README.md'],
      );
    });

    test('excludes .obsidian files', () {
      expect(filterChangedDocs(['docs/.obsidian/workspace.json']), isEmpty);
    });
  });

  group('collectDocChangeSet', () {
    test('pure rename (git mv) reports the old path as deleted', () async {
      final repo = _createGitRepo({
        'docs/a.md': '# A\n',
        'docs/other.md': '# Other\n',
      });
      _runGit(repo, ['mv', 'docs/a.md', 'docs/b.md']);

      final changeSet = await collectDocChangeSet(repo);

      // deletedDocs non-empty is what main() checks to fall back to the
      // full vault — without --no-renames a pure rename would be missed.
      expect(changeSet.deletedDocs, contains('a.md'));
      expect(changeSet.changedDocs, containsAll(['a.md', 'b.md']));
    });

    test('plain deletion reports the deleted doc', () async {
      final repo = _createGitRepo({
        'docs/a.md': '# A\n',
        'docs/other.md': '# Other\n',
      });
      _runGit(repo, ['rm', 'docs/a.md']);

      final changeSet = await collectDocChangeSet(repo);

      expect(changeSet.deletedDocs, ['a.md']);
      expect(changeSet.changedDocs, contains('a.md'));
    });

    test('edit-only changes leave deletedDocs empty', () async {
      final repo = _createGitRepo({
        'docs/a.md': '# A\n',
        'docs/other.md': '# Other\n',
      });
      File(
        '${repo.path}${Platform.pathSeparator}docs${Platform.pathSeparator}a.md',
      ).writeAsStringSync('# A edited\n');

      final changeSet = await collectDocChangeSet(repo);

      expect(changeSet.deletedDocs, isEmpty);
      expect(changeSet.changedDocs, ['a.md']);
    });
  });

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

/// Creates a temp git repo with [files] committed, for change-set tests.
Directory _createGitRepo(Map<String, String> files) {
  final tempRoot = Directory.systemTemp.createTempSync(
    'luminous-doc-changeset-test-',
  );
  addTearDown(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });
  _runGit(tempRoot, ['init']);
  files.forEach((name, content) {
    File('${tempRoot.path}${Platform.pathSeparator}$name')
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  });
  _runGit(tempRoot, ['add', '.']);
  _runGit(tempRoot, [
    '-c',
    'user.name=Test',
    '-c',
    'user.email=test@example.com',
    '-c',
    'commit.gpgsign=false',
    'commit',
    '-m',
    'init',
  ]);
  return tempRoot;
}

/// Runs [args] in [repo], failing the test on a non-zero exit.
void _runGit(Directory repo, List<String> args) {
  final result = Process.runSync('git', args, workingDirectory: repo.path);
  if (result.exitCode != 0) {
    fail('git ${args.join(' ')} failed:\n${result.stderr}');
  }
}
