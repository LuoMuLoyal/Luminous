import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Switch statements over a **server-derived** enum value must carry an
/// unknown-safe fallback branch: a `default` clause, a wildcard (`_`) pattern, a
/// `null` pattern, or an explicit branch for an enum constant named `unknown`
/// (including the OpenAPI generator's `unknownDefaultOpenApi` sentinel).
///
/// Only enums declared outside the host app count as server-derived — in
/// practice the enums of the generated API client. Those are the only ones that
/// can carry a value the host app has never heard of, because the server may
/// return a variant added after this client was built.
///
/// Switches over the host app's own enums are deliberately **not** reported:
/// such an enum is white-box, every matching switch is compiled together with
/// it, and a switch statement over an enum with no fallback is a genuine
/// compile-time invitation to handle a newly added constant. Adding a `default`
/// there would be dead code that silently swallows that future constant instead
/// of surfacing it as a break at every site.
///
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
            'Flags switches over server-derived (generated-client) enum values '
            'that lack a default, wildcard, null, or explicit unknown branch.',
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
    required Uri? unitUri,
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

    if (!switchesOverServerDerivedEnum(scrutinee, unitUri)) return;
    if (hasFallback) return;
    report(node);
  }

  /// Whether the scrutinee's static type is an enum declared **outside** the
  /// package that [unitUri] belongs to — the only kind that can carry a value
  /// this code never saw.
  ///
  /// Local enums are white-box: their switches compile together with the enum,
  /// so a missing fallback surfaces a newly added constant at compile time
  /// rather than silently mis-handling a runtime value.
  static bool switchesOverServerDerivedEnum(
    Expression scrutinee,
    Uri? unitUri,
  ) {
    final type = scrutinee.staticType;
    if (type is! InterfaceType) return false;
    final element = type.element;
    if (element is! EnumElement) return false;
    return !_isInSamePackageAs(element, unitUri);
  }

  /// Whether [element] is declared by the same package as the linted unit.
  ///
  /// Package identity is compared as the *library* part of each URI rather than
  /// against the literal string `luminous`: the same source tree resolves to
  /// `package:luminous/...` in the real app and to `package:test/...` under
  /// `analyzer_testing`, and the rule must behave identically in both. A
  /// dependency such as the generated API client (`package:lucent_api/...`) has
  /// a different library prefix, and so counts as external.
  static bool _isInSamePackageAs(Element element, Uri? unitUri) {
    final uri = element.firstFragment.libraryFragment?.source.uri;
    if (uri == null) return false;
    if (uri.scheme != 'package') return true;
    final enumPackage = _packageOf(uri.path);
    final unitPackage = unitUri?.scheme == 'package'
        ? _packageOf(unitUri!.path)
        : null;
    if (enumPackage == null || unitPackage == null) return false;
    return enumPackage == unitPackage;
  }

  /// Extracts the package name from a `package:` URI path
  /// (`lucent_api/src/model/x.dart` → `lucent_api`).
  static String? _packageOf(String path) {
    final slash = path.indexOf('/');
    return slash <= 0 ? null : path.substring(0, slash);
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
  ///
  /// Also accepts the OpenAPI generator's unknown-value sentinel
  /// `unknownDefaultOpenApi` (and any name merely *starting* with `unknown`):
  /// the generated client collapses every unrecognised server value into that
  /// single constant, so branching on it is exactly the unknown-safe handling
  /// this rule asks for. Matching only the exact lexeme `unknown` would report
  /// sites that already handle the unknown case correctly.
  ///
  /// Three spellings must be covered, because the same constant parses
  /// differently by arity:
  /// - `unknown` / `Status.unknown` — [SimpleIdentifier] / [PrefixedIdentifier];
  /// - `lucent.Status.unknownDefaultOpenApi` — a three-segment qualified name
  ///   is a [PropertyAccess], not a [PrefixedIdentifier].
  static bool _isUnknownExpression(Expression expression) {
    if (expression is SimpleIdentifier) {
      return _startsWithUnknown(expression.token.lexeme);
    }
    if (expression is PrefixedIdentifier) {
      return _startsWithUnknown(expression.identifier.token.lexeme);
    }
    if (expression is PropertyAccess) {
      return _startsWithUnknown(expression.propertyName.token.lexeme);
    }
    return false;
  }

  /// Whether [name] marks an unknown-safe constant: `unknown`,
  /// `unknownDefaultOpenApi`, and any other `unknown*` variant.
  static bool _startsWithUnknown(String name) =>
      name.toLowerCase().startsWith('unknown');
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
      _RecursiveSwitchVisitor(
        filePath: filePath,
        // The unit's own URI identifies which package we are linting, so the
        // rule can tell a host-app enum from a dependency's without hardcoding
        // the app's package name.
        unitUri: unit
            .declaredFragment
            ?.element
            .firstFragment
            .libraryFragment
            ?.source
            .uri,
        report: rule.reportAtNode,
      ),
    );
  }
}

final class _RecursiveSwitchVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final Uri? unitUri;
  final void Function(AstNode node) report;

  _RecursiveSwitchVisitor({
    required this.filePath,
    required this.unitUri,
    required this.report,
  });

  @override
  void visitSwitchStatement(SwitchStatement node) {
    EnumParseUnknownBranchRule.checkSwitch(
      node: node,
      filePath: filePath,
      unitUri: unitUri,
      report: report,
    );
    super.visitSwitchStatement(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    EnumParseUnknownBranchRule.checkSwitch(
      node: node,
      filePath: filePath,
      unitUri: unitUri,
      report: report,
    );
    super.visitSwitchExpression(node);
  }
}
