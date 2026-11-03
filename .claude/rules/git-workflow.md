# Git 워크플로 규칙 (항상 적용)

PR base·PR 단위·커밋 전 검증은 키트 공통 규칙, 형식 검사는 `guard-git` 훅이 맡는다. 이 앱에만 해당하는, 판단이 필요한 것만 둔다 (전체 규약은 `CONTRIBUTING.md`):

- 커밋/push/PR 생성은 사용자가 명시적으로 요청했을 때만 한다.
- 새로운 독립 변경은 `develop`에서 새 브랜치로 시작한다. 머지 안 된 PR 브랜치가 있으면 같은 성격의 변경은 이어서 쓰고, 성격이 다르면 분리한다.
- 요청과 무관한 사용자의 미커밋 변경은 건드리지 않는다. `git stash push -- <파일들>`로 분리해 작업하고, 끝나면 원래 브랜치에서 stash pop으로 되돌린다.
- `gh`가 없으므로 PR 요청마다 `https://github.com/shot013/doo_kbo_app/compare/develop...{branch}?expand=1` 링크를 반드시 준다(`/pull/new/`는 base가 `main`이 되므로 금지). `&title=`/`&body=`를 URL-인코딩해 붙이고, 본문은 `.github/PULL_REQUEST_TEMPLATE.md` 형식(체크박스는 실제 수행 항목만 `[x]`)으로 링크와 채팅 양쪽에 제시한다. 작성 전 `git log origin/develop..{branch} --oneline`으로 실제 diff를 확인한다.
