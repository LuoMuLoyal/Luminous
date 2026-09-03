//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:lucent_api/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:lucent_api/src/model/suggestion_explanation_async_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_explanation_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_feedback_response_dto.dart';
import 'package:lucent_api/src/model/suggestion_history_response_dto.dart';
import 'package:lucent_api/src/model/today_suggestion_controller_submit_feedback_v1_request.dart';
import 'package:lucent_api/src/model/today_suggestions_response_dto.dart';

class TodaySuggestionApi {
  final Dio _dio;

  const TodaySuggestionApi(this._dio);

  /// Enqueue async AI explanation for a suggestion card
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [acceptLanguage]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SuggestionExplanationAsyncResponseDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SuggestionExplanationAsyncResponseDto>>
  todaySuggestionControllerExplainSuggestionAsyncV1({
    required String id,
    required String acceptLanguage,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/user/today/suggestions/{id}/explain/async'
        .replaceAll(
          '{'
          r'id'
          '}',
          id.toString(),
        );
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'accept-language': acceptLanguage,
        ...?headers,
      },
      extra: <String, dynamic>{'secure': <Map<String, String>>[], ...?extra},
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SuggestionExplanationAsyncResponseDto? _responseData;

    try {
      final rawData = _response.data;
      _responseData = rawData == null
          ? null
          : deserialize<
              SuggestionExplanationAsyncResponseDto,
              SuggestionExplanationAsyncResponseDto
            >(rawData, 'SuggestionExplanationAsyncResponseDto', growable: true);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SuggestionExplanationAsyncResponseDto>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Poll async suggestion explanation status
  ///
  ///
  /// Parameters:
  /// * [jobId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> todaySuggestionControllerExplainSuggestionStatusV1({
    required String jobId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/user/today/suggestions/explain/status/{jobId}'
        .replaceAll(
          '{'
          r'jobId'
          '}',
          jobId.toString(),
        );
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{'secure': <Map<String, String>>[], ...?extra},
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return _response;
  }

  /// Get AI explanation for a suggestion card
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [acceptLanguage]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SuggestionExplanationResponseDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SuggestionExplanationResponseDto>>
  todaySuggestionControllerExplainSuggestionV1({
    required String id,
    required String acceptLanguage,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/user/today/suggestions/{id}/explain'.replaceAll(
      '{'
      r'id'
      '}',
      id.toString(),
    );
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'accept-language': acceptLanguage,
        ...?headers,
      },
      extra: <String, dynamic>{'secure': <Map<String, String>>[], ...?extra},
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SuggestionExplanationResponseDto? _responseData;

    try {
      final rawData = _response.data;
      _responseData = rawData == null
          ? null
          : deserialize<
              SuggestionExplanationResponseDto,
              SuggestionExplanationResponseDto
            >(rawData, 'SuggestionExplanationResponseDto', growable: true);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SuggestionExplanationResponseDto>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Get suggestion history for the Report page
  ///
  ///
  /// Parameters:
  /// * [acceptLanguage]
  /// * [startDate] - Start date (YYYY-MM-DD). Defaults to 30 days ago.
  /// * [endDate] - End date (YYYY-MM-DD). Defaults to today.
  /// * [lifecycleState] - Filter by lifecycle state.
  /// * [type] - Filter by suggestion type.
  /// * [limit] - Max items (default 100, max 500).
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SuggestionHistoryResponseDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SuggestionHistoryResponseDto>>
  todaySuggestionControllerGetHistoryV1({
    required String acceptLanguage,
    String? startDate,
    String? endDate,
    String? lifecycleState,
    String? type,
    num? limit,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/user/today/suggestions/history';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'accept-language': acceptLanguage,
        ...?headers,
      },
      extra: <String, dynamic>{'secure': <Map<String, String>>[], ...?extra},
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (startDate != null) r'startDate': startDate,
      if (endDate != null) r'endDate': endDate,
      if (lifecycleState != null) r'lifecycleState': lifecycleState,
      if (type != null) r'type': type,
      if (limit != null) r'limit': limit,
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SuggestionHistoryResponseDto? _responseData;

    try {
      final rawData = _response.data;
      _responseData = rawData == null
          ? null
          : deserialize<
              SuggestionHistoryResponseDto,
              SuggestionHistoryResponseDto
            >(rawData, 'SuggestionHistoryResponseDto', growable: true);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SuggestionHistoryResponseDto>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Get Today page suggestion cards
  ///
  ///
  /// Parameters:
  /// * [acceptLanguage]
  /// * [date] - Target date (YYYY-MM-DD). Defaults to today.
  /// * [excludeIds] - Suggestion IDs the user has dismissed.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TodaySuggestionsResponseDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TodaySuggestionsResponseDto>>
  todaySuggestionControllerGetSuggestionsV1({
    required String acceptLanguage,
    String? date,
    List<String>? excludeIds,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/user/today/suggestions';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'accept-language': acceptLanguage,
        ...?headers,
      },
      extra: <String, dynamic>{'secure': <Map<String, String>>[], ...?extra},
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (date != null) r'date': date,
      if (excludeIds != null) r'excludeIds': excludeIds,
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TodaySuggestionsResponseDto? _responseData;

    try {
      final rawData = _response.data;
      _responseData = rawData == null
          ? null
          : deserialize<
              TodaySuggestionsResponseDto,
              TodaySuggestionsResponseDto
            >(rawData, 'TodaySuggestionsResponseDto', growable: true);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TodaySuggestionsResponseDto>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Submit feedback for a suggestion card
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [todaySuggestionControllerSubmitFeedbackV1Request]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SuggestionFeedbackResponseDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SuggestionFeedbackResponseDto>>
  todaySuggestionControllerSubmitFeedbackV1({
    required String id,
    required TodaySuggestionControllerSubmitFeedbackV1Request
    todaySuggestionControllerSubmitFeedbackV1Request,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/user/today/suggestions/{id}/feedback'.replaceAll(
      '{'
      r'id'
      '}',
      id.toString(),
    );
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{...?headers},
      extra: <String, dynamic>{'secure': <Map<String, String>>[], ...?extra},
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      _bodyData = jsonEncode(todaySuggestionControllerSubmitFeedbackV1Request);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(_dio.options, _path),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SuggestionFeedbackResponseDto? _responseData;

    try {
      final rawData = _response.data;
      _responseData = rawData == null
          ? null
          : deserialize<
              SuggestionFeedbackResponseDto,
              SuggestionFeedbackResponseDto
            >(rawData, 'SuggestionFeedbackResponseDto', growable: true);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SuggestionFeedbackResponseDto>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
