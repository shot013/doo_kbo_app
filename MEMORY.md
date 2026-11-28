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

- **CI의 Flutter 버전을 3.47.9로 고정했다 (2026-11-27).** `channel: stable`만 두었더니 stable이 3.50으로 올라가면서 `material.dart` import에 deprecation info가 대량으로 나와 `flutter analyze`가 실패했다(코드 변경 없이). 버전을 올릴 때는 로컬에서 analyze를 먼저 통과시킨 뒤 `ci.yaml`의 `flutter-version`을 함께 바꾼다. 로컬 SDK가 더 새 버전이면 `flutter pub get`이 `pubspec.lock`을 다시 풀 수 있으니, 의도하지 않은 lock 변경은 커밋하지 않는다.

- **나의 직관 기록은 기기(SharedPreferences)에만, 나중에 서버 DB로 옮길 수 있는 형식으로 저장한다 (2026-11-28, KAN-28).** 로그인·서버 저장은 범위가 커서 뺐고, 사용 규모는 Analytics `attendance_check`/`attendance_uncheck`로 본 뒤 서버 이전 시점을 정한다. 기록은 한 사람당 수백 건 수준이라 sqflite/Drift 같은 로컬 DB 대신 키 하나(`attendance_records`)의 JSON을 택했다(새 네이티브 의존성·lock 변동 없음). 형식은 정책서 6.3을 따른다: 저장소 전체에 `schemaVersion`(앱 시작 때 n→n+1 차례로 변환 후 재저장, 앱보다 새 버전이면 덮어쓰지 않음), 기록 id는 앱이 만든 UUID v4, 해제·삭제는 `deletedAt` 소프트 삭제라 다시 체크하면 같은 id를 되살린다, `updatedAt`은 사용자 변경 때만 바뀐다. 점수·상태는 표시용 캐시라 DB로 옮기지 않아도 된다. 형식을 바꿀 때는 `attendance_storage.dart`의 `currentSchemaVersion`을 올리고 변환을 추가한다.

## 진행 중 / 예정

- **Jira 사용 중 (2026-11 시작).** 기능은 Jira 프로젝트 KAN의 에픽 → 스토리 → 하위 작업으로 관리하고, 정책서는 Confluence에 있다(경기 요약 KAN-4/KAN-5, 나의 직관 KAN-27/KAN-28). PR 본문의 "관련 이슈"에 Jira 키를 적는다. 브랜치명을 Jira 키 형식(예: `feat/KAN-28-...`)으로 바꾸는 일은 아직 하지 않았다(`CONTRIBUTING.md`, `.claude/hooks/guard-git.sh`).

## 알아두면 좋은 배경

_(아직 없음 — 백엔드 연동 일정, 외부 제약, 팀 합의 사항 등)_
