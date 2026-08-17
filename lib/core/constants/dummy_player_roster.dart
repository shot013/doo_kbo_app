import 'kbo_teams.dart';
import 'player_position.dart';

/// 백엔드에 선수/팀 API가 아직 없는 스캐폴딩 단계에서 쓰는 더미 선수 시드입니다.
/// `player`, `team` feature의 더미 datasource가 공통으로 이 목록을 참조해서
/// 같은 선수를 팀 로스터에서 봐도, 선수 탭 목록에서 봐도 동일한 id로 연결되게 합니다.
/// 실제 `/players`, `/teams/:code` API가 준비되면 두 feature 모두 이 파일 참조를 지웁니다.
final class DummyPlayerSeed {
  const DummyPlayerSeed({
    required this.id,
    required this.name,
    required this.teamCode,
    required this.teamName,
    required this.position,
    required this.backNumber,
    required this.primaryStat,
    required this.statLines,
  });

  final String id;
  final String name;
  final String teamCode;
  final String teamName;
  final PlayerPosition position;
  final int backNumber;
  final String primaryStat;
  final List<(String label, String value)> statLines;
}

const _positionLabel = {
  PlayerPosition.pitcher: '투',
  PlayerPosition.catcher: '포',
  PlayerPosition.infielder: '내',
  PlayerPosition.outfielder: '외',
};

final List<DummyPlayerSeed> kDummyPlayerRoster = [
  for (var ti = 0; ti < kKboTeams.length; ti++)
    for (final position in PlayerPosition.values)
      for (var slot = 1; slot <= 2; slot++)
        _buildSeed(
          team: kKboTeams[ti],
          teamIndex: ti,
          position: position,
          slot: slot,
        ),
];

DummyPlayerSeed _buildSeed({
  required KboTeam team,
  required int teamIndex,
  required PlayerPosition position,
  required int slot,
}) {
  final label = _positionLabel[position]!;
  final id = '${team.code}-$label$slot';
  final name = '선수 $label$slot';
  final backNumber = teamIndex * 8 + slot;

  if (position == PlayerPosition.pitcher) {
    final era = (2.80 + teamIndex * 0.15 + slot * 0.30).toStringAsFixed(2);
    final wins = 4 + (teamIndex + slot) % 8;
    final losses = 3 + (teamIndex + slot * 2) % 6;
    final saves = position == PlayerPosition.pitcher && slot == 2
        ? 10 + teamIndex
        : 0;
    final games = 20 + teamIndex + slot * 3;
    final inningsPitched = 90 + teamIndex * 4 + slot * 10;
    final strikeouts = 60 + teamIndex * 3 + slot * 8;
    return DummyPlayerSeed(
      id: id,
      name: name,
      teamCode: team.code,
      teamName: team.name,
      position: position,
      backNumber: backNumber,
      primaryStat: '평균자책 $era',
      statLines: [
        ('평균자책', era),
        ('경기', '$games'),
        ('승', '$wins'),
        ('패', '$losses'),
        ('세이브', '$saves'),
        ('이닝', '$inningsPitched'),
        ('탈삼진', '$strikeouts'),
      ],
    );
  }

  final avg = (0.230 + teamIndex * 0.010 + slot * 0.020);
  final avgLabel = '.${(avg * 1000).round()}';
  final games = 90 + teamIndex + slot * 4;
  final rbi = 30 + teamIndex * 3 + slot * 6;
  final homeRuns = (teamIndex + slot) % 20;
  final stolenBases = (teamIndex * 2 + slot) % 15;
  final obp = '.${((avg + 0.07) * 1000).round()}';
  return DummyPlayerSeed(
    id: id,
    name: name,
    teamCode: team.code,
    teamName: team.name,
    position: position,
    backNumber: backNumber,
    primaryStat: '타율 $avgLabel',
    statLines: [
      ('타율', avgLabel),
      ('경기', '$games'),
      ('타점', '$rbi'),
      ('홈런', '$homeRuns'),
      ('도루', '$stolenBases'),
      ('출루율', obp),
    ],
  );
}
