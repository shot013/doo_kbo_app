import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 실제 HTTP 요청 없이 Dio가 정해진 응답/에러를 받도록 하는 테스트용 어댑터.
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter.success(Object responseBody)
    : _responseBody = responseBody is String
          ? responseBody
          : jsonEncode(responseBody),
      _error = null;

  FakeHttpClientAdapter.failure(DioException error)
    : _responseBody = null,
      _error = error;

  final String? _responseBody;
  final DioException? _error;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final error = _error;
    if (error != null) throw error;
    return ResponseBody.fromString(
      _responseBody!,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
