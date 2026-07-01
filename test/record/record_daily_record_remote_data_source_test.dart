import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/record/data/datasources/daily_record_remote_data_source.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';

void main() {
  group('DailyRecordRemoteDataSource', () {
    late _FakeDailyRecordAdapter adapter;
    late DailyRecordRemoteDataSource dataSource;

    setUp(() {
      adapter = _FakeDailyRecordAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.httpClientAdapter = adapter;
      dataSource = DailyRecordRemoteDataSource(
        api: lucent.DailyRecordsApi(dio),
        dio: dio,
      );
    });

    test('create sends attachment metadata without leaking DTOs', () async {
      await dataSource.create(
        const DailyRecordCreateInput(
          kind: DailyRecordKind.meal,
          occurredAt: '2026-06-06',
          occurredTime: '09:45',
          title: 'Breakfast',
          attachments: <DailyRecordAttachmentInput>[
            DailyRecordAttachmentInput(
              objectKey: 'daily-records/u1/photo.jpg',
              bucket: 'bucket-1',
              provider: 'tencent-cos',
              fileName: 'photo.jpg',
              contentType: 'image/jpeg',
              sizeBytes: 3,
              publicUrl: 'https://cdn.example.test/photo.jpg',
            ),
          ],
        ),
      );

      final request = adapter.requestAt('POST', '/api/v1/user/daily-records');
      expect(request.jsonBody['kind'], 'meal');
      expect(request.jsonBody['occurredTime'], '09:45');
      expect(request.jsonBody['title'], 'Breakfast');
      final attachments = request.jsonBody['attachments'] as List<Object?>;
      expect(attachments, hasLength(1));
      expect(
        attachments.single,
        containsPair('objectKey', 'daily-records/u1/photo.jpg'),
      );
      expect(attachments.single, containsPair('kind', 'image'));
      expect(attachments.single, containsPair('provider', 'tencent-cos'));
    });

    test('update omits attachments to keep existing metadata', () async {
      await dataSource.update(
        'record-1',
        const DailyRecordUpdateInput(title: 'Updated', occurredTime: '10:20'),
      );

      final request = adapter.requestAt(
        'PATCH',
        '/api/v1/user/daily-records/record-1',
      );
      expect(request.jsonBody, containsPair('title', 'Updated'));
      expect(request.jsonBody, containsPair('occurredTime', '10:20'));
      expect(request.jsonBody.containsKey('attachments'), isFalse);
    });

    test('update sends empty attachments list to clear metadata', () async {
      await dataSource.update(
        'record-1',
        const DailyRecordUpdateInput(
          attachments: <DailyRecordAttachmentInput>[],
        ),
      );

      final request = adapter.requestAt(
        'PATCH',
        '/api/v1/user/daily-records/record-1',
      );
      expect(request.jsonBody['attachments'], isEmpty);
    });

    test('update sends attachment list to replace metadata', () async {
      await dataSource.update(
        'record-1',
        const DailyRecordUpdateInput(
          attachments: <DailyRecordAttachmentInput>[
            DailyRecordAttachmentInput(
              objectKey: 'daily-records/u1/replacement.webp',
              contentType: 'image/webp',
              sizeBytes: 12,
            ),
          ],
        ),
      );

      final request = adapter.requestAt(
        'PATCH',
        '/api/v1/user/daily-records/record-1',
      );
      final attachments = request.jsonBody['attachments'] as List<Object?>;
      expect(attachments, hasLength(1));
      expect(
        attachments.single,
        containsPair('objectKey', 'daily-records/u1/replacement.webp'),
      );
      expect(attachments.single, containsPair('contentType', 'image/webp'));
    });

    test('uploadImage presigns, PUTs bytes, and returns metadata', () async {
      final attachment = await dataSource.uploadImage(
        const DailyRecordImageUploadInput(
          bytes: <int>[1, 2, 3],
          contentType: 'image/jpeg',
          sizeBytes: 3,
          fileName: 'photo.jpg',
        ),
      );

      final presign = adapter.requestAt(
        'POST',
        '/api/v1/user/daily-records/attachments/images/presign-upload',
      );
      expect(presign.jsonBody, {
        'contentType': 'image/jpeg',
        'sizeBytes': 3,
        'fileName': 'photo.jpg',
      });

      final upload = adapter.requestAt(
        'PUT',
        'https://cos.example.test/upload-object',
      );
      expect(upload.bodyBytes, <int>[1, 2, 3]);
      expect(upload.headers['content-type'], 'image/jpeg');
      expect(upload.headers['content-length'], '3');
      expect(upload.headers.containsKey('authorization'), isFalse);
      expect(upload.extra['skipAuthorization'], isTrue);
      expect(upload.extra['skipAuthRefresh'], isTrue);

      expect(attachment.objectKey, 'daily-records/u1/photo.jpg');
      expect(attachment.bucket, 'bucket-1');
      expect(attachment.provider, 'tencent-cos');
      expect(attachment.publicUrl, 'https://cdn.example.test/photo.jpg');
    });

    test(
      'fetchRecords maps meal analysis hot fields from generated DTOs',
      () async {
        final result = await dataSource.fetchRecords('2026-06-06');

        expect(result.total, 1);
        final item = result.items.single;
        expect(item.mealAnalysisStatus, 'unconfirmed');
        expect(item.mealAnalysisCoverage, 'partial');
        expect(item.mealAnalysisUpdatedAt, '2026-07-01T10:00:00.000Z');
        expect(item.mealAnalysisFailureReason, isNull);
        expect(item.mealShortDescription, '一份米饭配鸡胸肉');
        expect(item.mealTopFoods, <String>['米饭', '鸡胸肉']);
      },
    );

    test(
      'fetchSummary maps latest meal analysis hot fields from generated DTOs',
      () async {
        final result = await dataSource.fetchSummary('2026-06-06');

        expect(result.summaries, hasLength(1));
        final latest = result.summaries.single.latest;
        expect(latest, isNotNull);
        expect(latest!.mealAnalysisStatus, 'unconfirmed');
        expect(latest.mealAnalysisCoverage, 'partial');
        expect(latest.mealAnalysisUpdatedAt, '2026-07-01T10:00:00.000Z');
        expect(latest.mealAnalysisFailureReason, isNull);
        expect(latest.mealShortDescription, '一份米饭配鸡胸肉');
        expect(latest.mealTopFoods, <String>['米饭', '鸡胸肉']);
      },
    );

    test(
      'get preserves meal analysis hot fields from generated DTOs',
      () async {
        final item = await dataSource.get('record-1');

        expect(item.mealAnalysisStatus, 'unconfirmed');
        expect(item.mealAnalysisCoverage, 'partial');
        expect(item.mealAnalysisUpdatedAt, '2026-07-01T10:00:00.000Z');
        expect(item.mealAnalysisFailureReason, isNull);
        expect(item.mealShortDescription, '一份米饭配鸡胸肉');
        expect(item.mealTopFoods, <String>['米饭', '鸡胸肉']);
      },
    );
  });
}

class _FakeDailyRecordAdapter implements HttpClientAdapter {
  final requests = <_CapturedRequest>[];

  _CapturedRequest requestAt(String method, String uriOrPath) {
    return requests.singleWhere(
      (request) =>
          request.method == method &&
          (request.path == uriOrPath || request.uri == uriOrPath),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bodyBytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bodyBytes.addAll(chunk);
      }
    }

    requests.add(
      _CapturedRequest(
        method: options.method,
        uri: options.uri.toString(),
        path: options.path,
        headers: options.headers.map(
          (key, value) => MapEntry(key.toLowerCase(), value.toString()),
        ),
        extra: Map<String, Object?>.from(options.extra),
        bodyBytes: bodyBytes,
      ),
    );

    if (options.uri.host == 'cos.example.test') {
      return ResponseBody.fromString('', 200);
    }

    if (options.path.endsWith('/attachments/images/presign-upload')) {
      return _jsonResponse(<String, Object?>{
        'code': 0,
        'message': '',
        'data': <String, Object?>{
          'provider': 'tencent-cos',
          'bucket': 'bucket-1',
          'objectKey': 'daily-records/u1/photo.jpg',
          'uploadUrl': 'https://cos.example.test/upload-object',
          'headers': <String, String>{'Content-Type': 'image/jpeg'},
          'publicUrl': 'https://cdn.example.test/photo.jpg',
          'expiresAt': '2026-06-06T00:10:00.000Z',
          'maxSizeBytes': 50000000,
        },
      });
    }

    if (options.path == '/api/v1/user/daily-records/summary') {
      return _jsonResponse(<String, Object?>{
        'code': 0,
        'message': '',
        'data': <String, Object?>{
          'summaries': <Object?>[
            <String, Object?>{
              'kind': 'meal',
              'count': 1,
              'latest': _recordJson(attachments: const <Object?>[]),
            },
          ],
        },
      });
    }

    if (options.method == 'GET' &&
        options.path == '/api/v1/user/daily-records') {
      return _jsonResponse(<String, Object?>{
        'code': 0,
        'message': '',
        'data': <String, Object?>{
          'items': <Object?>[
            _recordJson(
              attachments: _lastJsonAttachments() ?? const <Object?>[],
            ),
          ],
          'total': 1,
        },
      });
    }

    return _jsonResponse(<String, Object?>{
      'code': 0,
      'message': '',
      'data': _recordJson(
        attachments: _lastJsonAttachments() ?? const <Object?>[],
      ),
    });
  }

  @override
  void close({bool force = false}) {}

  List<Object?>? _lastJsonAttachments() {
    final jsonBody = requests.last.jsonBody;
    final attachments = jsonBody['attachments'];
    return attachments is List<Object?> ? attachments : null;
  }

  ResponseBody _jsonResponse(Map<String, Object?> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: const <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  Map<String, Object?> _recordJson({required List<Object?> attachments}) {
    return <String, Object?>{
      'id': 'record-1',
      'kind': 'meal',
      'occurredAt': '2026-06-06',
      'occurredTime': '09:45',
      'title': 'Record',
      'value': null,
      'unit': null,
      'note': null,
      'source': 'manual',
      'payload': <String, Object?>{
        'mealAnalysis': <String, Object?>{
          'analysisStatus': 'unconfirmed',
          'coverage': 'partial',
        },
      },
      'mealAnalysisStatus': 'unconfirmed',
      'mealAnalysisCoverage': 'partial',
      'mealAnalysisUpdatedAt': '2026-07-01T10:00:00.000Z',
      'mealAnalysisFailureReason': null,
      'mealShortDescription': '一份米饭配鸡胸肉',
      'mealTopFoods': <String>['米饭', '鸡胸肉'],
      'attachments': attachments.map((raw) {
        final attachment = raw as Map<String, Object?>;
        return <String, Object?>{
          'id': 'attachment-1',
          'kind': attachment['kind'] ?? 'image',
          'objectKey': attachment['objectKey'],
          'bucket': attachment['bucket'],
          'provider': attachment['provider'],
          'fileName': attachment['fileName'],
          'contentType': attachment['contentType'],
          'sizeBytes': attachment['sizeBytes'],
          'width': attachment['width'],
          'height': attachment['height'],
          'publicUrl': attachment['publicUrl'],
          'createdAt': '2026-06-06T00:00:00.000Z',
        };
      }).toList(),
      'createdAt': '2026-06-06T00:00:00.000Z',
      'updatedAt': '2026-06-06T00:00:00.000Z',
    };
  }
}

class _CapturedRequest {
  const _CapturedRequest({
    required this.method,
    required this.uri,
    required this.path,
    required this.headers,
    required this.extra,
    required this.bodyBytes,
  });

  final String method;
  final String uri;
  final String path;
  final Map<String, String> headers;
  final Map<String, Object?> extra;
  final List<int> bodyBytes;

  Map<String, dynamic> get jsonBody {
    if (bodyBytes.isEmpty) return const <String, dynamic>{};
    return jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
  }
}
