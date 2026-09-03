import 'package:lucent_api/src/model/account_controller_change_email_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_change_password_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_delete_account_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_set_password_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_unlink_identity_v1_request.dart';
import 'package:lucent_api/src/model/account_controller_update_account_v1_request.dart';
import 'package:lucent_api/src/model/account_email_response_dto.dart';
import 'package:lucent_api/src/model/account_response_dto.dart';
import 'package:lucent_api/src/model/account_response_dto_linked_identities_inner.dart';
import 'package:lucent_api/src/model/app_info_response_dto.dart';
import 'package:lucent_api/src/model/assistant_capabilities_response_dto.dart';
import 'package:lucent_api/src/model/assistant_capabilities_response_dto_assistant_context.dart';
import 'package:lucent_api/src/model/assistant_capabilities_response_dto_tools_inner.dart';
import 'package:lucent_api/src/model/assistant_clear_memory_response_dto.dart';
import 'package:lucent_api/src/model/assistant_clear_result_response_dto.dart';
import 'package:lucent_api/src/model/assistant_confirm_result_response_dto.dart';
import 'package:lucent_api/src/model/assistant_controller_confirm_proposal_v1_request.dart';
import 'package:lucent_api/src/model/assistant_controller_rename_conversation_v1_request.dart';
import 'package:lucent_api/src/model/assistant_controller_stream_messages_v1_request.dart';
import 'package:lucent_api/src/model/assistant_controller_stream_messages_v1_request_messages_inner.dart';
import 'package:lucent_api/src/model/assistant_conversation_data_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_data_dto_messages_inner.dart';
import 'package:lucent_api/src/model/assistant_conversation_response_dto.dart';
import 'package:lucent_api/src/model/assistant_conversation_summary_dto_inner.dart';
import 'package:lucent_api/src/model/clinic_summary_export_async_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_allergies_inner.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_conditions_inner.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_coverage.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_coverage_check_ins.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_coverage_sleep.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_coverage_water.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_current_medicines_inner.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_note_entries_inner.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_profile.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_sleep_entries_inner.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_water_entries_inner.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/clinic_summary_share_response_dto.dart';
import 'package:lucent_api/src/model/clinic_summary_share_response_dto_scope.dart';
import 'package:lucent_api/src/model/daily_record_candidate_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_candidate_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/daily_record_image_upload_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_list_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_list_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/daily_record_list_response_dto_items_inner_attachments_inner.dart';
import 'package:lucent_api/src/model/daily_record_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_summary_response_dto.dart';
import 'package:lucent_api/src/model/daily_record_summary_response_dto_summaries_inner.dart';
import 'package:lucent_api/src/model/daily_record_summary_response_dto_summaries_inner_latest.dart';
import 'package:lucent_api/src/model/daily_records_controller_create_image_upload_v1_request.dart';
import 'package:lucent_api/src/model/daily_records_controller_create_v1_request.dart';
import 'package:lucent_api/src/model/daily_records_controller_create_v1_request_attachments_inner.dart';
import 'package:lucent_api/src/model/daily_records_controller_generate_candidates_v1_request.dart';
import 'package:lucent_api/src/model/daily_records_controller_update_v1_request.dart';
import 'package:lucent_api/src/model/data_export_controller_create_request_v1_request.dart';
import 'package:lucent_api/src/model/data_export_request_data_dto.dart';
import 'package:lucent_api/src/model/data_export_request_response_dto.dart';
import 'package:lucent_api/src/model/dose_log_list_response_dto.dart';
import 'package:lucent_api/src/model/dose_log_list_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/dose_log_response_dto.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto_air_quality.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto_humidity.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto_pollen.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto_temperature.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto_uv.dart';
import 'package:lucent_api/src/model/event_review_data_dto.dart';
import 'package:lucent_api/src/model/event_review_data_dto_coverage.dart';
import 'package:lucent_api/src/model/event_review_data_dto_coverage_check_ins.dart';
import 'package:lucent_api/src/model/event_review_data_dto_coverage_check_ins_today_check_in.dart';
import 'package:lucent_api/src/model/event_review_data_dto_coverage_daily_records.dart';
import 'package:lucent_api/src/model/event_review_data_dto_event.dart';
import 'package:lucent_api/src/model/event_review_data_dto_sections.dart';
import 'package:lucent_api/src/model/event_review_data_dto_sections_what_happened.dart';
import 'package:lucent_api/src/model/event_review_data_dto_sections_what_happened_facts.dart';
import 'package:lucent_api/src/model/event_review_data_dto_source_timestamps.dart';
import 'package:lucent_api/src/model/event_review_list_response_dto.dart';
import 'package:lucent_api/src/model/event_review_response_dto.dart';
import 'package:lucent_api/src/model/files_controller_create_upload_v1_request.dart';
import 'package:lucent_api/src/model/forgot_password_response_dto.dart';
import 'package:lucent_api/src/model/funnel_response_dto.dart';
import 'package:lucent_api/src/model/funnel_response_dto_daily_inner.dart';
import 'package:lucent_api/src/model/funnel_response_dto_optional.dart';
import 'package:lucent_api/src/model/funnel_response_dto_totals.dart';
import 'package:lucent_api/src/model/funnel_response_dto_window.dart';
import 'package:lucent_api/src/model/health_app_info_dto.dart';
import 'package:lucent_api/src/model/health_component_dto.dart';
import 'package:lucent_api/src/model/health_context_response_dto.dart';
import 'package:lucent_api/src/model/health_context_response_dto_allergies_inner.dart';
import 'package:lucent_api/src/model/health_context_response_dto_conditions_inner.dart';
import 'package:lucent_api/src/model/health_context_response_dto_current_medicines_inner.dart';
import 'package:lucent_api/src/model/health_context_response_dto_profile.dart';
import 'package:lucent_api/src/model/health_context_response_dto_profile_emergency_contact.dart';
import 'package:lucent_api/src/model/health_context_response_dto_summary.dart';
import 'package:lucent_api/src/model/health_event_list_response_dto.dart';
import 'package:lucent_api/src/model/health_event_list_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/health_event_nullable_response_dto.dart';
import 'package:lucent_api/src/model/health_event_response_dto.dart';
import 'package:lucent_api/src/model/health_event_response_dto_check_in.dart';
import 'package:lucent_api/src/model/health_event_response_dto_coverage.dart';
import 'package:lucent_api/src/model/health_events_controller_create_v1_request.dart';
import 'package:lucent_api/src/model/health_events_controller_end_v1_request.dart';
import 'package:lucent_api/src/model/health_events_controller_upsert_check_in_v1_request.dart';
import 'package:lucent_api/src/model/health_response_dto.dart';
import 'package:lucent_api/src/model/health_summary_dto.dart';
import 'package:lucent_api/src/model/legal_document_detail_response_dto.dart';
import 'package:lucent_api/src/model/legal_document_list_response_dto.dart';
import 'package:lucent_api/src/model/legal_document_list_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/local_capability_response_dto.dart';
import 'package:lucent_api/src/model/local_controller_forgot_password_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_login_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_register_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_reset_password_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_send_verification_code_v1_request.dart';
import 'package:lucent_api/src/model/local_controller_verify_email_v1_request.dart';
import 'package:lucent_api/src/model/login_response_dto.dart';
import 'package:lucent_api/src/model/login_response_dto_user.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto_detail.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto_detail_one_of.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto_detail_one_of1.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto_detail_one_of_drug_interactions_inner.dart';
import 'package:lucent_api/src/model/medicine_dose_logs_controller_create_v1_request.dart';
import 'package:lucent_api/src/model/medicine_dose_logs_controller_mark_v1_request.dart';
import 'package:lucent_api/src/model/medicine_dose_logs_controller_update_v1_request.dart';
import 'package:lucent_api/src/model/medicine_recognition_async_response_dto.dart';
import 'package:lucent_api/src/model/medicine_recognition_async_response_dto_result.dart';
import 'package:lucent_api/src/model/medicine_reminder_list_response_dto.dart';
import 'package:lucent_api/src/model/medicine_reminder_list_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/medicine_reminder_response_dto.dart';
import 'package:lucent_api/src/model/medicine_reminders_controller_create_v1_request.dart';
import 'package:lucent_api/src/model/medicine_reminders_controller_update_v1_request.dart';
import 'package:lucent_api/src/model/medicine_reminders_controller_upsert_group_v1_request.dart';
import 'package:lucent_api/src/model/medicine_reminders_controller_upsert_group_v1_request_slots_inner.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_response_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_dto_static.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_dto_static_result.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_dto_static_result_coverage_issues_inner.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_dto_static_result_findings_inner.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_dto_static_result_red_flags_inner.dart';
import 'package:lucent_api/src/model/medicine_safety_tip_response_dto_inner.dart';
import 'package:lucent_api/src/model/medicine_search_response_dto.dart';
import 'package:lucent_api/src/model/medicine_search_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/medicine_search_response_dto_pagination.dart';
import 'package:lucent_api/src/model/medicines_controller_recognize_v1_request.dart';
import 'package:lucent_api/src/model/medicines_controller_run_risk_check_v1_request.dart';
import 'package:lucent_api/src/model/medicines_controller_run_risk_check_v1_request_candidate.dart';
import 'package:lucent_api/src/model/notification_detail_response_dto.dart';
import 'package:lucent_api/src/model/notification_list_response_dto.dart';
import 'package:lucent_api/src/model/notification_list_response_dto_items_inner.dart';
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
import 'package:lucent_api/src/model/problem_details_dto.dart';
import 'package:lucent_api/src/model/product_events_controller_record_batch_v1_request.dart';
import 'package:lucent_api/src/model/product_events_controller_record_batch_v1_request_events_inner.dart';
import 'package:lucent_api/src/model/refresh_response_dto.dart';
import 'package:lucent_api/src/model/register_response_dto.dart';
import 'package:lucent_api/src/model/register_response_dto_tokens.dart';
import 'package:lucent_api/src/model/register_response_dto_user.dart';
import 'package:lucent_api/src/model/reminder_deliveries_controller_record_receipt_v1_request.dart';
import 'package:lucent_api/src/model/reminder_deliveries_controller_report_local_capability_v1_request.dart';
import 'package:lucent_api/src/model/reminder_delivery_list_response_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_list_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/reminder_delivery_receipt_response_dto.dart';
import 'package:lucent_api/src/model/reminder_delivery_receipt_response_dto_item.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto_findings_inner.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto_metrics_inner.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto_metrics_inner_observed_metric.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto_patterns_inner.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto_trends_inner.dart';
import 'package:lucent_api/src/model/report_summary_async_response_dto.dart';
import 'package:lucent_api/src/model/report_summary_async_response_dto_result.dart';
import 'package:lucent_api/src/model/report_summary_response_dto.dart';
import 'package:lucent_api/src/model/report_summary_response_dto_coverage.dart';
import 'package:lucent_api/src/model/report_summary_response_dto_coverage_medication.dart';
import 'package:lucent_api/src/model/report_summary_response_dto_low_risk_action.dart';
import 'package:lucent_api/src/model/report_summary_response_dto_observed_pattern.dart';
import 'package:lucent_api/src/model/reports_controller_generate_summary_v1_request.dart';
import 'package:lucent_api/src/model/reports_controller_preview_clinic_summary_v1_request.dart';
import 'package:lucent_api/src/model/send_verification_code_response_dto.dart';
import 'package:lucent_api/src/model/session_controller_logout_v1_request.dart';
import 'package:lucent_api/src/model/session_list_item_dto_inner.dart';
import 'package:lucent_api/src/model/sse_problem_details_dto.dart';
import 'package:lucent_api/src/model/suggestion_explanation_async_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_explanation_async_response_dto_result.dart';
import 'package:lucent_api/src/model/suggestion_explanation_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_feedback_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_history_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_history_response_dto_items_inner.dart';
import 'package:lucent_api/src/model/today_analysis_async_job_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto_result.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto_result_any_of.dart';
import 'package:lucent_api/src/model/today_analysis_async_status_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_controller_generate_v1200_response.dart';
import 'package:lucent_api/src/model/today_analysis_controller_refresh_v1_request.dart';
import 'package:lucent_api/src/model/today_analysis_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_read_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_dto.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_dto_analysis.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_dto_analysis_bullets_inner.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_dto_analysis_metrics_inner.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_pending_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_dto.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_dto_analysis.dart';
import 'package:lucent_api/src/model/today_recommendation_response_dto_inner.dart';
import 'package:lucent_api/src/model/today_suggestion_controller_submit_feedback_v1_request.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary_evidence_inner.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary_observed_metric.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary_primary_action.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary_secondary_actions_inner.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto_secondary_inner.dart';
import 'package:lucent_api/src/model/unread_count_response_dto.dart';
import 'package:lucent_api/src/model/user_health_context_controller_create_allergy_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_create_condition_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_create_current_medicine_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_update_allergy_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_update_condition_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_update_current_medicine_v1_request.dart';
import 'package:lucent_api/src/model/user_health_context_controller_update_user_health_context_profile_v1_request.dart';
import 'package:lucent_api/src/model/user_settings_controller_update_settings_v1_request.dart';
import 'package:lucent_api/src/model/user_settings_controller_update_settings_v1_request_assistant_context.dart';
import 'package:lucent_api/src/model/user_settings_response_dto.dart';
import 'package:lucent_api/src/model/user_settings_response_dto_assistant_context.dart';
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
    case 'AccountResponseDto':
      return AccountResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AccountResponseDtoLinkedIdentitiesInner':
      return AccountResponseDtoLinkedIdentitiesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AppInfoResponseDto':
      return AppInfoResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantCapabilitiesResponseDto':
      return AssistantCapabilitiesResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantCapabilitiesResponseDtoAssistantContext':
      return AssistantCapabilitiesResponseDtoAssistantContext.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantCapabilitiesResponseDtoToolsInner':
      return AssistantCapabilitiesResponseDtoToolsInner.fromJson(
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
    case 'AssistantConversationDataDtoMessagesInner':
      return AssistantConversationDataDtoMessagesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationResponseDto':
      return AssistantConversationResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationSummaryDtoInner':
      return AssistantConversationSummaryDtoInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryExportAsyncResponseDto':
      return ClinicSummaryExportAsyncResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDto':
      return ClinicSummaryResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryResponseDtoAllergiesInner':
      return ClinicSummaryResponseDtoAllergiesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoConditionsInner':
      return ClinicSummaryResponseDtoConditionsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoCoverage':
      return ClinicSummaryResponseDtoCoverage.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoCoverageCheckIns':
      return ClinicSummaryResponseDtoCoverageCheckIns.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoCoverageSleep':
      return ClinicSummaryResponseDtoCoverageSleep.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoCoverageWater':
      return ClinicSummaryResponseDtoCoverageWater.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoCurrentMedicinesInner':
      return ClinicSummaryResponseDtoCurrentMedicinesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoNoteEntriesInner':
      return ClinicSummaryResponseDtoNoteEntriesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoProfile':
      return ClinicSummaryResponseDtoProfile.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoSleepEntriesInner':
      return ClinicSummaryResponseDtoSleepEntriesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseDtoWaterEntriesInner':
      return ClinicSummaryResponseDtoWaterEntriesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareListResponseDto':
      return ClinicSummaryShareListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareListResponseDtoItemsInner':
      return ClinicSummaryShareListResponseDtoItemsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareResponseDto':
      return ClinicSummaryShareResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareResponseDtoScope':
      return ClinicSummaryShareResponseDtoScope.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordCandidateResponseDto':
      return DailyRecordCandidateResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordCandidateResponseDtoItemsInner':
      return DailyRecordCandidateResponseDtoItemsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordImageUploadResponseDto':
      return DailyRecordImageUploadResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordListResponseDto':
      return DailyRecordListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordListResponseDtoItemsInner':
      return DailyRecordListResponseDtoItemsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordListResponseDtoItemsInnerAttachmentsInner':
      return DailyRecordListResponseDtoItemsInnerAttachmentsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordResponseDto':
      return DailyRecordResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordSummaryResponseDto':
      return DailyRecordSummaryResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordSummaryResponseDtoSummariesInner':
      return DailyRecordSummaryResponseDtoSummariesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordSummaryResponseDtoSummariesInnerLatest':
      return DailyRecordSummaryResponseDtoSummariesInnerLatest.fromJson(
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
    case 'DataExportRequestDataDto':
      return DataExportRequestDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DataExportRequestResponseDto':
      return DataExportRequestResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DoseLogListResponseDto':
      return DoseLogListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogListResponseDtoItemsInner':
      return DoseLogListResponseDtoItemsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DoseLogResponseDto':
      return DoseLogResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EnvironmentSnapshotResponseDto':
      return EnvironmentSnapshotResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponseDtoAirQuality':
      return EnvironmentSnapshotResponseDtoAirQuality.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponseDtoHumidity':
      return EnvironmentSnapshotResponseDtoHumidity.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponseDtoPollen':
      return EnvironmentSnapshotResponseDtoPollen.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponseDtoTemperature':
      return EnvironmentSnapshotResponseDtoTemperature.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponseDtoUv':
      return EnvironmentSnapshotResponseDtoUv.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataDto':
      return EventReviewDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewDataDtoCoverage':
      return EventReviewDataDtoCoverage.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewDataDtoCoverageCheckIns':
      return EventReviewDataDtoCoverageCheckIns.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataDtoCoverageCheckInsTodayCheckIn':
      return EventReviewDataDtoCoverageCheckInsTodayCheckIn.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataDtoCoverageDailyRecords':
      return EventReviewDataDtoCoverageDailyRecords.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataDtoEvent':
      return EventReviewDataDtoEvent.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewDataDtoSections':
      return EventReviewDataDtoSections.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewDataDtoSectionsWhatHappened':
      return EventReviewDataDtoSectionsWhatHappened.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataDtoSectionsWhatHappenedFacts':
      return EventReviewDataDtoSectionsWhatHappenedFacts.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataDtoSourceTimestamps':
      return EventReviewDataDtoSourceTimestamps.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewListResponseDto':
      return EventReviewListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewResponseDto':
      return EventReviewResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FilesControllerCreateUploadV1Request':
      return FilesControllerCreateUploadV1Request.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ForgotPasswordResponseDto':
      return ForgotPasswordResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseDto':
      return FunnelResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseDtoDailyInner':
      return FunnelResponseDtoDailyInner.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseDtoOptional':
      return FunnelResponseDtoOptional.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseDtoTotals':
      return FunnelResponseDtoTotals.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseDtoWindow':
      return FunnelResponseDtoWindow.fromJson(value as Map<String, dynamic>)
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
    case 'HealthContextResponseDtoAllergiesInner':
      return HealthContextResponseDtoAllergiesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseDtoConditionsInner':
      return HealthContextResponseDtoConditionsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseDtoCurrentMedicinesInner':
      return HealthContextResponseDtoCurrentMedicinesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseDtoProfile':
      return HealthContextResponseDtoProfile.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseDtoProfileEmergencyContact':
      return HealthContextResponseDtoProfileEmergencyContact.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseDtoSummary':
      return HealthContextResponseDtoSummary.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventListResponseDto':
      return HealthEventListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventListResponseDtoItemsInner':
      return HealthEventListResponseDtoItemsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventNullableResponseDto':
      return HealthEventNullableResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventResponseDto':
      return HealthEventResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventResponseDtoCheckIn':
      return HealthEventResponseDtoCheckIn.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventResponseDtoCoverage':
      return HealthEventResponseDtoCoverage.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
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
    case 'LegalDocumentDetailResponseDto':
      return LegalDocumentDetailResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LegalDocumentListResponseDto':
      return LegalDocumentListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LegalDocumentListResponseDtoItemsInner':
      return LegalDocumentListResponseDtoItemsInner.fromJson(
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
    case 'LoginResponseDtoUser':
      return LoginResponseDtoUser.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineDetailResponseDto':
      return MedicineDetailResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineDetailResponseDtoDetail':
      return MedicineDetailResponseDtoDetail.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineDetailResponseDtoDetailOneOf':
      return MedicineDetailResponseDtoDetailOneOf.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineDetailResponseDtoDetailOneOf1':
      return MedicineDetailResponseDtoDetailOneOf1.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineDetailResponseDtoDetailOneOfDrugInteractionsInner':
      return MedicineDetailResponseDtoDetailOneOfDrugInteractionsInner.fromJson(
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
    case 'MedicineRecognitionAsyncResponseDto':
      return MedicineRecognitionAsyncResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRecognitionAsyncResponseDtoResult':
      return MedicineRecognitionAsyncResponseDtoResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineReminderListResponseDto':
      return MedicineReminderListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineReminderListResponseDtoItemsInner':
      return MedicineReminderListResponseDtoItemsInner.fromJson(
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
    case 'MedicineRiskCheckRecordResponseDto':
      return MedicineRiskCheckRecordResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseDto':
      return MedicineRiskCheckRecordsResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseDtoStatic':
      return MedicineRiskCheckRecordsResponseDtoStatic.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseDtoStaticResult':
      return MedicineRiskCheckRecordsResponseDtoStaticResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInner':
      return MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner':
      return MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInner':
      return MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineSafetyTipResponseDtoInner':
      return MedicineSafetyTipResponseDtoInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineSearchResponseDto':
      return MedicineSearchResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchResponseDtoItemsInner':
      return MedicineSearchResponseDtoItemsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineSearchResponseDtoPagination':
      return MedicineSearchResponseDtoPagination.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
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
    case 'NotificationListResponseDto':
      return NotificationListResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationListResponseDtoItemsInner':
      return NotificationListResponseDtoItemsInner.fromJson(
            value as Map<String, dynamic>,
          )
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
    case 'RegisterResponseDtoTokens':
      return RegisterResponseDtoTokens.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterResponseDtoUser':
      return RegisterResponseDtoUser.fromJson(value as Map<String, dynamic>)
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
    case 'ReminderDeliveryListResponseDto':
      return ReminderDeliveryListResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryListResponseDtoItemsInner':
      return ReminderDeliveryListResponseDtoItemsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryReceiptResponseDto':
      return ReminderDeliveryReceiptResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryReceiptResponseDtoItem':
      return ReminderDeliveryReceiptResponseDtoItem.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponseDto':
      return ReportDashboardResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportDashboardResponseDtoFindingsInner':
      return ReportDashboardResponseDtoFindingsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponseDtoMetricsInner':
      return ReportDashboardResponseDtoMetricsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponseDtoMetricsInnerObservedMetric':
      return ReportDashboardResponseDtoMetricsInnerObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponseDtoPatternsInner':
      return ReportDashboardResponseDtoPatternsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponseDtoTrendsInner':
      return ReportDashboardResponseDtoTrendsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryAsyncResponseDto':
      return ReportSummaryAsyncResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryAsyncResponseDtoResult':
      return ReportSummaryAsyncResponseDtoResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponseDto':
      return ReportSummaryResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportSummaryResponseDtoCoverage':
      return ReportSummaryResponseDtoCoverage.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponseDtoCoverageMedication':
      return ReportSummaryResponseDtoCoverageMedication.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponseDtoLowRiskAction':
      return ReportSummaryResponseDtoLowRiskAction.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponseDtoObservedPattern':
      return ReportSummaryResponseDtoObservedPattern.fromJson(
            value as Map<String, dynamic>,
          )
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
    case 'SessionListItemDtoInner':
      return SessionListItemDtoInner.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SseProblemDetailsDto':
      return SseProblemDetailsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionExplanationAsyncResponseDto':
      return SuggestionExplanationAsyncResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionExplanationAsyncResponseDtoResult':
      return SuggestionExplanationAsyncResponseDtoResult.fromJson(
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
    case 'SuggestionHistoryResponseDto':
      return SuggestionHistoryResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionHistoryResponseDtoItemsInner':
      return SuggestionHistoryResponseDtoItemsInner.fromJson(
            value as Map<String, dynamic>,
          )
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
    case 'TodayAnalysisAsyncResultDataDtoResult':
      return TodayAnalysisAsyncResultDataDtoResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataDtoResultAnyOf':
      return TodayAnalysisAsyncResultDataDtoResultAnyOf.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncStatusDataDto':
      return TodayAnalysisAsyncStatusDataDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisControllerGenerateV1200Response':
      return TodayAnalysisControllerGenerateV1200Response.fromJson(
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
    case 'TodayAnalysisReadDataDto':
      return TodayAnalysisReadDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisReadResponseDto':
      return TodayAnalysisReadResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadResponseDtoAnalysis':
      return TodayAnalysisReadResponseDtoAnalysis.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadResponseDtoAnalysisBulletsInner':
      return TodayAnalysisReadResponseDtoAnalysisBulletsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadResponseDtoAnalysisMetricsInner':
      return TodayAnalysisReadResponseDtoAnalysisMetricsInner.fromJson(
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
    case 'TodayAnalysisRefreshReadyDataDtoAnalysis':
      return TodayAnalysisRefreshReadyDataDtoAnalysis.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayRecommendationResponseDtoInner':
      return TodayRecommendationResponseDtoInner.fromJson(
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
    case 'TodaySuggestionsResponseDtoPrimary':
      return TodaySuggestionsResponseDtoPrimary.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseDtoPrimaryEvidenceInner':
      return TodaySuggestionsResponseDtoPrimaryEvidenceInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseDtoPrimaryObservedMetric':
      return TodaySuggestionsResponseDtoPrimaryObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseDtoPrimaryPrimaryAction':
      return TodaySuggestionsResponseDtoPrimaryPrimaryAction.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseDtoPrimarySecondaryActionsInner':
      return TodaySuggestionsResponseDtoPrimarySecondaryActionsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseDtoSecondaryInner':
      return TodaySuggestionsResponseDtoSecondaryInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UnreadCountResponseDto':
      return UnreadCountResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
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
    case 'UserSettingsResponseDtoAssistantContext':
      return UserSettingsResponseDtoAssistantContext.fromJson(
            value as Map<String, dynamic>,
          )
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
