import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/pages/Login/login.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    final controller = Get.put(UserController(), permanent: true);
    await controller.init();
  });

  tearDown(() {
    ToastUtils.instance.dismiss();
  });

  Widget createLoginWidget({AuthApi? authApi}) {
    return MaterialApp(home: LoginPage(authApi: authApi ?? FakeAuthApi()));
  }

  testWidgets('tap login with empty fields shows phone error', (tester) async {
    await tester.pumpWidget(createLoginWidget());

    await tester.ensureVisible(find.text('登录'));
    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('请输入手机号'), findsWidgets);
  });

  testWidgets('invalid phone shows phone format error before network', (
    tester,
  ) async {
    await tester.pumpWidget(createLoginWidget());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '123');
    await tester.enterText(fields.at(1), 'Abc123');

    await tester.ensureVisible(find.text('登录'));
    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('手机号格式不正确'), findsWidgets);
  });

  testWidgets(
    'code login not registered prompts auto register and prefills form',
    (tester) async {
      final fakeAuth = FakeAuthApi(throwNotRegisteredOnCodeLogin: true);
      await tester.pumpWidget(createLoginWidget(authApi: fakeAuth));

      await tester.tap(find.text('验证码登录'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '13800138000');
      await tester.tap(find.text('发送验证码'));
      await tester.pump();
      ToastUtils.instance.dismiss();
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('登录'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('账号未注册'), findsOneWidget);
      await tester.tap(find.text('去注册'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RegisterView), findsOneWidget);
      final registerFields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      expect(registerFields[0].controller?.text, '13800138000');
      expect(registerFields[1].controller?.text, '123456');
    },
  );

  testWidgets(
    'register blocks submit without svg code even with business code',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterView(
            authApi: FakeAuthApi(),
            initialIdentifierType: AuthIdentifierType.phone,
            initialIdentifier: '13800138000',
            initialCode: '123456',
            initialCodeId: 'phone-code-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(3), 'Abc123');
      await tester.enterText(fields.at(4), 'Abc123');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pump();

      final submitButton = find.widgetWithText(FilledButton, '注册');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pump();

      expect(find.text('请输入SVG验证码'), findsWidgets);
    },
  );

  testWidgets('register blocks submit without business code session', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterView(
          authApi: FakeAuthApi(),
          initialIdentifierType: AuthIdentifierType.phone,
          initialIdentifier: '13800138000',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), '123456');
    await tester.enterText(fields.at(2), '1234');
    await tester.enterText(fields.at(3), 'Abc123');
    await tester.enterText(fields.at(4), 'Abc123');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox), warnIfMissed: false);
    await tester.pump();

    final submitButton = find.widgetWithText(FilledButton, '注册');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('请先获取当前账号的验证码'), findsOneWidget);
    ToastUtils.instance.dismiss();
    await tester.pump();
  });
}

class FakeAuthApi extends AuthApi {
  FakeAuthApi({this.throwNotRegisteredOnCodeLogin = false});

  final bool throwNotRegisteredOnCodeLogin;

  @override
  Future<ApiResult<SvgCodeResult>> fetchSvgCode({
    AuthCodeScene scene = AuthCodeScene.register,
  }) async {
    return const ApiResult<SvgCodeResult>(
      code: '1',
      msg: 'ok',
      result: SvgCodeResult(
        id: 'svg-code-1',
        svg:
            '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="50"><text x="12" y="32">1234</text></svg>',
      ),
    );
  }

  @override
  Future<ApiResult<CodeTicketResult>> sendEmailCode({
    required String email,
    required AuthCodeScene scene,
  }) async {
    return const ApiResult<CodeTicketResult>(
      code: '1',
      msg: 'ok',
      result: CodeTicketResult(id: 'email-code-1'),
    );
  }

  @override
  Future<ApiResult<CodeTicketResult>> sendPhoneCode({
    required String phone,
    required AuthCodeScene scene,
  }) async {
    return const ApiResult<CodeTicketResult>(
      code: '1',
      msg: 'ok',
      result: CodeTicketResult(id: 'phone-code-1'),
    );
  }

  @override
  Future<ApiResult<LoginResult>> loginWithPassword({
    required AuthIdentifierType identifierType,
    required String identifier,
    required String password,
  }) async {
    return ApiResult<LoginResult>(
      code: '1',
      msg: '登录成功',
      result: LoginResult(
        user: UserSafe(
          id: 'user-1',
          username: identifier,
          email: identifierType == AuthIdentifierType.email ? identifier : '',
          phone: identifierType == AuthIdentifierType.phone ? identifier : '',
          name: '',
          type: 0,
        ),
        token: '',
      ),
    );
  }

  @override
  Future<ApiResult<LoginResult>> loginWithCode({
    required AuthIdentifierType identifierType,
    required String identifier,
    required String code,
    required String codeId,
  }) async {
    if (throwNotRegisteredOnCodeLogin) {
      throw const ApiException('该账号尚未注册，是否前往注册？', code: 'NOT_REGISTERED');
    }

    return ApiResult<LoginResult>(
      code: '1',
      msg: '登录成功',
      result: LoginResult(
        user: UserSafe(
          id: 'user-1',
          username: identifier,
          email: identifierType == AuthIdentifierType.email ? identifier : '',
          phone: identifierType == AuthIdentifierType.phone ? identifier : '',
          name: '',
          type: 0,
        ),
        token: '',
      ),
    );
  }

  @override
  Future<ApiResult<RegisterResult>> registerWithEmail({
    required String email,
    required String code,
    required String codeId,
    required String svgCode,
    required String svgId,
    required String password,
  }) async {
    return const ApiResult<RegisterResult>(
      code: '1',
      msg: '注册成功',
      result: RegisterResult(id: 'register-1'),
    );
  }

  @override
  Future<ApiResult<RegisterResult>> registerWithPhone({
    required String phone,
    required String code,
    required String codeId,
    required String svgCode,
    required String svgId,
    required String password,
  }) async {
    return const ApiResult<RegisterResult>(
      code: '1',
      msg: '注册成功',
      result: RegisterResult(id: 'register-1'),
    );
  }
}
