# Git 워크플로 규칙 (항상 적용)

- 이 저장소에는 push 전 포맷/analyze/test를 자동 실행하는 `pre-push` 훅이 `.githooks/`에 있다. 활성화는 `git config core.hooksPath ...`가 필요한데, 이는 git 설정을 변경하는 행위이므로 Claude가 직접 실행하지 않는다 — 대신 `.githooks/pre-push`를 `.git/hooks/pre-push`로 복사(`cp`)해 파일만 배치하는 방식으로 로컬에 적용한다. 훅이 있어도 커밋 전 `dart format`/`flutter analyze`/`flutter test`를 직접 실행해 확인하는 절차는 그대로 유지한다(훅은 안전망이지 대체가 아님).
- `main`에 직접 push하지 않는다. 항상 PR을 통해 병합한다.
- 브랜치명: `feature/{issue번호}-{짧은-설명}`, `fix/{issue번호}-{짧은-설명}`, `chore/{짧은-설명}`, `release/{version}`.
- 커밋 메시지는 Conventional Commits 형식을 따른다: `<type>(<scope>): <subject>` — `type`은 `feat`/`fix`/`docs`/`style`/`refactor`/`test`/`chore`/`perf` 중 하나, `subject`는 명령형·소문자 시작·마침표 없음.
- 하나의 PR에는 하나의 리뷰 가능한 단위만 담는다. 여러 기능을 한 PR에 묶지 않는다.
- 커밋을 생성하기 전에 `flutter analyze`와 `flutter test`가 로컬에서 통과하는지 확인한다.
