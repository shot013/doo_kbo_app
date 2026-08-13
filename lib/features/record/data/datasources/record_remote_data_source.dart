import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/batter_record_model.dart';
import '../models/pitcher_record_model.dart';

abstract interface class RecordRemoteDataSource {
  Future<List<BatterRecordModel>> getBatterRecords({int? seasonYear});

  Future<List<PitcherRecordModel>> getPitcherRecords({int? seasonYear});
}

/// 실제 백엔드가 준비되면 사용할 구현체입니다.
/// `record_providers.dart`에서 이 클래스로 교체하면 실제 API를 호출합니다.
class RecordRemoteDataSourceImpl implements RecordRemoteDataSource {
  const RecordRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<BatterRecordModel>> getBatterRecords({int? seasonYear}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/records/batters',
        queryParameters: {'seasonYear': ?seasonYear},
      );
      final data = response.data?['data'] as List<dynamic>? ?? const [];
      return data
          .map(
            (json) => BatterRecordModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      throw const ServerException();
    }
  }

  @override
  Future<List<PitcherRecordModel>> getPitcherRecords({int? seasonYear}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/records/pitchers',
        queryParameters: {'seasonYear': ?seasonYear},
      );
      final data = response.data?['data'] as List<dynamic>? ?? const [];
      return data
          .map(
            (json) => PitcherRecordModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      throw const ServerException();
    }
  }
}

/// 백엔드가 아직 없는 스캐폴딩 단계에서 화면을 바로 확인할 수 있도록 만든
/// 더미 구현체입니다. API가 준비되면 [RecordRemoteDataSourceImpl]로 교체하세요.
class RecordDummyDataSource implements RecordRemoteDataSource {
  const RecordDummyDataSource();

  @override
  Future<List<BatterRecordModel>> getBatterRecords({int? seasonYear}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _dummyBatterRecords;
  }

  @override
  Future<List<PitcherRecordModel>> getPitcherRecords({int? seasonYear}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _dummyPitcherRecords;
  }
}

const _dummyBatterRecords = [
  BatterRecordModel(
    rank: 1,
    playerName: '타자 1',
    teamCode: 'LG',
    teamName: 'LG 트윈스',
    avg: '.365',
    games: 118,
    homeRuns: 24,
    rbi: 89,
  ),
  BatterRecordModel(
    rank: 2,
    playerName: '타자 2',
    teamCode: 'KT',
    teamName: 'kt wiz',
    avg: '.352',
    games: 120,
    homeRuns: 18,
    rbi: 76,
  ),
  BatterRecordModel(
    rank: 3,
    playerName: '타자 3',
    teamCode: 'SS',
    teamName: '삼성 라이온즈',
    avg: '.341',
    games: 115,
    homeRuns: 21,
    rbi: 82,
  ),
  BatterRecordModel(
    rank: 4,
    playerName: '타자 4',
    teamCode: 'HT',
    teamName: 'KIA 타이거즈',
    avg: '.336',
    games: 119,
    homeRuns: 15,
    rbi: 70,
  ),
  BatterRecordModel(
    rank: 5,
    playerName: '타자 5',
    teamCode: 'OB',
    teamName: '두산 베어스',
    avg: '.330',
    games: 112,
    homeRuns: 27,
    rbi: 91,
  ),
  BatterRecordModel(
    rank: 6,
    playerName: '타자 6',
    teamCode: 'SK',
    teamName: 'SSG 랜더스',
    avg: '.325',
    games: 117,
    homeRuns: 30,
    rbi: 95,
  ),
  BatterRecordModel(
    rank: 7,
    playerName: '타자 7',
    teamCode: 'HH',
    teamName: '한화 이글스',
    avg: '.319',
    games: 110,
    homeRuns: 12,
    rbi: 58,
  ),
  BatterRecordModel(
    rank: 8,
    playerName: '타자 8',
    teamCode: 'NC',
    teamName: 'NC 다이노스',
    avg: '.312',
    games: 108,
    homeRuns: 19,
    rbi: 65,
  ),
  BatterRecordModel(
    rank: 9,
    playerName: '타자 9',
    teamCode: 'LT',
    teamName: '롯데 자이언츠',
    avg: '.308',
    games: 114,
    homeRuns: 9,
    rbi: 52,
  ),
  BatterRecordModel(
    rank: 10,
    playerName: '타자 10',
    teamCode: 'WO',
    teamName: '키움 히어로즈',
    avg: '.301',
    games: 109,
    homeRuns: 14,
    rbi: 60,
  ),
];

const _dummyPitcherRecords = [
  PitcherRecordModel(
    rank: 1,
    playerName: '투수 1',
    teamCode: 'KT',
    teamName: 'kt wiz',
    era: '2.14',
    games: 26,
    wins: 16,
    losses: 4,
    saves: 0,
  ),
  PitcherRecordModel(
    rank: 2,
    playerName: '투수 2',
    teamCode: 'LG',
    teamName: 'LG 트윈스',
    era: '2.31',
    games: 25,
    wins: 14,
    losses: 5,
    saves: 0,
  ),
  PitcherRecordModel(
    rank: 3,
    playerName: '투수 3',
    teamCode: 'SS',
    teamName: '삼성 라이온즈',
    era: '2.58',
    games: 60,
    wins: 3,
    losses: 2,
    saves: 34,
  ),
  PitcherRecordModel(
    rank: 4,
    playerName: '투수 4',
    teamCode: 'HT',
    teamName: 'KIA 타이거즈',
    era: '2.75',
    games: 27,
    wins: 13,
    losses: 6,
    saves: 0,
  ),
  PitcherRecordModel(
    rank: 5,
    playerName: '투수 5',
    teamCode: 'OB',
    teamName: '두산 베어스',
    era: '2.89',
    games: 58,
    wins: 4,
    losses: 3,
    saves: 29,
  ),
  PitcherRecordModel(
    rank: 6,
    playerName: '투수 6',
    teamCode: 'SK',
    teamName: 'SSG 랜더스',
    era: '3.02',
    games: 24,
    wins: 12,
    losses: 7,
    saves: 0,
  ),
  PitcherRecordModel(
    rank: 7,
    playerName: '투수 7',
    teamCode: 'HH',
    teamName: '한화 이글스',
    era: '3.18',
    games: 55,
    wins: 5,
    losses: 4,
    saves: 22,
  ),
  PitcherRecordModel(
    rank: 8,
    playerName: '투수 8',
    teamCode: 'NC',
    teamName: 'NC 다이노스',
    era: '3.35',
    games: 26,
    wins: 10,
    losses: 8,
    saves: 0,
  ),
  PitcherRecordModel(
    rank: 9,
    playerName: '투수 9',
    teamCode: 'LT',
    teamName: '롯데 자이언츠',
    era: '3.47',
    games: 23,
    wins: 9,
    losses: 9,
    saves: 0,
  ),
  PitcherRecordModel(
    rank: 10,
    playerName: '투수 10',
    teamCode: 'WO',
    teamName: '키움 히어로즈',
    era: '3.59',
    games: 52,
    wins: 3,
    losses: 5,
    saves: 18,
  ),
];
