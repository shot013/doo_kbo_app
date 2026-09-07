# MEMORY.md

코드나 git 히스토리만으로는 알 수 없는 프로젝트 맥락(결정, 이유, 진행 상황)을
기록하는 문서입니다. 새 세션(팀원 또는 Claude Code)이 이 파일을 읽으면
"왜 지금 이 상태인지"를 빠르게 파악할 수 있어야 합니다.

작성 규칙:
- 시간순이 아니라 주제별로 정리합니다. 오래된/무효화된 항목은 삭제하거나 수정합니다.
- "무엇을 했다"가 아니라 "왜 그렇게 했다/하기로 했다"를 남깁니다.
- 코드를 읽으면 알 수 있는 내용(구조, 파일 위치)은 적지 않습니다 — `docs/ARCHITECTURE.md`, `CLAUDE.md` 참고.

## 결정 사항

- **행동 로그(`lib/features/action_log/`) 수집 방식**: `POST /action-logs`는 `logs` 배열을 한 번에 받는 벌크 API라서, 라우트가 바뀔 때마다(`ActionLogNavigatorObserver`) 매번 서버로 보내지 않고 모았다가 주기적으로(`flush()`) 일괄 전송한다. "N분 간격으로 전송"이라는 요구를 "N분마다 현재 라우트 하나만 샘플링"이 아니라 "N분마다 그동안 쌓인 이동 로그를 일괄 전송"으로 해석했다 — 짧게 여러 화면을 오간 사용자의 이동을 누락하지 않기 위함.
- flush 주기는 처음 5분으로 시작했다가 **1분으로 단축**했다 — 서버 스펙이 낮아서, 한 번에 쌓여서 전송되는 배치 크기를 줄여 요청당 부하를 가볍게 하는 쪽을 택함(요청 횟수는 늘지만 배치가 작아짐). 서버 스펙이 개선되면 다시 늘리는 것도 고려할 수 있음. 상수는 `action_log_providers.dart`의 `_flushInterval`.
- 처음엔 메모리 버퍼(`List`)로만 모았는데, flush 주기(1분)가 되기 전에 앱이 종료되면 그 로그가 통째로 사라지는 문제가 있어서 **`SharedPreferences`(`ActionLogLocalDataSource`)에 즉시 영속화**하는 방식으로 바꿨다. `recordNavigation()`이 호출되자마자 바로 저장하고, `flush()`는 저장된 걸 전부 읽어 전송한 뒤 **성공했을 때만** 지운다 — 실패하면 다음 flush 때 자동으로 재시도된다(이전엔 "실패 시 재시도 안 함"이었는데, 영속화 도입으로 자연스럽게 재시도 효과가 생겼다). `SharedPreferences` 인스턴스는 비동기로만 얻을 수 있어 `main()`에서 미리 얻어 `sharedPreferencesProvider`를 override하는 방식을 쓴다(`lib/core/storage/shared_preferences_provider.dart`) — 이 provider를 override하지 않고 쓰면 `UnimplementedError`가 던져지므로, `App()`을 pump하는 테스트는 전부 `SharedPreferences.setMockInitialValues({})` + override가 필요하다(`test/widget_test.dart` 참고).
- `userId` 필드는 API 스펙상 선택이고 아직 회원 기능이 없어서, `ActionLog` 엔티티에 아예 넣지 않았다(가상의 값을 채우지 않음). 회원 기능이 생기면 그때 필드를 추가한다.
- 라우트명은 기존 `_RouteLoggingObserver`/`_CrashlyticsBreadcrumbObserver`와 동일하게 `route.settings.name`(go_router가 채워주는 GoRoute의 `name`)을 쓰고, `params`는 `route.settings.arguments`(go_router가 pathParameters+queryParameters를 합쳐 넣어주는 `Map<String,String>`)를 그대로 쓴다 — 별도 파싱 없이 go_router의 `_buildPlatformAdapterPage` 동작에 의존하는 것이므로, go_router 메이저 업그레이드 시 이 부분이 깨지지 않는지 확인이 필요하다.

## 진행 중 / 예정

_(아직 없음 — 진행 중인 기능, 보류된 작업, 다음 단계 등을 기록)_

## 알아두면 좋은 배경

_(아직 없음 — 백엔드 연동 일정, 외부 제약, 팀 합의 사항 등)_
