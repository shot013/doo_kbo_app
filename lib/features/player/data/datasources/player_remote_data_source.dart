import 'package:dio/dio.dart';

import '../../../../core/constants/dummy_player_roster.dart';
import '../../../../core/constants/player_position.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/player_stat_line.dart';
import '../models/player_detail_model.dart';
import '../models/player_summary_model.dart';

abstract interface class PlayerRemoteDataSource {
  Future<List<PlayerSummaryModel>> getPlayers({
    String? search,
    String? teamCode,
    PlayerPosition? position,
  });

  Future<PlayerDetailModel> getPlayerDetail(String id);
}

/// 실제 백엔드가 준비되면 사용할 구현체입니다.
/// `player_providers.dart`에서 이 클래스로 교체하면 실제 API를 호출합니다.
class PlayerRemoteDataSourceImpl implements PlayerRemoteDataSource {
  const PlayerRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<PlayerSummaryModel>> getPlayers({
    String? search,
    String? teamCode,
    PlayerPosition? position,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/players',
        queryParameters: {
          'search': ?search,
          'teamCode': ?teamCode,
          'position': ?position?.name,
          // 선수 탭은 서버 페이지네이션 없이 전체 목록을 한 번에 불러와
          // 클라이언트에서 검색/필터링한다(presentation/providers/player_providers.dart).
          'limit': '500',
        },
      );
      final data = response.data?['data'] as List<dynamic>? ?? const [];
      return data
          .map(
            (json) => PlayerSummaryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      throw const ServerException();
    }
  }

  @override
  Future<PlayerDetailModel> getPlayerDetail(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/players/$id');
      final data = response.data ?? const {};
      return PlayerDetailModel.fromJson(data);
    } on DioException {
      throw const ServerException();
    }
  }
}

/// 백엔드가 아직 없는 스캐폴딩 단계에서 화면을 바로 확인할 수 있도록 만든
/// 더미 구현체입니다. API가 준비되면 [PlayerRemoteDataSourceImpl]로 교체하세요.
/// 필터 인자는 실제 API 계약만 맞춰두고, 실제 필터링은 presentation에서
/// 클라이언트 사이드로 처리합니다([StandingDummyDataSource]가 `seasonYear`를
/// 무시하는 것과 동일한 스캐폴딩 관례).
class PlayerDummyDataSource implements PlayerRemoteDataSource {
  const PlayerDummyDataSource();

  @override
  Future<List<PlayerSummaryModel>> getPlayers({
    String? search,
    String? teamCode,
    PlayerPosition? position,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      for (final seed in kDummyPlayerRoster)
        PlayerSummaryModel(
          id: seed.id,
          name: seed.name,
          teamCode: seed.teamCode,
          teamName: seed.teamName,
          position: seed.position,
          backNumber: seed.backNumber,
          primaryStat: seed.primaryStat,
        ),
    ];
  }

  @override
  Future<PlayerDetailModel> getPlayerDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final seed = kDummyPlayerRoster.firstWhere(
      (seed) => seed.id == id,
      orElse: () => throw const ServerException('선수를 찾을 수 없습니다.'),
    );
    return PlayerDetailModel(
      id: seed.id,
      name: seed.name,
      teamCode: seed.teamCode,
      teamName: seed.teamName,
      position: seed.position,
      backNumber: seed.backNumber,
      statLines: [
        for (final (label, value) in seed.statLines)
          PlayerStatLine(label: label, value: value),
      ],
    );
  }
}
