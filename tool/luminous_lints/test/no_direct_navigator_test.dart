import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoDirectNavigatorRuleTest);
  });
}

@reflectiveTest
class NoDirectNavigatorRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = NoDirectNavigatorRule();
    super.setUp();
  }

  Future<void> test_navigatorOfInFeature_isReported() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/material.dart';

void f(BuildContext context) {
  Navigator.of(context).pop();
}
''',
      [lint(74, 21)],
    );
  }

  Future<void> test_routerBootstrapIsWhitelisted() async {
    final path = convertPath('/home/test/lib/core/router/bootstrap.dart');
    newFile(path, r'''
import 'package:flutter/material.dart';

void f(BuildContext context) {
  Navigator.of(context).pop();
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_shellFeatureIsWhitelisted() async {
    final path = convertPath('/home/test/lib/features/shell/page.dart');
    newFile(path, r'''
import 'package:flutter/material.dart';

void f(BuildContext context) {
  Navigator.of(context).pop();
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_navigatorInNonWhitelistedFeature_isReported() async {
    final path = convertPath('/home/test/lib/features/auth/gate.dart');
    newFile(path, r'''
import 'package:flutter/material.dart';

void f(BuildContext context) {
  Navigator.of(context).pop();
}
''');
    await assertDiagnosticsInFile(path, [lint(74, 21)]);
  }
}
