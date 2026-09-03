import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/action_log_model.dart';

abstract interface class ActionLogRemoteDataSource {
  Future<void> sendLogs(List<ActionLogModel> logs);
}

class ActionLogRemoteDataSourceImpl implements ActionLogRemoteDataSource {
  const ActionLogRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> sendLogs(List<ActionLogModel> logs) async {
    try {
      await _dio.post<void>(
        '/action-logs',
        data: {'logs': logs.map((log) => log.toJson()).toList()},
      );
    } on DioException {
      throw const ServerException();
    }
  }
}
