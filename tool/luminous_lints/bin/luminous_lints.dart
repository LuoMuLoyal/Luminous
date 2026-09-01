// CLI driver for the Luminous lint rules.
//
// The rules are also shipped as an analysis-server plugin (see lib/main.dart),
// but the host app's dependency graph currently pins analyzer 12.x (freezed)
// while the analysis server requires the plugin to match its in-process
// analyzer (14.1.0), so in-IDE integration is deferred. This driver runs the
// exact same rule logic (the static check* methods) over the host app's `lib/`
// tree from the plugin package's own dependency context.
//
// Usage (from tool/luminous_lints/):
//   dart run bin/luminous_lints.dart [--fatal] [--quiet] [<target-dir>]
//
// Default target is the host app's `lib/` directory. Without `--fatal` the
// driver always exits 0 (observation mode); `--fatal` exits 1 when any finding
// is reported (for future gate integration). `--quiet` prints only the
// per-rule summary (used by pre-push / daily checks to keep output short).
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:luminous_lints/luminous_lints.dart';

/// Default fallback copy for rules whose message carries no interpolated
/// argument (the layered_import rule reports its own description).
const Map<String, String> _ruleCopy = {
  'no_direct_navigator':
      'Direct Material Navigator usage; GoRouter is the only navigation entry.',
  'first_where_requires_or_else':
      '`firstWhere` without `orElse` throws a StateError when no element matches.',
  'no_bang_on_response_data':
      '`!` force-unwrap inside data-layer code; a malformed payload must map '
      'to a domain failure, not crash.',
  'empty_catch_requires_comment':
      'Empty catch block swallows the error silently.',
  'enum_parse_unknown_branch': 'Switch over enum value has no fallback branch.',
  'no_raw_datetime_parse':
      '`DateTime.parse` throws FormatException on malformed input.',
};

void main(List<String> args) async {
  final fatal = args.contains('--fatal');
  final quiet = args.contains('--quiet');
  final targetArg = args.where((a) => !a.startsWith('-')).firstOrNull;
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  final target = targetArg ?? '$scriptDir/../../../lib';
  final targetPathRaw = Directory(target).absolute.path;

  if (!Directory(targetPathRaw).existsSync()) {
    stderr.writeln('Target directory does not exist: $targetPathRaw');
    exit(2);
  }

  // Normalize `..` segments; the analyzer only accepts absolute normalized
  // paths.
  final targetPath = Directory(targetPathRaw).resolveSymbolicLinksSync();

  final findings = <_Finding>[];
  final collection = AnalysisContextCollection(includedPaths: [targetPath]);
  var fileCount = 0;

  for (final context in collection.contexts) {
    for (final path in context.contextRoot.analyzedFiles()) {
      if (!path.endsWith('.dart')) continue;
      final result = await context.currentSession.getResolvedUnit(path);
      if (result is! ResolvedUnitResult) continue;
      fileCount++;
      result.unit.accept(
        _RuleDriverVisitor(
          filePath: path,
          report: (rule, node, arguments) {
            final lineInfo = result.unit.lineInfo;
            final loc = lineInfo.getLocation(node.offset);
            findings.add(
              _Finding(
                rule: rule,
                filePath: path,
                line: loc.lineNumber,
                column: loc.columnNumber,
                message: arguments.isEmpty
                    ? (_ruleCopy[rule] ?? '')
                    : arguments.join(' '),
              ),
            );
          },
        ),
      );
    }
  }

  findings.sort((a, b) {
    final byPath = a.filePath.compareTo(b.filePath);
    if (byPath != 0) return byPath;
    return a.line.compareTo(b.line);
  });
  if (!quiet) {
    for (final finding in findings) {
      final rel = _relativize(finding.filePath);
      stdout.writeln(
        '$rel:${finding.line}:${finding.column} '
        '[${finding.rule}] ${finding.message}',
      );
    }
  }

  final byRule = <String, int>{};
  for (final finding in findings) {
    byRule[finding.rule] = (byRule[finding.rule] ?? 0) + 1;
  }
  stdout.writeln('');
  stdout.writeln(
    'luminous_lints: ${findings.length} finding(s) across $fileCount file(s).',
  );
  for (final rule in byRule.keys.toList()..sort()) {
    stdout.writeln('  $rule: ${byRule[rule]}');
  }
  stdout.writeln(
    findings.isEmpty
        ? 'observation mode: clean.'
        : 'observation mode: findings are warnings (run with --fatal to gate).',
  );
  exit(fatal && findings.isNotEmpty ? 1 : 0);
}

String _relativize(String path) {
  final normalized = path.replaceAll('\\', '/');
  final index = normalized.indexOf('/lib/');
  return index < 0 ? normalized : normalized.substring(index + 1);
}

class _Finding {
  const _Finding({
    required this.rule,
    required this.filePath,
    required this.line,
    required this.column,
    required this.message,
  });

  final String rule;
  final String filePath;
  final int line;
  final int column;
  final String message;
}

final class _RuleDriverVisitor extends RecursiveAstVisitor<void> {
  _RuleDriverVisitor({required this.filePath, required this.report});

  final String filePath;
  final void Function(String rule, AstNode node, List<Object> arguments) report;

  @override
  void visitImportDirective(ImportDirective node) {
    LayeredImportRule.checkImport(
      directive: node,
      filePath: filePath,
      report: (node, arguments) => report('layered_import', node, arguments),
    );
    super.visitImportDirective(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    NoDirectNavigatorRule.checkMethodInvocation(
      invocation: node,
      filePath: filePath,
      report: (n) => report('no_direct_navigator', n, const []),
    );
    FirstWhereRequiresOrElseRule.checkMethodInvocation(
      invocation: node,
      filePath: filePath,
      report: (n) => report('first_where_requires_or_else', n, const []),
    );
    NoRawDatetimeParseRule.checkMethodInvocation(
      invocation: node,
      filePath: filePath,
      report: (n) => report('no_raw_datetime_parse', n, const []),
    );
    super.visitMethodInvocation(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    NoBangOnResponseDataRule.checkPostfixExpression(
      expression: node,
      filePath: filePath,
      report: (n) => report('no_bang_on_response_data', n, const []),
    );
    super.visitPostfixExpression(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    EmptyCatchRequiresCommentRule.checkCatchClause(
      clause: node,
      filePath: filePath,
      report: (n) => report('empty_catch_requires_comment', n, const []),
    );
    super.visitCatchClause(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    EnumParseUnknownBranchRule.checkSwitch(
      node: node,
      filePath: filePath,
      report: (n) => report('enum_parse_unknown_branch', n, const []),
    );
    super.visitSwitchStatement(node);
  }
}
