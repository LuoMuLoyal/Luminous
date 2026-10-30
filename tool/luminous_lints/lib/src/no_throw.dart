import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Hand-written application code must not `throw`: errors travel as
/// `LucentFailure` through `Either` / `TaskEither`, never as control flow.
///
/// Scope is the code the team owns — `lib/features/*/{application,presentation,
/// data}`:
///
/// - `application/` and `presentation/` may not throw at all;
/// - `data/` may only throw the failure it is about to hand back to its
///   `TaskEither` (`throw <LucentFailure…>`, `throw failure`); a bare
///   `StateError` / `FormatException` would escape the mapper.
///
/// Two package contracts are exempt because throwing is not a choice there:
///
/// - overriding a framework member that declares `@mustBeOverridden` (for
///   example `State.build` calling `throw UnimplementedError()`);
/// - passing the throwing function to a package API that owns the error path
///   (`TaskEither.tryCatch(run, onError)`, `Stream.map(onError: …)`), where the
///   thrown value is the declared failure channel.
///
/// `domain/`, `core/`, the composition root and tests are out of scope: `domain`
/// keeps `FormatException` inside `fromJson` factories (mapped at the data
/// boundary), and `core/` is where the mapper itself lives.
final class NoThrowRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'no_throw',
    'Hand-written application code must not `throw`; return a failure through '
        'Either.',
    correctionMessage:
        'Return the error as `LucentFailure` (or a state value) and let the '
        'caller branch on it instead of throwing.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoThrowRule()
    : super(
        name: 'no_throw',
        description:
            'Flags `throw` in application/presentation code, and in data-layer '
            'code outside the TaskEither failure channel.',
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

  /// Checks a single `throw` statement located at [filePath].
  ///
  /// Exposed as a static method so the CLI driver reuses exactly one
  /// implementation.
  static void checkThrow({
    required ThrowExpression statement,
    required String filePath,
    required void Function(AstNode node) report,
  }) {
    final path = libRelativePath(filePath);
    if (path == null) return;
    final layer = layerOf(path);
    if (layer != 'application' && layer != 'presentation' && layer != 'data') {
      return;
    }
    if (layer == 'data' && isFailureThrow(statement)) return;
    if (_ownerAllowsThrow(statement)) return;
    report(statement);
  }

  /// `application` / `data` / `presentation` / `domain` / `core` /
  /// `composition` / `other`.
  static String layerOf(String libRelativePath) {
    const featurePrefix = 'lib/features/';
    if (libRelativePath.startsWith(featurePrefix)) {
      final rest = libRelativePath.substring(featurePrefix.length);
      for (final layer in const [
        'domain',
        'application',
        'data',
        'presentation',
      ]) {
        if (rest.startsWith('$layer/') || rest.contains('/$layer/')) {
          return layer;
        }
      }
      return 'other';
    }
    if (libRelativePath.startsWith('lib/core/')) return 'core';
    if (libRelativePath.startsWith('lib/app/')) return 'composition';
    return 'other';
  }

  /// Whether [statement] throws one of the failure renderings allowed at the
  /// data-layer boundary.
  ///
  /// A data source reports its failure by throwing it — the repository wraps
  /// the call in `TaskEither.tryCatch`, so the throw *is* the failure value.
  /// `LucentFailure` itself, a `failure` variable, and the client-detected
  /// `LucentFailure.client(...)` builders all qualify.
  static bool isFailureThrow(ThrowExpression statement) {
    final expression = _unwrap(statement.expression);
    if (expression is InstanceCreationExpression) {
      final name = expression.constructorName.type.name.lexeme;
      return name == 'LucentFailure';
    }
    if (expression is SimpleIdentifier) {
      return expression.name == 'failure';
    }
    if (expression is PrefixedIdentifier) {
      return expression.identifier.name == 'failure';
    }
    if (expression is PropertyAccess) {
      return expression.propertyName.name == 'failure';
    }
    return _isFailureBuilderCall(expression);
  }

  /// `mapSseStreamError(data)` / `failureFor(code)` / …: a call whose callee
  /// names a failure (identified by the `failure` identifier). The concrete
  /// type cannot be checked in a syntactic rule, so the naming convention is
  /// the contract.
  static bool _isFailureBuilderCall(Expression expression) {
    if (expression is! MethodInvocation) return false;
    final method = expression.methodName.name;
    return method.toLowerCase().contains('failure');
  }

  static Expression _unwrap(Expression expression) {
    var current = expression;
    while (current is ParenthesizedExpression) {
      current = current.expression;
    }
    return current;
  }

  /// Whether the throw is required by a package API rather than chosen:
  /// the enclosing method overrides an `@mustBeOverridden` framework member
  /// (e.g. `State.build`), or the enclosing closure is an argument of some
  /// invocation/creation that owns the error channel (`TaskEither.tryCatch`,
  /// `Stream.map(onError: …)`, `assert`).
  static bool _ownerAllowsThrow(ThrowExpression statement) {
    var current = statement.parent;
    while (current != null) {
      final enclosing = _enclosingOwner(current);
      if (enclosing != null) return enclosing;
      current = current.parent;
    }
    return false;
  }

  /// Answer for the first owner found above the statement, or `null` while
  /// still walking (nested blocks/expressions are transparent).
  static bool? _enclosingOwner(AstNode node) {
    if (node is FunctionExpression) {
      return node.parent is ArgumentList;
    }
    if (node is MethodDeclaration) {
      final element = node.declaredFragment?.element;
      if (element is! ExecutableElement) return true;
      // Unresolved (or stub) elements carry no inheritance info, so treat them
      // as framework overrides rather than producing a false positive.
      return element is Metadata && (element as Metadata).hasOverride;
    }
    return null;
  }
}

final class _UnitVisitor extends SimpleAstVisitor<void> {
  final NoThrowRule rule;
  final RuleContext context;

  _UnitVisitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit unit) {
    final filePath =
        context.currentUnit?.file.path ?? context.definingUnit.file.path;
    unit.accept(_ThrowCollector(filePath: filePath, report: rule.reportAtNode));
  }
}

final class _ThrowCollector extends RecursiveAstVisitor<void> {
  _ThrowCollector({required this.filePath, required this.report});

  final String filePath;
  final void Function(AstNode node) report;

  @override
  void visitThrowExpression(ThrowExpression node) {
    NoThrowRule.checkThrow(statement: node, filePath: filePath, report: report);
    super.visitThrowExpression(node);
  }
}
