import '../../../game/domain/entities/game_status.dart';
import '../../domain/entities/attendance_record.dart';

/// 정책서 6.3 "직관 기록 저장 형식"의 기록 하나. 이름은 camelCase이고, 서버
/// DB로 옮길 때 snake_case로 바꾼다. 시각은 ISO 8601 UTC 밀리초.
final class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.gameId,
    required super.seasonYear,
    required super.gameDate,
    required super.stadium,
    required super.homeTeamCode,
    required super.awayTeamCode,
    required super.homeScore,
    required super.awayScore,
    required super.gameStatus,
    required super.source,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
  });

  factory AttendanceRecordModel.fromEntity(AttendanceRecord r) {
    return AttendanceRecordModel(
      id: r.id,
      gameId: r.gameId,
      seasonYear: r.seasonYear,
      gameDate: r.gameDate,
      stadium: r.stadium,
      homeTeamCode: r.homeTeamCode,
      awayTeamCode: r.awayTeamCode,
      homeScore: r.homeScore,
      awayScore: r.awayScore,
      gameStatus: r.gameStatus,
      source: r.source,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
    );
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final gameDate = json['gameDate'] as String;
    final createdAt = _parseTime(json['createdAt']);
    return AttendanceRecordModel(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      seasonYear:
          json['seasonYear'] as int? ??
          int.tryParse(gameDate.split('-').first) ??
          createdAt.year,
      gameDate: gameDate,
      stadium: json['stadium'] as String?,
      homeTeamCode: json['homeTeamCode'] as String,
      awayTeamCode: json['awayTeamCode'] as String,
      homeScore: json['homeScore'] as int?,
      awayScore: json['awayScore'] as int?,
      // 캐시라서 모르는 값은 경기 전으로 두고 다음에 열 때 다시 받아 고친다.
      gameStatus:
          GameStatus.values.asNameMap()[json['gameStatus'] as String?] ??
          GameStatus.scheduled,
      source: AttendanceRecordSource.values.firstWhere(
        (source) => source.value == json['source'],
        orElse: () => AttendanceRecordSource.summary,
      ),
      createdAt: createdAt,
      updatedAt: _parseTime(json['updatedAt'], fallback: createdAt),
      deletedAt: json['deletedAt'] == null
          ? null
          : _parseTime(json['deletedAt']),
    );
  }

  /// 도메인 값. Equatable은 타입까지 비교하므로, 읽은 기록과 앱에서 만든
  /// 기록이 같은 값이면 같게 보이도록 모델 타입을 벗겨 둔다.
  AttendanceRecord toEntity() => AttendanceRecord(
    id: id,
    gameId: gameId,
    seasonYear: seasonYear,
    gameDate: gameDate,
    stadium: stadium,
    homeTeamCode: homeTeamCode,
    awayTeamCode: awayTeamCode,
    homeScore: homeScore,
    awayScore: awayScore,
    gameStatus: gameStatus,
    source: source,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'gameId': gameId,
    'seasonYear': seasonYear,
    'gameDate': gameDate,
    'stadium': stadium,
    'homeTeamCode': homeTeamCode,
    'awayTeamCode': awayTeamCode,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'gameStatus': gameStatus.name,
    'source': source.value,
    'createdAt': formatUtcMillis(createdAt),
    'updatedAt': formatUtcMillis(updatedAt),
    'deletedAt': deletedAt == null ? null : formatUtcMillis(deletedAt!),
  };

  static DateTime _parseTime(Object? value, {DateTime? fallback}) =>
      DateTime.tryParse(value as String? ?? '')?.toUtc() ??
      fallback ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

/// 예: `2026-11-28T04:14:34.120Z` (UTC, 밀리초까지)
String formatUtcMillis(DateTime time) {
  final utc = time.toUtc();
  return DateTime.utc(
    utc.year,
    utc.month,
    utc.day,
    utc.hour,
    utc.minute,
    utc.second,
    utc.millisecond,
  ).toIso8601String();
}
