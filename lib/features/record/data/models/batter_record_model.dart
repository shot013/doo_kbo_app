import '../../domain/entities/batter_record.dart';

final class BatterRecordModel extends BatterRecord {
  const BatterRecordModel({
    required super.rank,
    required super.playerId,
    required super.playerName,
    required super.teamCode,
    required super.teamName,
    required super.avg,
    required super.games,
    required super.homeRuns,
    required super.rbi,
  });

  factory BatterRecordModel.fromJson(Map<String, dynamic> json) {
    return BatterRecordModel(
      rank: json['rank'] as int,
      playerId: json['playerId'] as int?,
      playerName: json['playerName'] as String,
      teamCode: json['teamCode'] as String,
      teamName: json['teamName'] as String,
      avg: json['avg'] as String,
      games: json['games'] as int,
      homeRuns: json['homeRuns'] as int,
      rbi: json['rbi'] as int,
    );
  }
}
