# 규칙 적용 순서

`docs/CLAUDE_CODE.md`가 "어떤 층이 무엇을 하는지"를 정리한 문서라면, 이 문서는
"실제 작업 중 어떤 시점에 어떤 순서로 발동되는지"를 정리한 문서입니다
(`doo_kbo_harness_kit`의 `docs/RULE_APPLICATION_ORDER.md.template`을 이 앱 구조에 맞게 적용).

doo_kbo_app은 단일 Flutter 클라이언트라 프론트/서버/DB/인프라가 별도 레이어로 나뉘어
있지 않습니다. 대신 feature 하나 안에서 `domain` → `data` → `presentation` 3계층이
반복되므로, 아래 순서는 **작업 단계(세션 시작 → 코딩 → 커밋 전 → PR → push → CI)** 기준입니다.

## 0. 세션 시작 시 — 항상, 자동

1. `CLAUDE.md` — 빌드/테스트/린트 명령, 아키텍처 요약, "Claude Code 작업 규칙" 섹션
2. `.claude/rules/architecture.md` — `domain`이 Flutter SDK/`data`/`presentation`을 import하지 않는 등 레이어링 강제 규칙
3. `.claude/rules/code-style.md` — `analysis_options.yaml` 린트 규칙
4. `.claude/rules/git-workflow.md` — 브랜치/커밋/PR 규칙

(킷의 `api-docs-sync.md`는 doo_kbo_app에는 없음 — 이 앱은 백엔드 API를 소비만 하고
정의하지 않아서 적용되지 않았습니다.)

## 1. 새 feature 작업 시작 시

- Claude가 "새 feature가 필요하다"고 판단하거나 `/add-feature`로 직접 호출하면 실행됩니다.
- `lib/features/example/`을 복사해 `domain` → `data` → `presentation` → `app_router.dart`
  라우트 등록 순으로 작성합니다 (`architecture.md`, `docs/ARCHITECTURE.md` 참고).

## 2. 코드 작성/수정 중 — 자동

- 파일을 수정할 때마다 `code-style.md` 규칙이 적용됩니다.
- `lib/`, `test/` 하위 `.dart` 파일을 저장하면 **format-dart hook**이 즉시 `dart format`을 실행합니다.
- `build/`, `.dart_tool/` 하위 파일을 수정하려 하면 **block-generated-edit hook**이 차단합니다.

## 3. 변경 완료 후, 커밋 전

1. Claude가 필요하다고 판단하거나 "리뷰해줘"라고 요청하면 **flutter-reviewer subagent**가
   레이어링 위반, `Result<T>` 에러 처리, Riverpod 사용 여부, feature 템플릿 이탈을 점검합니다.
2. `/verify` skill로 CI와 동일한 순서(`dart format` 체크 → `flutter analyze` → `flutter test`)를
   로컬에서 재현합니다.
3. UI/프론트엔드 변경은 가능하면 에뮬레이터(`flutter run -d emulator-5554`)에서 실제로 띄워
   스크린샷으로 확인한 뒤 커밋합니다 (doo_kbo_app 고유 규칙, `CLAUDE.md` "Claude Code 작업 규칙").

## 4. 커밋 / PR

- `git-workflow.md`의 브랜치명·커밋 메시지(Conventional Commits) 규칙 적용
- PR은 항상 `main`이 아니라 **`develop`을 base로** 합니다 (doo_kbo_app 고유 규칙).
- `gh` CLI를 쓸 수 없는 환경이므로, `.github/PULL_REQUEST_TEMPLATE.md` 형식으로 제목/본문을
  URL-인코딩해 채운 compare 링크(`https://github.com/shot013/doo_kbo_app/compare/develop...{branch}?expand=1`)를
  직접 만들어 제시합니다.
- PR 하나 = 리뷰 가능한 단위 하나, 최소 1명 승인 필요, squash merge.
- 커밋/푸시/PR 생성은 사용자가 명시적으로 요청했을 때만 수행합니다.

## 4.5 push 시 — 로컬, 활성화되어 있으면 자동

- `.githooks/pre-push`가 push 직전 포맷/`flutter analyze`/`flutter test`를 다시 검증합니다.
- 활성화(`git config core.hooksPath .githooks`)는 git 설정 변경이라 Claude가 직접 실행하지
  않고, 대신 `.githooks/pre-push`를 `.git/hooks/pre-push`로 복사만 해둡니다. 훅이 있어도
  3단계의 로컬 검증은 그대로 직접 수행합니다.

## 5. PR 병합 전 — 원격, 자동 (`.github/workflows/ci.yaml`)

3~4.5단계에서 로컬로 미리 재현한 것과 **동일한 순서**로 원격에서 다시 실행됩니다:

```
dart format 체크 → flutter analyze → flutter test
```

세 단계 모두 통과해야 병합 가능합니다.

## 이 순서와 무관하게, 계속 — `MEMORY.md` / `ERRORS.md`

특정 단계에 묶여 있지 않고 작업 전반에 걸쳐 있습니다. `doo_kbo_harness_kit`의 문서 관례를
그대로 채택했습니다.

- 세션 시작 시 읽어서 "왜 지금 이 상태인지" 파악
- 주요 결정을 내리거나 까다로운 에러를 해결하면 그때그때 기록
