import '../../domain/entities/pitcher_record.dart';

final class PitcherRecordModel extends PitcherRecord {
  const PitcherRecordModel({
    required super.rank,
    required super.playerId,
    required super.playerName,
    required super.teamCode,
    required super.teamName,
    required super.era,
    required super.games,
    required super.wins,
    required super.losses,
    required super.saves,
  });

  factory PitcherRecordModel.fromJson(Map<String, dynamic> json) {
    return PitcherRecordModel(
      rank: json['rank'] as int,
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      teamCode: json['teamCode'] as String,
      teamName: json['teamName'] as String,
      era: json['era'] as String? ?? '0.00',
      games: json['games'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      saves: json['saves'] as int,
    );
  }
}
