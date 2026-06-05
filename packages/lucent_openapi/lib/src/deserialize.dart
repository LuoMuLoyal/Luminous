import 'package:lucent_openapi/src/model/account_dto.dart';
import 'package:lucent_openapi/src/model/account_email_data_dto.dart';
import 'package:lucent_openapi/src/model/account_email_response_dto.dart';
import 'package:lucent_openapi/src/model/account_identity_dto.dart';
import 'package:lucent_openapi/src/model/account_response_dto.dart';
import 'package:lucent_openapi/src/model/change_email_dto.dart';
import 'package:lucent_openapi/src/model/change_password_dto.dart';
import 'package:lucent_openapi/src/model/cn_medicine_detail_dto.dart';
import 'package:lucent_openapi/src/model/cooldown_message_dto.dart';
import 'package:lucent_openapi/src/model/create_current_medicine_dto.dart';
import 'package:lucent_openapi/src/model/create_daily_record_dto.dart';
import 'package:lucent_openapi/src/model/create_dose_log_dto.dart';
import 'package:lucent_openapi/src/model/create_health_context_allergy_dto.dart';
import 'package:lucent_openapi/src/model/create_health_context_condition_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_item_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_list_data_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_list_response_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_response_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_summary_data_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_summary_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_summary_response_dto.dart';
import 'package:lucent_openapi/src/model/delete_account_dto.dart';
import 'package:lucent_openapi/src/model/dose_log_item_dto.dart';
import 'package:lucent_openapi/src/model/dose_log_list_data_dto.dart';
import 'package:lucent_openapi/src/model/dose_log_list_response_dto.dart';
import 'package:lucent_openapi/src/model/dose_log_response_dto.dart';
import 'package:lucent_openapi/src/model/drugbank_medicine_detail_dto.dart';
import 'package:lucent_openapi/src/model/forgot_password_dto.dart';
import 'package:lucent_openapi/src/model/forgot_password_response_dto.dart';
import 'package:lucent_openapi/src/model/health_context_data_dto.dart';
import 'package:lucent_openapi/src/model/health_context_response_dto.dart';
import 'package:lucent_openapi/src/model/login_data_dto.dart';
import 'package:lucent_openapi/src/model/login_dto.dart';
import 'package:lucent_openapi/src/model/login_response_dto.dart';
import 'package:lucent_openapi/src/model/logout_dto.dart';
import 'package:lucent_openapi/src/model/medicine_detail_data_dto.dart';
import 'package:lucent_openapi/src/model/medicine_detail_data_dto_detail.dart';
import 'package:lucent_openapi/src/model/medicine_detail_response_dto.dart';
import 'package:lucent_openapi/src/model/medicine_pagination_dto.dart';
import 'package:lucent_openapi/src/model/medicine_search_item_dto.dart';
import 'package:lucent_openapi/src/model/medicine_search_meta_dto.dart';
import 'package:lucent_openapi/src/model/medicine_search_response_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_authorize_data_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_authorize_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_authorize_response_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_callback_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_code_callback_dto.dart';
import 'package:lucent_openapi/src/model/refresh_dto.dart';
import 'package:lucent_openapi/src/model/refresh_response_dto.dart';
import 'package:lucent_openapi/src/model/register_data_dto.dart';
import 'package:lucent_openapi/src/model/register_dto.dart';
import 'package:lucent_openapi/src/model/register_response_dto.dart';
import 'package:lucent_openapi/src/model/reset_password_dto.dart';
import 'package:lucent_openapi/src/model/send_verification_code_dto.dart';
import 'package:lucent_openapi/src/model/send_verification_code_response_dto.dart';
import 'package:lucent_openapi/src/model/success_response_dto.dart';
import 'package:lucent_openapi/src/model/tokens_dto.dart';
import 'package:lucent_openapi/src/model/update_account_dto.dart';
import 'package:lucent_openapi/src/model/update_current_medicine_dto.dart';
import 'package:lucent_openapi/src/model/update_daily_record_dto.dart';
import 'package:lucent_openapi/src/model/update_dose_log_dto.dart';
import 'package:lucent_openapi/src/model/update_health_context_allergy_dto.dart';
import 'package:lucent_openapi/src/model/update_health_context_condition_dto.dart';
import 'package:lucent_openapi/src/model/update_health_context_profile_dto.dart';
import 'package:lucent_openapi/src/model/user_allergy_item_dto.dart';
import 'package:lucent_openapi/src/model/user_brief_dto.dart';
import 'package:lucent_openapi/src/model/user_condition_item_dto.dart';
import 'package:lucent_openapi/src/model/user_current_medicine_item_dto.dart';
import 'package:lucent_openapi/src/model/user_full_dto.dart';
import 'package:lucent_openapi/src/model/user_health_profile_dto.dart';
import 'package:lucent_openapi/src/model/user_health_summary_dto.dart';
import 'package:lucent_openapi/src/model/verify_email_data_dto.dart';
import 'package:lucent_openapi/src/model/verify_email_dto.dart';
import 'package:lucent_openapi/src/model/verify_email_response_dto.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AccountDto':
      return AccountDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'AccountEmailDataDto':
      return AccountEmailDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AccountEmailResponseDto':
      return AccountEmailResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AccountIdentityDto':
      return AccountIdentityDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AccountResponseDto':
      return AccountResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangeEmailDto':
      return ChangeEmailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangePasswordDto':
      return ChangePasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CnMedicineDetailDto':
      return CnMedicineDetailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CooldownMessageDto':
      return CooldownMessageDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateCurrentMedicineDto':
      return CreateCurrentMedicineDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateDailyRecordDto':
      return CreateDailyRecordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateDoseLogDto':
      return CreateDoseLogDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateHealthContextAllergyDto':
      return CreateHealthContextAllergyDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'CreateHealthContextConditionDto':
      return CreateHealthContextConditionDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordItemDto':
      return DailyRecordItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordKind':
    case 'DailyRecordListDataDto':
      return DailyRecordListDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordListResponseDto':
      return DailyRecordListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordResponseDto':
      return DailyRecordResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordSummaryDataDto':
      return DailyRecordSummaryDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordSummaryDto':
      return DailyRecordSummaryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordSummaryResponseDto':
      return DailyRecordSummaryResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DeleteAccountDto':
      return DeleteAccountDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogItemDto':
      return DoseLogItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogListDataDto':
      return DoseLogListDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogListResponseDto':
      return DoseLogListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogResponseDto':
      return DoseLogResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogStatus':
    case 'DrugbankMedicineDetailDto':
      return DrugbankMedicineDetailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ForgotPasswordDto':
      return ForgotPasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ForgotPasswordResponseDto':
      return ForgotPasswordResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthContextDataDto':
      return HealthContextDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthContextResponseDto':
      return HealthContextResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LactationState':
    case 'LoginDataDto':
      return LoginDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LoginDto':
      return LoginDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LoginResponseDto':
      return LoginResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LogoutDto':
      return LogoutDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MedicineDetailDataDto':
      return MedicineDetailDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineDetailDataDtoDetail':
      return MedicineDetailDataDtoDetail.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineDetailResponseDto':
      return MedicineDetailResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicinePaginationDto':
      return MedicinePaginationDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchItemDto':
      return MedicineSearchItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchMetaDto':
      return MedicineSearchMetaDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchResponseDto':
      return MedicineSearchResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSource':
    case 'OAuthAuthorizeDataDto':
      return OAuthAuthorizeDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OAuthAuthorizeDto':
      return OAuthAuthorizeDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OAuthAuthorizeResponseDto':
      return OAuthAuthorizeResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OAuthCallbackDto':
      return OAuthCallbackDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OAuthCodeCallbackDto':
      return OAuthCodeCallbackDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PregnancyState':
    case 'RefreshDto':
      return RefreshDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RefreshResponseDto':
      return RefreshResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterDataDto':
      return RegisterDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterDto':
      return RegisterDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RegisterResponseDto':
      return RegisterResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ResetPasswordDto':
      return ResetPasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SendVerificationCodeDto':
      return SendVerificationCodeDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SendVerificationCodeResponseDto':
      return SendVerificationCodeResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SexAtBirth':
    case 'SuccessResponseDto':
      return SuccessResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TokensDto':
      return TokensDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UnitSystem':
    case 'UpdateAccountDto':
      return UpdateAccountDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateCurrentMedicineDto':
      return UpdateCurrentMedicineDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateDailyRecordDto':
      return UpdateDailyRecordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateDoseLogDto':
      return UpdateDoseLogDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateHealthContextAllergyDto':
      return UpdateHealthContextAllergyDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UpdateHealthContextConditionDto':
      return UpdateHealthContextConditionDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UpdateHealthContextProfileDto':
      return UpdateHealthContextProfileDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserAllergyItemDto':
      return UserAllergyItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserAllergyKind':
    case 'UserAllergySeverity':
    case 'UserBriefDto':
      return UserBriefDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UserConditionItemDto':
      return UserConditionItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserConditionStatus':
    case 'UserCurrentMedicineItemDto':
      return UserCurrentMedicineItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserFullDto':
      return UserFullDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UserHealthProfileDto':
      return UserHealthProfileDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserHealthSummaryDto':
      return UserHealthSummaryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerifyEmailDataDto':
      return VerifyEmailDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerifyEmailDto':
      return VerifyEmailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerifyEmailResponseDto':
      return VerifyEmailResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
