import '../../../../core/constants/player_position.dart';
import '../../domain/entities/player_summary.dart';

final class PlayerSummaryModel extends PlayerSummary {
  const PlayerSummaryModel({
    required super.id,
    required super.name,
    required super.teamCode,
    required super.teamName,
    required super.position,
    required super.backNumber,
    required super.primaryStat,
  });

  factory PlayerSummaryModel.fromJson(Map<String, dynamic> json) {
    return PlayerSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      teamCode: json['teamCode'] as String,
      teamName: json['teamName'] as String,
      position: PlayerPosition.values.byName(json['position'] as String),
      backNumber: json['backNumber'] as int,
      primaryStat: json['primaryStat'] as String,
    );
  }
}
