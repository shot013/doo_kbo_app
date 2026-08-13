import 'package:dio/dio.dart';

import '../../../../core/constants/dummy_player_roster.dart';
import '../../../../core/error/exceptions.dart';
import '../../../player/data/models/player_summary_model.dart';
import '../models/team_detail_model.dart';
import '../models/team_summary_model.dart';

abstract interface class TeamRemoteDataSource {
  Future<List<TeamSummaryModel>> getTeams();

  Future<TeamDetailModel> getTeamDetail(String code);
}

/// 실제 백엔드가 준비되면 사용할 구현체입니다.
/// `team_providers.dart`에서 이 클래스로 교체하면 실제 API를 호출합니다.
class TeamRemoteDataSourceImpl implements TeamRemoteDataSource {
  const TeamRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TeamSummaryModel>> getTeams() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/teams');
      final data = response.data?['data'] as List<dynamic>? ?? const [];
      return data
          .map(
            (json) => TeamSummaryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      throw const ServerException();
    }
  }

  @override
  Future<TeamDetailModel> getTeamDetail(String code) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/teams/$code');
      final data = response.data ?? const {};
      return TeamDetailModel.fromJson(data);
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
  Future<List<TeamSummaryModel>> getTeams() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _dummyTeams;
  }

  @override
  Future<TeamDetailModel> getTeamDetail(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final summary = _dummyTeams.firstWhere(
      (team) => team.code == code,
      orElse: () => throw const ServerException('팀을 찾을 수 없습니다.'),
    );
    final roster = [
      for (final seed in kDummyPlayerRoster)
        if (seed.teamCode == code)
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
    return TeamDetailModel(summary: summary, roster: roster);
  }
}

const _dummyTeams = [
  TeamSummaryModel(
    code: 'KT',
    name: 'kt wiz',
    rank: 1,
    wins: 60,
    losses: 37,
    draws: 2,
    winRate: '0.619',
    gamesBehind: '0.0',
    recentForm: ['W', 'W', 'L', 'W', 'W'],
  ),
  TeamSummaryModel(
    code: 'SS',
    name: '삼성 라이온즈',
    rank: 2,
    wins: 59,
    losses: 41,
    draws: 2,
    winRate: '0.590',
    gamesBehind: '2.5',
    recentForm: ['W', 'L', 'W', 'W', 'W'],
  ),
  TeamSummaryModel(
    code: 'LG',
    name: 'LG 트윈스',
    rank: 3,
    wins: 56,
    losses: 46,
    draws: 1,
    winRate: '0.549',
    gamesBehind: '6.5',
    recentForm: ['L', 'W', 'W', 'L', 'W'],
  ),
  TeamSummaryModel(
    code: 'HT',
    name: 'KIA 타이거즈',
    rank: 4,
    wins: 54,
    losses: 46,
    draws: 2,
    winRate: '0.540',
    gamesBehind: '7.5',
    recentForm: ['W', 'W', 'L', 'L', 'W'],
  ),
  TeamSummaryModel(
    code: 'OB',
    name: '두산 베어스',
    rank: 5,
    wins: 53,
    losses: 46,
    draws: 4,
    winRate: '0.535',
    gamesBehind: '8.0',
    recentForm: ['L', 'W', 'W', 'W', 'L'],
  ),
  TeamSummaryModel(
    code: 'HH',
    name: '한화 이글스',
    rank: 6,
    wins: 48,
    losses: 50,
    draws: 3,
    winRate: '0.490',
    gamesBehind: '12.5',
    recentForm: ['L', 'L', 'W', 'W', 'L'],
  ),
  TeamSummaryModel(
    code: 'NC',
    name: 'NC 다이노스',
    rank: 7,
    wins: 44,
    losses: 51,
    draws: 2,
    winRate: '0.463',
    gamesBehind: '15.0',
    recentForm: ['W', 'L', 'L', 'W', 'L'],
  ),
  TeamSummaryModel(
    code: 'LT',
    name: '롯데 자이언츠',
    rank: 8,
    wins: 44,
    losses: 56,
    draws: 2,
    winRate: '0.440',
    gamesBehind: '17.5',
    recentForm: ['L', 'L', 'W', 'L', 'L'],
  ),
  TeamSummaryModel(
    code: 'SK',
    name: 'SSG 랜더스',
    rank: 9,
    wins: 41,
    losses: 60,
    draws: 4,
    winRate: '0.406',
    gamesBehind: '21.0',
    recentForm: ['L', 'L', 'L', 'W', 'L'],
  ),
  TeamSummaryModel(
    code: 'WO',
    name: '키움 히어로즈',
    rank: 10,
    wins: 39,
    losses: 65,
    draws: 2,
    winRate: '0.375',
    gamesBehind: '24.5',
    recentForm: ['L', 'L', 'L', 'L', 'W'],
  ),
];
