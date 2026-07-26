import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for AccountApi
void main() {
  final instance = LucentApi().getAccountApi();

  group(AccountApi, () {
    // Change authenticated account email
    //
    //Future<AccountEmailResponseDto> accountControllerChangeEmailV1(ChangeEmailDto changeEmailDto) async
    test('test accountControllerChangeEmailV1', () async {
      // TODO
    });

    // Change authenticated account password
    //
    //Future<SuccessResponseDto> accountControllerChangePasswordV1(ChangePasswordDto changePasswordDto) async
    test('test accountControllerChangePasswordV1', () async {
      // TODO
    });

    // Create WeChat web OAuth authorize URL for linking
    //
    //Future<OAuthAuthorizeResponseDto> accountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1({ OAuthAuthorizeDto oAuthAuthorizeDto }) async
    test(
      'test accountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1',
      () async {
        // TODO
      },
    );

    // Delete authenticated account
    //
    //Future<SuccessResponseDto> accountControllerDeleteAccountV1(DeleteAccountDto deleteAccountDto) async
    test('test accountControllerDeleteAccountV1', () async {
      // TODO
    });

    // Get authenticated account profile
    //
    //Future<AccountResponseDto> accountControllerGetAccountV1() async
    test('test accountControllerGetAccountV1', () async {
      // TODO
    });

    // Link WeChat mobile identity to authenticated account
    //
    //Future<AccountResponseDto> accountControllerLinkWechatMobileIdentityV1(OAuthCodeCallbackDto oAuthCodeCallbackDto) async
    test('test accountControllerLinkWechatMobileIdentityV1', () async {
      // TODO
    });

    // Link WeChat web identity to authenticated account
    //
    //Future<AccountResponseDto> accountControllerLinkWechatWebIdentityV1(OAuthCallbackDto oAuthCallbackDto) async
    test('test accountControllerLinkWechatWebIdentityV1', () async {
      // TODO
    });

    // Set initial password for OAuth-only account using email verification
    //
    //Future<SuccessResponseDto> accountControllerSetPasswordV1(SetPasswordDto setPasswordDto) async
    test('test accountControllerSetPasswordV1', () async {
      // TODO
    });

    // Unlink authenticated account OAuth identity
    //
    //Future<AccountResponseDto> accountControllerUnlinkIdentityV1(String identityId) async
    test('test accountControllerUnlinkIdentityV1', () async {
      // TODO
    });

    // Update authenticated account profile
    //
    //Future<AccountResponseDto> accountControllerUpdateAccountV1(UpdateAccountDto updateAccountDto) async
    test('test accountControllerUpdateAccountV1', () async {
      // TODO
    });
  });
}
