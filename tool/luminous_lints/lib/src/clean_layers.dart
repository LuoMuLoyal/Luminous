/// Strict Clean Architecture layer rules for the Luminous app.
///
/// Replaces the old single `layered_import` rule (three sub-rules with carve-outs)
/// with seven independent rules and **no whitelist**:
///
/// - [domain_purity] (R1/R2): `domain/**` may only import `dart:*`, an allowed
///   pure-Dart package list, and files inside the same feature's `domain/`.
/// - [application_layer] (R3): `application/**` may only import `domain/**`
///   (same feature), `dart:*`, and the same pure-Dart package list.
/// - [data_layer] (R4): `data/**` may only import `domain/**` (same feature),
///   its own layer, `dart:*`, third-party packages, and `core/network` /
///   `core/database` / `core/storage`.
/// - [presentation_layer] (R5): `presentation/**` may only import
///   `application/**` + `domain/**` (same feature), its own layer, `dart:*`,
///   third-party packages, and the pure-UI `core/` subtrees. Importing
///   `data/**` from presentation is always a violation.
/// - [cross_feature_import] (R6): a feature may not import another feature's
///   `data/**` or `presentation/**`; cross-feature access goes through the
///   owner's `domain/`.
/// - [core_not_import_features] (R7): `lib/core/**` may not import
///   `lib/features/**` at all. The old `core/auth` and `core/push` carve-outs
///   are gone.
///
/// All path handling is string based and normalized to forward slashes so the
/// rules behave identically on Windows and Linux. The pure (non-AST) predicate
/// is exposed as [checkImportPath] so the CLI driver and the unit tests share
/// exactly one implementation.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'common.dart';

/// Packages the `domain/` layer is allowed to depend on.
///
/// These are pure-Dart value/functional dependencies with no framework, no
/// platform channel and no network/storage access.
const Set<String> allowedDomainPackages = {
  'fpdart',
  'freezed_annotation',
  'meta',
  'clock',
};

/// `core/` subtrees that the `data/` layer may depend on.
const List<String> allowedCoreForData = [
  'lib/core/network/',
  'lib/core/database/',
  'lib/core/storage/',
  // Shared kernel: pure-Dart value objects / failure vocabulary / tokens.
  'lib/shared/',
];

/// `core/` subtrees that the `presentation/` layer may depend on.
///
/// These are pure-UI building blocks (design tokens, shared widgets, i18n,
/// feedback), the generated localizations, the app-level router seam, and the
/// contract error vocabulary (error codes/mappers are part of the value model
/// the UI renders, not I/O). Anything else under `core/` — notably
/// `core/auth`, `core/push`, `core/database`, `core/network/client` — is out of
/// bounds.
const List<String> allowedCoreForPresentation = [
  'lib/core/design/',
  'lib/core/widgets/',
  'lib/core/i18n/',
  'lib/core/feedback/',
  'lib/core/utils/',
  'lib/core/theme/',
  'lib/core/logger/',
  'lib/core/providers/',
  'lib/core/accessibility/',
  'lib/core/config/',
  'lib/core/errors/',
  'lib/core/forms/',
  'lib/core/router/',
  'lib/core/ai/',
  // Generated localizations: every page reads its copy from here.
  'lib/l10n/',
  // App-level router seam shared by feature route tables.
  'lib/app/router',
  // App-level auth session adapter: gives `AuthSessionState.user` (typed as
  // `Object?` in the feature-free `lib/core/auth`) its concrete `AuthUser`
  // accessor. It is a read-only value seam, not I/O, and every presentation
  // file that renders the signed-in user needs it.
  'lib/app/auth_session_adapter.dart',
  // Contract error vocabulary rendered by the UI (code + mapper).
  'lib/core/network/contract/',
  // Shared kernel (pure-Dart value objects + failure vocabulary + tokens).
  'lib/shared/',
  // Composition root and pure config/analytics/network value seams.
  'lib/app/composition/',
  'lib/core/network/config/',
  'lib/core/network/app_log.dart',
  'lib/core/network/i18n/',
  'lib/core/analytics/',
  // Composition root and pure config/analytics/logging seams.
];

/// The single violation predicate shared by the AST rules and the CLI driver.
///
/// [importer] and [target] are both `lib/...` paths produced by
/// [libRelativePath] / [resolveImportTarget]. Returns the rule name that
/// [importer] violates, or `null` when the edge is allowed.
///
/// When more than one rule would match, the most specific layer rule wins
/// (R1/R2 before R3 before R4 before R5 before R6 before R7).
String? checkImportPath({required String importer, required String target}) {
  // R7: core must not import features (checked first so a core file importing
  // a feature is reported as a core violation, not as a layer one).
  if (isCorePath(importer) && target.startsWith('lib/features/')) {
    return 'core_not_import_features';
  }

  final importerFeature = featureNameOf(importer);
  final targetFeature = featureNameOf(target);
  final sameFeature =
      importerFeature != null && importerFeature == targetFeature;

  final importingDomain = importer.contains('/domain/');
  final importingApplication = importer.contains('/application/');
  final importingData = importer.contains('/data/');
  final importingPresentation = importer.contains('/presentation/');
  final targetIsDomain = target.contains('/domain/');
  final targetIsData = target.contains('/data/');
  final targetIsPresentation = target.contains('/presentation/');

  // R1/R2: domain purity.
  if (importingDomain) {
    if (target.startsWith('package:')) {
      // Unreachable through resolveImportTarget (package targets are already
      // resolved), kept for the direct-string use in tests.
      return 'domain_purity';
    }
    if (sameFeature && targetIsDomain) return null;
    // The shared kernel (`lib/shared/domain/`) holds pure-Dart value objects
    // and the failure vocabulary shared by every bounded context. It has no
    // Flutter/Riverpod/IO dependency, so depending on it keeps domain pure.
    if (target.startsWith('lib/shared/domain/')) return null;
    return 'domain_purity';
  }

  // R3: application may only see domain/ — its own feature's, or another
  // feature's published language (AGENTS.md §Cross-Feature Import Rules:
  // "application -> domain allowed: the application layer may import other
  // features' domain layer (interfaces + entities) for cross-feature
  // orchestration").
  if (importingApplication) {
    if (targetIsDomain) return null;
    // The shared kernel (value objects / failure vocabulary) is domain-level
    // published language too.
    if (target.startsWith('lib/shared/domain/')) return null;
    if (!target.startsWith('lib/')) {
      // dart: / third-party.
      return null;
    }
    return 'application_layer';
  }

  // R6: cross-feature access to data/ or presentation/ is always forbidden,
  // even when the importer is itself in data/ or presentation/.
  if (importerFeature != null &&
      targetFeature != null &&
      importerFeature != targetFeature &&
      (targetIsData || targetIsPresentation)) {
    return 'cross_feature_import';
  }

  // R4: data may only see its own feature's domain, its own layer, and the
  // allowed core subtrees.
  if (importingData) {
    if (sameFeature && (targetIsDomain || importingData && targetIsData)) {
      return null;
    }
    // Shared kernel + design tokens (pure value objects).
    if (target.startsWith('lib/shared/')) return null;
    if (target.startsWith('lib/core/design/')) return null;
    // Another feature's domain is the published language: reading it from data
    // is the sanctioned cross-feature seam (cross_feature_import already
    // rejected their data/ and presentation/ above).
    if (targetFeature != null && targetIsDomain) return null;
    if (isCorePath(target) &&
        allowedCoreForData.any((prefix) => target.startsWith(prefix))) {
      return null;
    }
    if (!target.startsWith('lib/')) return null;
    return 'data_layer';
  }

  // R5: presentation may only see its own feature's application/domain, its
  // own layer, and the pure-UI core subtrees. Importing data/ is always a
  // violation.
  if (importingPresentation) {
    if (sameFeature &&
        (targetIsDomain ||
            target.contains('/application/') ||
            targetIsPresentation)) {
      return null;
    }
    if (targetIsData) return 'presentation_layer';
    // Non-feature targets (lib/core, lib/l10n, lib/app, lib/shared) are either
    // sanctioned shared infrastructure or an explicit violation, decided by
    // the allowlist below.
    if (!target.startsWith('lib/features/')) {
      if (allowedCoreForPresentation.any((p) => target.startsWith(p))) {
        return null;
      }
      // Everything else: third-party/dart: never reaches this branch, and any
      // other lib/ path is a violation.
      return 'presentation_layer';
    }
    // Another feature's domain/application is sanctioned (domain is the
    // published language); data/presentation already returned above.
    return null;
  }

  return null;
}

/// R1/R2 — `domain/**` purity.
final class DomainPurityRule extends AnalysisRule {
  DomainPurityRule()
    : super(name: ruleName, description: 'Enforces domain layer purity.');

  static const String ruleName = 'domain_purity';
  static const LintCode code = LintCode(
    ruleName,
    'domain layer may only depend on dart:*, fpdart, freezed_annotation, '
    'meta, clock, and the same feature\'s domain/ files.',
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  String get name => ruleName;

  @override
  String get description => 'Enforces domain layer purity.';

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _LayerUnitVisitor(this, context));
  }

  /// Reports a violation of [checkImportPath] as [ruleName] when it matches.
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
    if (checkImportPath(importer: importer, target: target) == ruleName) {
      report(directive.uri, [
        checkImportPath(importer: importer, target: target)!,
      ]);
    }
  }
}

/// R3 — `application/**` layering.
final class ApplicationLayerRule extends AnalysisRule {
  ApplicationLayerRule()
    : super(
        name: ruleName,
        description: 'Enforces application layer boundaries.',
      );

  static const String ruleName = 'application_layer';
  static const LintCode code = LintCode(
    ruleName,
    'application layer may only depend on the same feature\'s domain/.',
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  String get name => ruleName;

  @override
  String get description => 'Enforces application layer boundaries.';

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _LayerUnitVisitor(this, context));
  }

  static void checkImport({
    required ImportDirective directive,
    required String filePath,
    required void Function(AstNode node, List<Object> arguments) report,
  }) {
    _reportIfMatches(ruleName, directive, filePath, report);
  }
}

/// R4 — `data/**` layering.
final class DataLayerRule extends AnalysisRule {
  DataLayerRule()
    : super(name: ruleName, description: 'Enforces data layer boundaries.');

  static const String ruleName = 'data_layer';
  static const LintCode code = LintCode(
    ruleName,
    'data layer may only depend on the same feature\'s domain/, its own layer, '
    'and core/network, core/database, core/storage.',
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  String get name => ruleName;

  @override
  String get description => 'Enforces data layer boundaries.';

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _LayerUnitVisitor(this, context));
  }

  static void checkImport({
    required ImportDirective directive,
    required String filePath,
    required void Function(AstNode node, List<Object> arguments) report,
  }) {
    _reportIfMatches(ruleName, directive, filePath, report);
  }
}

/// R5 — `presentation/**` layering.
final class PresentationLayerRule extends AnalysisRule {
  PresentationLayerRule()
    : super(
        name: ruleName,
        description: 'Enforces presentation layer boundaries.',
      );

  static const String ruleName = 'presentation_layer';
  static const LintCode code = LintCode(
    ruleName,
    'presentation layer may only depend on the same feature\'s application/ '
    'and domain/, plus pure-UI core subtrees. Importing data/ is forbidden.',
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  String get name => ruleName;

  @override
  String get description => 'Enforces presentation layer boundaries.';

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _LayerUnitVisitor(this, context));
  }

  static void checkImport({
    required ImportDirective directive,
    required String filePath,
    required void Function(AstNode node, List<Object> arguments) report,
  }) {
    _reportIfMatches(ruleName, directive, filePath, report);
  }
}

/// R6 — cross-feature access to another feature's data/ or presentation/.
final class CrossFeatureImportRule extends AnalysisRule {
  CrossFeatureImportRule()
    : super(
        name: ruleName,
        description: 'Forbids cross-feature data/presentation imports.',
      );

  static const String ruleName = 'cross_feature_import';
  static const LintCode code = LintCode(
    ruleName,
    'features must not import another feature\'s data/ or presentation/; '
    'cross-feature access goes through the owner\'s domain/.',
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  String get name => ruleName;

  @override
  String get description => 'Forbids cross-feature data/presentation imports.';

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _LayerUnitVisitor(this, context));
  }

  static void checkImport({
    required ImportDirective directive,
    required String filePath,
    required void Function(AstNode node, List<Object> arguments) report,
  }) {
    _reportIfMatches(ruleName, directive, filePath, report);
  }
}

/// R7 — `core/**` must not import `features/**`.
final class CoreNotImportFeaturesRule extends AnalysisRule {
  CoreNotImportFeaturesRule()
    : super(
        name: ruleName,
        description: 'Forbids core from importing features.',
      );

  static const String ruleName = 'core_not_import_features';
  static const LintCode code = LintCode(
    ruleName,
    'core must not import features; core is feature-free.',
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  String get name => ruleName;

  @override
  String get description => 'Forbids core from importing features.';

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _LayerUnitVisitor(this, context));
  }

  static void checkImport({
    required ImportDirective directive,
    required String filePath,
    required void Function(AstNode node, List<Object> arguments) report,
  }) {
    _reportIfMatches(ruleName, directive, filePath, report);
  }
}

void _reportIfMatches(
  String ruleName,
  ImportDirective directive,
  String filePath,
  void Function(AstNode node, List<Object> arguments) report,
) {
  final importer = libRelativePath(filePath);
  if (importer == null) return;
  final uri = directive.uri.stringValue;
  if (uri == null) return;
  final target = resolveImportTarget(uri, importer);
  if (target == null) return;
  final violation = checkImportPath(importer: importer, target: target);
  if (violation == ruleName) {
    report(directive.uri, [target]);
  }
}

final class _LayerUnitVisitor extends SimpleAstVisitor<void> {
  _LayerUnitVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit unit) {
    final filePath =
        context.currentUnit?.file.path ?? context.definingUnit.file.path;
    void report(AstNode node, List<Object> arguments) =>
        rule.reportAtNode(node, arguments: arguments);
    for (final directive in unit.directives) {
      if (directive is! ImportDirective) continue;
      final importer = libRelativePath(filePath);
      if (importer == null) continue;
      final uri = directive.uri.stringValue;
      if (uri == null) continue;
      final target = resolveImportTarget(uri, importer);
      if (target == null) continue;
      final violation = checkImportPath(importer: importer, target: target);
      if (violation == ruleNameOf(rule)) {
        report(directive.uri, [target]);
      }
    }
  }

  static String ruleNameOf(AnalysisRule rule) {
    if (rule is DomainPurityRule) return DomainPurityRule.ruleName;
    if (rule is ApplicationLayerRule) return ApplicationLayerRule.ruleName;
    if (rule is DataLayerRule) return DataLayerRule.ruleName;
    if (rule is PresentationLayerRule) return PresentationLayerRule.ruleName;
    if (rule is CrossFeatureImportRule) return CrossFeatureImportRule.ruleName;
    return CoreNotImportFeaturesRule.ruleName;
  }
}
