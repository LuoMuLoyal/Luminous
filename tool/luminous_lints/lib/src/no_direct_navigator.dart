import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Business code must not drive navigation through the Material `Navigator`
/// class (`Navigator.push/pop/pushNamed/...`, and `Navigator.of/maybeOf`,
/// which exist solely to reach the imperative `NavigatorState` API).
/// GoRouter is the only navigation entry in Luminous.
///
/// Allowed locations (whitelist):
/// - `lib/core/router/` (router bootstrap and observers);
/// - `lib/features/shell/` (the shell hosts the router outlet).
///
/// The check is syntactic (any `<target>.method(...)` invocation whose target
/// identifier is named `Navigator`); this keeps it deterministic and
/// independent of how Flutter was imported.
final class NoDirectNavigatorRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'no_direct_navigator',
    'Do not use the Material Navigator directly; GoRouter is the only '
        'navigation entry in Luminous.',
    correctionMessage:
        'Use `context.go` / `context.push` (GoRouter) or a router helper '
        'instead. Navigator is only allowed in lib/core/router/ and '
        'lib/features/shell/.',
    severity: DiagnosticSeverity.WARNING,
  );

  /// Directory prefixes (relative to `lib/`) where direct Navigator usage is
  /// allowed.
  static const List<String> _allowedPrefixes = [
    'lib/core/router/',
    'lib/features/shell/',
  ];

  NoDirectNavigatorRule()
    : super(
        name: 'no_direct_navigator',
        description:
            'Flags direct Material Navigator usage outside the router '
            'bootstrap; GoRouter is the only navigation entry.',
      );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _UnitVisitor(this, context));
  }

  /// Checks a single method [invocation] located at [filePath].
  ///
  /// Exposed as a static method so the repository sampling script can reuse
  /// the exact rule logic.
  static void checkMethodInvocation({
    required MethodInvocation invocation,
    required String filePath,
    required void Function(AstNode node) report,
  }) {
    final importer = libRelativePath(filePath);
    if (importer == null) return;
    for (final prefix in _allowedPrefixes) {
      if (importer.startsWith(prefix)) return;
    }

    final target = invocation.target;
    if (target is SimpleIdentifier && target.token.lexeme == 'Navigator') {
      report(invocation);
    }
  }
}

final class _UnitVisitor extends SimpleAstVisitor<void> {
  final NoDirectNavigatorRule rule;
  final RuleContext context;

  _UnitVisitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit unit) {
    final filePath =
        context.currentUnit?.file.path ?? context.definingUnit.file.path;
    unit.accept(
      _RecursiveMethodVisitor(filePath: filePath, report: rule.reportAtNode),
    );
  }
}

final class _RecursiveMethodVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final void Function(AstNode node) report;

  _RecursiveMethodVisitor({required this.filePath, required this.report});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    NoDirectNavigatorRule.checkMethodInvocation(
      invocation: node,
      filePath: filePath,
      report: report,
    );
    super.visitMethodInvocation(node);
  }
}
