import 'package:lucent_openapi/src/model/account_dto.dart';
import 'package:lucent_openapi/src/model/account_email_data_dto.dart';
import 'package:lucent_openapi/src/model/account_email_response_dto.dart';
import 'package:lucent_openapi/src/model/account_identity_dto.dart';
import 'package:lucent_openapi/src/model/account_response_dto.dart';
import 'package:lucent_openapi/src/model/air_quality_indicator_dto.dart';
import 'package:lucent_openapi/src/model/app_info_data_dto.dart';
import 'package:lucent_openapi/src/model/app_info_response_dto.dart';
import 'package:lucent_openapi/src/model/change_email_dto.dart';
import 'package:lucent_openapi/src/model/change_password_dto.dart';
import 'package:lucent_openapi/src/model/cn_medicine_detail_dto.dart';
import 'package:lucent_openapi/src/model/cooldown_message_dto.dart';
import 'package:lucent_openapi/src/model/create_current_medicine_dto.dart';
import 'package:lucent_openapi/src/model/create_daily_record_dto.dart';
import 'package:lucent_openapi/src/model/create_daily_record_image_upload_dto.dart';
import 'package:lucent_openapi/src/model/create_dose_log_dto.dart';
import 'package:lucent_openapi/src/model/create_health_context_allergy_dto.dart';
import 'package:lucent_openapi/src/model/create_health_context_condition_dto.dart';
import 'package:lucent_openapi/src/model/create_medicine_reminder_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_attachment_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_attachment_input_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_candidate_data_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_candidate_item_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_candidate_response_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_image_upload_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_image_upload_response_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_item_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_list_data_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_list_response_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_response_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_summary_data_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_summary_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_summary_response_dto.dart';
import 'package:lucent_openapi/src/model/data_export_latest_response_dto.dart';
import 'package:lucent_openapi/src/model/data_export_request_data_dto.dart';
import 'package:lucent_openapi/src/model/data_export_request_response_dto.dart';
import 'package:lucent_openapi/src/model/delete_account_dto.dart';
import 'package:lucent_openapi/src/model/dose_log_item_dto.dart';
import 'package:lucent_openapi/src/model/dose_log_list_data_dto.dart';
import 'package:lucent_openapi/src/model/dose_log_list_response_dto.dart';
import 'package:lucent_openapi/src/model/dose_log_response_dto.dart';
import 'package:lucent_openapi/src/model/drugbank_medicine_detail_dto.dart';
import 'package:lucent_openapi/src/model/environment_snapshot_dto.dart';
import 'package:lucent_openapi/src/model/environment_snapshot_response_dto.dart';
import 'package:lucent_openapi/src/model/forgot_password_dto.dart';
import 'package:lucent_openapi/src/model/forgot_password_response_dto.dart';
import 'package:lucent_openapi/src/model/generate_daily_record_candidates_dto.dart';
import 'package:lucent_openapi/src/model/generate_report_summary_dto.dart';
import 'package:lucent_openapi/src/model/generate_today_analysis_dto.dart';
import 'package:lucent_openapi/src/model/health_app_info_dto.dart';
import 'package:lucent_openapi/src/model/health_component_dto.dart';
import 'package:lucent_openapi/src/model/health_context_data_dto.dart';
import 'package:lucent_openapi/src/model/health_context_response_dto.dart';
import 'package:lucent_openapi/src/model/health_probe_dto.dart';
import 'package:lucent_openapi/src/model/health_response_dto.dart';
import 'package:lucent_openapi/src/model/health_summary_dto.dart';
import 'package:lucent_openapi/src/model/humidity_indicator_dto.dart';
import 'package:lucent_openapi/src/model/login_data_dto.dart';
import 'package:lucent_openapi/src/model/login_dto.dart';
import 'package:lucent_openapi/src/model/login_response_dto.dart';
import 'package:lucent_openapi/src/model/logout_dto.dart';
import 'package:lucent_openapi/src/model/medicine_detail_data_dto.dart';
import 'package:lucent_openapi/src/model/medicine_detail_data_dto_detail.dart';
import 'package:lucent_openapi/src/model/medicine_detail_response_dto.dart';
import 'package:lucent_openapi/src/model/medicine_pagination_dto.dart';
import 'package:lucent_openapi/src/model/medicine_reminder_item_dto.dart';
import 'package:lucent_openapi/src/model/medicine_reminder_list_data_dto.dart';
import 'package:lucent_openapi/src/model/medicine_reminder_list_response_dto.dart';
import 'package:lucent_openapi/src/model/medicine_reminder_response_dto.dart';
import 'package:lucent_openapi/src/model/medicine_search_item_dto.dart';
import 'package:lucent_openapi/src/model/medicine_search_meta_dto.dart';
import 'package:lucent_openapi/src/model/medicine_search_response_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_authorize_data_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_authorize_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_authorize_response_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_callback_dto.dart';
import 'package:lucent_openapi/src/model/o_auth_code_callback_dto.dart';
import 'package:lucent_openapi/src/model/pollen_indicator_dto.dart';
import 'package:lucent_openapi/src/model/refresh_dto.dart';
import 'package:lucent_openapi/src/model/refresh_response_dto.dart';
import 'package:lucent_openapi/src/model/register_data_dto.dart';
import 'package:lucent_openapi/src/model/register_dto.dart';
import 'package:lucent_openapi/src/model/register_response_dto.dart';
import 'package:lucent_openapi/src/model/reminder_delivery_item_dto.dart';
import 'package:lucent_openapi/src/model/reminder_delivery_list_data_dto.dart';
import 'package:lucent_openapi/src/model/reminder_delivery_list_response_dto.dart';
import 'package:lucent_openapi/src/model/report_dashboard_data_dto.dart';
import 'package:lucent_openapi/src/model/report_dashboard_response_dto.dart';
import 'package:lucent_openapi/src/model/report_dashboard_score_dto.dart';
import 'package:lucent_openapi/src/model/report_finding_dto.dart';
import 'package:lucent_openapi/src/model/report_metric_dto.dart';
import 'package:lucent_openapi/src/model/report_pattern_dto.dart';
import 'package:lucent_openapi/src/model/report_summary_bullet_dto.dart';
import 'package:lucent_openapi/src/model/report_summary_data_dto.dart';
import 'package:lucent_openapi/src/model/report_summary_response_dto.dart';
import 'package:lucent_openapi/src/model/report_trend_dto.dart';
import 'package:lucent_openapi/src/model/reset_password_dto.dart';
import 'package:lucent_openapi/src/model/send_verification_code_dto.dart';
import 'package:lucent_openapi/src/model/send_verification_code_response_dto.dart';
import 'package:lucent_openapi/src/model/success_response_dto.dart';
import 'package:lucent_openapi/src/model/support_resource_dto.dart';
import 'package:lucent_openapi/src/model/support_resource_list_data_dto.dart';
import 'package:lucent_openapi/src/model/support_resource_list_response_dto.dart';
import 'package:lucent_openapi/src/model/temperature_indicator_dto.dart';
import 'package:lucent_openapi/src/model/today_analysis_bullet_dto.dart';
import 'package:lucent_openapi/src/model/today_analysis_data_dto.dart';
import 'package:lucent_openapi/src/model/today_analysis_response_dto.dart';
import 'package:lucent_openapi/src/model/tokens_dto.dart';
import 'package:lucent_openapi/src/model/update_account_dto.dart';
import 'package:lucent_openapi/src/model/update_current_medicine_dto.dart';
import 'package:lucent_openapi/src/model/update_daily_record_dto.dart';
import 'package:lucent_openapi/src/model/update_dose_log_dto.dart';
import 'package:lucent_openapi/src/model/update_health_context_allergy_dto.dart';
import 'package:lucent_openapi/src/model/update_health_context_condition_dto.dart';
import 'package:lucent_openapi/src/model/update_health_context_profile_dto.dart';
import 'package:lucent_openapi/src/model/update_medicine_reminder_dto.dart';
import 'package:lucent_openapi/src/model/update_user_settings_dto.dart';
import 'package:lucent_openapi/src/model/user_allergy_item_dto.dart';
import 'package:lucent_openapi/src/model/user_brief_dto.dart';
import 'package:lucent_openapi/src/model/user_condition_item_dto.dart';
import 'package:lucent_openapi/src/model/user_current_medicine_item_dto.dart';
import 'package:lucent_openapi/src/model/user_full_dto.dart';
import 'package:lucent_openapi/src/model/user_health_profile_dto.dart';
import 'package:lucent_openapi/src/model/user_health_summary_dto.dart';
import 'package:lucent_openapi/src/model/user_settings_data_dto.dart';
import 'package:lucent_openapi/src/model/user_settings_response_dto.dart';
import 'package:lucent_openapi/src/model/uv_indicator_dto.dart';
import 'package:lucent_openapi/src/model/verify_email_data_dto.dart';
import 'package:lucent_openapi/src/model/verify_email_dto.dart';
import 'package:lucent_openapi/src/model/verify_email_response_dto.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
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
          return AccountEmailDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountEmailResponseDto':
          return AccountEmailResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountIdentityDto':
          return AccountIdentityDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountResponseDto':
          return AccountResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AirQualityIndicatorDto':
          return AirQualityIndicatorDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AirQualityLevel':
          
          
        case 'AppInfoDataDto':
          return AppInfoDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AppInfoResponseDto':
          return AppInfoResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChangeEmailDto':
          return ChangeEmailDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChangePasswordDto':
          return ChangePasswordDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CnMedicineDetailDto':
          return CnMedicineDetailDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CooldownMessageDto':
          return CooldownMessageDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateCurrentMedicineDto':
          return CreateCurrentMedicineDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateDailyRecordDto':
          return CreateDailyRecordDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateDailyRecordImageUploadDto':
          return CreateDailyRecordImageUploadDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateDoseLogDto':
          return CreateDoseLogDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateHealthContextAllergyDto':
          return CreateHealthContextAllergyDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateHealthContextConditionDto':
          return CreateHealthContextConditionDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateMedicineReminderDto':
          return CreateMedicineReminderDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordAttachmentDto':
          return DailyRecordAttachmentDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordAttachmentInputDto':
          return DailyRecordAttachmentInputDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordAttachmentKind':
          
          
        case 'DailyRecordCandidateDataDto':
          return DailyRecordCandidateDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordCandidateItemDto':
          return DailyRecordCandidateItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordCandidateKind':
          
          
        case 'DailyRecordCandidateResponseDto':
          return DailyRecordCandidateResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordImageUploadDto':
          return DailyRecordImageUploadDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordImageUploadResponseDto':
          return DailyRecordImageUploadResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordItemDto':
          return DailyRecordItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordKind':
          
          
        case 'DailyRecordListDataDto':
          return DailyRecordListDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordListResponseDto':
          return DailyRecordListResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordResponseDto':
          return DailyRecordResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordSummaryDataDto':
          return DailyRecordSummaryDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordSummaryDto':
          return DailyRecordSummaryDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DailyRecordSummaryResponseDto':
          return DailyRecordSummaryResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataExportLatestResponseDto':
          return DataExportLatestResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataExportRequestDataDto':
          return DataExportRequestDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataExportRequestResponseDto':
          return DataExportRequestResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataExportStatus':
          
          
        case 'DeleteAccountDto':
          return DeleteAccountDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DoseLogItemDto':
          return DoseLogItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DoseLogListDataDto':
          return DoseLogListDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DoseLogListResponseDto':
          return DoseLogListResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DoseLogResponseDto':
          return DoseLogResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DoseLogStatus':
          
          
        case 'DrugbankMedicineDetailDto':
          return DrugbankMedicineDetailDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnvironmentDataSource':
          
          
        case 'EnvironmentSnapshotDto':
          return EnvironmentSnapshotDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EnvironmentSnapshotResponseDto':
          return EnvironmentSnapshotResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ForgotPasswordDto':
          return ForgotPasswordDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ForgotPasswordResponseDto':
          return ForgotPasswordResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GenerateDailyRecordCandidatesDto':
          return GenerateDailyRecordCandidatesDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GenerateReportSummaryDto':
          return GenerateReportSummaryDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GenerateTodayAnalysisDto':
          return GenerateTodayAnalysisDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthAppInfoDto':
          return HealthAppInfoDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthComponentDto':
          return HealthComponentDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthComponentStatus':
          
          
        case 'HealthContextDataDto':
          return HealthContextDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthContextResponseDto':
          return HealthContextResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthOverallStatus':
          
          
        case 'HealthProbeDto':
          return HealthProbeDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthProbeType':
          
          
        case 'HealthResponseDto':
          return HealthResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthSummaryDto':
          return HealthSummaryDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HumidityIndicatorDto':
          return HumidityIndicatorDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LactationState':
          
          
        case 'LoginDataDto':
          return LoginDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginDto':
          return LoginDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginResponseDto':
          return LoginResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogoutDto':
          return LogoutDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineDetailDataDto':
          return MedicineDetailDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineDetailDataDtoDetail':
          return MedicineDetailDataDtoDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineDetailResponseDto':
          return MedicineDetailResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicinePaginationDto':
          return MedicinePaginationDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineReminderItemDto':
          return MedicineReminderItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineReminderListDataDto':
          return MedicineReminderListDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineReminderListResponseDto':
          return MedicineReminderListResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineReminderResponseDto':
          return MedicineReminderResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineSearchItemDto':
          return MedicineSearchItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineSearchMetaDto':
          return MedicineSearchMetaDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineSearchResponseDto':
          return MedicineSearchResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MedicineSource':
          
          
        case 'OAuthAuthorizeDataDto':
          return OAuthAuthorizeDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OAuthAuthorizeDto':
          return OAuthAuthorizeDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OAuthAuthorizeResponseDto':
          return OAuthAuthorizeResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OAuthCallbackDto':
          return OAuthCallbackDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OAuthCodeCallbackDto':
          return OAuthCodeCallbackDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PollenIndicatorDto':
          return PollenIndicatorDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PollenLevel':
          
          
        case 'PregnancyState':
          
          
        case 'RefreshDto':
          return RefreshDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RefreshResponseDto':
          return RefreshResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RegisterDataDto':
          return RegisterDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RegisterDto':
          return RegisterDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RegisterResponseDto':
          return RegisterResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReminderDeliveryItemDto':
          return ReminderDeliveryItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReminderDeliveryListDataDto':
          return ReminderDeliveryListDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReminderDeliveryListResponseDto':
          return ReminderDeliveryListResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportDashboardDataDto':
          return ReportDashboardDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportDashboardResponseDto':
          return ReportDashboardResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportDashboardScoreDto':
          return ReportDashboardScoreDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportFindingDto':
          return ReportFindingDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportMetricDto':
          return ReportMetricDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportPatternDto':
          return ReportPatternDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportSummaryBulletDto':
          return ReportSummaryBulletDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportSummaryDataDto':
          return ReportSummaryDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportSummaryResponseDto':
          return ReportSummaryResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReportTrendDto':
          return ReportTrendDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ResetPasswordDto':
          return ResetPasswordDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SendVerificationCodeDto':
          return SendVerificationCodeDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SendVerificationCodeResponseDto':
          return SendVerificationCodeResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SexAtBirth':
          
          
        case 'SuccessResponseDto':
          return SuccessResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SupportResourceActionType':
          
          
        case 'SupportResourceDto':
          return SupportResourceDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SupportResourceListDataDto':
          return SupportResourceListDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SupportResourceListResponseDto':
          return SupportResourceListResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SupportResourceScope':
          
          
        case 'TemperatureIndicatorDto':
          return TemperatureIndicatorDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TodayAnalysisBulletDto':
          return TodayAnalysisBulletDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TodayAnalysisDataDto':
          return TodayAnalysisDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TodayAnalysisResponseDto':
          return TodayAnalysisResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TokensDto':
          return TokensDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UnitSystem':
          
          
        case 'UpdateAccountDto':
          return UpdateAccountDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateCurrentMedicineDto':
          return UpdateCurrentMedicineDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateDailyRecordDto':
          return UpdateDailyRecordDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateDoseLogDto':
          return UpdateDoseLogDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateHealthContextAllergyDto':
          return UpdateHealthContextAllergyDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateHealthContextConditionDto':
          return UpdateHealthContextConditionDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateHealthContextProfileDto':
          return UpdateHealthContextProfileDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateMedicineReminderDto':
          return UpdateMedicineReminderDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateUserSettingsDto':
          return UpdateUserSettingsDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserAllergyItemDto':
          return UserAllergyItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserAllergyKind':
          
          
        case 'UserAllergySeverity':
          
          
        case 'UserBriefDto':
          return UserBriefDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserConditionItemDto':
          return UserConditionItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserConditionStatus':
          
          
        case 'UserCurrentMedicineItemDto':
          return UserCurrentMedicineItemDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserFullDto':
          return UserFullDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserHealthProfileDto':
          return UserHealthProfileDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserHealthSummaryDto':
          return UserHealthSummaryDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserSettingsDataDto':
          return UserSettingsDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserSettingsResponseDto':
          return UserSettingsResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UvIndicatorDto':
          return UvIndicatorDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UvLevel':
          
          
        case 'VerifyEmailDataDto':
          return VerifyEmailDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VerifyEmailDto':
          return VerifyEmailDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VerifyEmailResponseDto':
          return VerifyEmailResponseDto.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }