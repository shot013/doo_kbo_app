import '../../domain/entities/pitcher_appearance.dart';
import 'summary_json_codec.dart';

final class PitcherEntryModel extends PitcherEntry {
  const PitcherEntryModel({
    required super.inning,
    required super.half,
    required super.outs,
    required super.runners,
    required super.atInningStart,
  });

  factory PitcherEntryModel.fromJson(Map<String, dynamic> json) {
    return PitcherEntryModel(
      inning: json['inning'] as int,
      half: inningHalfFromJson(json['half']),
      outs: json['outs'] as int?,
      runners: (json['runners'] as List<dynamic>? ?? const [])
          .map((base) => base as int)
          .toList(),
      atInningStart: json['atInningStart'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'inning': inning,
    'half': inningHalfToJson(half),
    'outs': outs,
    'runners': runners,
    'atInningStart': atInningStart,
  };
}

final class PitcherAppearanceModel extends PitcherAppearance {
  const PitcherAppearanceModel({
    required super.playerId,
    required super.playerName,
    required super.role,
    required super.entry,
    required super.outs,
    required super.pitchCount,
    required super.runs,
    required super.decision,
  });

  factory PitcherAppearanceModel.fromJson(Map<String, dynamic> json) {
    final entryJson = json['entry'] as Map<String, dynamic>?;
    return PitcherAppearanceModel(
      playerId: json['playerId'] as int?,
      playerName: json['playerName'] as String,
      role: pitcherRoleFromJson(json['role'], hasEntry: entryJson != null),
      entry: entryJson == null ? null : PitcherEntryModel.fromJson(entryJson),
      outs: json['outs'] as int,
      pitchCount: json['pitchCount'] as int?,
      runs: json['runs'] as int?,
      decision: decisionFromJson(json['decision']),
    );
  }

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'playerName': playerName,
    'role': pitcherRoleToJson(role),
    'entry': (entry as PitcherEntryModel?)?.toJson(),
    'outs': outs,
    'pitchCount': pitchCount,
    'runs': runs,
    'decision': decisionToJson(decision),
  };
}
