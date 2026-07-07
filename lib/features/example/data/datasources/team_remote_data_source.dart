import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/team_model.dart';

abstract interface class TeamRemoteDataSource {
  Future<List<TeamModel>> getTeams();
}

/// 실제 백엔드가 준비되면 사용할 구현체입니다.
/// `team_providers.dart`에서 이 클래스로 교체하면 실제 API를 호출합니다.
class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  const TeamRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TeamModel>> getTeams() async {
    try {
      final response = await _dio.get<List<dynamic>>('/teams');
      final data = response.data ?? const [];
      return data
          .map((json) => TeamModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw const ServerException();
    }
  }
}

/// 백엔드가 아직 없는 스캐폴딩 단계에서 화면을 바로 확인할 수 있도록 만든
/// 더미 구현체입니다. API가 준비되면 [TeamRemoteDataSourceImpl]로 교체하세요.
class TeamDummyDataSource implements TeamRemoteDataSource {
  const TeamDummyDataSource();

  @override
  Future<List<TeamModel>> getTeams() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _dummyTeams;
  }
}

const _dummyTeams = [
  TeamModel(id: 'doosan', name: 'Doosan Bears', city: 'Seoul'),
  TeamModel(id: 'lg', name: 'LG Twins', city: 'Seoul'),
  TeamModel(id: 'kia', name: 'KIA Tigers', city: 'Gwangju'),
];
