#!/usr/bin/env bash
# PreToolUse hook (Bash|PowerShell): enforce the deterministic git conventions of doo_kbo_app.
# Adapted from doo_kbo_harness_kit/.claude/hooks/guard-git.sh.template.
#
# Why a hook and not a prompt rule: these checks need no judgement, so paying for them
# as always-loaded prompt text on every turn is waste. A hook costs zero tokens and,
# unlike a rule, is enforced 100% of the time.
#
# Enforced here:  no direct push to main/master, branch naming, Conventional Commits,
#                 no `git config` writes.
# Left to .claude/rules/git-workflow.md: anything needing judgement.
#
# Parses hook stdin JSON with shell expansion only (no jq/python dependency) for
# portability. Fails open: anything it cannot parse confidently is allowed through.

input=$(cat)

case "$input" in
  *'"command"'*) ;;
  *) exit 0 ;;
esac

# Isolate tool_input.command: drop everything up to the key, then cut at the next
# sibling key. Backslashes are then stripped so the JSON-escaped \" around a commit
# message reads as a plain quote. git commands do not meaningfully contain backslashes.
cmd=${input#*'"command"'}
cmd=${cmd#*'"'}
cmd=${cmd%%'","description":'*}
cmd=${cmd%%'","timeout":'*}
cmd=${cmd%%'","run_in_background":'*}
cmd=${cmd%'"}}'*}
cmd=$(printf '%s' "$cmd" | tr -d '\134' | tr '\n' ' ')

case "$cmd" in
  *git*) ;;
  *) exit 0 ;;
esac

# 명령 판정(push/브랜치/config)은 따옴표 안의 문자열을 지운 버전으로 한다. 그러지 않으면
# 커밋 메시지 본문에 'git config'나 'main' 같은 단어가 들어 있을 때 명령으로 오인한다.
# 커밋 메시지 자체를 검사할 때만 원문($cmd)을 쓴다.
bare=$(printf '%s' "$cmd" | sed -E "s/\"[^\"]*\"//g; s/'[^']*'//g")

deny() {
  # JSON 문자열에 넣기 전에 따옴표/역슬래시를 제거한다 (이스케이프보다 단순하고 안전).
  escaped=$(printf '%s' "$1" | tr -d '\042\134')
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$escaped"
  exit 0
}

# 1. main/master는 PR로만 병합한다 — 직접 push 차단.
if printf '%s' "$bare" | grep -qE '(^|[^a-zA-Z0-9_-])git[[:space:]]+push'; then
  if printf '%s' "$bare" | grep -qE '(^|[[:space:]:])(main|master)([[:space:]]|:|$)'; then
    deny "git-workflow: main/master로 직접 push할 수 없습니다. develop을 target으로 PR을 여세요."
  fi
  # 명시적 refspec이 없으면 현재 브랜치로 push된다.
  branch=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null)
  case "$branch" in
    main|master)
      deny "git-workflow: 현재 브랜치가 ${branch}입니다. 직접 push할 수 없으니 develop에서 작업 브랜치를 분기한 뒤 PR을 여세요."
      ;;
  esac
fi

# 2. 브랜치명 규약: {type}/{desc}. 이슈 번호는 선택(예: feat/42-team-standings).
#    type은 이 저장소에서 실제로 써온 접두사들이다.
newbr=$(printf '%s' "$bare" \
  | grep -oE 'git[[:space:]]+(checkout[[:space:]]+-b|switch[[:space:]]+-c)[[:space:]]+[^[:space:];&|]+' \
  | head -1 \
  | awk '{print $NF}')
if [ -n "$newbr" ]; then
  if ! printf '%s' "$newbr" | grep -qE '^((feat|feature|fix|hotfix|refactor|chore|ci|docs|test|perf|style)/[a-z0-9._+-]+|release/[A-Za-z0-9._+-]+)$'; then
    deny "git-workflow: 브랜치명 '${newbr}'이(가) 규약에 맞지 않습니다. {type}/{desc} 형식(type: feat, feature, fix, hotfix, refactor, chore, ci, docs, test, perf, style) 또는 release/{version}을 사용하세요."
  fi
fi

# 3. Conventional Commits. -m 뒤 첫 따옴표 구간(= subject)만 검사한다.
#    -F/heredoc/PowerShell here-string으로 메시지를 넘기면 매치되지 않고 그대로 통과한다(fail-open).
if printf '%s' "$bare" | grep -qE '(^|[^a-zA-Z0-9_-])git[[:space:]]+commit'; then
  # -m이 여러 개면(본문, Co-Authored-By 등) 첫 번째만 subject다. greedy `.*`로 자르면 마지막 -m이 잡힌다.
  msg=$(printf '%s' "$cmd" | grep -oE -- "-m[[:space:]]*[\"'][^\"']*" | head -1 | sed -E "s/^-m[[:space:]]*[\"']//")
  if [ -n "$msg" ]; then
    if ! printf '%s' "$msg" | grep -qE '^(feat|fix|docs|style|refactor|test|chore|perf|ci)(\([a-z0-9._/-]+\))?: [a-z](.*[^.])?$'; then
      deny "git-workflow: 커밋 메시지 '${msg}'이(가) Conventional Commits 형식이 아닙니다. <type>(<scope>): <subject> — type은 feat|fix|docs|style|refactor|test|chore|perf|ci, subject는 명령형·소문자 시작·마침표 없이."
    fi
  fi
fi

# 4. git config는 저장소 로컬 설정이라도 바꾸지 않는다. 읽기 전용 조회만 허용한다.
#    훅 적용은 .githooks/pre-push를 .git/hooks/로 cp하는 파일 조작으로 대신한다.
if printf '%s' "$bare" | grep -qE '(^|[^a-zA-Z0-9_-])git[[:space:]]+config([[:space:]]|$)'; then
  if ! printf '%s' "$bare" | grep -qE 'git[[:space:]]+config[[:space:]]+(--get|--get-all|--get-regexp|--list|-l|--show-origin)([[:space:]]|$)'; then
    deny "git-workflow: git config는 실행하지 않습니다. 훅이 필요하면 cp .githooks/pre-push .git/hooks/pre-push && chmod +x .git/hooks/pre-push로 파일만 배치하세요."
  fi
fi

exit 0
