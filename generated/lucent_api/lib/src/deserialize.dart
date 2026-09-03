import 'package:lucent_api/src/model/account_controller_change_email_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_change_password_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_delete_account_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_set_password_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_unlink_identity_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_update_account_v1_request.dart';
import 'package:lucent_api/src/model/account_email_response_dto.dart';
import 'package:lucent_api/src/model/account_identity_dto.dart';
import 'package:lucent_api/src/model/account_response_dto.dart';
import 'package:lucent_api/src/model/air_quality_indicator_dto.dart';
import 'package:lucent_api/src/model/app_info_response_dto.dart';
import 'package:lucent_api/src/model/assistant_capabilities_response_dto.dart';
import 'package:lucent_api/src/model/assistant_clear_memory_response_dto.dart';
import 'package:lucent_api/src/model/assistant_clear_result_response_dto.dart';
import 'package:lucent_api/src/model/assistant_confirm_result_response_dto.dart';
import 'package:lucent_api/src/model/assistant_context_settings_dto.dart';
import 'package:lucent_api/src/model/assistant_controller_confirm_proposal_v1_request.dart';
import 'package:lucent_api/src/model/assistant_controller_rename_conversation_v1_request.dart';
import 'package:lucent_api/src/model/assistant_controller_stream_messages_v1_request.dart';
import 'package:lucent_api/src/model/assistant_controller_stream_messages_v1_request_messages_inner.dart';
import 'package:lucent_api/src/model/assistant_conversation_data_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_message_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_response_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_summary_dto.dart';
import 'package:lucent_api/src/model/assistant_tool_capability_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_allergy_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_condition_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_coverage_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_coverage_entry_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_export_async_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_medicine_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_note_entry_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_profile_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_item_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_scope_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_sleep_entry_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_water_entry_dto.dart';
import 'package:lucent_api/src/model/cn_medicine_detail_dto.dart';
import 'package:lucent_api/src/model/daily_record_attachment_dto.dart';
import 'package:lucent_api/src/model/daily_record_candidate_item_dto.dart';
import 'package:lucent_api/src/model/daily_record_candidate_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_image_upload_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_item_dto.dart';
import 'package:lucent_api/src/model/daily_record_list_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_summary_dto.dart';
import 'package:lucent_api/src/model/daily_record_summary_response_dto.dart';
import 'package:lucent_api/src/model/daily_records_controller_create_image_upload_v1_request.dart';
import 'package:lucent_api/src/model/daily_records_controller_create_v1_request.dart';
import 'package:lucent_api/src/model/daily_records_controller_create_v1_request_attachments_inner.dart';
import 'package:lucent_api/src/model/daily_records_controller_generate_candidates_v1_request.dart';
import 'package:lucent_api/src/model/daily_records_controller_update_v1_request.dart';
import 'package:lucent_api/src/model/data_export_controller_create_request_v1_request.dart';
import 'package:lucent_api/src/model/data_export_request_data_dto.dart';
import 'package:lucent_api/src/model/data_export_request_response_dto.dart';
import 'package:lucent_api/src/model/dose_log_item_dto.dart';
import 'package:lucent_api/src/model/dose_log_list_response_dto.dart';
import 'package:lucent_api/src/model/dose_log_response_dto.dart';
import 'package:lucent_api/src/model/drugbank_drug_interaction_dto.dart';
import 'package:lucent_api/src/model/drugbank_medicine_detail_dto.dart';
import 'package:lucent_api/src/model/emergency_contact_dto.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto.dart';
import 'package:lucent_api/src/model/event_review_check_in_coverage_dto.dart';
import 'package:lucent_api/src/model/event_review_coverage_summary_dto.dart';
import 'package:lucent_api/src/model/event_review_data_dto.dart';
import 'package:lucent_api/src/model/event_review_event_dto.dart';
import 'package:lucent_api/src/model/event_review_list_response_dto.dart';
import 'package:lucent_api/src/model/event_review_observed_source_dto.dart';
import 'package:lucent_api/src/model/event_review_response_dto.dart';
import 'package:lucent_api/src/model/event_review_section_dto.dart';
import 'package:lucent_api/src/model/event_review_section_facts_dto.dart';
import 'package:lucent_api/src/model/event_review_sections_dto.dart';
import 'package:lucent_api/src/model/event_review_source_timestamps_dto.dart';
import 'package:lucent_api/src/model/event_review_today_check_in_dto.dart';
import 'package:lucent_api/src/model/evidence_item_dto.dart';
import 'package:lucent_api/src/model/files_controller_create_upload_v1_request.dart';
import 'package:lucent_api/src/model/forgot_password_response_dto.dart';
import 'package:lucent_api/src/model/funnel_daily_counts_dto.dart';
import 'package:lucent_api/src/model/funnel_optional_counts_dto.dart';
import 'package:lucent_api/src/model/funnel_response_dto.dart';
import 'package:lucent_api/src/model/funnel_totals_dto.dart';
import 'package:lucent_api/src/model/funnel_window_dto.dart';
import 'package:lucent_api/src/model/health_app_info_dto.dart';
import 'package:lucent_api/src/model/health_component_dto.dart';
import 'package:lucent_api/src/model/health_context_response_dto.dart';
import 'package:lucent_api/src/model/health_event_check_in_response_dto.dart';
import 'package:lucent_api/src/model/health_event_coverage_dto.dart';
import 'package:lucent_api/src/model/health_event_item_dto.dart';
import 'package:lucent_api/src/model/health_event_list_response_dto.dart';
import 'package:lucent_api/src/model/health_event_response_dto.dart';
import 'package:lucent_api/src/model/health_events_controller_create_v1_request.dart';
import 'package:lucent_api/src/model/health_events_controller_end_v1_request.dart';
import 'package:lucent_api/src/model/health_events_controller_upsert_check_in_v1_request.dart';
import 'package:lucent_api/src/model/health_response_dto.dart';
import 'package:lucent_api/src/model/health_summary_dto.dart';
import 'package:lucent_api/src/model/humidity_indicator_dto.dart';
import 'package:lucent_api/src/model/legal_document_detail_response_dto.dart';
import 'package:lucent_api/src/model/legal_document_list_item_dto.dart';
import 'package:lucent_api/src/model/legal_document_list_response_dto.dart';
import 'package:lucent_api/src/model/local_capability_response_dto.dart';
import 'package:lucent_api/src/model/local_controller_forgot_password_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_login_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_register_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_reset_password_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_send_verification_code_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_verify_email_v1_request.dart';
import 'package:lucent_api/src/model/login_response_dto.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto_detail.dart';
import 'package:lucent_api/src/model/medicine_dose_logs_controller_create_v1_request.dart';
import 'package:lucent_api/src/model/medicine_dose_logs_controller_mark_v1_request.dart';
import 'package:lucent_api/src/model/medicine_dose_logs_controller_update_v1_request.dart';
import 'package:lucent_api/src/model/medicine_pagination_dto.dart';
import 'package:lucent_api/src/model/medicine_recognition_async_response_dto.dart';
import 'package:lucent_api/src/model/medicine_recognition_result_dto.dart';
import 'package:lucent_api/src/model/medicine_red_flag_dto.dart';
import 'package:lucent_api/src/model/medicine_reminder_item_dto.dart';
import 'package:lucent_api/src/model/medicine_reminder_list_response_dto.dart';
import 'package:lucent_api/src/model/medicine_reminder_response_dto.dart';
import 'package:lucent_api/src/model/medicine_reminders_controller_create_v1_request.dart';
import 'package:lucent_api/src/model/medicine_reminders_controller_update_v1_request.dart';
import 'package:lucent_api/src/model/medicine_reminders_controller_upsert_group_v1_request.dart';
import 'package:lucent_api/src/model/medicine_reminders_controller_upsert_group_v1_request_slots_inner.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_response_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_response_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_coverage_issue_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_finding_dto.dart';
import 'package:lucent_api/src/model/medicine_safety_tip_response_dto.dart';
import 'package:lucent_api/src/model/medicine_search_item_dto.dart';
import 'package:lucent_api/src/model/medicine_search_response_dto.dart';
import 'package:lucent_api/src/model/medicines_controller_recognize_v1_request.dart';
import 'package:lucent_api/src/model/medicines_controller_run_risk_check_v1_request.dart';
import 'package:lucent_api/src/model/medicines_controller_run_risk_check_v1_request_candidate.dart';
import 'package:lucent_api/src/model/notification_detail_response_dto.dart';
import 'package:lucent_api/src/model/notification_list_item_dto.dart';
import 'package:lucent_api/src/model/notification_list_response_dto.dart';
import 'package:lucent_api/src/model/notification_preferences_controller_patch_v1_request.dart';
import 'package:lucent_api/src/model/notification_preferences_response_dto.dart';
import 'package:lucent_api/src/model/notifications_controller_create_v1_request.dart';
import 'package:lucent_api/src/model/o_auth_authorize_response_dto.dart';
import 'package:lucent_api/src/model/o_auth_controller_create_google_authorize_url_v1_request.dart';
import 'package:lucent_api/src/model/o_auth_controller_create_qq_authorize_url_v1_request.dart';
import 'package:lucent_api/src/model/o_auth_controller_create_wechat_web_authorize_url_v1_request.dart';
import 'package:lucent_api/src/model/o_auth_controller_create_weibo_authorize_url_v1_request.dart';
import 'package:lucent_api/src/model/o_auth_controller_login_with_apple_v1_request.dart';
import 'package:lucent_api/src/model/o_auth_controller_login_with_wechat_mobile_v1_request.dart';
import 'package:lucent_api/src/model/o_auth_controller_login_with_wechat_web_v1_request.dart';
import 'package:lucent_api/src/model/pollen_indicator_dto.dart';
import 'package:lucent_api/src/model/problem_details_dto.dart';
import 'package:lucent_api/src/model/product_events_controller_record_batch_v1_request.dart';
import 'package:lucent_api/src/model/product_events_controller_record_batch_v1_request_events_inner.dart';
import 'package:lucent_api/src/model/refresh_response_dto.dart';
import 'package:lucent_api/src/model/register_response_dto.dart';
import 'package:lucent_api/src/model/reminder_deliveries_controller_record_receipt_v1_request.dart';
import 'package:lucent_api/src/model/reminder_deliveries_controller_report_local_capability_v1_request.dart';
import 'package:lucent_api/src/model/reminder_delivery_item_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_list_response_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_receipt_response_dto.dart';
import 'package:lucent_api/src/model/report_coverage_dimension_dto.dart';
import 'package:lucent_api/src/model/report_coverage_dto.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto.dart';
import 'package:lucent_api/src/model/report_finding_dto.dart';
import 'package:lucent_api/src/model/report_low_risk_action_dto.dart';
import 'package:lucent_api/src/model/report_metric_dto.dart';
import 'package:lucent_api/src/model/report_observed_metric_dto.dart';
import 'package:lucent_api/src/model/report_observed_pattern_dto.dart';
import 'package:lucent_api/src/model/report_pattern_dto.dart';
import 'package:lucent_api/src/model/report_summary_async_response_dto.dart';
import 'package:lucent_api/src/model/report_summary_data_dto.dart';
import 'package:lucent_api/src/model/report_summary_response_dto.dart';
import 'package:lucent_api/src/model/report_trend_dto.dart';
import 'package:lucent_api/src/model/reports_controller_generate_summary_v1_request.dart';
import 'package:lucent_api/src/model/reports_controller_preview_clinic_summary_v1_request.dart';
import 'package:lucent_api/src/model/send_verification_code_response_dto.dart';
import 'package:lucent_api/src/model/session_controller_logout_v1_request.dart';
import 'package:lucent_api/src/model/session_list_item_dto.dart';
import 'package:lucent_api/src/model/sse_problem_details_dto.dart';
import 'package:lucent_api/src/model/suggestion_action_dto.dart';
import 'package:lucent_api/src/model/suggestion_explanation_async_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_explanation_data_dto.dart';
import 'package:lucent_api/src/model/suggestion_explanation_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_feedback_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_history_item_dto.dart';
import 'package:lucent_api/src/model/suggestion_history_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_item_dto.dart';
import 'package:lucent_api/src/model/suggestion_observed_metric_dto.dart';
import 'package:lucent_api/src/model/temperature_indicator_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_job_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_status_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_bullet_dto.dart';
import 'package:lucent_api/src/model/today_analysis_controller_generate_async_v1202_response.dart';
import 'package:lucent_api/src/model/today_analysis_controller_generate_v1200_response.dart';
import 'package:lucent_api/src/model/today_analysis_controller_refresh_v1201_response.dart';
import 'package:lucent_api/src/model/today_analysis_controller_refresh_v1_request.dart';
import 'package:lucent_api/src/model/today_analysis_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_metric_dto.dart';
import 'package:lucent_api/src/model/today_analysis_observed_metric_dto.dart';
import 'package:lucent_api/src/model/today_analysis_read_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_pending_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_stream_error_dto.dart';
import 'package:lucent_api/src/model/today_analysis_stream_result_dto.dart';
import 'package:lucent_api/src/model/today_analysis_stream_result_dto_data.dart';
import 'package:lucent_api/src/model/today_analysis_stream_summary_dto.dart';
import 'package:lucent_api/src/model/today_recommendation_response_dto.dart';
import 'package:lucent_api/src/model/today_suggestion_controller_submit_feedback_v1_request.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto.dart';
import 'package:lucent_api/src/model/tokens_dto.dart';
import 'package:lucent_api/src/model/unread_count_response_dto.dart';
import 'package:lucent_api/src/model/user_allergy_item_dto.dart';
import 'package:lucent_api/src/model/user_brief_dto.dart';
import 'package:lucent_api/src/model/user_condition_item_dto.dart';
import 'package:lucent_api/src/model/user_current_medicine_item_dto.dart';
import 'package:lucent_api/src/model/user_full_dto.dart';
import 'package:lucent_api/src/model/user_health_context_controller_create_allergy_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_create_condition_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_create_current_medicine_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_update_allergy_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_update_condition_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_update_current_medicine_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_update_user_health_context_profile_v1_request.dart';
import 'package:lucent_api/src/model/user_health_profile_dto.dart';
import 'package:lucent_api/src/model/user_health_summary_dto.dart';
import 'package:lucent_api/src/model/user_settings_controller_update_settings_v1_request.dart';
import 'package:lucent_api/src/model/user_settings_controller_update_settings_v1_request_assistant_context.dart';
import 'package:lucent_api/src/model/user_settings_response_dto.dart';
import 'package:lucent_api/src/model/uv_indicator_dto.dart';
import 'package:lucent_api/src/model/verify_email_response_dto.dart';

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
    case 'AccountControllerChangeEmailV1Request':
      return AccountControllerChangeEmailV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AccountControllerChangePasswordV1Request':
      return AccountControllerChangePasswordV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AccountControllerDeleteAccountV1Request':
      return AccountControllerDeleteAccountV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AccountControllerSetPasswordV1Request':
      return AccountControllerSetPasswordV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AccountControllerUnlinkIdentityV1Request':
      return AccountControllerUnlinkIdentityV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AccountControllerUpdateAccountV1Request':
      return AccountControllerUpdateAccountV1Request.fromJson(
            value as Map<String, dynamic>,
          )
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
    case 'AirQualityIndicatorDto':
      return AirQualityIndicatorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AirQualityLevel':
    case 'AppInfoResponseDto':
      return AppInfoResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantCapabilitiesResponseDto':
      return AssistantCapabilitiesResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantClearMemoryResponseDto':
      return AssistantClearMemoryResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantClearResultResponseDto':
      return AssistantClearResultResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConfirmResultResponseDto':
      return AssistantConfirmResultResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantContextSettingsDto':
      return AssistantContextSettingsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantControllerConfirmProposalV1Request':
      return AssistantControllerConfirmProposalV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantControllerRenameConversationV1Request':
      return AssistantControllerRenameConversationV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantControllerStreamMessagesV1Request':
      return AssistantControllerStreamMessagesV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantControllerStreamMessagesV1RequestMessagesInner':
      return AssistantControllerStreamMessagesV1RequestMessagesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationDataDto':
      return AssistantConversationDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationMessageDto':
      return AssistantConversationMessageDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationResponseDto':
      return AssistantConversationResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationSummaryDto':
      return AssistantConversationSummaryDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantToolCapabilityDto':
      return AssistantToolCapabilityDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryAllergyDto':
      return ClinicSummaryAllergyDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryConditionDto':
      return ClinicSummaryConditionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryCoverageDto':
      return ClinicSummaryCoverageDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryCoverageEntryDto':
      return ClinicSummaryCoverageEntryDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryExportAsyncResponseDto':
      return ClinicSummaryExportAsyncResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryMedicineDto':
      return ClinicSummaryMedicineDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryNoteEntryDto':
      return ClinicSummaryNoteEntryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryProfileDto':
      return ClinicSummaryProfileDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryResponseDto':
      return ClinicSummaryResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryShareListItemDto':
      return ClinicSummaryShareListItemDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareListResponseDto':
      return ClinicSummaryShareListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareResponseDto':
      return ClinicSummaryShareResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareScopeDto':
      return ClinicSummaryShareScopeDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummarySleepEntryDto':
      return ClinicSummarySleepEntryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryWaterEntryDto':
      return ClinicSummaryWaterEntryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CnMedicineDetailDto':
      return CnMedicineDetailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordAttachmentDto':
      return DailyRecordAttachmentDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordAttachmentKind':
    case 'DailyRecordCandidateItemDto':
      return DailyRecordCandidateItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordCandidateKind':
    case 'DailyRecordCandidateResponseDto':
      return DailyRecordCandidateResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordImageUploadResponseDto':
      return DailyRecordImageUploadResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordItemDto':
      return DailyRecordItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordKind':
    case 'DailyRecordListResponseDto':
      return DailyRecordListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordResponseDto':
      return DailyRecordResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordSummaryDto':
      return DailyRecordSummaryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordSummaryResponseDto':
      return DailyRecordSummaryResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordsControllerCreateImageUploadV1Request':
      return DailyRecordsControllerCreateImageUploadV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordsControllerCreateV1Request':
      return DailyRecordsControllerCreateV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordsControllerCreateV1RequestAttachmentsInner':
      return DailyRecordsControllerCreateV1RequestAttachmentsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordsControllerGenerateCandidatesV1Request':
      return DailyRecordsControllerGenerateCandidatesV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordsControllerUpdateV1Request':
      return DailyRecordsControllerUpdateV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DataExportControllerCreateRequestV1Request':
      return DataExportControllerCreateRequestV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DataExportFormat':
    case 'DataExportKind':
    case 'DataExportRange':
    case 'DataExportRequestDataDto':
      return DataExportRequestDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DataExportRequestResponseDto':
      return DataExportRequestResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DataExportStatus':
    case 'DoseLogItemDto':
      return DoseLogItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogListResponseDto':
      return DoseLogListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogResponseDto':
      return DoseLogResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogStatus':
    case 'DrugbankDrugInteractionDto':
      return DrugbankDrugInteractionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DrugbankMedicineDetailDto':
      return DrugbankMedicineDetailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EmergencyContactDto':
      return EmergencyContactDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EnvironmentDataSource':
    case 'EnvironmentSnapshotResponseDto':
      return EnvironmentSnapshotResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewCheckInCoverageDto':
      return EventReviewCheckInCoverageDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewCoverageSummaryDto':
      return EventReviewCoverageSummaryDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataDto':
      return EventReviewDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewEventDto':
      return EventReviewEventDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewListResponseDto':
      return EventReviewListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewObservedSourceDto':
      return EventReviewObservedSourceDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseDto':
      return EventReviewResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewSectionDto':
      return EventReviewSectionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewSectionFactsDto':
      return EventReviewSectionFactsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewSectionsDto':
      return EventReviewSectionsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewSourceTimestampsDto':
      return EventReviewSourceTimestampsDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewTodayCheckInDto':
      return EventReviewTodayCheckInDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EvidenceItemDto':
      return EvidenceItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FilesControllerCreateUploadV1Request':
      return FilesControllerCreateUploadV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ForgotPasswordResponseDto':
      return ForgotPasswordResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelDailyCountsDto':
      return FunnelDailyCountsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelOptionalCountsDto':
      return FunnelOptionalCountsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseDto':
      return FunnelResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelTotalsDto':
      return FunnelTotalsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelWindowDto':
      return FunnelWindowDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthAppInfoDto':
      return HealthAppInfoDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthComponentDto':
      return HealthComponentDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthComponentStatus':
    case 'HealthContextResponseDto':
      return HealthContextResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventCheckInResponseDto':
      return HealthEventCheckInResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventCoverageDto':
      return HealthEventCoverageDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventItemDto':
      return HealthEventItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventKind':
    case 'HealthEventListResponseDto':
      return HealthEventListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventOutcome':
    case 'HealthEventResponseDto':
      return HealthEventResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventStatus':
    case 'HealthEventsControllerCreateV1Request':
      return HealthEventsControllerCreateV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventsControllerEndV1Request':
      return HealthEventsControllerEndV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventsControllerUpsertCheckInV1Request':
      return HealthEventsControllerUpsertCheckInV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthOverallStatus':
    case 'HealthProbeType':
    case 'HealthResponseDto':
      return HealthResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthSummaryDto':
      return HealthSummaryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HumidityIndicatorDto':
      return HumidityIndicatorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LegalDocumentDetailResponseDto':
      return LegalDocumentDetailResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LegalDocumentListItemDto':
      return LegalDocumentListItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LegalDocumentListResponseDto':
      return LegalDocumentListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LocalCapabilityResponseDto':
      return LocalCapabilityResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LocalControllerForgotPasswordV1Request':
      return LocalControllerForgotPasswordV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LocalControllerLoginV1Request':
      return LocalControllerLoginV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LocalControllerRegisterV1Request':
      return LocalControllerRegisterV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LocalControllerResetPasswordV1Request':
      return LocalControllerResetPasswordV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LocalControllerSendVerificationCodeV1Request':
      return LocalControllerSendVerificationCodeV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LocalControllerVerifyEmailV1Request':
      return LocalControllerVerifyEmailV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LoginResponseDto':
      return LoginResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineDetailResponseDto':
      return MedicineDetailResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineDetailResponseDtoDetail':
      return MedicineDetailResponseDtoDetail.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineDoseLogsControllerCreateV1Request':
      return MedicineDoseLogsControllerCreateV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineDoseLogsControllerMarkV1Request':
      return MedicineDoseLogsControllerMarkV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineDoseLogsControllerUpdateV1Request':
      return MedicineDoseLogsControllerUpdateV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicinePaginationDto':
      return MedicinePaginationDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineRecognitionAsyncResponseDto':
      return MedicineRecognitionAsyncResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRecognitionResultDto':
      return MedicineRecognitionResultDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRedFlagDto':
      return MedicineRedFlagDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineReminderItemDto':
      return MedicineReminderItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineReminderListResponseDto':
      return MedicineReminderListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineReminderResponseDto':
      return MedicineReminderResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineRemindersControllerCreateV1Request':
      return MedicineRemindersControllerCreateV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRemindersControllerUpdateV1Request':
      return MedicineRemindersControllerUpdateV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRemindersControllerUpsertGroupV1Request':
      return MedicineRemindersControllerUpsertGroupV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRemindersControllerUpsertGroupV1RequestSlotsInner':
      return MedicineRemindersControllerUpsertGroupV1RequestSlotsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordDto':
      return MedicineRiskCheckRecordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineRiskCheckRecordResponseDto':
      return MedicineRiskCheckRecordResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsDto':
      return MedicineRiskCheckRecordsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseDto':
      return MedicineRiskCheckRecordsResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckResponseDto':
      return MedicineRiskCheckResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCoverageIssueDto':
      return MedicineRiskCoverageIssueDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskFindingDto':
      return MedicineRiskFindingDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSafetyTipResponseDto':
      return MedicineSafetyTipResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineSearchItemDto':
      return MedicineSearchItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchResponseDto':
      return MedicineSearchResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSource':
    case 'MedicinesControllerRecognizeV1Request':
      return MedicinesControllerRecognizeV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicinesControllerRunRiskCheckV1Request':
      return MedicinesControllerRunRiskCheckV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicinesControllerRunRiskCheckV1RequestCandidate':
      return MedicinesControllerRunRiskCheckV1RequestCandidate.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'NotificationDetailResponseDto':
      return NotificationDetailResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'NotificationListItemDto':
      return NotificationListItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationListResponseDto':
      return NotificationListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationPreferencesControllerPatchV1Request':
      return NotificationPreferencesControllerPatchV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'NotificationPreferencesResponseDto':
      return NotificationPreferencesResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'NotificationsControllerCreateV1Request':
      return NotificationsControllerCreateV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'OAuthAuthorizeResponseDto':
      return OAuthAuthorizeResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OAuthControllerCreateGoogleAuthorizeUrlV1Request':
      return OAuthControllerCreateGoogleAuthorizeUrlV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'OAuthControllerCreateQqAuthorizeUrlV1Request':
      return OAuthControllerCreateQqAuthorizeUrlV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'OAuthControllerCreateWechatWebAuthorizeUrlV1Request':
      return OAuthControllerCreateWechatWebAuthorizeUrlV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'OAuthControllerCreateWeiboAuthorizeUrlV1Request':
      return OAuthControllerCreateWeiboAuthorizeUrlV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'OAuthControllerLoginWithAppleV1Request':
      return OAuthControllerLoginWithAppleV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'OAuthControllerLoginWithWechatMobileV1Request':
      return OAuthControllerLoginWithWechatMobileV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'OAuthControllerLoginWithWechatWebV1Request':
      return OAuthControllerLoginWithWechatWebV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'PollenIndicatorDto':
      return PollenIndicatorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PollenLevel':
    case 'ProblemDetailsDto':
      return ProblemDetailsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProductEventsControllerRecordBatchV1Request':
      return ProductEventsControllerRecordBatchV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ProductEventsControllerRecordBatchV1RequestEventsInner':
      return ProductEventsControllerRecordBatchV1RequestEventsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'RefreshResponseDto':
      return RefreshResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterResponseDto':
      return RegisterResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReminderDeliveriesControllerRecordReceiptV1Request':
      return ReminderDeliveriesControllerRecordReceiptV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveriesControllerReportLocalCapabilityV1Request':
      return ReminderDeliveriesControllerReportLocalCapabilityV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryItemDto':
      return ReminderDeliveryItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReminderDeliveryListResponseDto':
      return ReminderDeliveryListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryReceiptResponseDto':
      return ReminderDeliveryReceiptResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportCoverageDimensionDto':
      return ReportCoverageDimensionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportCoverageDto':
      return ReportCoverageDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportDashboardResponseDto':
      return ReportDashboardResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportFindingDto':
      return ReportFindingDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportLowRiskActionDto':
      return ReportLowRiskActionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportMetricDto':
      return ReportMetricDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportObservedMetricDto':
      return ReportObservedMetricDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportObservedPatternDto':
      return ReportObservedPatternDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportPatternDto':
      return ReportPatternDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportSummaryAsyncResponseDto':
      return ReportSummaryAsyncResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryDataDto':
      return ReportSummaryDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportSummaryResponseDto':
      return ReportSummaryResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportTrendDto':
      return ReportTrendDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportsControllerGenerateSummaryV1Request':
      return ReportsControllerGenerateSummaryV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportsControllerPreviewClinicSummaryV1Request':
      return ReportsControllerPreviewClinicSummaryV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SendVerificationCodeResponseDto':
      return SendVerificationCodeResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SessionControllerLogoutV1Request':
      return SessionControllerLogoutV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SessionListItemDto':
      return SessionListItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SexAtBirth':
    case 'SseProblemDetailsDto':
      return SseProblemDetailsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionActionDto':
      return SuggestionActionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionExplanationAsyncResponseDto':
      return SuggestionExplanationAsyncResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionExplanationDataDto':
      return SuggestionExplanationDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionExplanationResponseDto':
      return SuggestionExplanationResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionFeedbackResponseDto':
      return SuggestionFeedbackResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionHistoryItemDto':
      return SuggestionHistoryItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionHistoryResponseDto':
      return SuggestionHistoryResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionItemDto':
      return SuggestionItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionObservedMetricDto':
      return SuggestionObservedMetricDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TemperatureIndicatorDto':
      return TemperatureIndicatorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisAsyncJobDataDto':
      return TodayAnalysisAsyncJobDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataDto':
      return TodayAnalysisAsyncResultDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncStatusDataDto':
      return TodayAnalysisAsyncStatusDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisBulletDto':
      return TodayAnalysisBulletDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisControllerGenerateAsyncV1202Response':
      return TodayAnalysisControllerGenerateAsyncV1202Response.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisControllerGenerateV1200Response':
      return TodayAnalysisControllerGenerateV1200Response.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisControllerRefreshV1201Response':
      return TodayAnalysisControllerRefreshV1201Response.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisControllerRefreshV1Request':
      return TodayAnalysisControllerRefreshV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisDataDto':
      return TodayAnalysisDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisMetricDto':
      return TodayAnalysisMetricDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisObservedMetricDto':
      return TodayAnalysisObservedMetricDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadDataDto':
      return TodayAnalysisReadDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisReadResponseDto':
      return TodayAnalysisReadResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisRefreshPendingDataDto':
      return TodayAnalysisRefreshPendingDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisRefreshReadyDataDto':
      return TodayAnalysisRefreshReadyDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisStreamErrorDto':
      return TodayAnalysisStreamErrorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisStreamResultDto':
      return TodayAnalysisStreamResultDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisStreamResultDtoData':
      return TodayAnalysisStreamResultDtoData.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisStreamSummaryDto':
      return TodayAnalysisStreamSummaryDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayRecommendationResponseDto':
      return TodayRecommendationResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionControllerSubmitFeedbackV1Request':
      return TodaySuggestionControllerSubmitFeedbackV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseDto':
      return TodaySuggestionsResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TokensDto':
      return TokensDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UnitSystem':
    case 'UnreadCountResponseDto':
      return UnreadCountResponseDto.fromJson(value as Map<String, dynamic>)
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
    case 'UserHealthContextControllerCreateAllergyV1Request':
      return UserHealthContextControllerCreateAllergyV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserHealthContextControllerCreateConditionV1Request':
      return UserHealthContextControllerCreateConditionV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserHealthContextControllerCreateCurrentMedicineV1Request':
      return UserHealthContextControllerCreateCurrentMedicineV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserHealthContextControllerUpdateAllergyV1Request':
      return UserHealthContextControllerUpdateAllergyV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserHealthContextControllerUpdateConditionV1Request':
      return UserHealthContextControllerUpdateConditionV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserHealthContextControllerUpdateCurrentMedicineV1Request':
      return UserHealthContextControllerUpdateCurrentMedicineV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserHealthContextControllerUpdateUserHealthContextProfileV1Request':
      return UserHealthContextControllerUpdateUserHealthContextProfileV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserHealthProfileDto':
      return UserHealthProfileDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserHealthSummaryDto':
      return UserHealthSummaryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserNotificationType':
    case 'UserSettingsControllerUpdateSettingsV1Request':
      return UserSettingsControllerUpdateSettingsV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserSettingsControllerUpdateSettingsV1RequestAssistantContext':
      return UserSettingsControllerUpdateSettingsV1RequestAssistantContext.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UserSettingsResponseDto':
      return UserSettingsResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UvIndicatorDto':
      return UvIndicatorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UvLevel':
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
