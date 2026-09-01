import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Switch statements over an enum value must carry an unknown-safe fallback
/// branch: a `default` clause, a wildcard (`_`) pattern, a `null` pattern, or
/// an explicit branch for an enum constant named `unknown`.
///
/// New enum values and unknown server payloads must fail safe instead of
/// falling through silently. Switch statements are not exhaustiveness-checked
/// by the compiler, so a silently-skipped new value is a real runtime risk.
/// Dart 3 switch **expressions** are exempt: the compiler enforces
/// exhaustiveness there, so adding an enum value breaks compilation at every
/// matching site instead of falling through.
/// A switch whose scrutinee type cannot be resolved is skipped.
final class EnumParseUnknownBranchRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'enum_parse_unknown_branch',
    'Switch over enum value has no fallback branch.',
    correctionMessage:
        'Add a `_` wildcard, a `null` branch, or an explicit `unknown` enum '
        'branch so new or unknown values fail safe.',
    severity: DiagnosticSeverity.WARNING,
  );

  EnumParseUnknownBranchRule()
    : super(
        name: 'enum_parse_unknown_branch',
        description:
            'Flags switches over enum values that lack a default, wildcard, '
            'null, or explicit unknown branch.',
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

  /// Checks a single switch [node] located at [filePath].
  ///
  /// Exposed as a static method so the repository sampling script can reuse
  /// the exact rule logic.
  static void checkSwitch({
    required AstNode node,
    required String filePath,
    required void Function(AstNode node) report,
  }) {
    if (libRelativePath(filePath) == null) return;

    final Expression scrutinee;
    final bool hasFallback;
    switch (node) {
      case final SwitchStatement statement:
        scrutinee = statement.expression;
        hasFallback = statement.members.any(_memberHasFallback);
      // Switch expressions are exempt: Dart 3 enforces exhaustiveness on them
      // at compile time, so they cannot silently skip a new enum value.
      default:
        return;
    }

    if (!switchesOverEnum(scrutinee)) return;
    if (hasFallback) return;
    report(node);
  }

  /// Whether the switch scrutinee's static type is an enum type.
  static bool switchesOverEnum(Expression scrutinee) {
    final type = scrutinee.staticType;
    if (type is! InterfaceType) return false;
    return type.element is EnumElement;
  }

  static bool _memberHasFallback(SwitchMember member) {
    if (member is SwitchDefault) return true;
    if (member is SwitchPatternCase) {
      return _patternHasFallback(member.guardedPattern.pattern);
    }
    // Legacy expression-based `case expr:` members.
    if (member is SwitchCase) {
      final expression = member.expression;
      return _isUnknownExpression(expression) ||
          _isWildcardIdentifier(expression) ||
          expression is NullLiteral;
    }
    return false;
  }

  /// Whether [expression] is the bare `_` identifier used by the legacy
  /// `case _:` member form.
  static bool _isWildcardIdentifier(Expression expression) =>
      expression is SimpleIdentifier && expression.token.lexeme == '_';

  /// Whether [pattern] provides an unknown-safe fallback.
  static bool _patternHasFallback(DartPattern pattern) {
    switch (pattern) {
      case WildcardPattern():
        return true;
      case DeclaredVariablePattern(name: final name):
        return name.lexeme == '_';
      case ConstantPattern(expression: final expression):
        return expression is NullLiteral || _isUnknownExpression(expression);
      case ParenthesizedPattern(pattern: final inner):
        return _patternHasFallback(inner);
      case CastPattern(pattern: final inner):
        return _patternHasFallback(inner);
      case NullCheckPattern(pattern: final inner):
        return _patternHasFallback(inner);
      case NullAssertPattern(pattern: final inner):
        return _patternHasFallback(inner);
      case LogicalOrPattern():
        return _patternHasFallback(pattern.leftOperand) ||
            _patternHasFallback(pattern.rightOperand);
      default:
        return false;
    }
  }

  /// Whether [expression] refers to a constant named `unknown` (for example
  /// `Status.unknown` or a top-level `unknown` constant).
  static bool _isUnknownExpression(Expression expression) {
    if (expression is SimpleIdentifier) {
      return expression.token.lexeme.toLowerCase() == 'unknown';
    }
    if (expression is PrefixedIdentifier) {
      return expression.identifier.token.lexeme.toLowerCase() == 'unknown';
    }
    return false;
  }
}

final class _UnitVisitor extends SimpleAstVisitor<void> {
  final EnumParseUnknownBranchRule rule;
  final RuleContext context;

  _UnitVisitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit unit) {
    final filePath =
        context.currentUnit?.file.path ?? context.definingUnit.file.path;
    unit.accept(
      _RecursiveSwitchVisitor(filePath: filePath, report: rule.reportAtNode),
    );
  }
}

final class _RecursiveSwitchVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final void Function(AstNode node) report;

  _RecursiveSwitchVisitor({required this.filePath, required this.report});

  @override
  void visitSwitchStatement(SwitchStatement node) {
    EnumParseUnknownBranchRule.checkSwitch(
      node: node,
      filePath: filePath,
      report: report,
    );
    super.visitSwitchStatement(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    EnumParseUnknownBranchRule.checkSwitch(
      node: node,
      filePath: filePath,
      report: report,
    );
    super.visitSwitchExpression(node);
  }
}
