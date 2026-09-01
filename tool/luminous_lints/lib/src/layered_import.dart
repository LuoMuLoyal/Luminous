import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Layered import constraints for the Luminous app.
///
/// Three sub-rules are enforced on `lib/` sources (mirroring the
/// "Cross-Feature Import Rules" section in the repository `AGENTS.md`):
///
/// 1. A data-layer file (path contains `/data/`) must not import another
///    feature's data layer; cross-feature reads go through the owning
///    feature's domain layer.
/// 2. A presentation-layer file must not import another feature's
///    presentation layer; consumers use domain entities, the shared snapshot
///    hub, or the DataChangeBus instead.
/// 3. `lib/core/**` must not import `lib/features/**` (core is feature-free).
///
/// Cross-feature imports of `domain/` (and other feature seams such as data
/// providers consumed from presentation) are sanctioned by AGENTS.md and not
/// reported. Both `package:luminous/...` and relative import URIs are
/// analyzed.
final class LayeredImportRule extends AnalysisRule {
  static const LintCode _code = LintCode(
    'layered_import',
    'Layered-import violation: {0}.',
    correctionMessage:
        'Follow the Luminous layering contract (AGENTS.md): a data layer must '
        'not depend on another feature\'s data layer, presentation must not '
        'consume another feature\'s presentation layer, and core must not '
        'import features.',
    severity: DiagnosticSeverity.WARNING,
  );

  LayeredImportRule()
    : super(
        name: 'layered_import',
        description:
            'Enforces layered import constraints between features, core, '
            'and data layers.',
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

  /// Checks a single import [directive] located at [filePath].
  ///
  /// [report] receives the node to highlight. Exposed as a static method so
  /// the repository sampling script can reuse the exact rule logic.
  static void checkImport({
    required ImportDirective directive,
    required String filePath,
    required void Function(AstNode node, List<Object> arguments) report,
  }) {
    final importer = libRelativePath(filePath);
    if (importer == null) return;

    final uri = directive.uri.stringValue;
    if (uri == null) return;
    final target = resolveImportTarget(uri, importer);
    if (target == null) return;

    final importerFeature = featureNameOf(importer);
    final targetFeature = featureNameOf(target);

    // Sub-rule 3 (checked first, most specific): data layer -> other
    // feature's data layer.
    if (isDataLayerPath(importer) &&
        isDataLayerPath(target) &&
        importerFeature != null &&
        targetFeature != null &&
        importerFeature != targetFeature) {
      report(directive.uri, [
        'data layer of feature "$importerFeature" must not import the data '
            'layer of feature "$targetFeature"',
      ]);
      return;
    }

    // Sub-rule 2: presentation -> other feature's presentation.
    if (isPresentationLayerPath(importer) &&
        isPresentationLayerPath(target) &&
        importerFeature != null &&
        targetFeature != null &&
        importerFeature != targetFeature) {
      report(directive.uri, [
        'presentation layer of feature "$importerFeature" must not import '
            'the presentation layer of feature "$targetFeature"',
      ]);
      return;
    }

    // Sub-rule 2: core -> feature.
    if (isCorePath(importer) && targetFeature != null) {
      report(directive.uri, ['core must not import feature "$targetFeature"']);
      return;
    }
  }
}

final class _UnitVisitor extends SimpleAstVisitor<void> {
  final LayeredImportRule rule;
  final RuleContext context;

  _UnitVisitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit unit) {
    final filePath =
        context.currentUnit?.file.path ?? context.definingUnit.file.path;
    for (final directive in unit.directives) {
      if (directive is ImportDirective) {
        LayeredImportRule.checkImport(
          directive: directive,
          filePath: filePath,
          report: (node, arguments) =>
              rule.reportAtNode(node, arguments: arguments),
        );
      }
    }
  }
}
