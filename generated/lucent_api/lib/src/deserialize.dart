import 'package:lucent_api/src/model/account_email_response.dart';
import 'package:lucent_api/src/model/account_response.dart';
import 'package:lucent_api/src/model/account_response_linked_identities.dart';
import 'package:lucent_api/src/model/app_info_response.dart';
import 'package:lucent_api/src/model/assistant_capabilities_response.dart';
import 'package:lucent_api/src/model/assistant_capabilities_response_assistant_context.dart';
import 'package:lucent_api/src/model/assistant_capabilities_response_tools.dart';
import 'package:lucent_api/src/model/assistant_clear_memory_response.dart';
import 'package:lucent_api/src/model/assistant_clear_result_response.dart';
import 'package:lucent_api/src/model/assistant_confirm_result_response.dart';
import 'package:lucent_api/src/model/assistant_conversation_data.dart';
import 'package:lucent_api/src/model/assistant_conversation_data_messages.dart';
import 'package:lucent_api/src/model/assistant_conversation_response.dart';
import 'package:lucent_api/src/model/assistant_conversation_response_messages.dart';
import 'package:lucent_api/src/model/assistant_conversation_summary_item.dart';
import 'package:lucent_api/src/model/change_email_request.dart';
import 'package:lucent_api/src/model/change_password_request.dart';
import 'package:lucent_api/src/model/clinic_summary_export_job_response.dart';
import 'package:lucent_api/src/model/clinic_summary_response.dart';
import 'package:lucent_api/src/model/clinic_summary_response_allergies.dart';
import 'package:lucent_api/src/model/clinic_summary_response_conditions.dart';
import 'package:lucent_api/src/model/clinic_summary_response_coverage.dart';
import 'package:lucent_api/src/model/clinic_summary_response_coverage_check_ins.dart';
import 'package:lucent_api/src/model/clinic_summary_response_coverage_dose.dart';
import 'package:lucent_api/src/model/clinic_summary_response_coverage_sleep.dart';
import 'package:lucent_api/src/model/clinic_summary_response_coverage_water.dart';
import 'package:lucent_api/src/model/clinic_summary_response_current_medicines.dart';
import 'package:lucent_api/src/model/clinic_summary_response_note_entries.dart';
import 'package:lucent_api/src/model/clinic_summary_response_profile.dart';
import 'package:lucent_api/src/model/clinic_summary_response_sleep_entries.dart';
import 'package:lucent_api/src/model/clinic_summary_response_water_entries.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_response.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_response_items.dart';
import 'package:lucent_api/src/model/clinic_summary_share_list_response_items_scope.dart';
import 'package:lucent_api/src/model/clinic_summary_share_response.dart';
import 'package:lucent_api/src/model/clinic_summary_share_response_scope.dart';
import 'package:lucent_api/src/model/confirm_proposal_request.dart';
import 'package:lucent_api/src/model/create_allergy_request.dart';
import 'package:lucent_api/src/model/create_condition_request.dart';
import 'package:lucent_api/src/model/create_current_medicine_request.dart';
import 'package:lucent_api/src/model/create_daily_record_request.dart';
import 'package:lucent_api/src/model/create_daily_record_request_attachments.dart';
import 'package:lucent_api/src/model/create_dose_log_request.dart';
import 'package:lucent_api/src/model/create_google_authorize_url_request.dart';
import 'package:lucent_api/src/model/create_health_event_request.dart';
import 'package:lucent_api/src/model/create_image_upload_request.dart';
import 'package:lucent_api/src/model/create_medicine_reminder_request.dart';
import 'package:lucent_api/src/model/create_notification_request.dart';
import 'package:lucent_api/src/model/create_qq_authorize_url_request.dart';
import 'package:lucent_api/src/model/create_request_request.dart';
import 'package:lucent_api/src/model/create_upload_request.dart';
import 'package:lucent_api/src/model/create_wechat_web_authorize_url_request.dart';
import 'package:lucent_api/src/model/create_wechat_web_identity_link_authorize_url_request.dart';
import 'package:lucent_api/src/model/create_weibo_authorize_url_request.dart';
import 'package:lucent_api/src/model/daily_record_candidate_response.dart';
import 'package:lucent_api/src/model/daily_record_candidate_response_items.dart';
import 'package:lucent_api/src/model/daily_record_image_upload_response.dart';
import 'package:lucent_api/src/model/daily_record_list_response.dart';
import 'package:lucent_api/src/model/daily_record_list_response_items.dart';
import 'package:lucent_api/src/model/daily_record_list_response_items_attachments.dart';
import 'package:lucent_api/src/model/daily_record_response.dart';
import 'package:lucent_api/src/model/daily_record_response_attachments.dart';
import 'package:lucent_api/src/model/daily_record_summary_response.dart';
import 'package:lucent_api/src/model/daily_record_summary_response_summaries.dart';
import 'package:lucent_api/src/model/daily_record_summary_response_summaries_latest.dart';
import 'package:lucent_api/src/model/daily_record_summary_response_summaries_latest_attachments.dart';
import 'package:lucent_api/src/model/data_export_request_data.dart';
import 'package:lucent_api/src/model/data_export_request_response.dart';
import 'package:lucent_api/src/model/delete_account_request.dart';
import 'package:lucent_api/src/model/dose_log_list_response.dart';
import 'package:lucent_api/src/model/dose_log_list_response_items.dart';
import 'package:lucent_api/src/model/dose_log_response.dart';
import 'package:lucent_api/src/model/download_clinic_summary_pdf_request.dart';
import 'package:lucent_api/src/model/end_request.dart';
import 'package:lucent_api/src/model/enqueue_analysis_generation_request.dart';
import 'package:lucent_api/src/model/enqueue_clinic_summary_pdf_export_request.dart';
import 'package:lucent_api/src/model/enqueue_medicine_recognition_request.dart';
import 'package:lucent_api/src/model/enqueue_summary_generation_request.dart';
import 'package:lucent_api/src/model/environment_snapshot_response.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_air_quality.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_humidity.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_pollen.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_temperature.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_uv.dart';
import 'package:lucent_api/src/model/event_review_data.dart';
import 'package:lucent_api/src/model/event_review_data_coverage.dart';
import 'package:lucent_api/src/model/event_review_data_coverage_check_ins.dart';
import 'package:lucent_api/src/model/event_review_data_coverage_check_ins_today_check_in.dart';
import 'package:lucent_api/src/model/event_review_data_coverage_daily_records.dart';
import 'package:lucent_api/src/model/event_review_data_coverage_dose_logs.dart';
import 'package:lucent_api/src/model/event_review_data_event.dart';
import 'package:lucent_api/src/model/event_review_data_sections.dart';
import 'package:lucent_api/src/model/event_review_data_sections_completed_actions.dart';
import 'package:lucent_api/src/model/event_review_data_sections_completed_actions_facts.dart';
import 'package:lucent_api/src/model/event_review_data_sections_key_changes.dart';
import 'package:lucent_api/src/model/event_review_data_sections_key_changes_facts.dart';
import 'package:lucent_api/src/model/event_review_data_sections_next_step.dart';
import 'package:lucent_api/src/model/event_review_data_sections_next_step_facts.dart';
import 'package:lucent_api/src/model/event_review_data_sections_what_happened.dart';
import 'package:lucent_api/src/model/event_review_data_sections_what_happened_facts.dart';
import 'package:lucent_api/src/model/event_review_data_source_timestamps.dart';
import 'package:lucent_api/src/model/event_review_list_response.dart';
import 'package:lucent_api/src/model/event_review_list_response_items.dart';
import 'package:lucent_api/src/model/event_review_response.dart';
import 'package:lucent_api/src/model/event_review_response_coverage.dart';
import 'package:lucent_api/src/model/event_review_response_coverage_check_ins.dart';
import 'package:lucent_api/src/model/event_review_response_coverage_check_ins_today_check_in.dart';
import 'package:lucent_api/src/model/event_review_response_coverage_daily_records.dart';
import 'package:lucent_api/src/model/event_review_response_coverage_dose_logs.dart';
import 'package:lucent_api/src/model/event_review_response_event.dart';
import 'package:lucent_api/src/model/event_review_response_sections.dart';
import 'package:lucent_api/src/model/event_review_response_sections_completed_actions.dart';
import 'package:lucent_api/src/model/event_review_response_sections_completed_actions_facts.dart';
import 'package:lucent_api/src/model/event_review_response_sections_key_changes.dart';
import 'package:lucent_api/src/model/event_review_response_sections_key_changes_facts.dart';
import 'package:lucent_api/src/model/event_review_response_sections_next_step.dart';
import 'package:lucent_api/src/model/event_review_response_sections_next_step_facts.dart';
import 'package:lucent_api/src/model/event_review_response_sections_what_happened.dart';
import 'package:lucent_api/src/model/event_review_response_sections_what_happened_facts.dart';
import 'package:lucent_api/src/model/event_review_response_source_timestamps.dart';
import 'package:lucent_api/src/model/forgot_password_request.dart';
import 'package:lucent_api/src/model/forgot_password_response.dart';
import 'package:lucent_api/src/model/funnel_response.dart';
import 'package:lucent_api/src/model/funnel_response_daily.dart';
import 'package:lucent_api/src/model/funnel_response_optional.dart';
import 'package:lucent_api/src/model/funnel_response_totals.dart';
import 'package:lucent_api/src/model/funnel_response_window.dart';
import 'package:lucent_api/src/model/generate200_response.dart';
import 'package:lucent_api/src/model/generate_candidates_request.dart';
import 'package:lucent_api/src/model/generate_request.dart';
import 'package:lucent_api/src/model/generate_stream_request.dart';
import 'package:lucent_api/src/model/generate_summary_request.dart';
import 'package:lucent_api/src/model/generate_summary_stream_request.dart';
import 'package:lucent_api/src/model/health_app_info.dart';
import 'package:lucent_api/src/model/health_component.dart';
import 'package:lucent_api/src/model/health_context_response.dart';
import 'package:lucent_api/src/model/health_context_response_allergies.dart';
import 'package:lucent_api/src/model/health_context_response_conditions.dart';
import 'package:lucent_api/src/model/health_context_response_current_medicines.dart';
import 'package:lucent_api/src/model/health_context_response_profile.dart';
import 'package:lucent_api/src/model/health_context_response_profile_emergency_contact.dart';
import 'package:lucent_api/src/model/health_context_response_summary.dart';
import 'package:lucent_api/src/model/health_event_list_response.dart';
import 'package:lucent_api/src/model/health_event_list_response_items.dart';
import 'package:lucent_api/src/model/health_event_list_response_items_check_in.dart';
import 'package:lucent_api/src/model/health_event_list_response_items_coverage.dart';
import 'package:lucent_api/src/model/health_event_nullable_response.dart';
import 'package:lucent_api/src/model/health_event_nullable_response_check_in.dart';
import 'package:lucent_api/src/model/health_event_nullable_response_coverage.dart';
import 'package:lucent_api/src/model/health_event_response.dart';
import 'package:lucent_api/src/model/health_event_response_check_in.dart';
import 'package:lucent_api/src/model/health_event_response_coverage.dart';
import 'package:lucent_api/src/model/health_response.dart';
import 'package:lucent_api/src/model/health_summary.dart';
import 'package:lucent_api/src/model/legal_document_detail_response.dart';
import 'package:lucent_api/src/model/legal_document_list_response.dart';
import 'package:lucent_api/src/model/legal_document_list_response_items.dart';
import 'package:lucent_api/src/model/link_wechat_mobile_identity_request.dart';
import 'package:lucent_api/src/model/link_wechat_web_identity_request.dart';
import 'package:lucent_api/src/model/local_capability_response.dart';
import 'package:lucent_api/src/model/login_request.dart';
import 'package:lucent_api/src/model/login_response.dart';
import 'package:lucent_api/src/model/login_response_tokens.dart';
import 'package:lucent_api/src/model/login_response_user.dart';
import 'package:lucent_api/src/model/login_with_apple_request.dart';
import 'package:lucent_api/src/model/login_with_google_request.dart';
import 'package:lucent_api/src/model/login_with_qq_request.dart';
import 'package:lucent_api/src/model/login_with_wechat_mobile_request.dart';
import 'package:lucent_api/src/model/login_with_wechat_web_request.dart';
import 'package:lucent_api/src/model/login_with_weibo_request.dart';
import 'package:lucent_api/src/model/logout_request.dart';
import 'package:lucent_api/src/model/mark_request.dart';
import 'package:lucent_api/src/model/medicine_detail_response.dart';
import 'package:lucent_api/src/model/medicine_detail_response_detail.dart';
import 'package:lucent_api/src/model/medicine_detail_response_detail_one_of.dart';
import 'package:lucent_api/src/model/medicine_detail_response_detail_one_of1.dart';
import 'package:lucent_api/src/model/medicine_detail_response_drug_interactions.dart';
import 'package:lucent_api/src/model/medicine_recognition_job.dart';
import 'package:lucent_api/src/model/medicine_recognition_job_result.dart';
import 'package:lucent_api/src/model/medicine_reminder_list_response.dart';
import 'package:lucent_api/src/model/medicine_reminder_list_response_items.dart';
import 'package:lucent_api/src/model/medicine_reminder_response.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_response.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_response_result.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_response_result_coverage_issues.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_response_result_findings.dart';
import 'package:lucent_api/src/model/medicine_risk_check_record_response_result_red_flags.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_llm.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_llm_result.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_llm_result_coverage_issues.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_llm_result_findings.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_llm_result_red_flags.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_static.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_static_result.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_static_result_coverage_issues.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_static_result_findings.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_static_result_red_flags.dart';
import 'package:lucent_api/src/model/medicine_safety_tip_item.dart';
import 'package:lucent_api/src/model/medicine_search_response.dart';
import 'package:lucent_api/src/model/medicine_search_response_items.dart';
import 'package:lucent_api/src/model/medicine_search_response_pagination.dart';
import 'package:lucent_api/src/model/notification_detail_response.dart';
import 'package:lucent_api/src/model/notification_list_response.dart';
import 'package:lucent_api/src/model/notification_list_response_items.dart';
import 'package:lucent_api/src/model/notification_preferences_response.dart';
import 'package:lucent_api/src/model/o_auth_authorize_response.dart';
import 'package:lucent_api/src/model/patch_request.dart';
import 'package:lucent_api/src/model/preview_clinic_summary_request.dart';
import 'package:lucent_api/src/model/problem_details_dto.dart';
import 'package:lucent_api/src/model/recognize_request.dart';
import 'package:lucent_api/src/model/record_batch_request.dart';
import 'package:lucent_api/src/model/record_batch_request_events.dart';
import 'package:lucent_api/src/model/record_receipt_request.dart';
import 'package:lucent_api/src/model/refresh_response.dart';
import 'package:lucent_api/src/model/refresh_session_request.dart';
import 'package:lucent_api/src/model/refresh_today_analysis_request.dart';
import 'package:lucent_api/src/model/register_request.dart';
import 'package:lucent_api/src/model/register_response.dart';
import 'package:lucent_api/src/model/register_response_tokens.dart';
import 'package:lucent_api/src/model/register_response_user.dart';
import 'package:lucent_api/src/model/reminder_delivery_list_response.dart';
import 'package:lucent_api/src/model/reminder_delivery_list_response_items.dart';
import 'package:lucent_api/src/model/reminder_delivery_receipt_response.dart';
import 'package:lucent_api/src/model/reminder_delivery_receipt_response_item.dart';
import 'package:lucent_api/src/model/rename_conversation_request.dart';
import 'package:lucent_api/src/model/report_dashboard_response.dart';
import 'package:lucent_api/src/model/report_dashboard_response_findings.dart';
import 'package:lucent_api/src/model/report_dashboard_response_metrics.dart';
import 'package:lucent_api/src/model/report_dashboard_response_metrics_observed_metric.dart';
import 'package:lucent_api/src/model/report_dashboard_response_patterns.dart';
import 'package:lucent_api/src/model/report_dashboard_response_trends.dart';
import 'package:lucent_api/src/model/report_dashboard_response_trends_observed_metric.dart';
import 'package:lucent_api/src/model/report_local_capability_request.dart';
import 'package:lucent_api/src/model/report_summary_job_response.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_coverage.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_coverage_medication.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_coverage_sleep.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_coverage_water.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_low_risk_action.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_observed_pattern.dart';
import 'package:lucent_api/src/model/report_summary_response.dart';
import 'package:lucent_api/src/model/report_summary_response_coverage.dart';
import 'package:lucent_api/src/model/report_summary_response_coverage_medication.dart';
import 'package:lucent_api/src/model/report_summary_response_coverage_sleep.dart';
import 'package:lucent_api/src/model/report_summary_response_coverage_water.dart';
import 'package:lucent_api/src/model/report_summary_response_low_risk_action.dart';
import 'package:lucent_api/src/model/report_summary_response_observed_pattern.dart';
import 'package:lucent_api/src/model/reset_password_request.dart';
import 'package:lucent_api/src/model/run_risk_check_request.dart';
import 'package:lucent_api/src/model/run_risk_check_request_candidate.dart';
import 'package:lucent_api/src/model/send_verification_code_request.dart';
import 'package:lucent_api/src/model/send_verification_code_response.dart';
import 'package:lucent_api/src/model/session_list_item_entry.dart';
import 'package:lucent_api/src/model/set_password_request.dart';
import 'package:lucent_api/src/model/share_clinic_summary_request.dart';
import 'package:lucent_api/src/model/sse_problem_details_dto.dart';
import 'package:lucent_api/src/model/stream_messages_request.dart';
import 'package:lucent_api/src/model/stream_messages_request_messages.dart';
import 'package:lucent_api/src/model/submit_feedback_request.dart';
import 'package:lucent_api/src/model/suggestion_explanation_job_response.dart';
import 'package:lucent_api/src/model/suggestion_explanation_job_response_result.dart';
import 'package:lucent_api/src/model/suggestion_explanation_response.dart';
import 'package:lucent_api/src/model/suggestion_feedback_response.dart';
import 'package:lucent_api/src/model/suggestion_history_response.dart';
import 'package:lucent_api/src/model/suggestion_history_response_items.dart';
import 'package:lucent_api/src/model/today_analysis_async_job_data.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_analysis.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_analysis_bullets.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_analysis_metrics.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_analysis_metrics_observed_metric.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_bullets.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_metrics.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_metrics_observed_metric.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_result.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_result_any_of.dart';
import 'package:lucent_api/src/model/today_analysis_async_result_data_result_any_of1.dart';
import 'package:lucent_api/src/model/today_analysis_async_status_data.dart';
import 'package:lucent_api/src/model/today_analysis_data.dart';
import 'package:lucent_api/src/model/today_analysis_data_bullets.dart';
import 'package:lucent_api/src/model/today_analysis_data_metrics.dart';
import 'package:lucent_api/src/model/today_analysis_data_metrics_observed_metric.dart';
import 'package:lucent_api/src/model/today_analysis_read_data.dart';
import 'package:lucent_api/src/model/today_analysis_read_data_analysis.dart';
import 'package:lucent_api/src/model/today_analysis_read_data_analysis_bullets.dart';
import 'package:lucent_api/src/model/today_analysis_read_data_analysis_metrics.dart';
import 'package:lucent_api/src/model/today_analysis_read_data_analysis_metrics_observed_metric.dart';
import 'package:lucent_api/src/model/today_analysis_read_response.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_analysis.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_analysis_bullets.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_analysis_metrics.dart';
import 'package:lucent_api/src/model/today_analysis_read_response_analysis_metrics_observed_metric.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_pending_data.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_analysis.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_analysis_bullets.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_analysis_metrics.dart';
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_analysis_metrics_observed_metric.dart';
import 'package:lucent_api/src/model/today_recommendation_item.dart';
import 'package:lucent_api/src/model/today_suggestions_response.dart';
import 'package:lucent_api/src/model/today_suggestions_response_observations.dart';
import 'package:lucent_api/src/model/today_suggestions_response_observations_evidence.dart';
import 'package:lucent_api/src/model/today_suggestions_response_observations_observed_metric.dart';
import 'package:lucent_api/src/model/today_suggestions_response_observations_primary_action.dart';
import 'package:lucent_api/src/model/today_suggestions_response_observations_secondary_actions.dart';
import 'package:lucent_api/src/model/today_suggestions_response_primary.dart';
import 'package:lucent_api/src/model/today_suggestions_response_primary_evidence.dart';
import 'package:lucent_api/src/model/today_suggestions_response_primary_observed_metric.dart';
import 'package:lucent_api/src/model/today_suggestions_response_primary_primary_action.dart';
import 'package:lucent_api/src/model/today_suggestions_response_primary_secondary_actions.dart';
import 'package:lucent_api/src/model/today_suggestions_response_secondary.dart';
import 'package:lucent_api/src/model/today_suggestions_response_secondary_evidence.dart';
import 'package:lucent_api/src/model/today_suggestions_response_secondary_observed_metric.dart';
import 'package:lucent_api/src/model/today_suggestions_response_secondary_primary_action.dart';
import 'package:lucent_api/src/model/today_suggestions_response_secondary_secondary_actions.dart';
import 'package:lucent_api/src/model/unlink_identity_request.dart';
import 'package:lucent_api/src/model/unread_count_response.dart';
import 'package:lucent_api/src/model/update_account_request.dart';
import 'package:lucent_api/src/model/update_allergy_request.dart';
import 'package:lucent_api/src/model/update_condition_request.dart';
import 'package:lucent_api/src/model/update_current_medicine_request.dart';
import 'package:lucent_api/src/model/update_daily_record_request.dart';
import 'package:lucent_api/src/model/update_daily_record_request_attachments.dart';
import 'package:lucent_api/src/model/update_dose_log_request.dart';
import 'package:lucent_api/src/model/update_medicine_reminder_request.dart';
import 'package:lucent_api/src/model/update_settings_request.dart';
import 'package:lucent_api/src/model/update_settings_request_assistant_context.dart';
import 'package:lucent_api/src/model/update_user_health_context_profile_request.dart';
import 'package:lucent_api/src/model/upsert_check_in_request.dart';
import 'package:lucent_api/src/model/upsert_group_request.dart';
import 'package:lucent_api/src/model/upsert_group_request_slots.dart';
import 'package:lucent_api/src/model/user_settings_response.dart';
import 'package:lucent_api/src/model/user_settings_response_assistant_context.dart';
import 'package:lucent_api/src/model/verify_email_request.dart';
import 'package:lucent_api/src/model/verify_email_response.dart';

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
    case 'AccountEmailResponse':
      return AccountEmailResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AccountResponse':
      return AccountResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AccountResponseLinkedIdentities':
      return AccountResponseLinkedIdentities.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AppInfoResponse':
      return AppInfoResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantCapabilitiesResponse':
      return AssistantCapabilitiesResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantCapabilitiesResponseAssistantContext':
      return AssistantCapabilitiesResponseAssistantContext.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantCapabilitiesResponseTools':
      return AssistantCapabilitiesResponseTools.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantClearMemoryResponse':
      return AssistantClearMemoryResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantClearResultResponse':
      return AssistantClearResultResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConfirmResultResponse':
      return AssistantConfirmResultResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationData':
      return AssistantConversationData.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AssistantConversationDataMessages':
      return AssistantConversationDataMessages.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationResponse':
      return AssistantConversationResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationResponseMessages':
      return AssistantConversationResponseMessages.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AssistantConversationSummaryItem':
      return AssistantConversationSummaryItem.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ChangeEmailRequest':
      return ChangeEmailRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangePasswordRequest':
      return ChangePasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryExportJobResponse':
      return ClinicSummaryExportJobResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponse':
      return ClinicSummaryResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryResponseAllergies':
      return ClinicSummaryResponseAllergies.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseConditions':
      return ClinicSummaryResponseConditions.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseCoverage':
      return ClinicSummaryResponseCoverage.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseCoverageCheckIns':
      return ClinicSummaryResponseCoverageCheckIns.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseCoverageDose':
      return ClinicSummaryResponseCoverageDose.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseCoverageSleep':
      return ClinicSummaryResponseCoverageSleep.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseCoverageWater':
      return ClinicSummaryResponseCoverageWater.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseCurrentMedicines':
      return ClinicSummaryResponseCurrentMedicines.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseNoteEntries':
      return ClinicSummaryResponseNoteEntries.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseProfile':
      return ClinicSummaryResponseProfile.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseSleepEntries':
      return ClinicSummaryResponseSleepEntries.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryResponseWaterEntries':
      return ClinicSummaryResponseWaterEntries.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareListResponse':
      return ClinicSummaryShareListResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareListResponseItems':
      return ClinicSummaryShareListResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareListResponseItemsScope':
      return ClinicSummaryShareListResponseItemsScope.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ClinicSummaryShareResponse':
      return ClinicSummaryShareResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ClinicSummaryShareResponseScope':
      return ClinicSummaryShareResponseScope.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ConfirmProposalRequest':
      return ConfirmProposalRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateAllergyRequest':
      return CreateAllergyRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateConditionRequest':
      return CreateConditionRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateCurrentMedicineRequest':
      return CreateCurrentMedicineRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'CreateDailyRecordRequest':
      return CreateDailyRecordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateDailyRecordRequestAttachments':
      return CreateDailyRecordRequestAttachments.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'CreateDoseLogRequest':
      return CreateDoseLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateGoogleAuthorizeUrlRequest':
      return CreateGoogleAuthorizeUrlRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'CreateHealthEventRequest':
      return CreateHealthEventRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateImageUploadRequest':
      return CreateImageUploadRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateMedicineReminderRequest':
      return CreateMedicineReminderRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'CreateNotificationRequest':
      return CreateNotificationRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateQqAuthorizeUrlRequest':
      return CreateQqAuthorizeUrlRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateRequestRequest':
      return CreateRequestRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateUploadRequest':
      return CreateUploadRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateWechatWebAuthorizeUrlRequest':
      return CreateWechatWebAuthorizeUrlRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'CreateWechatWebIdentityLinkAuthorizeUrlRequest':
      return CreateWechatWebIdentityLinkAuthorizeUrlRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'CreateWeiboAuthorizeUrlRequest':
      return CreateWeiboAuthorizeUrlRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordCandidateResponse':
      return DailyRecordCandidateResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordCandidateResponseItems':
      return DailyRecordCandidateResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordImageUploadResponse':
      return DailyRecordImageUploadResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordListResponse':
      return DailyRecordListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordListResponseItems':
      return DailyRecordListResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordListResponseItemsAttachments':
      return DailyRecordListResponseItemsAttachments.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordResponse':
      return DailyRecordResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordResponseAttachments':
      return DailyRecordResponseAttachments.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordSummaryResponse':
      return DailyRecordSummaryResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DailyRecordSummaryResponseSummaries':
      return DailyRecordSummaryResponseSummaries.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordSummaryResponseSummariesLatest':
      return DailyRecordSummaryResponseSummariesLatest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DailyRecordSummaryResponseSummariesLatestAttachments':
      return DailyRecordSummaryResponseSummariesLatestAttachments.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DataExportRequestData':
      return DataExportRequestData.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DataExportRequestResponse':
      return DataExportRequestResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DeleteAccountRequest':
      return DeleteAccountRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogListResponse':
      return DoseLogListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogListResponseItems':
      return DoseLogListResponseItems.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DoseLogResponse':
      return DoseLogResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DownloadClinicSummaryPdfRequest':
      return DownloadClinicSummaryPdfRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EndRequest':
      return EndRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'EnqueueAnalysisGenerationRequest':
      return EnqueueAnalysisGenerationRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnqueueClinicSummaryPdfExportRequest':
      return EnqueueClinicSummaryPdfExportRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnqueueMedicineRecognitionRequest':
      return EnqueueMedicineRecognitionRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnqueueSummaryGenerationRequest':
      return EnqueueSummaryGenerationRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponse':
      return EnvironmentSnapshotResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EnvironmentSnapshotResponseAirQuality':
      return EnvironmentSnapshotResponseAirQuality.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponseHumidity':
      return EnvironmentSnapshotResponseHumidity.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponsePollen':
      return EnvironmentSnapshotResponsePollen.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponseTemperature':
      return EnvironmentSnapshotResponseTemperature.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EnvironmentSnapshotResponseUv':
      return EnvironmentSnapshotResponseUv.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewData':
      return EventReviewData.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewDataCoverage':
      return EventReviewDataCoverage.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewDataCoverageCheckIns':
      return EventReviewDataCoverageCheckIns.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataCoverageCheckInsTodayCheckIn':
      return EventReviewDataCoverageCheckInsTodayCheckIn.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataCoverageDailyRecords':
      return EventReviewDataCoverageDailyRecords.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataCoverageDoseLogs':
      return EventReviewDataCoverageDoseLogs.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataEvent':
      return EventReviewDataEvent.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewDataSections':
      return EventReviewDataSections.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewDataSectionsCompletedActions':
      return EventReviewDataSectionsCompletedActions.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataSectionsCompletedActionsFacts':
      return EventReviewDataSectionsCompletedActionsFacts.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataSectionsKeyChanges':
      return EventReviewDataSectionsKeyChanges.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataSectionsKeyChangesFacts':
      return EventReviewDataSectionsKeyChangesFacts.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataSectionsNextStep':
      return EventReviewDataSectionsNextStep.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataSectionsNextStepFacts':
      return EventReviewDataSectionsNextStepFacts.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataSectionsWhatHappened':
      return EventReviewDataSectionsWhatHappened.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataSectionsWhatHappenedFacts':
      return EventReviewDataSectionsWhatHappenedFacts.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewDataSourceTimestamps':
      return EventReviewDataSourceTimestamps.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewListResponse':
      return EventReviewListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewListResponseItems':
      return EventReviewListResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponse':
      return EventReviewResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewResponseCoverage':
      return EventReviewResponseCoverage.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewResponseCoverageCheckIns':
      return EventReviewResponseCoverageCheckIns.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseCoverageCheckInsTodayCheckIn':
      return EventReviewResponseCoverageCheckInsTodayCheckIn.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseCoverageDailyRecords':
      return EventReviewResponseCoverageDailyRecords.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseCoverageDoseLogs':
      return EventReviewResponseCoverageDoseLogs.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseEvent':
      return EventReviewResponseEvent.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewResponseSections':
      return EventReviewResponseSections.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EventReviewResponseSectionsCompletedActions':
      return EventReviewResponseSectionsCompletedActions.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseSectionsCompletedActionsFacts':
      return EventReviewResponseSectionsCompletedActionsFacts.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseSectionsKeyChanges':
      return EventReviewResponseSectionsKeyChanges.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseSectionsKeyChangesFacts':
      return EventReviewResponseSectionsKeyChangesFacts.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseSectionsNextStep':
      return EventReviewResponseSectionsNextStep.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseSectionsNextStepFacts':
      return EventReviewResponseSectionsNextStepFacts.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseSectionsWhatHappened':
      return EventReviewResponseSectionsWhatHappened.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseSectionsWhatHappenedFacts':
      return EventReviewResponseSectionsWhatHappenedFacts.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'EventReviewResponseSourceTimestamps':
      return EventReviewResponseSourceTimestamps.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ForgotPasswordRequest':
      return ForgotPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ForgotPasswordResponse':
      return ForgotPasswordResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponse':
      return FunnelResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseDaily':
      return FunnelResponseDaily.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseOptional':
      return FunnelResponseOptional.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseTotals':
      return FunnelResponseTotals.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FunnelResponseWindow':
      return FunnelResponseWindow.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Generate200Response':
      return Generate200Response.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GenerateCandidatesRequest':
      return GenerateCandidatesRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GenerateRequest':
      return GenerateRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GenerateStreamRequest':
      return GenerateStreamRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GenerateSummaryRequest':
      return GenerateSummaryRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GenerateSummaryStreamRequest':
      return GenerateSummaryStreamRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthAppInfo':
      return HealthAppInfo.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthComponent':
      return HealthComponent.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthComponentStatus':
    case 'HealthContextResponse':
      return HealthContextResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthContextResponseAllergies':
      return HealthContextResponseAllergies.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseConditions':
      return HealthContextResponseConditions.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseCurrentMedicines':
      return HealthContextResponseCurrentMedicines.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseProfile':
      return HealthContextResponseProfile.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseProfileEmergencyContact':
      return HealthContextResponseProfileEmergencyContact.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthContextResponseSummary':
      return HealthContextResponseSummary.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventListResponse':
      return HealthEventListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventListResponseItems':
      return HealthEventListResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventListResponseItemsCheckIn':
      return HealthEventListResponseItemsCheckIn.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventListResponseItemsCoverage':
      return HealthEventListResponseItemsCoverage.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventNullableResponse':
      return HealthEventNullableResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventNullableResponseCheckIn':
      return HealthEventNullableResponseCheckIn.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventNullableResponseCoverage':
      return HealthEventNullableResponseCoverage.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'HealthEventResponse':
      return HealthEventResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventResponseCheckIn':
      return HealthEventResponseCheckIn.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthEventResponseCoverage':
      return HealthEventResponseCoverage.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthOverallStatus':
    case 'HealthProbeType':
    case 'HealthResponse':
      return HealthResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthSummary':
      return HealthSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LegalDocumentDetailResponse':
      return LegalDocumentDetailResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LegalDocumentListResponse':
      return LegalDocumentListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LegalDocumentListResponseItems':
      return LegalDocumentListResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LinkWechatMobileIdentityRequest':
      return LinkWechatMobileIdentityRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LinkWechatWebIdentityRequest':
      return LinkWechatWebIdentityRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LocalCapabilityResponse':
      return LocalCapabilityResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginRequest':
      return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LoginResponse':
      return LoginResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginResponseTokens':
      return LoginResponseTokens.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginResponseUser':
      return LoginResponseUser.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginWithAppleRequest':
      return LoginWithAppleRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginWithGoogleRequest':
      return LoginWithGoogleRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginWithQqRequest':
      return LoginWithQqRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginWithWechatMobileRequest':
      return LoginWithWechatMobileRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LoginWithWechatWebRequest':
      return LoginWithWechatWebRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginWithWeiboRequest':
      return LoginWithWeiboRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LogoutRequest':
      return LogoutRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MarkRequest':
      return MarkRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MedicineDetailResponse':
      return MedicineDetailResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineDetailResponseDetail':
      return MedicineDetailResponseDetail.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineDetailResponseDetailOneOf':
      return MedicineDetailResponseDetailOneOf.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineDetailResponseDetailOneOf1':
      return MedicineDetailResponseDetailOneOf1.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineDetailResponseDrugInteractions':
      return MedicineDetailResponseDrugInteractions.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRecognitionJob':
      return MedicineRecognitionJob.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineRecognitionJobResult':
      return MedicineRecognitionJobResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineReminderListResponse':
      return MedicineReminderListResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineReminderListResponseItems':
      return MedicineReminderListResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineReminderResponse':
      return MedicineReminderResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineRiskCheckRecordResponse':
      return MedicineRiskCheckRecordResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordResponseResult':
      return MedicineRiskCheckRecordResponseResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordResponseResultCoverageIssues':
      return MedicineRiskCheckRecordResponseResultCoverageIssues.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordResponseResultFindings':
      return MedicineRiskCheckRecordResponseResultFindings.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordResponseResultRedFlags':
      return MedicineRiskCheckRecordResponseResultRedFlags.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponse':
      return MedicineRiskCheckRecordsResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseLlm':
      return MedicineRiskCheckRecordsResponseLlm.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseLlmResult':
      return MedicineRiskCheckRecordsResponseLlmResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseLlmResultCoverageIssues':
      return MedicineRiskCheckRecordsResponseLlmResultCoverageIssues.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseLlmResultFindings':
      return MedicineRiskCheckRecordsResponseLlmResultFindings.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseLlmResultRedFlags':
      return MedicineRiskCheckRecordsResponseLlmResultRedFlags.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseStatic':
      return MedicineRiskCheckRecordsResponseStatic.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseStaticResult':
      return MedicineRiskCheckRecordsResponseStaticResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseStaticResultCoverageIssues':
      return MedicineRiskCheckRecordsResponseStaticResultCoverageIssues.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseStaticResultFindings':
      return MedicineRiskCheckRecordsResponseStaticResultFindings.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineRiskCheckRecordsResponseStaticResultRedFlags':
      return MedicineRiskCheckRecordsResponseStaticResultRedFlags.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'MedicineSafetyTipItem':
      return MedicineSafetyTipItem.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchResponse':
      return MedicineSearchResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchResponseItems':
      return MedicineSearchResponseItems.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MedicineSearchResponsePagination':
      return MedicineSearchResponsePagination.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'NotificationDetailResponse':
      return NotificationDetailResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationListResponse':
      return NotificationListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NotificationListResponseItems':
      return NotificationListResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'NotificationPreferencesResponse':
      return NotificationPreferencesResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'OAuthAuthorizeResponse':
      return OAuthAuthorizeResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PatchRequest':
      return PatchRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PreviewClinicSummaryRequest':
      return PreviewClinicSummaryRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProblemDetailsDto':
      return ProblemDetailsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RecognizeRequest':
      return RecognizeRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RecordBatchRequest':
      return RecordBatchRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RecordBatchRequestEvents':
      return RecordBatchRequestEvents.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RecordReceiptRequest':
      return RecordReceiptRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RefreshResponse':
      return RefreshResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RefreshSessionRequest':
      return RefreshSessionRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RefreshTodayAnalysisRequest':
      return RefreshTodayAnalysisRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterRequest':
      return RegisterRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterResponse':
      return RegisterResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterResponseTokens':
      return RegisterResponseTokens.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterResponseUser':
      return RegisterResponseUser.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReminderDeliveryListResponse':
      return ReminderDeliveryListResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryListResponseItems':
      return ReminderDeliveryListResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryReceiptResponse':
      return ReminderDeliveryReceiptResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReminderDeliveryReceiptResponseItem':
      return ReminderDeliveryReceiptResponseItem.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'RenameConversationRequest':
      return RenameConversationRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportDashboardResponse':
      return ReportDashboardResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportDashboardResponseFindings':
      return ReportDashboardResponseFindings.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponseMetrics':
      return ReportDashboardResponseMetrics.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponseMetricsObservedMetric':
      return ReportDashboardResponseMetricsObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponsePatterns':
      return ReportDashboardResponsePatterns.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponseTrends':
      return ReportDashboardResponseTrends.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportDashboardResponseTrendsObservedMetric':
      return ReportDashboardResponseTrendsObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportLocalCapabilityRequest':
      return ReportLocalCapabilityRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryJobResponse':
      return ReportSummaryJobResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportSummaryJobResponseResult':
      return ReportSummaryJobResponseResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryJobResponseResultCoverage':
      return ReportSummaryJobResponseResultCoverage.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryJobResponseResultCoverageMedication':
      return ReportSummaryJobResponseResultCoverageMedication.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryJobResponseResultCoverageSleep':
      return ReportSummaryJobResponseResultCoverageSleep.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryJobResponseResultCoverageWater':
      return ReportSummaryJobResponseResultCoverageWater.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryJobResponseResultLowRiskAction':
      return ReportSummaryJobResponseResultLowRiskAction.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryJobResponseResultObservedPattern':
      return ReportSummaryJobResponseResultObservedPattern.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponse':
      return ReportSummaryResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReportSummaryResponseCoverage':
      return ReportSummaryResponseCoverage.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponseCoverageMedication':
      return ReportSummaryResponseCoverageMedication.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponseCoverageSleep':
      return ReportSummaryResponseCoverageSleep.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponseCoverageWater':
      return ReportSummaryResponseCoverageWater.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponseLowRiskAction':
      return ReportSummaryResponseLowRiskAction.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ReportSummaryResponseObservedPattern':
      return ReportSummaryResponseObservedPattern.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ResetPasswordRequest':
      return ResetPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RunRiskCheckRequest':
      return RunRiskCheckRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RunRiskCheckRequestCandidate':
      return RunRiskCheckRequestCandidate.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SendVerificationCodeRequest':
      return SendVerificationCodeRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SendVerificationCodeResponse':
      return SendVerificationCodeResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SessionListItemEntry':
      return SessionListItemEntry.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SetPasswordRequest':
      return SetPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ShareClinicSummaryRequest':
      return ShareClinicSummaryRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SseProblemDetailsDto':
      return SseProblemDetailsDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'StreamMessagesRequest':
      return StreamMessagesRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'StreamMessagesRequestMessages':
      return StreamMessagesRequestMessages.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SubmitFeedbackRequest':
      return SubmitFeedbackRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionExplanationJobResponse':
      return SuggestionExplanationJobResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionExplanationJobResponseResult':
      return SuggestionExplanationJobResponseResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionExplanationResponse':
      return SuggestionExplanationResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuggestionFeedbackResponse':
      return SuggestionFeedbackResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionHistoryResponse':
      return SuggestionHistoryResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SuggestionHistoryResponseItems':
      return SuggestionHistoryResponseItems.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncJobData':
      return TodayAnalysisAsyncJobData.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisAsyncResultData':
      return TodayAnalysisAsyncResultData.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataAnalysis':
      return TodayAnalysisAsyncResultDataAnalysis.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataAnalysisBullets':
      return TodayAnalysisAsyncResultDataAnalysisBullets.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataAnalysisMetrics':
      return TodayAnalysisAsyncResultDataAnalysisMetrics.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataAnalysisMetricsObservedMetric':
      return TodayAnalysisAsyncResultDataAnalysisMetricsObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataBullets':
      return TodayAnalysisAsyncResultDataBullets.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataMetrics':
      return TodayAnalysisAsyncResultDataMetrics.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataMetricsObservedMetric':
      return TodayAnalysisAsyncResultDataMetricsObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataResult':
      return TodayAnalysisAsyncResultDataResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataResultAnyOf':
      return TodayAnalysisAsyncResultDataResultAnyOf.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncResultDataResultAnyOf1':
      return TodayAnalysisAsyncResultDataResultAnyOf1.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisAsyncStatusData':
      return TodayAnalysisAsyncStatusData.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisData':
      return TodayAnalysisData.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisDataBullets':
      return TodayAnalysisDataBullets.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisDataMetrics':
      return TodayAnalysisDataMetrics.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisDataMetricsObservedMetric':
      return TodayAnalysisDataMetricsObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadData':
      return TodayAnalysisReadData.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisReadDataAnalysis':
      return TodayAnalysisReadDataAnalysis.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadDataAnalysisBullets':
      return TodayAnalysisReadDataAnalysisBullets.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadDataAnalysisMetrics':
      return TodayAnalysisReadDataAnalysisMetrics.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadDataAnalysisMetricsObservedMetric':
      return TodayAnalysisReadDataAnalysisMetricsObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadResponse':
      return TodayAnalysisReadResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodayAnalysisReadResponseAnalysis':
      return TodayAnalysisReadResponseAnalysis.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadResponseAnalysisBullets':
      return TodayAnalysisReadResponseAnalysisBullets.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadResponseAnalysisMetrics':
      return TodayAnalysisReadResponseAnalysisMetrics.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisReadResponseAnalysisMetricsObservedMetric':
      return TodayAnalysisReadResponseAnalysisMetricsObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisRefreshPendingData':
      return TodayAnalysisRefreshPendingData.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisRefreshReadyData':
      return TodayAnalysisRefreshReadyData.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisRefreshReadyDataAnalysis':
      return TodayAnalysisRefreshReadyDataAnalysis.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisRefreshReadyDataAnalysisBullets':
      return TodayAnalysisRefreshReadyDataAnalysisBullets.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisRefreshReadyDataAnalysisMetrics':
      return TodayAnalysisRefreshReadyDataAnalysisMetrics.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayAnalysisRefreshReadyDataAnalysisMetricsObservedMetric':
      return TodayAnalysisRefreshReadyDataAnalysisMetricsObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodayRecommendationItem':
      return TodayRecommendationItem.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodaySuggestionsResponse':
      return TodaySuggestionsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TodaySuggestionsResponseObservations':
      return TodaySuggestionsResponseObservations.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseObservationsEvidence':
      return TodaySuggestionsResponseObservationsEvidence.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseObservationsObservedMetric':
      return TodaySuggestionsResponseObservationsObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseObservationsPrimaryAction':
      return TodaySuggestionsResponseObservationsPrimaryAction.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseObservationsSecondaryActions':
      return TodaySuggestionsResponseObservationsSecondaryActions.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponsePrimary':
      return TodaySuggestionsResponsePrimary.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponsePrimaryEvidence':
      return TodaySuggestionsResponsePrimaryEvidence.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponsePrimaryObservedMetric':
      return TodaySuggestionsResponsePrimaryObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponsePrimaryPrimaryAction':
      return TodaySuggestionsResponsePrimaryPrimaryAction.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponsePrimarySecondaryActions':
      return TodaySuggestionsResponsePrimarySecondaryActions.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseSecondary':
      return TodaySuggestionsResponseSecondary.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseSecondaryEvidence':
      return TodaySuggestionsResponseSecondaryEvidence.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseSecondaryObservedMetric':
      return TodaySuggestionsResponseSecondaryObservedMetric.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseSecondaryPrimaryAction':
      return TodaySuggestionsResponseSecondaryPrimaryAction.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'TodaySuggestionsResponseSecondarySecondaryActions':
      return TodaySuggestionsResponseSecondarySecondaryActions.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UnlinkIdentityRequest':
      return UnlinkIdentityRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UnreadCountResponse':
      return UnreadCountResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateAccountRequest':
      return UpdateAccountRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateAllergyRequest':
      return UpdateAllergyRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateConditionRequest':
      return UpdateConditionRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateCurrentMedicineRequest':
      return UpdateCurrentMedicineRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UpdateDailyRecordRequest':
      return UpdateDailyRecordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateDailyRecordRequestAttachments':
      return UpdateDailyRecordRequestAttachments.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UpdateDoseLogRequest':
      return UpdateDoseLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateMedicineReminderRequest':
      return UpdateMedicineReminderRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UpdateSettingsRequest':
      return UpdateSettingsRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateSettingsRequestAssistantContext':
      return UpdateSettingsRequestAssistantContext.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UpdateUserHealthContextProfileRequest':
      return UpdateUserHealthContextProfileRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'UpsertCheckInRequest':
      return UpsertCheckInRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpsertGroupRequest':
      return UpsertGroupRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpsertGroupRequestSlots':
      return UpsertGroupRequestSlots.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserSettingsResponse':
      return UserSettingsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserSettingsResponseAssistantContext':
      return UserSettingsResponseAssistantContext.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'VerifyEmailRequest':
      return VerifyEmailRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerifyEmailResponse':
      return VerifyEmailResponse.fromJson(value as Map<String, dynamic>)
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
