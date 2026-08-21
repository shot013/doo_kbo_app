import '../../domain/entities/best_performer.dart';

final class BestPerformerModel extends BestPerformer {
  const BestPerformerModel({
    required super.playerName,
    required super.teamCode,
    required super.atBats,
    required super.hits,
    required super.rbi,
    required super.runs,
    required super.line,
  });

  factory BestPerformerModel.fromJson(Map<String, dynamic> json) {
    return BestPerformerModel(
      playerName: json['playerName'] as String,
      teamCode: json['teamCode'] as String,
      atBats: json['atBats'] as int,
      hits: json['hits'] as int,
      rbi: json['rbi'] as int,
      runs: json['runs'] as int,
      line: json['line'] as String,
    );
  }
}
