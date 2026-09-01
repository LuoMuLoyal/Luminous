import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// `firstWhere(...)` calls must provide an `orElse` callback.
///
/// Without `orElse`, a non-matching element throws an uncaught
/// `StateError` at runtime. The check is syntactic so it also covers chained
/// calls such as `items.where(...).firstWhere(...)`.
final class FirstWhereRequiresOrElseRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'first_where_requires_or_else',
    '`firstWhere` without `orElse` throws a StateError when no element '
        'matches.',
    correctionMessage:
        'Provide an `orElse:` callback, or use a nullable lookup such as '
        '`firstOrNull` and handle the null case.',
    severity: DiagnosticSeverity.WARNING,
  );

  FirstWhereRequiresOrElseRule()
    : super(
        name: 'first_where_requires_or_else',
        description:
            'Flags firstWhere calls that lack an orElse callback and would '
            'throw a StateError on a non-matching collection.',
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
    if (libRelativePath(filePath) == null) return;
    if (invocation.methodName.token.lexeme != 'firstWhere') return;

    final hasOrElse = invocation.argumentList.arguments.any(
      (argument) =>
          argument is NamedArgument && argument.name.lexeme == 'orElse',
    );
    if (!hasOrElse) {
      report(invocation.methodName);
    }
  }
}

final class _UnitVisitor extends SimpleAstVisitor<void> {
  final FirstWhereRequiresOrElseRule rule;
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
    FirstWhereRequiresOrElseRule.checkMethodInvocation(
      invocation: node,
      filePath: filePath,
      report: report,
    );
    super.visitMethodInvocation(node);
  }
}
