import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(EnumParseUnknownBranchRuleTest);
  });
}

@reflectiveTest
class EnumParseUnknownBranchRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = EnumParseUnknownBranchRule();
    super.setUp();
  }

  Future<void> test_exhaustiveSwitchWithoutFallback_isReported() async {
    await assertDiagnostics(
      r'''
enum Status { active, archived }

void f(Status s) {
  switch (s) {
    case Status.active:
      break;
    case Status.archived:
      break;
  }
}
''',
      [lint(55, 92)],
    );
  }

  Future<void> test_switchWithWildcard_isNotReported() async {
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

  Future<void> test_switchWithDefault_isNotReported() async {
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

  Future<void> test_switchExpressionWithWildcard_isNotReported() async {
    await assertNoDiagnostics(r'''
enum Status { active, archived }

String f(Status s) => switch (s) {
  Status.active => 'a',
  _ => 'unknown',
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
}
