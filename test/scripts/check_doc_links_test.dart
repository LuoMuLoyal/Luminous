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

  group('checkDocFileLinks repo path existence', () {
    test(
      'reports missing lib/docs/plans tokens from inline code and prose',
      () {
        final (vault, _) = _createRepo(
          docsFiles: {
            'a.md':
                'See `lib/features/auth/login.dart` twice: '
                '`lib/features/auth/login.dart`, plus docs/missing/ref.md.\n',
          },
        );

        final problems = checkDocFileLinks(vault, vault.markdownFiles.single);

        // The inline token is reported once despite appearing twice; the
        // plain-text token keeps its trailing sentence period stripped.
        expect(problems, hasLength(2));
        expect(
          problems[0],
          'docs/a.md: path lib/features/auth/login.dart not found',
        );
        expect(problems[1], 'docs/a.md: path docs/missing/ref.md not found');
      },
    );

    test('passes for existing file, directory and anchored references', () {
      final (vault, _) = _createRepo(
        docsFiles: {
          'a.md':
              '`lib/app/router.dart`, `lib/features/`, `lib/core` and '
              'plain docs/README.md, plus `docs/TODO.md#top`.\n',
          'README.md': '# Docs\n',
          'TODO.md': '# TODO\n',
        },
        repoFiles: {
          'lib/app/router.dart': 'void main() {}\n',
          'lib/core/config.dart': '',
          'lib/features/auth/auth.dart': '',
        },
      );
      final aFile = vault.markdownFiles.firstWhere(
        (file) => vault.relativePath(file) == 'a.md',
      );

      final problems = checkDocFileLinks(vault, aFile);

      expect(problems, isEmpty);
    });

    test(
      'skips URLs, globs, placeholders, ellipsis, commands, bare prefixes',
      () {
        final (vault, _) = _createRepo(
          docsFiles: {
            'a.md':
                '`https://example.com/docs/x.md` and a plain URL tail at '
                'https://github.com/org/repo/blob/main/lib/a.dart; also '
                '`lib/features/**`, `lib/features/<feature>/`, `lib/foo...`, '
                '`docs/`, `lib` and the command `dart run scripts/x.dart`.\n',
          },
        );

        expect(checkDocFileLinks(vault, vault.markdownFiles.single), isEmpty);
      },
    );

    test('honors the explicit exemption list (slash optional)', () {
      final (vault, _) = _createRepo(
        docsFiles: {
          'a.md':
              'Legacy `lib/pages/`, `lib/stores/` trees; the `docs/tests` '
              'option; template `docs/logs/migration-log/YYYY-MM-DD.md`; '
              'renamed `lib/pages` and '
              '`lib/features/auth/presentation/providers/shared/'
              'auth_form_mixin.dart`.\n',
        },
      );

      expect(checkDocFileLinks(vault, vault.markdownFiles.single), isEmpty);
    });

    test('skips path tokens inside code fences', () {
      final (vault, _) = _createRepo(
        docsFiles: {'a.md': '# A\n```\nlib/missing/inside_fence.dart\n```\n'},
      );

      expect(checkDocFileLinks(vault, vault.markdownFiles.single), isEmpty);
    });

    test('sub-paths of larger references are not repo-relative tokens', () {
      final (vault, _) = _createRepo(
        docsFiles: {
          'a.md':
              'Lucent sibling doc: ../../../../Lucent/docs/other-ref.md '
              '(plain text, no backticks).\n',
        },
      );

      // `docs/other-ref.md` is preceded by `/` inside the larger reference
      // and must not be validated as a repo-relative path.
      expect(checkDocFileLinks(vault, vault.markdownFiles.single), isEmpty);
    });

    test('markdown link targets stay under vault-relative link semantics', () {
      final (vault, _) = _createRepo(
        docsFiles: {
          'sub/a.md': 'See [x](docs/vault.md).\n',
          // Exists vault-relative (docs/sub/docs/vault.md) but not at the
          // repo root — the link check owns this target, not the path check.
          'sub/docs/vault.md': '# V\n',
        },
      );
      final aFile = vault.markdownFiles.firstWhere(
        (file) => vault.relativePath(file) == 'sub/a.md',
      );

      expect(checkDocFileLinks(vault, aFile), isEmpty);
    });

    test('archive and migration-log keep link checks but skip path checks', () {
      final (vault, _) = _createRepo(
        docsFiles: {
          'archive/old.md': '`lib/definitely/missing.dart`\n',
          'logs/migration-log/2026-01-01.md': '`lib/definitely/missing.dart`\n',
          // The standing ledger index is NOT scoped out.
          'logs/MigrationLog.md': '`lib/definitely/missing.dart`\n',
        },
      );
      File? fileFor(String relative) => vault.markdownFiles
          .where((file) => vault.relativePath(file) == relative)
          .firstOrNull;

      expect(checkDocFileLinks(vault, fileFor('archive/old.md')!), isEmpty);
      expect(
        checkDocFileLinks(vault, fileFor('logs/migration-log/2026-01-01.md')!),
        isEmpty,
      );
      expect(checkDocFileLinks(vault, fileFor('logs/MigrationLog.md')!), [
        'docs/logs/MigrationLog.md: path lib/definitely/missing.dart not found',
      ]);
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

/// Creates a temp repo root containing a `docs/` vault with [docsFiles] and
/// additional repo files ([repoFiles], e.g. `lib/...`), for repo-path
/// existence tests. Returns the vault index and the repo root.
(VaultIndex, Directory) _createRepo({
  required Map<String, String> docsFiles,
  Map<String, String> repoFiles = const {},
}) {
  final tempRoot = Directory.systemTemp.createTempSync(
    'luminous-doc-repo-path-test-',
  );
  addTearDown(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });
  void writeAll(Map<String, String> files) {
    files.forEach((name, content) {
      File(
          '${tempRoot.path}${Platform.pathSeparator}'
          '${name.replaceAll('/', Platform.pathSeparator)}',
        )
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
    });
  }

  writeAll({
    for (final entry in docsFiles.entries) 'docs/${entry.key}': entry.value,
  });
  writeAll(repoFiles);
  return (
    VaultIndex(Directory('${tempRoot.path}${Platform.pathSeparator}docs')),
    tempRoot,
  );
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
