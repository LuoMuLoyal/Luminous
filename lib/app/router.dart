import 'package:go_router/go_router.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_page.dart';
import 'package:luminous/features/auth/presentation/pages/change_email_page.dart';
import 'package:luminous/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:luminous/features/auth/presentation/pages/login_page.dart';
import 'package:luminous/features/auth/presentation/pages/register_page.dart';
import 'package:luminous/features/mine/presentation/pages/allergy_edit.dart';
import 'package:luminous/features/mine/presentation/pages/condition_edit.dart';
import 'package:luminous/features/mine/presentation/pages/current_medicine_edit.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';
import 'package:luminous/features/record/presentation/pages/record_create.dart';
import 'package:luminous/features/record/presentation/pages/record_detail.dart';
import 'package:luminous/features/record/presentation/pages/record_edit.dart';
import 'package:luminous/features/search/presentation/pages/search_page.dart';
import 'package:luminous/features/settings/presentation/pages/language_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/more_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/theme_settings_page.dart';
import 'package:luminous/features/shell/presentation/shell_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const ShellPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/login/oauth/wechat',
      builder: (context, state) => LoginPage(
        wechatCode: state.uri.queryParameters['code'],
        wechatState: state.uri.queryParameters['state'],
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountSettingsPage(),
    ),
    GoRoute(
      path: '/account/oauth/wechat',
      builder: (context, state) => AccountSettingsPage(
        wechatCode: state.uri.queryParameters['code'],
        wechatState: state.uri.queryParameters['state'],
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/settings/language',
      builder: (context, state) => const LanguageSettingsPage(),
    ),
    GoRoute(
      path: '/settings/theme',
      builder: (context, state) => const ThemeSettingsPage(),
    ),
    GoRoute(
      path: '/settings/notifications',
      builder: (context, state) => const NotificationSettingsPage(),
    ),
    GoRoute(
      path: '/settings/more',
      builder: (context, state) => const MoreSettingsPage(),
    ),
    GoRoute(
      path: '/account/change-email',
      builder: (context, state) => const ChangeEmailPage(),
    ),
    GoRoute(
      path: '/medicine/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/mine/profile/edit',
      builder: (context, state) => const ProfileEditPage(),
    ),
    GoRoute(
      path: '/mine/allergy/new',
      builder: (context, state) => const AllergyEditPage(),
    ),
    GoRoute(
      path: '/mine/allergy/:id/edit',
      builder: (context, state) =>
          AllergyEditPage(allergyId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/mine/condition/new',
      builder: (context, state) => const ConditionEditPage(),
    ),
    GoRoute(
      path: '/mine/condition/:id/edit',
      builder: (context, state) =>
          ConditionEditPage(conditionId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/mine/medicine/new',
      builder: (context, state) => const CurrentMedicineEditPage(),
    ),
    GoRoute(
      path: '/mine/medicine/:id/edit',
      builder: (context, state) =>
          CurrentMedicineEditPage(medicineId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/record/create',
      builder: (context, state) => const RecordCreatePage(),
    ),
    GoRoute(
      path: '/record/:id',
      builder: (context, state) =>
          RecordDetailPage(recordId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/record/:id/edit',
      builder: (context, state) =>
          RecordEditPage(recordId: state.pathParameters['id']!),
    ),
  ],
);
