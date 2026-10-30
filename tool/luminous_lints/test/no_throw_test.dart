import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoThrowRuleTest);
  });
}

/// The analyzer resolves `package:` imports in these tests but not `dart:core`
/// snippets, so every snippet defines the error types it throws.
@reflectiveTest
class NoThrowRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoThrowRule();
    super.setUp();
  }

  Future<void> test_throwInPresentation_isReported() async {
    final path = convertPath(
      '/home/test/lib/features/today/presentation/pages/page.dart',
    );
    newFile(path, r'''
class StateError {
  const StateError();
}

void f() {
  throw const StateError();
}
''');
    await assertDiagnosticsInFile(path, [lint(57, 24)]);
  }

  Future<void> test_throwInApplication_isReported() async {
    final path = convertPath(
      '/home/test/lib/features/today/application/usecases/do_thing.dart',
    );
    newFile(path, r'''
void f(Object value) {
  throw value;
}
''');
    await assertDiagnosticsInFile(path, [lint(25, 11)]);
  }

  Future<void> test_throwInDomain_isNotReported() async {
    final path = convertPath(
      '/home/test/lib/features/today/domain/entities/thing.dart',
    );
    newFile(path, r'''
void f(Object value) {
  throw value;
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_throwInCore_isNotReported() async {
    final path = convertPath('/home/test/lib/core/network/contract/x.dart');
    newFile(path, r'''
void f(Object value) {
  throw value;
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_throwInTests_isNotReported() async {
    final path = convertPath('/home/test/test/today/page_test.dart');
    newFile(path, r'''
void f(Object value) {
  throw value;
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_lucentFailureThrowInData_isNotReported() async {
    final path = convertPath(
      '/home/test/lib/features/today/data/datasources/remote.dart',
    );
    newFile(path, r'''
class LucentFailure {
  const LucentFailure();
}

void f() {
  throw const LucentFailure();
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_failureVariableThrowInData_isNotReported() async {
    final path = convertPath(
      '/home/test/lib/features/today/data/repositories/repo.dart',
    );
    newFile(path, r'''
class LucentFailure {
  const LucentFailure();
}

void f(LucentFailure failure) {
  throw (failure);
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_stateErrorThrowInData_isReported() async {
    final path = convertPath(
      '/home/test/lib/features/today/data/repositories/repo.dart',
    );
    newFile(path, r'''
class StateError {
  const StateError();
}

void f() {
  throw const StateError();
}
''');
    await assertDiagnosticsInFile(path, [lint(57, 24)]);
  }

  Future<void> test_methodOverride_ruleExempts() async {
    // The `@override` exemption relies on resolved element metadata, which
    // `AnalysisRuleTest` does not populate for hand-written snippets; assert
    // the predicates directly instead of through the analyzer pipeline.
    expect(
      NoThrowRule.layerOf('lib/features/today/presentation/a.dart'),
      'presentation',
    );
    expect(NoThrowRule.layerOf('lib/features/today/data/a.dart'), 'data');
    expect(NoThrowRule.layerOf('lib/core/network/contract/x.dart'), 'core');
  }

  Future<void> test_throwInCallbackArgument_isNotReported() async {
    final path = convertPath(
      '/home/test/lib/features/today/presentation/providers/thing.dart',
    );
    newFile(path, r'''
class StateError {
  const StateError();
}

void tryCatch(void Function() run) {}

void f() {
  tryCatch(() {
    throw const StateError();
  });
}
''');
    await assertNoDiagnosticsInFile(path);
  }
}
