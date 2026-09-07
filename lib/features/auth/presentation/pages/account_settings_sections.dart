import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

// 导入拆分后的文件
export 'package:luminous/features/auth/presentation/pages/account_identity.dart'
    show
        AccountStatusSection,
        EmailSection,
        LinkedIdentitiesSection,
        LinkedIdentityTile,
        identityProviderLabel;
export 'package:luminous/features/auth/presentation/pages/account_security.dart'
    show PasswordSection, DeleteAccountSection, DangerZoneSection;
export 'package:luminous/features/auth/presentation/pages/account_sessions.dart'
    show SessionManagementSection;

// 保留账号设置加载状态组件
class AccountSettingsLoading extends StatelessWidget {
  const AccountSettingsLoading({super.key});

  @override
  Widget build(BuildContext context) => const InlineSkeleton(
    children: [
      InlineSkeletonBlock(height: 96),
      InlineSkeletonBlock(height: 132),
      InlineSkeletonBlock(height: 96),
      InlineSkeletonBlock(height: 116),
    ],
  );
}
