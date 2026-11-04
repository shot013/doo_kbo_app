#!/usr/bin/env bash
# emulator-qa 스킬의 에뮬레이터 조작 도구. 사용법은 같은 폴더의 SKILL.md 참고.
#
# 화면 요소는 좌표를 짐작하지 않고 `uiautomator dump`(Flutter가 Android 접근성으로 노출하는
# 텍스트와 좌표)로 찾는다. 앱이 보낸 API 요청은 디버그 빌드의 dio 로그(logcat)로 확인한다.
set -u
# Git Bash가 /sdcard/... 같은 인자를 Windows 경로(C:/Program Files/Git/sdcard/...)로 바꾸지 않게 한다.
export MSYS_NO_PATHCONV=1

ADB="${ADB:-${ANDROID_HOME:-$LOCALAPPDATA/Android/Sdk}/platform-tools/adb.exe}"
[ -x "$ADB" ] || ADB=adb
PKG=com.kbo.app
SHOTS="${EMU_SHOTS:-${TMPDIR:-/tmp}/emu-shots}"

dump_xml() {
  "$ADB" shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1
  "$ADB" exec-out cat /sdcard/ui.xml
}

# 노드를 "라벨<TAB>x1 y1 x2 y2" 줄로 펼친다. 라벨 = text + content-desc, 줄바꿈은 " | ".
# 노드가 수백 개라 셸 루프로 돌면 Windows에서 수십 초가 걸리므로 awk 한 번으로 처리한다.
all_nodes() {
  dump_xml | tr '>' '\n' | grep -o '<node [^>]*' | awk '
    function attr(s, name) {
      if (match(s, " " name "=\"[^\"]*\"")) return substr(s, RSTART + length(name) + 3, RLENGTH - length(name) - 4)
      return ""
    }
    {
      label = attr($0, "text") attr($0, "content-desc")
      gsub(/&#10;/, " | ", label); gsub(/&amp;/, "\\&", label)
      b = attr($0, "bounds"); gsub(/\]\[|,/, " ", b); gsub(/[\[\]]/, "", b)
      print label "\t" b
    }'
}
nodes() { all_nodes | awk -F'\t' '$1 != ""'; }

center_tap() { # "x1 y1 x2 y2"
  set -- $1
  "$ADB" shell input tap $(( ($1 + $3) / 2 )) $(( ($2 + $4) / 2 ))
}

# 하단 탭 버튼 좌표. 비활성 탭은 라벨이 없어서 화면 아래쪽의 버튼 노드를 x 순으로 고른다.
tab_bounds() {
  all_nodes | awk -F'\t' '{ split($2, a, " "); if (a[2] >= 2500 && a[4] - a[2] < 160 && a[4] - a[2] > 80) print a[1] "\t" $2 }' \
    | sort -n | sed -n "$(( $1 + 1 ))p" | cut -f2
}

# 한글을 두벌식 자판 키로 바꾼다 (에뮬레이터 키보드가 한글 모드일 때 `input text`로 한글을 입력하기 위함).
to_dubeolsik() {
  # 글자 단위로 자르고 코드포인트를 얻으려면 UTF-8 로케일이어야 한다 (Git Bash 기본값은 바이트 단위).
  local LC_ALL=C.UTF-8
  local cho=(r R s e E f a q Q t T d w W c z x v g)
  local jung=(k o i O j p u P h hk ho hl y n nj np nl b m ml l)
  local jong=("" r R rt s sw sg e f fr fa fq ft fx fv fg a q qt t T d w c z x v g)
  local s="$1" out="" ch code i
  for (( i = 0; i < ${#s}; i++ )); do
    ch="${s:i:1}"
    code=$(printf '%d' "'$ch")
    if (( code >= 0xAC00 && code <= 0xD7A3 )); then
      code=$(( code - 0xAC00 ))
      out+="${cho[code / 588]}${jung[(code % 588) / 28]}${jong[code % 28]}"
    else
      out+="$ch"
    fi
  done
  printf '%s' "$out"
}

# logcat에서 dio LogInterceptor의 Request 블록 URI만 뽑아 퍼센트 인코딩을 푼다.
requests() {
  "$ADB" logcat -d -s flutter:I | sed 's/^.*flutter[^:]*: //' \
    | awk '/\*\*\* Request \*\*\*/{r=1; next} /\*\*\* (Response|DioException)/{r=0} r && /^uri: /{print substr($0, 6)}' \
    | while IFS= read -r u; do printf '%b\n' "${u//%/\\x}"; done
}

cmd="${1:-help}"; shift || true
case "$cmd" in
  # --- 준비 ---
  boot) # 에뮬레이터가 없으면 띄우고 부팅 완료까지 기다린다. 인자: AVD 이름 (기본 Pixel_10_Pro)
    if ! "$ADB" devices | grep -q "emulator-"; then
      "${ANDROID_HOME:-$LOCALAPPDATA/Android/Sdk}/emulator/emulator.exe" -avd "${1:-Pixel_10_Pro}" >/dev/null 2>&1 &
    fi
    "$ADB" wait-for-device
    for _ in $(seq 1 100); do [ "$("$ADB" shell getprop sys.boot_completed | tr -d '\r')" = 1 ] && { echo "booted"; exit 0; }; sleep 3; done
    echo "BOOT TIMEOUT"; exit 1 ;;
  install) # 디버그 APK를 설치 (먼저 저장소 루트에서 flutter build apk --debug)
    "$ADB" install -r build/app/outputs/flutter-apk/app-debug.apk ;;
  launch) "$ADB" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 ;;
  restart) "$ADB" shell am force-stop "$PKG"; "$ADB" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 ;;
  background) "$ADB" shell input keyevent KEYCODE_HOME ;;
  net) # on | off
    if [ "$1" = off ]; then "$ADB" shell svc wifi disable; "$ADB" shell svc data disable
    else "$ADB" shell svc wifi enable; "$ADB" shell svc data enable; fi ;;

  # --- 보기 ---
  dump) nodes ;;
  shot) mkdir -p "$SHOTS"; "$ADB" exec-out screencap -p > "$SHOTS/$1.png" && echo "$SHOTS/$1.png" ;;
  tabs) # 하단 탭 버튼 수 (누르지 않고 센다)
    all_nodes | awk -F'\t' '{ split($2, a, " "); if (a[2] >= 2500 && a[4] - a[2] < 160 && a[4] - a[2] > 80) n++ } END { print n + 0 }' ;;
  badge) # 앱바의 즐겨찾기 팀 코드 (없으면 빈 줄)
    nodes | awk -F'\t' '{ split($2, a, " "); if (a[2] < 300 && a[1] > 900) print $1 }' | head -1 ;;
  logclear) "$ADB" logcat -c ;;
  requests) requests ;;

  # --- 조작 ---
  tap) "$ADB" shell input tap "$1" "$2" ;;
  tapt) # 라벨에 텍스트가 포함된 n번째(기본 1) 노드의 가운데를 탭
    line=$(nodes | grep -F -- "$1" | sed -n "${2:-1}p")
    [ -z "$line" ] && { echo "NOT FOUND: $1"; exit 1; }
    echo "tap: ${line%%	*}"; center_tap "$(printf '%s' "$line" | cut -f2)" ;;
  tapx) # 라벨이 정확히 일치하고 위쪽 y가 [최소 y] 이상인 첫 노드를 탭 (예: 시트 안의 팀 `tapx LG 1900`)
    b=$(nodes | awk -F'\t' -v t="$1" -v min="${2:-0}" '{ split($2, a, " "); if ($1 == t && a[2] >= min) { print $2; exit } }')
    [ -z "$b" ] && { echo "NOT FOUND: $1 (y>=${2:-0})"; exit 1; }
    echo "tap: $1"; center_tap "$b" ;;
  tab) # 하단 탭: 0=HOME 1=순위 2=기록 3=팀 4=선수
    b=$(tab_bounds "$1"); [ -z "$b" ] && { echo "TAB NOT FOUND: $1"; exit 1; }
    center_tap "$b" ;;
  tapinput) # 첫 번째 입력창(EditText)
    b=$(dump_xml | tr '>' '\n' | grep -o '<node [^>]*class="android.widget.EditText"[^>]*' | head -1 | grep -o 'bounds="[^"]*"' | tr -c '0-9\n' ' ')
    [ -z "$b" ] && { echo "NO INPUT"; exit 1; }
    center_tap "$b" ;;
  type) "$ADB" shell input text "$1" ;;
  typeko) "$ADB" shell input text "$(to_dubeolsik "$1")" ;;
  erase) # 한글은 조합 중인 글자가 자모 단위로 지워져 글자 수보다 훨씬 많이 눌러야 하므로 기본 30번
    "$ADB" shell input keyevent $(printf 'KEYCODE_DEL %.0s' $(seq 1 "${1:-30}")) ;;
  back) "$ADB" shell input keyevent KEYCODE_BACK ;;
  up) "$ADB" shell input swipe 640 2000 640 900 300 ;;
  down) "$ADB" shell input swipe 640 900 640 2000 300 ;;
  pull) "$ADB" shell input swipe 640 600 640 2000 800 ;;

  # --- 확인 ---
  wait) # 텍스트가 나타날 때까지 기다린다. 인자: 텍스트, 최대 초(기본 10). 걸린 시간을 출력
    start=$(date +%s)
    while (( $(date +%s) - start < ${2:-10} )); do
      nodes | grep -qF -- "$1" && { echo "OK: '$1' ($(( $(date +%s) - start ))s)"; exit 0; }
      sleep 1
    done
    echo "TIMEOUT: '$1' (${2:-10}s)"; exit 1 ;;
  expect) nodes | grep -qF -- "$1" && echo "PASS: '$1' 있음" || { echo "FAIL: '$1' 없음"; exit 1; } ;;
  expectno) nodes | grep -qF -- "$1" && { echo "FAIL: '$1' 있음"; exit 1; } || echo "PASS: '$1' 없음" ;;

  *) sed -n '2,6p' "$0"; grep -E '^  [a-z]+\)' "$0" | sed 's/).*#/ —/; s/)$//' ;;
esac
