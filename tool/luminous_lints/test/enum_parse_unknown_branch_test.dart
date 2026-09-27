import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(EnumParseUnknownBranchRuleTest);
  });
}

/// Covers the host-app half of the rule's contract: switches over the app's own
/// enums are deliberately **not** reported, because such an enum is white-box —
/// every matching switch compiles together with it, so a new constant surfaces
/// as a compile error at each site instead of being silently swallowed by a
/// `default`. Reporting them would push dead code into 17 call sites.
///
/// The server-derived half (the generated API client's enums, which *can* carry
/// a value this code has never seen) is exercised by the repository scan
/// itself: `dart run bin/luminous_lints.dart` reports zero
/// `enum_parse_unknown_branch` findings only as long as the generated-client
/// enums keep their `unknownDefaultOpenApi` fallbacks.
@reflectiveTest
class EnumParseUnknownBranchRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = EnumParseUnknownBranchRule();
    super.setUp();
  }

  Future<void> test_localEnumWithoutFallback_isNotReported() async {
    await assertNoDiagnostics(r'''
enum Status { active, archived }

void f(Status s) {
  switch (s) {
    case Status.active:
      break;
    case Status.archived:
      break;
  }
}
''');
  }

  Future<void> test_localEnumWithUnknownConstant_isNotReported() async {
    await assertNoDiagnostics(r'''
enum Status { active, unknown }

void f(Status s) {
  switch (s) {
    case Status.active:
      break;
    case Status.unknown:
      break;
  }
}
''');
  }

  Future<void> test_localEnumWithWildcard_isNotReported() async {
    await assertNoDiagnostics(r'''
enum Status { active, archived }

void f(Status s) {
  switch (s) {
    case Status.active:
      break;
    case _:
      break;
  }
}
''');
  }

  Future<void> test_localEnumWithDefault_isNotReported() async {
    await assertNoDiagnostics(r'''
enum Status { active, archived }

void f(Status s) {
  switch (s) {
    case Status.active:
      break;
    default:
      break;
  }
}
''');
  }

  Future<void> test_switchExpressionWithoutWildcard_isNotReported() async {
    // Switch expressions are exempt: Dart 3 enforces exhaustiveness at
    // compile time, so a new enum value breaks compilation instead of
    // silently falling through.
    await assertNoDiagnostics(r'''
enum Status { active, archived }

String f(Status s) => switch (s) {
  Status.active => 'a',
  Status.archived => 'b',
};
''');
  }

  Future<void> test_switchOverNonEnum_isNotReported() async {
    await assertNoDiagnostics(r'''
void f(int value) {
  switch (value) {
    case 1:
      break;
    case 2:
      break;
  }
}
''');
  }

  /// A locally declared enum still skips the rule even when the switch carries
  /// no fallback and the enum is passed across a library boundary, mirroring
  /// the real host-app call sites (`DailyRecordKind`, `SoftIconVariant`, ...).
  Future<void> test_localEnumAcrossLibrary_isNotReported() async {
    newFile('$testPackageLibPath/status.dart', r'''
enum Status { active, archived }
''');
    await assertNoDiagnostics(r'''
import 'status.dart';

void f(Status s) {
  switch (s) {
    case Status.active:
      break;
    case Status.archived:
      break;
  }
}
''');
  }
}
