import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Data-layer files (path contains `/data/`) must not force-unwrap nullable
/// values with `!`.
///
/// The data layer is the system boundary: a broken server payload must be
/// converted into a domain failure instead of crashing with a
/// `TypeError`/`Null` assertion. The `response.data!` pattern is the most
/// common offender. Non-data layers are intentionally out of scope.
final class NoBangOnResponseDataRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'no_bang_on_response_data',
    'Do not force-unwrap with `!` in data-layer code; a malformed payload '
        'must map to a domain failure, not crash.',
    correctionMessage:
        'Check for null explicitly and return a domain failure (for example '
        'LucentFailure.network with an empty-response code) instead of '
        'writing `response.data!`.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoBangOnResponseDataRule()
    : super(
        name: 'no_bang_on_response_data',
        description:
            'Flags `!` force-unwrapping inside data-layer files, most '
            'notably the `response.data!` pattern.',
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

  /// Checks a single postfix [expression] located at [filePath].
  ///
  /// Exposed as a static method so the repository sampling script can reuse
  /// the exact rule logic.
  static void checkPostfixExpression({
    required PostfixExpression expression,
    required String filePath,
    required void Function(AstNode node) report,
  }) {
    final importer = libRelativePath(filePath);
    if (importer == null || !isDataLayerPath(importer)) return;
    if (expression.operator.lexeme != '!') return;
    report(expression);
  }
}

final class _UnitVisitor extends SimpleAstVisitor<void> {
  final NoBangOnResponseDataRule rule;
  final RuleContext context;

  _UnitVisitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit unit) {
    final filePath =
        context.currentUnit?.file.path ?? context.definingUnit.file.path;
    unit.accept(
      _RecursivePostfixVisitor(filePath: filePath, report: rule.reportAtNode),
    );
  }
}

final class _RecursivePostfixVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final void Function(AstNode node) report;

  _RecursivePostfixVisitor({required this.filePath, required this.report});

  @override
  void visitPostfixExpression(PostfixExpression node) {
    NoBangOnResponseDataRule.checkPostfixExpression(
      expression: node,
      filePath: filePath,
      report: report,
    );
    super.visitPostfixExpression(node);
  }
}
