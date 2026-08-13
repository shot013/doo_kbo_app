import '../../../../core/constants/player_position.dart';
import '../../domain/entities/player_detail.dart';
import '../../domain/entities/player_stat_line.dart';

final class PlayerDetailModel extends PlayerDetail {
  const PlayerDetailModel({
    required super.id,
    required super.name,
    required super.teamCode,
    required super.teamName,
    required super.position,
    required super.backNumber,
    required super.statLines,
  });

  factory PlayerDetailModel.fromJson(Map<String, dynamic> json) {
    final statLinesJson = json['statLines'] as List<dynamic>? ?? const [];
    return PlayerDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      teamCode: json['teamCode'] as String,
      teamName: json['teamName'] as String,
      position: PlayerPosition.values.byName(json['position'] as String),
      backNumber: json['backNumber'] as int,
      statLines: statLinesJson
          .map(
            (entry) => PlayerStatLine(
              label: (entry as Map<String, dynamic>)['label'] as String,
              value: entry['value'] as String,
            ),
          )
          .toList(),
    );
  }
}
