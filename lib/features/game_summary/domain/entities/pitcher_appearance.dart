import 'package:equatable/equatable.dart';

import '../../../game/domain/entities/pitcher_decision_type.dart';
import 'inning_half.dart';

enum PitcherRole { starter, reliever }

/// 구원 투수가 마운드에 오른 시점.
class PitcherEntry extends Equatable {
  const PitcherEntry({
    required this.inning,
    required this.half,
    required this.outs,
    required this.runners,
    required this.atInningStart,
  });

  final int inning;
  final InningHalf? half;

  /// 등판할 때의 아웃 수 (0~2). 출처에 없으면 null (KAN-8 v2).
  final int? outs;

  /// 주자가 있는 루 번호. 빈 목록이면 주자 없음. 출처에 주자 정보가 없을
  /// 때(API의 null)도 빈 목록으로 받는다. 화면에는 둘 다 `6회말 1사`로 같다.
  final List<int> runners;

  /// 이닝 시작과 함께 올라왔는지.
  final bool atInningStart;

  /// 예: `8회말 시작`, `6회말 1사 1루`, `7회초 무사 1·2루`, `9회초 2사 만루`.
  /// 아웃 수를 모르면 `6회말 등판`.
  String get label {
    final inningText = inningLabel(inning, half);
    if (atInningStart) return '$inningText 시작';
    final outs = this.outs;
    if (outs == null) return '$inningText 등판';
    final outsText = outs == 0 ? '무사' : '$outs사';
    final runnersText = _runnersText;
    return runnersText == null
        ? '$inningText $outsText'
        : '$inningText $outsText $runnersText';
  }

  String? get _runnersText {
    if (runners.isEmpty) return null;
    final bases = runners.toSet().toList()..sort();
    if (bases.length >= 3) return '만루';
    return '${bases.join('·')}루';
  }

  @override
  List<Object?> get props => [inning, half, outs, runners, atInningStart];
}

/// 투수 한 명의 등판 기록. 팀별로 등판 순서대로 온다.
class PitcherAppearance extends Equatable {
  const PitcherAppearance({
    required this.playerId,
    required this.playerName,
    required this.role,
    required this.entry,
    required this.outs,
    required this.pitchCount,
    required this.runs,
    required this.decision,
  });

  /// 선수 상세(`/players/{id}`)와 같은 id. 매칭되지 않으면 null.
  final int? playerId;
  final String playerName;
  final PitcherRole role;

  /// 선발은 null. 문자중계가 아직 없으면 구원 투수도 null (KAN-8 v2).
  final PitcherEntry? entry;

  /// 잡은 아웃 수 (16 = 5.1이닝).
  final int outs;

  /// 출처에 없으면 null.
  final int? pitchCount;
  final int? runs;

  /// 승·패·세·홀이 아니면 null.
  final PitcherDecisionType? decision;

  bool get isStarter => role == PitcherRole.starter;

  /// 교체 시점 칸. 선발은 `선발 등판`, 시점을 모르는 구원 투수는 `-`.
  String get entryLabel {
    if (isStarter) return '선발 등판';
    return entry?.label ?? '-';
  }

  /// 교체 시점을 강조할지. 시점을 아는 구원 투수만 강조한다.
  bool get highlightsEntry => !isStarter && entry != null;

  /// 앱 기록 표기와 같은 `5.1`, `5.2` 형식.
  String get inningsPitchedLabel => '${outs ~/ 3}.${outs % 3}';

  String get pitchCountLabel => pitchCount?.toString() ?? '-';

  String get runsLabel => runs?.toString() ?? '-';

  /// 결정 배지 글자. 결정이 없으면 null.
  String? get decisionLabel => switch (decision) {
    PitcherDecisionType.win => '승',
    PitcherDecisionType.loss => '패',
    PitcherDecisionType.save => '세',
    PitcherDecisionType.hold => '홀',
    null => null,
  };

  @override
  List<Object?> get props => [
    playerId,
    playerName,
    role,
    entry,
    outs,
    pitchCount,
    runs,
    decision,
  ];
}
