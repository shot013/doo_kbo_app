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
- `GamePreview` API 응답에는 홈/원정 팀 코드·이름이 아예 없다(전력비교 수치뿐). 그래서 "오늘의 경기" 카드에서 프리뷰 화면으로 이동할 때 이미 들고 있던 `Game` 객체를 go_router의 `extra`로 통째로 넘긴다(`GamePreviewScreen(gameId:, game:)`, `game`은 nullable) — 이 앱에서 `extra`를 쓰는 첫 사례다. `game`이 없어도(딥링크 등) 헤더 없이 통계만 보여주도록 만들어뒀다.

## 진행 중 / 예정

_(아직 없음 — 진행 중인 기능, 보류된 작업, 다음 단계 등을 기록)_

## 알아두면 좋은 배경

_(아직 없음 — 백엔드 연동 일정, 외부 제약, 팀 합의 사항 등)_
