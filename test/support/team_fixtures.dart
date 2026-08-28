/// TeamSummary(팀 요약) 응답 JSON을 만드는 테스트 픽스처 헬퍼.
///
/// 이 모양을 쓰는 테스트가 여러 파일에 흩어져 있으면, 필드명이 바뀔 때
/// 일부만 고치고 일부는 놓치기 쉽다 (실제로 한 번 그렇게 깨진 적 있다).
/// JSON 키를 이 함수 한 곳에만 두고, 테스트들은 이 함수를 호출만 하게
/// 만들어서 그 문제를 구조적으로 막는다.
Map<String, dynamic> teamSummaryJson({
  String teamCode = 'KT',
  String teamName = 'kt wiz',
  int rank = 1,
  int wins = 64,
  int losses = 41,
  int draws = 3,
  String winRate = '0.610',
  String? gamesBehind = '0.0',
  String battingAverage = '0.279',
  String era = '5.65',
  int runsScored = 598,
  int runsAllowed = 506,
  List<String>? recentForm = const ['L', 'L', 'W', 'D', 'W'],
}) {
  return {
    'teamCode': teamCode,
    'teamName': teamName,
    'rank': rank,
    'wins': wins,
    'losses': losses,
    'draws': draws,
    'winRate': winRate,
    'gamesBehind': gamesBehind,
    'battingAverage': battingAverage,
    'era': era,
    'runsScored': runsScored,
    'runsAllowed': runsAllowed,
    'recentForm': ?recentForm,
  };
}
