import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// A `Row` that mixes a text sibling with a non-flexible, intrinsically-sized
/// child (a badge/chip/pill/tag or a button) squeezes that text - or overflows
/// to the right - as soon as the text stops fitting.
///
/// Widgets such as `FBadge`, `PillChip`, `TintedStatusBadge`, `FButton`, and
/// the hand-rolled `_*Badge` / `_*Chip` / `_*Pill` / `_*Tag` wrappers around
/// `IntrinsicWidth` or a `DecoratedBox` + `Text` report an intrinsic width.
/// A `Row` gives every non-flexible child unbounded width, so such a child
/// keeps its full intrinsic width and the text sibling is left with whatever
/// remains. On a 360dp device at the 1.15-1.3 font tiers the text then wraps
/// to three or more lines, and past that the row overflows.
///
/// The fix is always a bounded width for the intrinsically-sized child -
/// `Flexible` / `Expanded` (flex share), `ConstrainedBox`, or a `SizedBox` /
/// `Container` with a width - so the text sibling keeps its share.
///
/// Reported only when the row *also* has a text sibling (`Text`, `Expanded`,
/// or `Flexible`), which is the shape that actually produces the symptom.
/// Children hidden behind a spread (`...badges`) or a non-literal `children:`
/// expression are opaque to a static check and are not reported - the rule is
/// a regression guard, not a proof of layout safety.
///
/// Only `Row` is inspected: `Wrap` and `OverflowBar` lay their children out
/// with their own (shrink-wrapping) constraints, so the same child is safe
/// there.
final class NonShrinkingRowChildRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'non_shrinking_row_child',
    'Non-shrinking Row child: {0}.',
    correctionMessage:
        'Give the intrinsically-sized child a bounded width - wrap it in '
        'Flexible, Expanded, ConstrainedBox, or SizedBox(width: ...) - so the '
        'text sibling keeps its share of the row.',
    severity: DiagnosticSeverity.WARNING,
  );

  NonShrinkingRowChildRule()
    : super(
        name: 'non_shrinking_row_child',
        description:
            'Flags Rows whose children mix a text sibling with a '
            'non-flexible, intrinsically-sized badge/chip/pill/tag or button.',
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

  /// Checks a single [node] located at [filePath].
  ///
  /// [report] receives the node to highlight (the whole `Row(...)`) plus the
  /// message arguments naming the offending child. Exposed as a static method
  /// so the repository sampling script can reuse the exact rule logic.
  static void checkInstanceCreation({
    required InstanceCreationExpression node,
    required String filePath,
    required void Function(AstNode node, List<Object> arguments) report,
  }) {
    if (libRelativePath(filePath) == null) return;
    if (!isRowCreation(node)) return;

    final children = rowChildren(node);
    if (children.isEmpty) return;
    if (!children.any(isTextSibling)) return;

    for (final child in children) {
      final offender = intrinsicWidthChild(child);
      if (offender != null) {
        report(node, [
          '$offender claims its intrinsic width and squeezes the text sibling',
        ]);
        // One finding per Row: the fix is a single layout decision.
        return;
      }
    }
  }
}

/// Whether [node] creates a `Row`.
///
/// Matching is name based - like the other rules in this package, it cannot
/// depend on Flutter - and reads the name after any import prefix, so both
/// `Row(...)` and `widgets.Row(...)` match.
bool isRowCreation(InstanceCreationExpression node) =>
    node.constructorName.type.name.lexeme == 'Row';

/// The widget expressions of [node]'s `children:` argument.
///
/// Returns an empty list when the row has no `children:` argument or passes
/// something other than a list literal (for example a prebuilt `List<Widget>`),
/// because the rule only reasons about statically visible children.
List<Expression> rowChildren(InstanceCreationExpression node) {
  final children = namedArgument(node, 'children');
  if (children is! ListLiteral) return const [];

  final expressions = <Expression>[];
  void collect(CollectionElement element) {
    switch (element) {
      case Expression():
        expressions.add(element);
      case IfElement():
        collect(element.thenElement);
        final elseElement = element.elseElement;
        if (elseElement != null) collect(elseElement);
      case ForElement():
        collect(element.body);
      default:
        // SpreadElement / MapLiteralEntry: the concrete children are not
        // statically visible.
        break;
    }
  }

  for (final element in children.elements) {
    collect(element);
  }
  return expressions;
}

/// Whether [expression] is a child that competes with the intrinsically-sized
/// child for the row's width: a `Text`, or a flex widget that wraps one.
bool isTextSibling(Expression expression) => widgetTypeNames(
  expression,
).any((name) => name == 'Text' || name == 'Expanded' || name == 'Flexible');

/// The name of the intrinsically-sized widget [expression] contributes to its
/// `Row`, or `null` when the child is not one (or is safely width-bounded).
///
/// The check walks through plain single-child wrappers (`Padding`, `Align`,
/// `DecoratedBox`, `SizedBox(height: ...)`, ...): those add spacing or
/// decoration but no width bound, so the squeeze survives them. It stops at
/// the first wrapper that does bound the width - `Flexible`, `Expanded`,
/// `ConstrainedBox`, or `SizedBox` / `Container` with a width.
String? intrinsicWidthChild(Expression expression) =>
    _intrinsicWidthChild(expression, depth: 0);

String? _intrinsicWidthChild(Expression expression, {required int depth}) {
  // Arbitrary nesting is possible in principle; a handful of levels covers
  // every wrapper stack seen in the app, and the bound keeps a pathological
  // expression from walking the whole tree.
  if (depth > _maxWrapperDepth) return null;

  if (expression is InstanceCreationExpression) {
    final name = expression.constructorName.type.name.lexeme;
    if (boundsChildWidth(expression)) return null;
    if (isIntrinsicWidthTypeName(name)) return name;
  }

  // The written constructor name can be a typedef or a helper's return type
  // (`_buildBadge()`); the resolved static type catches both.
  for (final name in widgetTypeNames(expression)) {
    if (isIntrinsicWidthTypeName(name)) return name;
  }

  final child = childArgument(expression);
  if (child == null) return null;
  return _intrinsicWidthChild(child, depth: depth + 1);
}

/// Whether [node] gives its child a bounded width.
///
/// - `Flexible` / `Expanded` hand the child a share of the row;
/// - `ConstrainedBox` bounds it through its constraints (unless those
///   constraints declare an infinite `maxWidth`, which is no bound at all);
/// - `SizedBox` and `Container` bound it through `width:` (or, for
///   `Container`, through bounded `constraints:`).
bool boundsChildWidth(InstanceCreationExpression node) {
  switch (node.constructorName.type.name.lexeme) {
    case 'Flexible':
    case 'Expanded':
      return true;
    case 'ConstrainedBox':
      return constraintsBoundWidth(namedArgument(node, 'constraints'));
    case 'SizedBox':
    case 'Container':
      final width = namedArgument(node, 'width');
      if (width != null) return !isUnboundedWidth(width);
      return constraintsBoundWidth(namedArgument(node, 'constraints'));
    default:
      return false;
  }
}

/// Whether the `constraints:` [expression] of a `ConstrainedBox` / `Container`
/// bounds the child's width.
///
/// Unknown expressions (a variable, a helper call) count as bounded: the rule
/// reports only what it can see, so it stays a regression guard rather than a
/// style checker.
bool constraintsBoundWidth(Expression? expression) {
  if (expression is! InstanceCreationExpression) return true;
  if (expression.constructorName.type.name.lexeme != 'BoxConstraints') {
    return true;
  }
  final maxWidth = namedArgument(expression, 'maxWidth');
  if (maxWidth != null) return !isUnboundedWidth(maxWidth);
  final width = namedArgument(expression, 'width');
  if (width != null) return !isUnboundedWidth(width);
  // `BoxConstraints()` defaults `maxWidth` to infinity; the positional forms
  // (`loose(Size)`, `tight(Size)`) do bound it.
  return expression.argumentList.arguments.any((it) => it is! NamedArgument);
}

/// Whether [expression] is an infinite width (`double.infinity`,
/// `double.maxFinite`, or the `infinity` constant of `dart:math`).
bool isUnboundedWidth(Expression expression) {
  switch (expression) {
    case PrefixedIdentifier(:final identifier):
      return _isInfiniteName(identifier.token.lexeme);
    case PropertyAccess(:final propertyName):
      return _isInfiniteName(propertyName.token.lexeme);
    case SimpleIdentifier(:final token):
      return _isInfiniteName(token.lexeme);
    default:
      return false;
  }
}

bool _isInfiniteName(String name) => name == 'infinity' || name == 'maxFinite';

/// The widget type names [expression] can have: the written constructor name
/// and, once resolved, the static type's element name.
Iterable<String> widgetTypeNames(Expression expression) sync* {
  if (expression is InstanceCreationExpression) {
    yield expression.constructorName.type.name.lexeme;
  }
  final type = expression.staticType;
  if (type is InterfaceType) {
    final name = type.element.name;
    if (name != null) yield name;
  }
}

/// Whether [name] is an intrinsically-sized widget type this rule guards: a
/// known design-system offender, or a hand-rolled `_*Badge` / `_*Chip` /
/// `_*Pill` / `_*Tag` variant (usually an `IntrinsicWidth` or a
/// `DecoratedBox` + `Text` pair).
bool isIntrinsicWidthTypeName(String name) =>
    _knownIntrinsicWidthTypes.contains(name) ||
    _intrinsicWidthNameShape.hasMatch(name);

/// The expression passed to a single `child:` named argument of an
/// instantiation, or `null` when [expression] has no such argument.
Expression? childArgument(Expression expression) {
  if (expression is! InstanceCreationExpression) return null;
  return namedArgument(expression, 'child');
}

/// The expression bound to the named argument [name] of [node], or `null`.
Expression? namedArgument(InstanceCreationExpression node, String name) {
  for (final argument in node.argumentList.arguments) {
    if (argument is NamedArgument && argument.name.lexeme == name) {
      return argument.argumentExpression;
    }
  }
  return null;
}

/// Widget types that size themselves to their intrinsic width and therefore
/// squeeze a text sibling in a `Row`.
///
/// `FBadge`, `PillChip`, and `TintedStatusBadge` also match
/// [_intrinsicWidthNameShape]; they are listed explicitly so the known
/// offenders stay greppable and so adding `FButton` (which does not match the
/// shape) is deliberate.
const Set<String> _knownIntrinsicWidthTypes = {
  'FBadge',
  'PillChip',
  'TintedStatusBadge',
  'FButton',
};

/// Type-name shape of the hand-rolled variants of the same design-system
/// widgets - `_StatusBadge`, `_InfoChip`, `_RiskPill`, `_MetaTag`, ... - which
/// grow as features add their own one-off wrappers.
final RegExp _intrinsicWidthNameShape = RegExp(
  r'^_?\w*(Badge|Chip|Pill|Tag)\w*$',
);

/// How many single-child wrappers the rule walks through before giving up.
const int _maxWrapperDepth = 8;

final class _UnitVisitor extends SimpleAstVisitor<void> {
  final NonShrinkingRowChildRule rule;
  final RuleContext context;

  _UnitVisitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit unit) {
    final filePath =
        context.currentUnit?.file.path ?? context.definingUnit.file.path;
    unit.accept(
      _RecursiveCreationVisitor(
        filePath: filePath,
        report: (node, arguments) =>
            rule.reportAtNode(node, arguments: arguments),
      ),
    );
  }
}

final class _RecursiveCreationVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final void Function(AstNode node, List<Object> arguments) report;

  _RecursiveCreationVisitor({required this.filePath, required this.report});

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    NonShrinkingRowChildRule.checkInstanceCreation(
      node: node,
      filePath: filePath,
      report: report,
    );
    super.visitInstanceCreationExpression(node);
  }
}
