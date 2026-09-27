import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Business code must not drive **route** navigation through the Material
/// `Navigator` class. GoRouter is the only navigation entry in Luminous.
///
/// Allowed locations (whitelist):
/// - `lib/core/router/` (router bootstrap and observers);
/// - `lib/features/shell/` (the shell hosts the router outlet).
///
/// **Overlay dismissal is deliberately not reported.** Closing a dialog or
/// bottom sheet — `Navigator.of(context).pop(value)`, or `maybePop()` when the
/// sheet may already be gone — is not route navigation, and GoRouter has no
/// equivalent: those overlays are pushed onto the Material `Navigator` in the
/// first place, so `Navigator.pop` is the only way to close them. The Modal API
/// and the route API are the same object, so the two cannot be separated
/// syntactically; flagging dismissal would report the one legitimate remaining
/// use of `Navigator`.
///
/// The sanctioned shape is therefore narrow and deliberate:
/// - the dismissal itself (`pop`, `maybePop`), and
/// - the `Navigator.of(...)` / `maybeOf(...)` accessor that reaches it,
///   whether used inline or bound to a local first.
///
/// Everything else still reports, including `canPop` (route back-navigation
/// state), `push`/`pushNamed`/`pushReplacement` (the actual defect this rule
/// exists to prevent), and any call reached through a variable that is not a
/// `Navigator.of(...)` result.
///
/// The check is syntactic — it keys off the receiver named `Navigator` — which
/// keeps it deterministic and independent of how Flutter was imported.
final class NoDirectNavigatorRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'no_direct_navigator',
    'Do not use the Material Navigator for routes; GoRouter is the only '
        'navigation entry in Luminous.',
    correctionMessage:
        'Use `context.go` / `context.push` (GoRouter) or a router helper '
        'instead. Navigator is only allowed in lib/core/router/ and '
        'lib/features/shell/ (plus `pop`/`maybePop` for closing overlays).',
    severity: DiagnosticSeverity.WARNING,
  );

  /// Directory prefixes (relative to `lib/`) where direct Navigator usage is
  /// allowed.
  static const List<String> _allowedPrefixes = [
    'lib/core/router/',
    'lib/features/shell/',
  ];

  /// `NavigatorState` members that close an overlay rather than navigate.
  ///
  /// See the class doc. `canPop` is included here only as a dismissal guard
  /// (see [_NavigatorAccessorAssignmentCollector]); it is not sanctioned when a
  /// handle is also used to push.
  static const Set<String> _overlayDismissMembers = {'pop', 'maybePop'};

  /// Members a `NavigatorState` handle may use while still counting as
  /// dismissal-only: the dismissals plus the `canPop()` guard around them.
  static const Set<String> _dismissalOrGuardMembers = {
    'pop',
    'maybePop',
    'canPop',
  };

  /// `Navigator` members that hand back a `NavigatorState` to call the above on.
  static const Set<String> _navigatorAccessors = {'of', 'maybeOf'};

  NoDirectNavigatorRule()
    : super(
        name: 'no_direct_navigator',
        description:
            'Flags direct Material Navigator route navigation outside the '
            'router bootstrap; GoRouter is the only navigation entry.',
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

    if (!_isNavigatorCall(invocation)) return;
    if (_isOverlayDismissal(invocation)) return;
    report(invocation);
  }

  /// Whether [invocation] is a dismissal, or the accessor that reaches one.
  ///
  /// Covers three shapes, all of which occur in this codebase:
  /// - the dismissal itself: `Navigator.of(c).pop(v)` / `.maybePop()`;
  /// - the inline accessor (`Navigator.of(c)`), which the AST walk visits as a
  ///   separate node — without this it would report the very call the carve-out
  ///   just allowed;
  /// - an accessor bound to a local first:
  ///   `final navigator = Navigator.of(c, rootNavigator: true); navigator.pop();`
  static bool _isOverlayDismissal(MethodInvocation invocation) {
    if (_overlayDismissMembers.contains(invocation.methodName.name))
      return true;

    if (_isNavigatorAccessor(invocation)) {
      final parent = invocation.parent;
      // Inline: `Navigator.of(c).pop(...)` is sanctioned, but
      // `Navigator.of(c).push(...)` still reports on the outer `push`.
      if (parent is MethodInvocation &&
          parent.target == invocation &&
          _overlayDismissMembers.contains(parent.methodName.name)) {
        return true;
      }
      // Bound to a local: the accessor itself is sanctioned when the handle it
      // initializes is only ever used for dismissal.
      return parent is VariableDeclaration &&
          _isDismissalOnlyHandle(parent.name.lexeme, invocation);
    }

    // A member call on a dismissal-only handle is sanctioned.
    return _isNavigatorStateLocalRead(invocation);
  }

  /// Whether the local named [name] is initialized from a Navigator accessor
  /// and used only for dismissals.
  static bool _isDismissalOnlyHandle(String name, AstNode context) {
    final unit = context.thisOrAncestorOfType<CompilationUnit>();
    if (unit == null) return false;
    final collector = _NavigatorAccessorAssignmentCollector(name);
    unit.accept(collector);
    return collector.isDismissalOnly;
  }

  /// Whether [invocation] is a member call on a variable holding a
  /// `Navigator.of(...)` / `maybeOf(...)` result.
  ///
  /// Matched by identifier name and static type within the enclosing unit:
  /// resolving the local's initializer through the element model is not
  /// available (the analyzer deprecates `LocalVariableElement` initializer
  /// access and points back at the AST), and the syntactic check is what this
  /// rule already relies on elsewhere.
  static bool _isNavigatorStateLocalRead(MethodInvocation invocation) {
    final target = invocation.target;
    if (target is! SimpleIdentifier) return false;
    return _isDismissalOnlyHandle(target.name, invocation);
  }

  /// Whether [invocation] is a call rooted at the Material `Navigator`.
  ///
  /// Matches both the direct form (`Navigator.push(...)`) and the
  /// instance-based form (`Navigator.of(context).push(...)`), whose target is
  /// itself a `Navigator.of(...)` invocation rather than an identifier. The
  /// latter is how the overwhelming majority of call sites are written, so
  /// matching only a bare `Navigator` identifier would silently miss them.
  static bool _isNavigatorCall(MethodInvocation invocation) {
    final target = invocation.target;
    if (target is SimpleIdentifier && target.token.lexeme == 'Navigator') {
      return true;
    }
    if (target is MethodInvocation) {
      return _isNavigatorAccessor(target);
    }
    return false;
  }

  /// Whether [invocation] is `Navigator.of(...)` / `Navigator.maybeOf(...)`,
  /// the accessor used to reach the imperative `NavigatorState` API.
  static bool _isNavigatorAccessor(MethodInvocation invocation) {
    final target = invocation.target;
    if (target is! SimpleIdentifier || target.token.lexeme != 'Navigator') {
      return false;
    }
    final name = invocation.methodName.name;
    return _navigatorAccessors.contains(name);
  }
}

/// Records how a local initialized from a `Navigator.of(...)` / `maybeOf(...)`
/// call is used, so the accessor can be sanctioned only when every use of it is
/// overlay dismissal.
///
/// A handle used for route navigation (`navigator.push(...)`) still reports.
final class _NavigatorAccessorAssignmentCollector
    extends RecursiveAstVisitor<void> {
  _NavigatorAccessorAssignmentCollector(this.name);

  final String name;

  /// Whether a declaration of [name] was initialized from a Navigator accessor.
  bool isAccessorHandle = false;

  /// The methods invoked on that handle.
  final Set<String> _methodsUsed = {};

  /// Whether every recorded use is a dismissal, i.e. the handle is never used
  /// to navigate a route. `canPop` is treated as part of dismissal: it is the
  /// guard for "is there an overlay left to close?".
  bool get isDismissalOnly =>
      isAccessorHandle &&
      _methodsUsed.isNotEmpty &&
      _methodsUsed.every(
        NoDirectNavigatorRule._dismissalOrGuardMembers.contains,
      );

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final initializer = node.initializer;
    if (node.name.lexeme == name &&
        initializer is MethodInvocation &&
        NoDirectNavigatorRule._isNavigatorAccessor(initializer)) {
      isAccessorHandle = true;
    }
    super.visitVariableDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    if (target is SimpleIdentifier && target.name == name) {
      _methodsUsed.add(node.methodName.name);
    }
    super.visitMethodInvocation(node);
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
