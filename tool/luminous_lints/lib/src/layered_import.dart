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
///
/// Two carve-outs keep sub-rule 2 aligned with that documented contract:
///
/// - **Presentation providers** (`.../presentation/providers/...`): AGENTS.md
///   sanctions consuming another feature's provider seam from presentation; the
///   rule reports the *layer* an import lives in, and for `Notifier` providers
///   the layer directory and the seam coincide. Flagging these would contradict
///   the contract the rule is meant to enforce.
/// - **Shell infrastructure** (`features/shell/presentation/`): shell holds the
///   shared tab chrome that every tab root composes, so its widgets are
///   cross-cutting UI infrastructure rather than one feature's presentation
///   internals.
///
/// Sub-rule 3 additionally exempts the two **app-level integration seams** under
/// `core/`, which are cross-feature by nature and cannot be feature-free:
///
/// - `lib/core/auth/` — the session state that gates the whole app must observe
///   the auth feature's providers and entities.
/// - `lib/core/push/` — the push coordinator must react to other features'
///   state (unread counts, today's AI analysis) to route a notification.
///
/// These are whitelisted as *directories*, not as "any core file may import
/// features": every other `core/` path still reports.
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
        importerFeature != targetFeature &&
        !_isSanctionedPresentationSeam(target, targetFeature)) {
      report(directive.uri, [
        'presentation layer of feature "$importerFeature" must not import '
            'the presentation layer of feature "$targetFeature"',
      ]);
      return;
    }

    // Sub-rule 3: core -> feature.
    if (isCorePath(importer) &&
        targetFeature != null &&
        !_isAppLevelIntegrationSeam(importer)) {
      report(directive.uri, ['core must not import feature "$targetFeature"']);
      return;
    }
  }

  /// Whether importing [target] from another feature's presentation layer is a
  /// sanctioned seam rather than a layering violation.
  ///
  /// See the class doc: presentation providers are the documented cross-feature
  /// provider seam, and shell widgets are shared tab chrome.
  static bool _isSanctionedPresentationSeam(
    String target,
    String targetFeature,
  ) {
    if (targetFeature == 'shell') return true;
    return target.contains('/presentation/providers/');
  }

  /// Whether [importer] (a `lib/core/...` path) is one of the two app-level
  /// integration seams allowed to reach into features.
  ///
  /// Scoped to these exact directories so the exemption cannot creep: a new
  /// `core/` file that imports a feature still reports.
  static bool _isAppLevelIntegrationSeam(String importer) {
    return importer.startsWith('lib/core/auth/') ||
        importer.startsWith('lib/core/push/');
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
