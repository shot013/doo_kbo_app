/// PlayerSummary(선수 요약) 응답 JSON을 만드는 테스트 픽스처 헬퍼.
///
/// team_fixtures.dart의 teamSummaryJson()과 같은 이유로 존재한다 — 이 모양이
/// player_summary_model_test.dart, player_remote_data_source_test.dart,
/// player_detail_model_test.dart 세 파일에 중복돼 있었다. PlayerDetailModel도
/// 같은 기본 필드(id/name/teamCode/teamName/position/backNumber)를 쓰므로,
/// primaryStat이 필요 없는 곳에서는 그냥 무시된다.
Map<String, dynamic> playerSummaryJson({
  String id = '54529',
  String name = '레이예스',
  String teamCode = 'LT',
  String teamName = '롯데 자이언츠',
  String position = 'outfielder',
  int backNumber = 29,
  String primaryStat = '타율 0.359',
}) {
  return {
    'id': id,
    'name': name,
    'teamCode': teamCode,
    'teamName': teamName,
    'position': position,
    'backNumber': backNumber,
    'primaryStat': primaryStat,
  };
}
