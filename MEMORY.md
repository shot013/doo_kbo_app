# MEMORY.md

코드나 git 히스토리만으로는 알 수 없는 프로젝트 맥락(결정, 이유, 진행 상황)을
기록하는 문서입니다. 새 세션(팀원 또는 Claude Code)이 이 파일을 읽으면
"왜 지금 이 상태인지"를 빠르게 파악할 수 있어야 합니다.

작성 규칙:
- 시간순이 아니라 주제별로 정리합니다. 오래된/무효화된 항목은 삭제하거나 수정합니다.
- "무엇을 했다"가 아니라 "왜 그렇게 했다/하기로 했다"를 남깁니다.
- 코드를 읽으면 알 수 있는 내용(구조, 파일 위치)은 적지 않습니다 — `docs/ARCHITECTURE.md`, `CLAUDE.md` 참고.

## 결정 사항

- **`GET /game-previews/:gameId`는 없으면 404를 내려준다는 게 API 스펙에 명시돼 있어서**, 이걸 다른 실패와 구분되는 `NotFoundException`/`NotFoundFailure`(`core/error/`)로 별도 처리했다. 오늘 경기가 아직 스크래핑 전일 수 있는 등 404가 흔히 일어날 수 있는 정상적인 상황이라, `GamePreviewScreen`에서 무서운 일반 오류 메시지 대신 "아직 이 경기의 프리뷰 정보가 없습니다."라는 별도 문구를 보여준다.
- `GamePreview` 응답 JSON은 홈/원정 필드명이 완전히 규칙적이지 않다 — 대부분 `{side}Team{Field}` 패턴(`homeTeamEra`, `awayTeamBattingAverage` 등)인데 `recentForm`만 예외로 `homeRecentForm`/`awayRecentForm`(중간에 `Team`이 없음)이다. `TeamPreviewStatsModel.homeFromJson`/`awayFromJson`을 문자열 조합 대신 키를 하나하나 명시해서 이 불규칙성을 코드에 그대로 반영해뒀다 — 나중에 필드가 더 추가되더라도 접두사 패턴을 함부로 믿지 말 것.
- `GamePreview` API 응답에는 홈/원정 팀 코드·이름이 아예 없다(전력비교 수치뿐). 그래서 "오늘의 경기" 카드에서 프리뷰 화면으로 이동할 때 이미 들고 있던 `Game` 객체를 go_router의 `extra`로 통째로 넘긴다 — 이 앱에서 `extra`를 쓰는 첫 사례다. 이후 "최근 경기 결과" 카드도 `GameResult`를 넘기게 되면서, 라우터(`_gamePreviewMatchupFromExtra`)가 두 타입을 `GamePreviewScreen`의 `matchup` record(팀 코드/표시명 4개, nullable)로 정규화하도록 바뀌었다. `matchup`이 없어도(딥링크 등) 헤더 없이 통계만 보여준다.

- **`/players` 정렬은 서버가 한다.** 타자는 타율순, 투수는 평균자책순, 기록 없는 선수는 뒤로 정렬된 응답이 내려온다. 클라이언트(`PlayerListNotifier`)에 정렬 로직을 추가했다가 서버에서 이미 처리한다는 확인을 받고 되돌렸다. 같은 내용을 해당 코드 주석에도 남겨뒀다.

- **배포 빌드 번호는 CI가 Play Console 기준으로 정한다 (2026-11-06).** 예전에는 배포마다 `chore: bump build number` PR로 `pubspec.yaml`의 `+N`을 손으로 올렸다. 이제 `main` 배포 작업이 fastlane `next_build_number`로 Play Console 트랙들의 최대 versionCode를 조회해 +1로 빌드한다. CI 실행 번호(`github.run_number`)를 쓰는 방법도 있었지만, 워크플로 파일 이름이 바뀌면 번호가 1부터 다시 시작하는 문제가 있고, 번호가 15·16…처럼 차례대로 이어지는 쪽을 택했다. `pubspec.yaml`의 `+N`은 이제 로컬 빌드용이며, 이 값이 Play 최대값보다 크면 그 값을 쓴다. 버전 이름(`2.0.0`)은 여전히 손으로 올린다.

## 진행 중 / 예정

- **Jira 연동 — 보류.** 이슈 추적·작업 분류용으로 나중에 연동할 계획이지만 일정은 없다. 사용자가 다시 꺼내기 전에는 먼저 제안하거나 설정하지 않는다. 다시 시작할 때의 출발점: (1) Claude가 티켓을 읽고 브랜치명/PR 본문을 채울 수 있도록 Jira MCP 서버 연결, (2) 브랜치명 규칙(`CONTRIBUTING.md`, `.claude/hooks/guard-git.sh`)을 선택적 이슈 번호 대신 Jira 키 형식(예: `feat/KBO-123-...`)으로 변경. 현재의 브랜치 접두사(`feature`/`fix`/`chore`)와 Conventional Commits 타입이 Jira 이슈 유형(Story/Bug/Task)에 자연스럽게 대응된다.

## 알아두면 좋은 배경

_(아직 없음 — 백엔드 연동 일정, 외부 제약, 팀 합의 사항 등)_
