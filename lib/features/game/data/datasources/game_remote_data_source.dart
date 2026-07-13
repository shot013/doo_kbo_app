import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/game_status.dart';
import '../../domain/entities/player_stat_type.dart';
import '../models/game_model.dart';
import '../models/game_stat_model.dart';

abstract interface class GameRemoteDataSource {
  Future<List<GameModel>> getGames({int? seasonYear, String? gameDate});

  Future<List<GameStatModel>> getGameStats(String gameId);
}

/// 실제 백엔드가 준비되면 사용할 구현체입니다.
/// `game_providers.dart`에서 이 클래스로 교체하면 실제 API를 호출합니다.
class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  const GameRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<GameModel>> getGames({int? seasonYear, String? gameDate}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/games',
        queryParameters: {'seasonYear': ?seasonYear, 'gameDate': ?gameDate},
      );
      final data = response.data ?? const [];
      return data
          .map((json) => GameModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw const ServerException();
    }
  }

  @override
  Future<List<GameStatModel>> getGameStats(String gameId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/game-stats',
        queryParameters: {'gameId': gameId},
      );
      final data = response.data ?? const [];
      return data
          .map((json) => GameStatModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw const ServerException();
    }
  }
}

/// 백엔드가 아직 없는 스캐폴딩 단계에서 화면을 바로 확인할 수 있도록 만든
/// 더미 구현체입니다. API가 준비되면 [GameRemoteDataSourceImpl]로 교체하세요.
class GameDummyDataSource implements GameRemoteDataSource {
  const GameDummyDataSource();

  @override
  Future<List<GameModel>> getGames({int? seasonYear, String? gameDate}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _dummyGames;
  }

  @override
  Future<List<GameStatModel>> getGameStats(String gameId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _dummyGameStats;
  }
}

final _dummyGames = [
  GameModel(
    id: '20260713OBLG0',
    seasonYear: 2026,
    gameDate: '2026-07-13',
    scheduledAt: DateTime(2026, 7, 13, 18, 30),
    stadium: '잠실야구장',
    homeTeamCode: 'LG',
    homeTeamName: 'LG 트윈스',
    awayTeamCode: 'OB',
    awayTeamName: '두산 베어스',
    homeScore: 3,
    awayScore: 2,
    currentInning: '7회말',
    status: GameStatus.inProgress,
  ),
  GameModel(
    id: '20260713SSHT0',
    seasonYear: 2026,
    gameDate: '2026-07-13',
    scheduledAt: DateTime(2026, 7, 13, 18, 30),
    stadium: '문학야구장',
    homeTeamCode: 'SS',
    homeTeamName: 'SSG 랜더스',
    awayTeamCode: 'HT',
    awayTeamName: 'KIA 타이거즈',
    homeScore: null,
    awayScore: null,
    currentInning: null,
    status: GameStatus.scheduled,
  ),
];

const _dummyGameStats = [
  GameStatModel(
    id: 1,
    gameId: '20260713OBLG0',
    teamCode: 'OB',
    playerName: '김민석',
    playerNo: '25',
    statType: PlayerStatType.batting,
    atBats: 4,
    hits: 2,
    doubles: 1,
    triples: 0,
    homeRuns: 0,
    rbi: 1,
    runs: 1,
    walks: 0,
    strikeouts: 1,
    stolenBases: 0,
    battingAverage: '0.500',
    inningsPitched: null,
    hitsAllowed: null,
    earnedRuns: null,
    strikeoutsPitched: null,
    walksAllowed: null,
    homeRunsAllowed: null,
    win: false,
    loss: false,
    save: false,
    hold: false,
    era: null,
  ),
  GameStatModel(
    id: 2,
    gameId: '20260713OBLG0',
    teamCode: 'LG',
    playerName: '이민호',
    playerNo: '54',
    statType: PlayerStatType.pitching,
    atBats: null,
    hits: null,
    doubles: null,
    triples: null,
    homeRuns: null,
    rbi: null,
    runs: null,
    walks: null,
    strikeouts: null,
    stolenBases: null,
    battingAverage: null,
    inningsPitched: '6.0',
    hitsAllowed: 5,
    earnedRuns: 2,
    strikeoutsPitched: 6,
    walksAllowed: 1,
    homeRunsAllowed: 0,
    win: true,
    loss: false,
    save: false,
    hold: false,
    era: '2.15',
  ),
];
