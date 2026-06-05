//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:lucent_openapi/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:lucent_openapi/src/model/medicine_detail_response_dto.dart';
import 'package:lucent_openapi/src/model/medicine_search_response_dto.dart';

class MedicinesApi {

  final Dio _dio;

  const MedicinesApi(this._dio);

  /// Get medicine detail from a selected knowledge source
  ///
  ///
  /// Parameters:
  /// * [id] - Medicine id in the selected source
  /// * [source_] - Knowledge source selector.
  /// * [xBypassCache] - Set to true/1/no-cache to bypass medicines read cache for this request only.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MedicineDetailResponseDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MedicineDetailResponseDto>> medicinesControllerGetDetailV1({
    required String id,
    String? source_ = 'drugbank',
    String? xBypassCache,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/medicines/{id}'.replaceAll('{' r'id' '}', id.toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xBypassCache != null) r'x-bypass-cache': xBypassCache,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (source_ != null) r'source': source_,
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    MedicineDetailResponseDto? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<MedicineDetailResponseDto, MedicineDetailResponseDto>(rawData, 'MedicineDetailResponseDto', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MedicineDetailResponseDto>(
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

  /// Search medicines from a selected knowledge source
  ///
  ///
  /// Parameters:
  /// * [source_] - Knowledge source selector.
  /// * [q] - Search keyword.
  /// * [page] - Page number, 1-based.
  /// * [pageSize] - Page size.
  /// * [xBypassCache] - Set to true/1/no-cache to bypass medicines read cache for this request only.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MedicineSearchResponseDto] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MedicineSearchResponseDto>> medicinesControllerSearchV1({
    String? source_ = 'drugbank',
    String? q,
    Object? page = 1,
    Object? pageSize = 20,
    String? xBypassCache,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/medicines';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xBypassCache != null) r'x-bypass-cache': xBypassCache,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (source_ != null) r'source': source_,
      if (q != null) r'q': q,
      if (page != null) r'page': page,
      if (pageSize != null) r'pageSize': pageSize,
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    MedicineSearchResponseDto? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<MedicineSearchResponseDto, MedicineSearchResponseDto>(rawData, 'MedicineSearchResponseDto', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MedicineSearchResponseDto>(
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
