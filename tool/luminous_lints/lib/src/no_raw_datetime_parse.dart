import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Direct `DateTime.parse(...)` calls must go through the project's safe
/// date-time wrappers.
///
/// `DateTime.parse` throws `FormatException` on malformed input (for example
/// a partially populated server payload). The Luminous app provides safe
/// wrappers in `lib/core/utils/date_format.dart`:
///
/// - `parseDateTimeOrNull(Object? value)` - returns `null` instead of
///   throwing;
/// - `parseDateTimeOrEpoch(Object? value, {DateTime? fallback})` - falls back
///   to a non-null default instead of throwing.
final class NoRawDatetimeParseRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'no_raw_datetime_parse',
    'DateTime.parse throws FormatException on malformed input.',
    correctionMessage:
        'Use the project safe wrappers parseDateTimeOrNull() or '
        'parseDateTimeOrEpoch() from package:luminous/core/utils/'
        'date_format.dart instead.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoRawDatetimeParseRule()
    : super(
        name: 'no_raw_datetime_parse',
        description:
            'Flags direct DateTime.parse calls and points to the project '
            'safe date-time wrappers.',
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

    final target = invocation.target;
    if (target is SimpleIdentifier &&
        target.token.lexeme == 'DateTime' &&
        invocation.methodName.token.lexeme == 'parse') {
      report(invocation);
    }
  }
}

final class _UnitVisitor extends SimpleAstVisitor<void> {
  final NoRawDatetimeParseRule rule;
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
    NoRawDatetimeParseRule.checkMethodInvocation(
      invocation: node,
      filePath: filePath,
      report: report,
    );
    super.visitMethodInvocation(node);
  }
}
