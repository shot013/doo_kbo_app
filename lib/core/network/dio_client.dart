import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
    ),
  );

  if (kDebugMode) {
    // dio 기본 LogInterceptor는 print()로 요청/응답 전체를 한 번에 찍는데,
    // 응답 본문이 큰 API(예: /games의 preview 포함 응답)에서는 안드로이드
    // logcat 파이프가 밀리면서 메인 스레드가 막혀 ANR("Input dispatching
    // timed out")이 발생한다. debugPrint(긴 문자열을 안전하게 나눠 찍음)로
    // 바꾸고 한 줄 길이를 제한해 이 문제를 피한다.
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          final text = object.toString();
          const maxLength = 1000;
          debugPrint(
            text.length > maxLength
                ? '${text.substring(0, maxLength)}... (${text.length - maxLength}자 생략)'
                : text,
          );
        },
      ),
    );
  }

  return dio;
});
