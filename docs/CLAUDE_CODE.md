# Claude Code 작업 방식

이 저장소를 Claude Code로 열면 `.claude/`에 있는 설정을 자동으로 읽어들입니다.
새로 합류한 팀원이 아래 규칙들을 따로 외우거나 신경 쓸 필요는 없습니다 —
대부분은 사람이 개입하지 않아도 Claude Code가 알아서 지키거나 실행합니다.
이 문서는 "지금 뭐가 자동으로 돌아가고 있는지" 파악하기 위한 참고용입니다.
실제 작업 중 이 규칙들이 어느 시점에 어떤 순서로 발동되는지는
[`docs/RULE_APPLICATION_ORDER.md`](RULE_APPLICATION_ORDER.md) 참고.

구조는 `doo_kbo_harness_kit`의 `docs/CLAUDE_CODE.md.template`을 따릅니다. 키트는 저장소 루트의
`doo_kbo_harness_kit/`에 clone해 두며(`.gitignore` 대상), 처음 받는 방법은 `CONTRIBUTING.md` 참고.

## 한눈에 보기

| 층 | 위치 | 언제 적용되나 | 상시 토큰 비용 |
|---|---|---|---|
| 키트 공통 규칙 | `doo_kbo_harness_kit/KIT_RULES.md` | 항상, **가장 먼저** (`CLAUDE.md` 맨 위에서 import) | 전액 선불 |
| 규칙 | `CLAUDE.md`, `.claude/rules/*.md` | 항상 (매 세션·매 턴 자동 로드) | **전액 선불** |
| Skills | `.claude/skills/*/SKILL.md` | 관련 작업이면 자동, 또는 `/add-feature` `/verify`로 호출 | `description`만 |
| Hooks | `.claude/settings.json`, `.claude/hooks/*.sh` | 완전 자동 (도구 호출 이벤트) | **0** |
| Subagent | `.claude/agents/flutter-reviewer.md` | 여러 파일에 걸친 변경이면 위임, 또는 "리뷰해줘"로 요청 | `description`만 |

## 어디에 둘 것인가 / 규칙 수정 시점

규칙 배치 기준(훅 → 스킬 → 서브에이전트 → 규칙), 규칙 파일에 두면 안 되는 것, 규칙을 작업 도중에 고치지 않는 이유는
모든 키트 프로젝트에 공통이라 키트에만 있습니다: `doo_kbo_harness_kit/KIT_RULES.md`(Claude가 따르는 원본)와
`doo_kbo_harness_kit/docs/CLAUDE_CODE.md.template`(사람용 설명). 이 앱에서의 예: `/players` 정렬 결정은 규칙이 아니라
`player_providers.dart` 주석에 둠.

## 키트 공통 규칙 — `doo_kbo_harness_kit/KIT_RULES.md`

`CLAUDE.md` 맨 위의 `@doo_kbo_harness_kit/KIT_RULES.md`로 다른 모든 규칙보다 먼저 로드됩니다. 이 앱의 규칙은 그것을
구체화만 하고, 다르게 하는 항목은 `CLAUDE.md`의 "키트와 다른 점"에 적습니다. 키트가 없으면 import가 조용히 건너뛰어지므로
**check-kit hook**(SessionStart)이 경고를 띄웁니다.

## 규칙 — `CLAUDE.md`, `.claude/rules/`

`.claude/rules/*.md`는 Claude Code가 자동으로 로드합니다. 키트 템플릿은 `CLAUDE.md`에서 `@`로 import하지만,
이 저장소는 자동 로드가 확인되어(세션 컨텍스트에 표시됨) 중복 로드를 피하려고 import하지 않습니다.
실제로 뭐가 로드됐는지는 세션에서 `/context`로 확인할 수 있습니다.

- `CLAUDE.md` — 키트 규칙 import, 키트와 다른 점, 빌드/테스트/린트 명령어, 아키텍처 요약
- `.claude/rules/architecture.md` — 레이어링, 에러 흐름, Riverpod, 색상, `extra` 직렬화 등
- `.claude/rules/code-style.md` — `analysis_options.yaml` 린트 규칙을 코드 작성 시점부터 준수
- `.claude/rules/git-workflow.md` — 이 앱 고유의, 판단이 필요한 git/PR 규칙만 (공통 git 규칙은 키트, 형식 검사는 훅)

## Skills — `.claude/skills/`

- **add-feature** — `lib/features/example/`을 복사해 새 feature를 만드는 절차 (domain → data → presentation → 라우트 등록)
- **verify** — CI와 동일하게 `dart format` → `flutter analyze` → `flutter test`를 실행하고, UI 변경이면 에뮬레이터로 확인하는 절차

## Hooks — `.claude/settings.json`, `.claude/hooks/`

팀 전체가 공유하는 `.claude/settings.json`에 등록되어 있어 저장소를 받는 모든 사람에게 동일하게 적용됩니다.

- **키트 확인** (`check-kit.sh`, SessionStart) — `doo_kbo_harness_kit/KIT_RULES.md`가 없으면 경고를 출력해 Claude가 사용자에게 알리게 합니다. 정상이면 출력이 없습니다.
- **자동 포맷** (`format-dart.sh`) — `.dart` 파일을 Claude Code가 수정하면 그 즉시 `dart format`이 실행됩니다.
  `dart`가 PATH에 없는 비대화형 셸에서도 동작하도록 `~/.bashrc` 등을 재로드합니다.
- **생성 파일 보호** (`block-generated-edit.sh`) — `build/`, `.dart_tool/` 하위 파일 수정 시도를 차단합니다.
- **git 규약** (`guard-git.sh`) — Bash/PowerShell 명령에서 `main`/`master` 직접 push, 규약에 맞지 않는 브랜치명,
  Conventional Commits가 아닌 커밋 메시지, `git config` 변경(조회는 허용)을 차단합니다. 파싱이 불확실하면 통과시킵니다(fail-open).

## Subagent — `.claude/agents/flutter-reviewer.md`

여러 파일에 걸친 `lib/` 변경이나 새 feature 추가 후, 또는 "리뷰해줘", "PR 올리기 전에 체크해줘"라고 요청하면
리뷰를 위임합니다. 레이어링 위반, `Result<T>` 에러 처리, Riverpod 사용, feature 템플릿 이탈 등 린터가 못 잡는 것을 봅니다.
`flutter analyze`/`flutter test` 자체는 실행하지 않습니다 (verify 스킬의 역할).

## MEMORY.md / ERRORS.md

코드나 git 히스토리만으로는 알 수 없는 맥락을 기록하는 문서입니다. 로드되지 않고, 필요할 때 해당 부분만 읽습니다.

- `MEMORY.md` — 결정 사항, 진행 중인 작업, 배경 맥락
- `ERRORS.md` — 재발 가능한 에러의 증상/원인/해결

## 무언가 바꾸고 싶다면

전부 일반 파일이라 직접 수정해도 되고, Claude Code에게 "이런 훅을 추가해줘" /
"이 스킬을 이렇게 바꿔줘"처럼 자연어로 요청해도 됩니다. 어느 층에 둘지는 키트 공통 규칙을 따르고,
모든 프로젝트에 해당하는 변경이면 이 저장소가 아니라 `doo_kbo_harness_kit`에 반영합니다.
