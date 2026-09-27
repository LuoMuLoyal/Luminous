import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:luminous_lints/luminous_lints.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoDirectNavigatorRuleTest);
  });
}

/// The rule is syntactic (it keys off the `Navigator` receiver), and these tests
/// assert only *which* invocations report. The bodies below therefore use a
/// locally declared `Navigator` stub rather than the real Flutter class, so the
/// fixture stays independent of what the test Flutter package exports.
@reflectiveTest
class NoDirectNavigatorRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = NoDirectNavigatorRule();
    super.setUp();
  }

  Future<void> test_navigatorPushInFeature_isReported() async {
    // Both the outer `push` and the `Navigator.of(...)` accessor it is reached
    // through report: the AST visitor sees each invocation node independently.
    await assertDiagnostics(
      r'''
class Navigator {
  static NavigatorState of(Object context) => NavigatorState();
  static void push(Object context, Object route) {}
}

class NavigatorState {
  void push(Object route) {}
  void pop() {}
  void maybePop() {}
}

void f(Object context) {
  Navigator.of(context).push(0);
}
''',
      [lint(256, 29), lint(256, 21)],
    );
  }

  Future<void> test_directNavigatorPush_isReported() async {
    await assertDiagnostics(
      r'''
class Navigator {
  static void push(Object context, Object route) {}
}

void f(Object context) {
  Navigator.push(context, 0);
}
''',
      [lint(100, 26)],
    );
  }

  Future<void> test_navigatorMaybePop_isNotReported() async {
    // `maybePop` dismisses the current overlay if there is one — the same
    // sanctioned shape as `pop`, for a sheet that may already be gone.
    await assertNoDiagnostics(r'''
class Navigator {
  static NavigatorState of(Object context) => NavigatorState();
}

class NavigatorState {
  void maybePop() {}
}

void f(Object context) {
  Navigator.of(context).maybePop();
}
''');
  }

  Future<void> test_handleUsedToPush_isReported() async {
    // A handle used to push is route navigation, so the push reports — the
    // dismissal carve-out must not leak to `push`.
    await assertDiagnostics(
      r'''
class Navigator {
  static NavigatorState of(Object context) => NavigatorState();
}

class NavigatorState {
  void push(Object route) {}
  void pop() {}
}

void f(Object context) {
  final navigator = Navigator.of(context);
  navigator.pop();
  navigator.push(0);
}
''',
      [lint(201, 21)],
    );
  }

  Future<void> test_navigatorPopForDialogResult_isNotReported() async {
    // Closing a dialog/sheet to return a result has no GoRouter equivalent:
    // those overlays are pushed onto the Material Navigator in the first
    // place, so `pop` is the only way to close them.
    await assertNoDiagnostics(r'''
class Navigator {
  static NavigatorState of(Object context) => NavigatorState();
}

class NavigatorState {
  void pop([Object? result]) {}
}

void f(Object context) {
  Navigator.of(context).pop(true);
}
''');
  }

  Future<void> test_navigatorPopWithoutResult_isNotReported() async {
    await assertNoDiagnostics(r'''
class Navigator {
  static NavigatorState of(Object context) => NavigatorState();
}

class NavigatorState {
  void pop() {}
}

void f(Object context) {
  Navigator.of(context).pop();
}
''');
  }

  Future<void> test_popOfNonNavigator_isNotReported() async {
    await assertNoDiagnostics(r'''
class Closer {
  void pop() {}
}

void f(Closer c) {
  c.pop();
}
''');
  }

  Future<void> test_routerBootstrapIsWhitelisted() async {
    final path = convertPath('/home/test/lib/core/router/bootstrap.dart');
    newFile(path, r'''
class Navigator {
  static void push(Object context, Object route) {}
}

void f(Object context) {
  Navigator.push(context, 0);
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_shellFeatureIsWhitelisted() async {
    final path = convertPath('/home/test/lib/features/shell/page.dart');
    newFile(path, r'''
class Navigator {
  static void push(Object context, Object route) {}
}

void f(Object context) {
  Navigator.push(context, 0);
}
''');
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_pushInNonWhitelistedFeature_isReported() async {
    final path = convertPath('/home/test/lib/features/auth/gate.dart');
    newFile(path, r'''
class Navigator {
  static void push(Object context, Object route) {}
}

void f(Object context) {
  Navigator.push(context, 0);
}
''');
    await assertDiagnosticsInFile(path, [lint(100, 26)]);
  }
}
