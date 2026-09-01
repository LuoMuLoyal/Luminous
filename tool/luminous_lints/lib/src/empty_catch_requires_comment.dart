import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Empty catch blocks must not swallow errors silently.
///
/// `catch (_) {}` / `catch (e) {}` (and the `on X catch (e)` form) are
/// reported when the block is empty and contains no comment. A comment - or
/// any statement, such as a log call or a rethrow - exempts the block.
final class EmptyCatchRequiresCommentRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'empty_catch_requires_comment',
    'Empty catch block swallows the error silently.',
    correctionMessage:
        'Log the error (logger.warn/error), rethrow, or leave an explanatory '
        'comment inside the catch block when ignoring is intentional.',
    severity: DiagnosticSeverity.WARNING,
  );

  EmptyCatchRequiresCommentRule()
    : super(
        name: 'empty_catch_requires_comment',
        description:
            'Flags empty catch blocks that contain neither a statement nor '
            'a comment.',
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

  /// Checks a single catch [clause] located at [filePath].
  ///
  /// Exposed as a static method so the repository sampling script can reuse
  /// the exact rule logic.
  static void checkCatchClause({
    required CatchClause clause,
    required String filePath,
    required void Function(AstNode node) report,
  }) {
    if (libRelativePath(filePath) == null) return;

    final body = clause.body;
    if (body.statements.isNotEmpty) return;
    if (catchBodyHasComment(body)) return;
    report(clause);
  }
}

/// Whether the statement [block] contains any comment token between its
/// braces. In an empty block, comments attach as preceding comments of the
/// closing brace.
bool catchBodyHasComment(Block block) {
  if (block.rightBracket.precedingComments != null) return true;
  Token? token = block.leftBracket.next;
  while (token != null && !identical(token, block.rightBracket)) {
    if (token.precedingComments != null) return true;
    token = token.next;
  }
  return false;
}

final class _UnitVisitor extends SimpleAstVisitor<void> {
  final EmptyCatchRequiresCommentRule rule;
  final RuleContext context;

  _UnitVisitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit unit) {
    final filePath =
        context.currentUnit?.file.path ?? context.definingUnit.file.path;
    unit.accept(
      _RecursiveCatchVisitor(filePath: filePath, report: rule.reportAtNode),
    );
  }
}

final class _RecursiveCatchVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final void Function(AstNode node) report;

  _RecursiveCatchVisitor({required this.filePath, required this.report});

  @override
  void visitCatchClause(CatchClause node) {
    EmptyCatchRequiresCommentRule.checkCatchClause(
      clause: node,
      filePath: filePath,
      report: report,
    );
    super.visitCatchClause(node);
  }
}
