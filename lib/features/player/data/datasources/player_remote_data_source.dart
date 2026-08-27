import 'package:dio/dio.dart';

import '../../../../core/constants/dummy_player_roster.dart';
import '../../../../core/constants/kbo_teams.dart';
import '../../../../core/constants/player_position.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/player_stat_line.dart';
import '../../domain/entities/player_vs_batter_stat.dart';
import '../../domain/entities/player_vs_pitcher_stat.dart';
import '../../domain/entities/player_vs_team_stat.dart';
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
          // 검색/필터는 서버에 그대로 전달해 매번 새로 요청하고
          // (presentation/providers/player_providers.dart), limit은 결과가
          // 페이지네이션 없이 한 번에 다 돌아오도록 넉넉히 잡아둔 값이다.
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
/// 실제 서버가 검색/필터를 처리하는 것과 동일하게, 여기서도 인자를 받아
/// 더미 데이터 안에서 걸러서 반환합니다.
class PlayerDummyDataSource implements PlayerRemoteDataSource {
  const PlayerDummyDataSource();

  @override
  Future<List<PlayerSummaryModel>> getPlayers({
    String? search,
    String? teamCode,
    PlayerPosition? position,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final query = search?.trim() ?? '';
    return [
      for (final seed in kDummyPlayerRoster)
        if ((query.isEmpty ||
                seed.name.contains(query) ||
                seed.teamName.contains(query)) &&
            (teamCode == null || seed.teamCode == teamCode) &&
            (position == null || seed.position == position))
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
      vsTeamStats: [
        for (final team in kKboTeams)
          if (team.code != seed.teamCode)
            PlayerVsTeamStat(
              teamCode: team.code,
              teamName: team.name,
              games: 10 + team.code.length,
              avg: '0.3${(20 + team.code.length * 7) % 80}',
            ),
      ],
      vsPitcherStats: seed.position == PlayerPosition.pitcher
          ? const []
          : [
              for (final team in kKboTeams)
                if (team.code != seed.teamCode) _dummyVsPitcherStat(team),
            ],
      vsBatterStats: seed.position != PlayerPosition.pitcher
          ? const []
          : [
              for (final team in kKboTeams)
                if (team.code != seed.teamCode) _dummyVsBatterStat(team),
            ],
    );
  }
}

PlayerVsPitcherStat _dummyVsPitcherStat(KboTeam team) {
  final pitcher = kDummyPlayerRoster.firstWhere(
    (candidate) =>
        candidate.teamCode == team.code &&
        candidate.position == PlayerPosition.pitcher,
  );
  final atBats = 3 + team.code.length;
  final hits = 1 + team.code.length % 3;
  return PlayerVsPitcherStat(
    pitcherId: pitcher.backNumber,
    pitcherName: pitcher.name,
    pitcherTeamCode: team.code,
    atBats: atBats,
    hits: hits,
    avg: (hits / atBats).toStringAsFixed(3),
  );
}

PlayerVsBatterStat _dummyVsBatterStat(KboTeam team) {
  final batter = kDummyPlayerRoster.firstWhere(
    (candidate) =>
        candidate.teamCode == team.code &&
        candidate.position != PlayerPosition.pitcher,
  );
  final atBats = 3 + team.code.length;
  final strikeouts = 1 + team.code.length % 3;
  return PlayerVsBatterStat(
    batterId: batter.backNumber,
    batterName: batter.name,
    batterTeamCode: team.code,
    atBats: atBats,
    strikeouts: strikeouts,
    strikeoutRate: (strikeouts / atBats).toStringAsFixed(3),
  );
}
