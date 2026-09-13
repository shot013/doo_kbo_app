/// 팀 정식명에서 표시용 짧은 팀명을 뽑아낸다 (예: "LG 트윈스" -> "LG").
/// "kt wiz"처럼 구단이 의도적으로 소문자로 표기하는 브랜드도 있어, 다른 팀과
/// 시각적으로 통일되도록 toUpperCase()를 적용한다 (한글은 대소문자 개념이
/// 없어 영향 없음).
String shortTeamName(String teamName) =>
    teamName.split(' ').first.toUpperCase();
