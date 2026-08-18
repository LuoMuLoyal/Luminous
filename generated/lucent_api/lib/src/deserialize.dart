import 'package:lucent_api/src/model/account_dto.dart';
import 'package:lucent_api/src/model/account_email_data_dto.dart';
import 'package:lucent_api/src/model/account_email_response_dto.dart';
import 'package:lucent_api/src/model/account_identity_dto.dart';
import 'package:lucent_api/src/model/account_response_dto.dart';
import 'package:lucent_api/src/model/air_quality_indicator_dto.dart';
import 'package:lucent_api/src/model/app_info_data_dto.dart';
import 'package:lucent_api/src/model/app_info_response_dto.dart';
import 'package:lucent_api/src/model/apple_o_auth_callback_dto.dart';
import 'package:lucent_api/src/model/assistant_capabilities_data_dto.dart';
import 'package:lucent_api/src/model/assistant_capabilities_response_dto.dart';
import 'package:lucent_api/src/model/assistant_clear_memory_data_dto.dart';
import 'package:lucent_api/src/model/assistant_clear_memory_response_dto.dart';
import 'package:lucent_api/src/model/assistant_clear_result_data_dto.dart';
import 'package:lucent_api/src/model/assistant_clear_result_response_dto.dart';
import 'package:lucent_api/src/model/assistant_confirm_result_dto.dart';
import 'package:lucent_api/src/model/assistant_confirm_result_response_dto.dart';
import 'package:lucent_api/src/model/assistant_context_settings_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_data_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_list_response_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_message_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_response_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_summary_dto.dart';
import 'package:lucent_api/src/model/assistant_input_message_dto.dart';
import 'package:lucent_api/src/model/assistant_tool_capability_dto.dart';
import 'package:lucent_api/src/model/change_email_dto.dart';
import 'package:lucent_api/src/model/change_password_dto.dart';
import 'package:lucent_api/src/model/change_security_pin_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_allergy_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_condition_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_coverage_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_coverage_entry_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_medicine_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_note_entry_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_profile_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_request_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_data_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_data_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_item_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_scope_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_sleep_entry_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_water_entry_dto.dart';
import 'package:lucent_api/src/model/cn_medicine_detail_dto.dart';
import 'package:lucent_api/src/model/confirm_assistant_proposal_dto.dart';
import 'package:lucent_api/src/model/cooldown_message_dto.dart';
import 'package:lucent_api/src/model/create_current_medicine_dto.dart';
import 'package:lucent_api/src/model/create_daily_record_dto.dart';
import 'package:lucent_api/src/model/create_daily_record_image_upload_dto.dart';
import 'package:lucent_api/src/model/create_data_export_request_dto.dart';
import 'package:lucent_api/src/model/create_dose_log_dto.dart';
import 'package:lucent_api/src/model/create_file_upload_dto.dart';
import 'package:lucent_api/src/model/create_health_context_allergy_dto.dart';
import 'package:lucent_api/src/model/create_health_context_condition_dto.dart';
import 'package:lucent_api/src/model/create_health_event_dto.dart';
import 'package:lucent_api/src/model/create_medicine_reminder_dto.dart';
import 'package:lucent_api/src/model/create_notification_dto.dart';
import 'package:lucent_api/src/model/create_product_event_batch_dto.dart';
import 'package:lucent_api/src/model/create_product_event_dto.dart';
import 'package:lucent_api/src/model/daily_record_attachment_dto.dart';
import 'package:lucent_api/src/model/daily_record_attachment_input_dto.dart';
import 'package:lucent_api/src/model/daily_record_candidate_data_dto.dart';
import 'package:lucent_api/src/model/daily_record_candidate_item_dto.dart';
import 'package:lucent_api/src/model/daily_record_candidate_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_image_upload_dto.dart';
import 'package:lucent_api/src/model/daily_record_image_upload_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_item_dto.dart';
import 'package:lucent_api/src/model/daily_record_list_data_dto.dart';
import 'package:lucent_api/src/model/daily_record_list_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_summary_data_dto.dart';
import 'package:lucent_api/src/model/daily_record_summary_dto.dart';
import 'package:lucent_api/src/model/daily_record_summary_response_dto.dart';
import 'package:lucent_api/src/model/data_export_latest_response_dto.dart';
import 'package:lucent_api/src/model/data_export_request_data_dto.dart';
import 'package:lucent_api/src/model/data_export_request_response_dto.dart';
import 'package:lucent_api/src/model/delete_account_dto.dart';
import 'package:lucent_api/src/model/disable_security_pin_dto.dart';
import 'package:lucent_api/src/model/dose_log_item_dto.dart';
import 'package:lucent_api/src/model/dose_log_list_data_dto.dart';
import 'package:lucent_api/src/model/dose_log_list_response_dto.dart';
import 'package:lucent_api/src/model/dose_log_response_dto.dart';
import 'package:lucent_api/src/model/drugbank_drug_interaction_dto.dart';
import 'package:lucent_api/src/model/drugbank_medicine_detail_dto.dart';
import 'package:lucent_api/src/model/emergency_contact_dto.dart';
import 'package:lucent_api/src/model/enable_security_pin_dto.dart';
import 'package:lucent_api/src/model/end_health_event_dto.dart';
import 'package:lucent_api/src/model/environment_snapshot_dto.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto.dart';
import 'package:lucent_api/src/model/event_review_check_in_coverage_dto.dart';
import 'package:lucent_api/src/model/event_review_coverage_summary_dto.dart';
import 'package:lucent_api/src/model/event_review_data_dto.dart';
import 'package:lucent_api/src/model/event_review_event_dto.dart';
import 'package:lucent_api/src/model/event_review_list_data_dto.dart';
import 'package:lucent_api/src/model/event_review_list_response_dto.dart';
import 'package:lucent_api/src/model/event_review_nullable_response_dto.dart';
import 'package:lucent_api/src/model/event_review_observed_source_dto.dart';
import 'package:lucent_api/src/model/event_review_response_dto.dart';
import 'package:lucent_api/src/model/event_review_section_dto.dart';
import 'package:lucent_api/src/model/event_review_section_facts_dto.dart';
import 'package:lucent_api/src/model/event_review_sections_dto.dart';
import 'package:lucent_api/src/model/event_review_source_timestamps_dto.dart';
import 'package:lucent_api/src/model/event_review_today_check_in_dto.dart';
import 'package:lucent_api/src/model/evidence_item_dto.dart';
import 'package:lucent_api/src/model/forgot_password_dto.dart';
import 'package:lucent_api/src/model/forgot_password_response_dto.dart';
import 'package:lucent_api/src/model/funnel_daily_counts_dto.dart';
import 'package:lucent_api/src/model/funnel_data_dto.dart';
import 'package:lucent_api/src/model/funnel_optional_counts_dto.dart';
import 'package:lucent_api/src/model/funnel_response_dto.dart';
import 'package:lucent_api/src/model/funnel_totals_dto.dart';
import 'package:lucent_api/src/model/funnel_window_dto.dart';
import 'package:lucent_api/src/model/generate_daily_record_candidates_dto.dart';
import 'package:lucent_api/src/model/generate_report_summary_dto.dart';
import 'package:lucent_api/src/model/generate_today_analysis_dto.dart';
import 'package:lucent_api/src/model/google_o_auth_authorize_dto.dart';
import 'package:lucent_api/src/model/google_o_auth_callback_dto.dart';
import 'package:lucent_api/src/model/health_app_info_dto.dart';
import 'package:lucent_api/src/model/health_component_dto.dart';
import 'package:lucent_api/src/model/health_context_data_dto.dart';
import 'package:lucent_api/src/model/health_context_response_dto.dart';
import 'package:lucent_api/src/model/health_event_check_in_response_dto.dart';
import 'package:lucent_api/src/model/health_event_coverage_dto.dart';
import 'package:lucent_api/src/model/health_event_item_dto.dart';
import 'package:lucent_api/src/model/health_event_list_data_dto.dart';
import 'package:lucent_api/src/model/health_event_list_response_dto.dart';
import 'package:lucent_api/src/model/health_event_nullable_response_dto.dart';
import 'package:lucent_api/src/model/health_event_response_dto.dart';
import 'package:lucent_api/src/model/health_probe_dto.dart';
import 'package:lucent_api/src/model/health_response_dto.dart';
import 'package:lucent_api/src/model/health_summary_dto.dart';
import 'package:lucent_api/src/model/humidity_indicator_dto.dart';
import 'package:lucent_api/src/model/legal_document_detail_dto.dart';
import 'package:lucent_api/src/model/legal_document_detail_response_dto.dart';
import 'package:lucent_api/src/model/legal_document_list_data_dto.dart';
import 'package:lucent_api/src/model/legal_document_list_item_dto.dart';
import 'package:lucent_api/src/model/legal_document_list_response_dto.dart';
import 'package:lucent_api/src/model/local_capability_data_dto.dart';
import 'package:lucent_api/src/model/local_capability_response_dto.dart';
import 'package:lucent_api/src/model/local_capability_state_dto.dart';
import 'package:lucent_api/src/model/login_data_dto.dart';
import 'package:lucent_api/src/model/login_dto.dart';
import 'package:lucent_api/src/model/login_response_dto.dart';
import 'package:lucent_api/src/model/logout_dto.dart';
import 'package:lucent_api/src/model/mark_dose_log_dto.dart';
import 'package:lucent_api/src/model/medicine_detail_data_dto.dart';
import 'package:lucent_api/src/model/medicine_detail_data_dto_detail.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto.dart';
import 'package:lucent_api/src/model/medicine_pagination_dto.dart';
import 'package:lucent_api/src/model/medicine_red_flag_dto.dart';
import 'package:lucent_api/src/model/medicine_reminder_item_dto.dart';
import 'package:lucent_api/src/model/medicine_reminder_list_data_dto.dart';
import 'package:lucent_api/src/model/medicine_reminder_list_response_dto.dart';
import 'package:lucent_api/src/model/medicine_reminder_response_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_response_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_response_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_coverage_issue_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_finding_dto.dart';
import 'package:lucent_api/src/model/medicine_safety_tip_list_response_dto.dart';
import 'package:lucent_api/src/model/medicine_safety_tip_response_dto.dart';
import 'package:lucent_api/src/model/medicine_search_data_dto.dart';
import 'package:lucent_api/src/model/medicine_search_item_dto.dart';
import 'package:lucent_api/src/model/medicine_search_response_dto.dart';
import 'package:lucent_api/src/model/notification_detail_dto.dart';
import 'package:lucent_api/src/model/notification_detail_response_dto.dart';
import 'package:lucent_api/src/model/notification_list_data_dto.dart';
import 'package:lucent_api/src/model/notification_list_item_dto.dart';
import 'package:lucent_api/src/model/notification_list_response_dto.dart';
import 'package:lucent_api/src/model/o_auth_authorize_data_dto.dart';
import 'package:lucent_api/src/model/o_auth_authorize_dto.dart';
import 'package:lucent_api/src/model/o_auth_authorize_response_dto.dart';
import 'package:lucent_api/src/model/o_auth_callback_dto.dart';
import 'package:lucent_api/src/model/o_auth_code_callback_dto.dart';
import 'package:lucent_api/src/model/pollen_indicator_dto.dart';
import 'package:lucent_api/src/model/qq_o_auth_authorize_dto.dart';
import 'package:lucent_api/src/model/qq_o_auth_callback_dto.dart';
import 'package:lucent_api/src/model/recognize_medicine_dto.dart';
import 'package:lucent_api/src/model/refresh_dto.dart';
import 'package:lucent_api/src/model/refresh_response_dto.dart';
import 'package:lucent_api/src/model/register_data_dto.dart';
import 'package:lucent_api/src/model/register_dto.dart';
import 'package:lucent_api/src/model/register_response_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_item_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_list_data_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_list_response_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_receipt_data_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_receipt_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_receipt_response_dto.dart';
import 'package:lucent_api/src/model/rename_conversation_dto.dart';
import 'package:lucent_api/src/model/report_coverage_dimension_dto.dart';
import 'package:lucent_api/src/model/report_coverage_dto.dart';
import 'package:lucent_api/src/model/report_dashboard_data_dto.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto.dart';
import 'package:lucent_api/src/model/report_finding_dto.dart';
import 'package:lucent_api/src/model/report_low_risk_action_dto.dart';
import 'package:lucent_api/src/model/report_metric_dto.dart';
import 'package:lucent_api/src/model/report_observed_metric_dto.dart';
import 'package:lucent_api/src/model/report_observed_pattern_dto.dart';
import 'package:lucent_api/src/model/report_pattern_dto.dart';
import 'package:lucent_api/src/model/report_summary_data_dto.dart';
import 'package:lucent_api/src/model/report_summary_response_dto.dart';
import 'package:lucent_api/src/model/report_trend_dto.dart';
import 'package:lucent_api/src/model/reports_controller_export_clinic_summary_pdf_async_v1201_response.dart';
import 'package:lucent_api/src/model/reports_controller_export_clinic_summary_pdf_async_v1201_response_data.dart';
import 'package:lucent_api/src/model/reset_password_dto.dart';
import 'package:lucent_api/src/model/risk_check_candidate_dto.dart';
import 'package:lucent_api/src/model/run_risk_check_dto.dart';
import 'package:lucent_api/src/model/security_pin_elevation_data_dto.dart';
import 'package:lucent_api/src/model/security_pin_elevation_response_dto.dart';
import 'package:lucent_api/src/model/security_pin_settings_dto.dart';
import 'package:lucent_api/src/model/send_verification_code_dto.dart';
import 'package:lucent_api/src/model/send_verification_code_response_dto.dart';
import 'package:lucent_api/src/model/set_password_dto.dart';
import 'package:lucent_api/src/model/stream_assistant_messages_dto.dart';
import 'package:lucent_api/src/model/success_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_action_dto.dart';
import 'package:lucent_api/src/model/suggestion_explanation_data_dto.dart';
import 'package:lucent_api/src/model/suggestion_explanation_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_feedback_data_dto.dart';
import 'package:lucent_api/src/model/suggestion_feedback_dto.dart';
import 'package:lucent_api/src/model/suggestion_feedback_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_history_data_dto.dart';
import 'package:lucent_api/src/model/suggestion_history_item_dto.dart';
import 'package:lucent_api/src/model/suggestion_history_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_item_dto.dart';
import 'package:lucent_api/src/model/suggestion_observed_metric_dto.dart';
import 'package:lucent_api/src/model/support_resource_dto.dart';
import 'package:lucent_api/src/model/support_resource_list_data_dto.dart';
import 'package:lucent_api/src/model/support_resource_list_response_dto.dart';
import 'package:lucent_api/src/model/temperature_indicator_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_job_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_response_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_response_dto_data.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto_result.dart';
import 'package:lucent_api/src/model/today_analysis_async_status_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_bullet_dto.dart';
import 'package:lucent_api/src/model/today_analysis_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_generate_response_dto.dart';
import 'package:lucent_api/src/model/today_analysis_metric_dto.dart';
import 'package:lucent_api/src/model/today_analysis_observed_metric_dto.dart';
import 'package:lucent_api/src/model/today_analysis_read_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_pending_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_response_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_response_dto_data.dart';
import 'package:lucent_api/src/model/today_analysis_stream_error_dto.dart';
import 'package:lucent_api/src/model/today_analysis_stream_result_dto.dart';
import 'package:lucent_api/src/model/today_analysis_stream_result_dto_data.dart';
import 'package:lucent_api/src/model/today_analysis_stream_summary_dto.dart';
import 'package:lucent_api/src/model/today_recommendation_response_dto.dart';
import 'package:lucent_api/src/model/today_suggestion_controller_explain_suggestion_async_v1202_response.dart';
import 'package:lucent_api/src/model/today_suggestion_controller_explain_suggestion_async_v1202_response_data.dart';
import 'package:lucent_api/src/model/today_suggestions_data_dto.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto.dart';
import 'package:lucent_api/src/model/tokens_dto.dart';
import 'package:lucent_api/src/model/unread_count_data_dto.dart';
import 'package:lucent_api/src/model/unread_count_response_dto.dart';
import 'package:lucent_api/src/model/update_account_dto.dart';
import 'package:lucent_api/src/model/update_assistant_context_settings_dto.dart';
import 'package:lucent_api/src/model/update_current_medicine_dto.dart';
import 'package:lucent_api/src/model/update_daily_record_dto.dart';
import 'package:lucent_api/src/model/update_dose_log_dto.dart';
import 'package:lucent_api/src/model/update_health_context_allergy_dto.dart';
import 'package:lucent_api/src/model/update_health_context_condition_dto.dart';
import 'package:lucent_api/src/model/update_health_context_profile_dto.dart';
import 'package:lucent_api/src/model/update_medicine_reminder_dto.dart';
import 'package:lucent_api/src/model/update_user_settings_dto.dart';
import 'package:lucent_api/src/model/upsert_health_event_check_in_dto.dart';
import 'package:lucent_api/src/model/upsert_medicine_reminder_group_dto.dart';
import 'package:lucent_api/src/model/upsert_reminder_slot_dto.dart';
import 'package:lucent_api/src/model/user_allergy_item_dto.dart';
import 'package:lucent_api/src/model/user_brief_dto.dart';
import 'package:lucent_api/src/model/user_condition_item_dto.dart';
import 'package:lucent_api/src/model/user_current_medicine_item_dto.dart';
import 'package:lucent_api/src/model/user_full_dto.dart';
import 'package:lucent_api/src/model/user_health_profile_dto.dart';
import 'package:lucent_api/src/model/user_health_summary_dto.dart';
import 'package:lucent_api/src/model/user_settings_data_dto.dart';
import 'package:lucent_api/src/model/user_settings_response_dto.dart';
import 'package:lucent_api/src/model/uv_indicator_dto.dart';
import 'package:lucent_api/src/model/verify_email_data_dto.dart';
import 'package:lucent_api/src/model/verify_email_dto.dart';
import 'package:lucent_api/src/model/verify_email_response_dto.dart';
import 'package:lucent_api/src/model/verify_security_pin_dto.dart';
import 'package:lucent_api/src/model/weibo_o_auth_authorize_dto.dart';
import 'package:lucent_api/src/model/weibo_o_auth_callback_dto.dart';

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
    case 'AirQualityIndicatorDto':
      return AirQualityIndicatorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AirQualityLevel':
    case 'AppInfoDataDto':
      return AppInfoDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AppInfoResponseDto':
      return AppInfoResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AppleOAuthCallbackDto':
      return AppleOAuthCallbackDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantCapabilitiesDataDto':
      return AssistantCapabilitiesDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantCapabilitiesResponseDto':
      return AssistantCapabilitiesResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantClearMemoryDataDto':
      return AssistantClearMemoryDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantClearMemoryResponseDto':
      return AssistantClearMemoryResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantClearResultDataDto':
      return AssistantClearResultDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantClearResultResponseDto':
      return AssistantClearResultResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConfirmResultDto':
      return AssistantConfirmResultDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantConfirmResultResponseDto':
      return AssistantConfirmResultResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantContextSettingsDto':
      return AssistantContextSettingsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantConversationDataDto':
      return AssistantConversationDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationListResponseDto':
      return AssistantConversationListResponseDto.fromJson(
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
    case 'AssistantInputMessageDto':
      return AssistantInputMessageDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantToolCapabilityDto':
      return AssistantToolCapabilityDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangeEmailDto':
      return ChangeEmailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangePasswordDto':
      return ChangePasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangeSecurityPinDto':
      return ChangeSecurityPinDto.fromJson(value as Map<String, dynamic>)
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
    case 'ClinicSummaryDto':
      return ClinicSummaryDto.fromJson(value as Map<String, dynamic>)
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
    case 'ClinicSummaryRequestDto':
      return ClinicSummaryRequestDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryResponseDto':
      return ClinicSummaryResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryShareDataDto':
      return ClinicSummaryShareDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryShareListDataDto':
      return ClinicSummaryShareListDataDto.fromJson(
            value as Map<String, dynamic>,
          )
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
    case 'ConfirmAssistantProposalDto':
      return ConfirmAssistantProposalDto.fromJson(value as Map<String, dynamic>)
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
    case 'CreateDailyRecordImageUploadDto':
      return CreateDailyRecordImageUploadDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'CreateDataExportRequestDto':
      return CreateDataExportRequestDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateDoseLogDto':
      return CreateDoseLogDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateFileUploadDto':
      return CreateFileUploadDto.fromJson(value as Map<String, dynamic>)
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
    case 'CreateHealthEventDto':
      return CreateHealthEventDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateMedicineReminderDto':
      return CreateMedicineReminderDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateNotificationDto':
      return CreateNotificationDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateProductEventBatchDto':
      return CreateProductEventBatchDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateProductEventDto':
      return CreateProductEventDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordAttachmentDto':
      return DailyRecordAttachmentDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordAttachmentInputDto':
      return DailyRecordAttachmentInputDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordAttachmentKind':
    case 'DailyRecordCandidateDataDto':
      return DailyRecordCandidateDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordCandidateItemDto':
      return DailyRecordCandidateItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordCandidateKind':
    case 'DailyRecordCandidateResponseDto':
      return DailyRecordCandidateResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordImageUploadDto':
      return DailyRecordImageUploadDto.fromJson(value as Map<String, dynamic>)
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
    case 'DataExportFormat':
    case 'DataExportKind':
    case 'DataExportLatestResponseDto':
      return DataExportLatestResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
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
    case 'DeleteAccountDto':
      return DeleteAccountDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DisableSecurityPinDto':
      return DisableSecurityPinDto.fromJson(value as Map<String, dynamic>)
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
    case 'DrugbankDrugInteractionDto':
      return DrugbankDrugInteractionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DrugbankMedicineDetailDto':
      return DrugbankMedicineDetailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EmergencyContactDto':
      return EmergencyContactDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EnableSecurityPinDto':
      return EnableSecurityPinDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EndHealthEventDto':
      return EndHealthEventDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EnvironmentDataSource':
    case 'EnvironmentSnapshotDto':
      return EnvironmentSnapshotDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
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
    case 'EventReviewListDataDto':
      return EventReviewListDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewListResponseDto':
      return EventReviewListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewNullableResponseDto':
      return EventReviewNullableResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
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
    case 'ForgotPasswordDto':
      return ForgotPasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ForgotPasswordResponseDto':
      return ForgotPasswordResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelDailyCountsDto':
      return FunnelDailyCountsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelDataDto':
      return FunnelDataDto.fromJson(value as Map<String, dynamic>)
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
    case 'GenerateDailyRecordCandidatesDto':
      return GenerateDailyRecordCandidatesDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'GenerateReportSummaryDto':
      return GenerateReportSummaryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GenerateTodayAnalysisDto':
      return GenerateTodayAnalysisDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GoogleOAuthAuthorizeDto':
      return GoogleOAuthAuthorizeDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GoogleOAuthCallbackDto':
      return GoogleOAuthCallbackDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthAppInfoDto':
      return HealthAppInfoDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthComponentDto':
      return HealthComponentDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthComponentStatus':
    case 'HealthContextDataDto':
      return HealthContextDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
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
    case 'HealthEventListDataDto':
      return HealthEventListDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventListResponseDto':
      return HealthEventListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventNullableResponseDto':
      return HealthEventNullableResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventOutcome':
    case 'HealthEventResponseDto':
      return HealthEventResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventStatus':
    case 'HealthOverallStatus':
    case 'HealthProbeDto':
      return HealthProbeDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
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
    case 'LegalDocumentDetailDto':
      return LegalDocumentDetailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LegalDocumentDetailResponseDto':
      return LegalDocumentDetailResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LegalDocumentListDataDto':
      return LegalDocumentListDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LegalDocumentListItemDto':
      return LegalDocumentListItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LegalDocumentListResponseDto':
      return LegalDocumentListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LocalCapabilityDataDto':
      return LocalCapabilityDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LocalCapabilityResponseDto':
      return LocalCapabilityResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LocalCapabilityStateDto':
      return LocalCapabilityStateDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginDataDto':
      return LoginDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LoginDto':
      return LoginDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LoginResponseDto':
      return LoginResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LogoutDto':
      return LogoutDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MarkDoseLogDto':
      return MarkDoseLogDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
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
    case 'MedicineRedFlagDto':
      return MedicineRedFlagDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineReminderItemDto':
      return MedicineReminderItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineReminderListDataDto':
      return MedicineReminderListDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineReminderListResponseDto':
      return MedicineReminderListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineReminderResponseDto':
      return MedicineReminderResponseDto.fromJson(value as Map<String, dynamic>)
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
    case 'MedicineSafetyTipListResponseDto':
      return MedicineSafetyTipListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineSafetyTipResponseDto':
      return MedicineSafetyTipResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineSearchDataDto':
      return MedicineSearchDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchItemDto':
      return MedicineSearchItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchResponseDto':
      return MedicineSearchResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSource':
    case 'NotificationDetailDto':
      return NotificationDetailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationDetailResponseDto':
      return NotificationDetailResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'NotificationListDataDto':
      return NotificationListDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationListItemDto':
      return NotificationListItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationListResponseDto':
      return NotificationListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
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
    case 'PollenIndicatorDto':
      return PollenIndicatorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PollenLevel':
    case 'ProductEventName':
    case 'ProductEventResult':
    case 'ProductEventSurface':
    case 'QqOAuthAuthorizeDto':
      return QqOAuthAuthorizeDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'QqOAuthCallbackDto':
      return QqOAuthCallbackDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RecognizeMedicineDto':
      return RecognizeMedicineDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
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
    case 'ReminderDeliveryItemDto':
      return ReminderDeliveryItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReminderDeliveryListDataDto':
      return ReminderDeliveryListDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReminderDeliveryListResponseDto':
      return ReminderDeliveryListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryReceiptDataDto':
      return ReminderDeliveryReceiptDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryReceiptDto':
      return ReminderDeliveryReceiptDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReminderDeliveryReceiptResponseDto':
      return ReminderDeliveryReceiptResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'RenameConversationDto':
      return RenameConversationDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportCoverageDimensionDto':
      return ReportCoverageDimensionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportCoverageDto':
      return ReportCoverageDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportDashboardDataDto':
      return ReportDashboardDataDto.fromJson(value as Map<String, dynamic>)
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
    case 'ReportSummaryDataDto':
      return ReportSummaryDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportSummaryResponseDto':
      return ReportSummaryResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportTrendDto':
      return ReportTrendDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportsControllerExportClinicSummaryPdfAsyncV1201Response':
      return ReportsControllerExportClinicSummaryPdfAsyncV1201Response.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseData':
      return ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseData.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ResetPasswordDto':
      return ResetPasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RiskCheckCandidateDto':
      return RiskCheckCandidateDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RunRiskCheckDto':
      return RunRiskCheckDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SecurityPinElevationDataDto':
      return SecurityPinElevationDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SecurityPinElevationResponseDto':
      return SecurityPinElevationResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SecurityPinSettingsDto':
      return SecurityPinSettingsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SendVerificationCodeDto':
      return SendVerificationCodeDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SendVerificationCodeResponseDto':
      return SendVerificationCodeResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SetPasswordDto':
      return SetPasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SexAtBirth':
    case 'StreamAssistantMessagesDto':
      return StreamAssistantMessagesDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuccessResponseDto':
      return SuccessResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionActionDto':
      return SuggestionActionDto.fromJson(value as Map<String, dynamic>)
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
    case 'SuggestionFeedbackDataDto':
      return SuggestionFeedbackDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionFeedbackDto':
      return SuggestionFeedbackDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionFeedbackResponseDto':
      return SuggestionFeedbackResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionHistoryDataDto':
      return SuggestionHistoryDataDto.fromJson(value as Map<String, dynamic>)
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
    case 'SupportResourceActionType':
    case 'SupportResourceDto':
      return SupportResourceDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SupportResourceListDataDto':
      return SupportResourceListDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SupportResourceListResponseDto':
      return SupportResourceListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SupportResourceScope':
    case 'TemperatureIndicatorDto':
      return TemperatureIndicatorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisAsyncJobDataDto':
      return TodayAnalysisAsyncJobDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResponseDto':
      return TodayAnalysisAsyncResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResponseDtoData':
      return TodayAnalysisAsyncResponseDtoData.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataDto':
      return TodayAnalysisAsyncResultDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataDtoResult':
      return TodayAnalysisAsyncResultDataDtoResult.fromJson(
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
    case 'TodayAnalysisDataDto':
      return TodayAnalysisDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisGenerateResponseDto':
      return TodayAnalysisGenerateResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
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
    case 'TodayAnalysisRefreshResponseDto':
      return TodayAnalysisRefreshResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisRefreshResponseDtoData':
      return TodayAnalysisRefreshResponseDtoData.fromJson(
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
    case 'TodaySuggestionControllerExplainSuggestionAsyncV1202Response':
      return TodaySuggestionControllerExplainSuggestionAsyncV1202Response.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseData':
      return TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseData.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsDataDto':
      return TodaySuggestionsDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodaySuggestionsResponseDto':
      return TodaySuggestionsResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TokensDto':
      return TokensDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UnitSystem':
    case 'UnreadCountDataDto':
      return UnreadCountDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UnreadCountResponseDto':
      return UnreadCountResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateAccountDto':
      return UpdateAccountDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateAssistantContextSettingsDto':
      return UpdateAssistantContextSettingsDto.fromJson(
            value as Map<String, dynamic>,
          )
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
    case 'UpdateMedicineReminderDto':
      return UpdateMedicineReminderDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateUserSettingsDto':
      return UpdateUserSettingsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpsertHealthEventCheckInDto':
      return UpsertHealthEventCheckInDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpsertMedicineReminderGroupDto':
      return UpsertMedicineReminderGroupDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UpsertReminderSlotDto':
      return UpsertReminderSlotDto.fromJson(value as Map<String, dynamic>)
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
    case 'UserDevicePlatform':
    case 'UserFullDto':
      return UserFullDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UserHealthProfileDto':
      return UserHealthProfileDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserHealthSummaryDto':
      return UserHealthSummaryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserNotificationType':
    case 'UserSettingsDataDto':
      return UserSettingsDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserSettingsResponseDto':
      return UserSettingsResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UvIndicatorDto':
      return UvIndicatorDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UvLevel':
    case 'VerifyEmailDataDto':
      return VerifyEmailDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerifyEmailDto':
      return VerifyEmailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerifyEmailResponseDto':
      return VerifyEmailResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerifySecurityPinDto':
      return VerifySecurityPinDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WeiboOAuthAuthorizeDto':
      return WeiboOAuthAuthorizeDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WeiboOAuthCallbackDto':
      return WeiboOAuthCallbackDto.fromJson(value as Map<String, dynamic>)
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
