# 기여 가이드

6인 이상이 함께 작업하는 프로젝트이므로, 아래 규칙은 리뷰 비용을 줄이고
충돌을 예방하기 위한 최소 합의입니다.

## 브랜치 전략

- `main` — 항상 배포 가능한 상태. 직접 push 금지, PR로만 병합.
- `develop` — 다음 배포를 준비하는 통합 브랜치. 기능 브랜치는 여기서 분기.
- 작업 브랜치 — `{type}/{짧은-설명}`. 이슈가 있으면 번호를 앞에 붙입니다(`feat/42-team-standings`).
  `type`은 커밋 타입과 같은 어휘를 씁니다:
  - `feat`(또는 `feature`) — 새 기능. 예: `feat/favorite-team`
  - `fix`, `hotfix` — 버그 수정
  - `refactor`, `test`, `docs`, `perf`, `style` — 각 커밋 타입과 같은 성격의 변경
  - `chore` — 빌드/설정/의존성 등 코드 동작에 영향 없는 변경. 예: `chore/bump-version-2.0.0+14`
  - `ci` — CI/배포 파이프라인 변경
- `release/{version}` — 배포 준비 (버전 고정, 최종 QA)

Claude Code에서는 `.claude/hooks/guard-git.sh`가 이 브랜치명 규약, 커밋 메시지 형식,
`main` 직접 push 금지를 자동으로 강제합니다.

기능 브랜치는 완료 후 삭제합니다. `develop`이 오래 밀리지 않도록 주기적으로
`main`에 병합하고 새로 분기하세요.

## 커밋 메시지 (Conventional Commits)

```
<type>(<scope>): <subject>

<body (선택)>
```

- `type`: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`
- `scope`: 영향받는 feature/모듈명 (예: `example`, `router`, `core`)
- `subject`: 명령형, 소문자 시작, 마침표 없이

예시:
```
feat(example): add team standings screen
fix(network): retry dio request on timeout
chore: bump go_router to 17.3.0
```

## PR 규칙

- PR의 base는 항상 `develop`입니다. `main`은 `develop`/`release`에서만 병합받습니다.
- PR 하나 = 리뷰 가능한 단위 하나. 여러 기능을 한 PR에 묶지 않습니다.
- PR 설명에는 변경 이유와 테스트 방법을 반드시 포함합니다 (템플릿 참고).
- 최소 1명 이상의 승인 후 병합합니다.
- 병합 전 `flutter analyze`와 `flutter test`가 로컬에서 통과해야 합니다.
  (CI에서도 동일하게 실행됩니다.)
- Squash merge를 기본으로 사용합니다.

## Claude Code 하네스 키트

이 저장소의 Claude Code 규칙은 공용 키트 [doo_kbo_harness_kit](https://github.com/shot013/doo_kbo_harness_kit)의
공통 규칙(`KIT_RULES.md`)을 먼저 적용하고, 그 위에 이 앱의 규칙(`CLAUDE.md`, `.claude/rules/*`)을 얹는 구조입니다.
키트는 저장소에 커밋하지 않으므로(`.gitignore`) 새로 clone했다면 저장소 루트에서 한 번 받아두세요.

```
git clone https://github.com/shot013/doo_kbo_harness_kit.git
```

키트가 없으면 Claude Code 세션 시작 시 경고가 뜹니다. 키트 공통 규칙이 바뀌면 `doo_kbo_harness_kit/`에서 `git pull`만 하면
되고, 이 저장소의 파일은 고칠 필요가 없습니다. 모든 프로젝트에 해당하는 규칙 변경은 이 저장소가 아니라 키트에 PR로 반영합니다.

## 로컬 훅 설정

push하기 전에 CI와 동일한 검증(포맷 체크 → `flutter analyze` → `flutter test`)을
자동으로 돌리는 `pre-push` 훅이 `.githooks/`에 준비되어 있습니다. 저장소를 새로
clone했다면 아래 중 하나로 한 번만 활성화하세요.

```
# 방법 1: 이 저장소에서만 훅 경로를 .githooks로 지정
git config core.hooksPath .githooks

# 방법 2: .git/hooks에 직접 복사
cp .githooks/pre-push .git/hooks/pre-push && chmod +x .git/hooks/pre-push
```

Claude Code는 `git config`를 실행하지 않으므로(훅으로 차단됨) 방법 2만 사용합니다.

검증이 실패하면 push가 막힙니다. 급하게 우회해야 하면 `git push --no-verify`를
쓰되, 왜 우회했는지 커밋/PR에 남겨두세요.

## 코드 작성 규칙

- 새 기능은 `lib/features/example/`의 폴더 구조를 그대로 복사해서 시작하세요.
  (`domain` → `data` → `presentation` 계층 분리, 자세한 내용은
  [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) 참고)
- `domain` 레이어는 Flutter SDK와 `data`/`presentation`을 import하지 않습니다.
- 상태 관리는 Riverpod (`Notifier`/`AsyncNotifier`)만 사용하고, 다른 상태관리
  라이브러리를 섞지 않습니다.
- `flutter analyze`에서 경고가 나오지 않는 것을 기본 목표로 합니다.
