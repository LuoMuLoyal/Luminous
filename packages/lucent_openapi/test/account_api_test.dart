import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for AccountApi
void main() {
  final instance = LucentOpenapi().getAccountApi();

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

    // Update authenticated account profile
    //
    //Future<AccountResponseDto> accountControllerUpdateAccountV1(UpdateAccountDto updateAccountDto) async
    test('test accountControllerUpdateAccountV1', () async {
      // TODO
    });

  });
}
