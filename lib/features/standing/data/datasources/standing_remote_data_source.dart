import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/standing_model.dart';

abstract interface class StandingRemoteDataSource {
  Future<List<StandingModel>> getStandings({int? seasonYear});
}

/// 실제 백엔드가 준비되면 사용할 구현체입니다.
/// `standing_providers.dart`에서 이 클래스로 교체하면 실제 API를 호출합니다.
class StandingRemoteDataSourceImpl implements StandingRemoteDataSource {
  const StandingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<StandingModel>> getStandings({int? seasonYear}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/standings',
        queryParameters: {'seasonYear': ?seasonYear},
      );
      final data = response.data?['data'] as List<dynamic>? ?? const [];
      return data
          .map((json) => StandingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw const ServerException();
    }
  }
}

/// 백엔드가 아직 없는 스캐폴딩 단계에서 화면을 바로 확인할 수 있도록 만든
/// 더미 구현체입니다. API가 준비되면 [StandingRemoteDataSourceImpl]로 교체하세요.
class StandingDummyDataSource implements StandingRemoteDataSource {
  const StandingDummyDataSource();

  @override
  Future<List<StandingModel>> getStandings({int? seasonYear}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _dummyStandings;
  }
}

const _dummyStandings = [
  StandingModel(
    seasonYear: 2026,
    teamCode: 'LG',
    teamName: 'LG 트윈스',
    rank: 1,
    gamesPlayed: 80,
    wins: 50,
    losses: 28,
    draws: 2,
    winRate: '0.641',
    gamesBehind: '0.0',
    streak: '3연승',
    last10: '7승3패',
    homeRecord: '27승12패1무',
    awayRecord: '23승16패1무',
  ),
  StandingModel(
    seasonYear: 2026,
    teamCode: 'OB',
    teamName: '두산 베어스',
    rank: 2,
    gamesPlayed: 80,
    wins: 46,
    losses: 32,
    draws: 2,
    winRate: '0.590',
    gamesBehind: '4.0',
    streak: '1패',
    last10: '5승5패',
    homeRecord: '25승14패1무',
    awayRecord: '21승18패1무',
  ),
];
