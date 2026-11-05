---
name: bug-report
description: Write a doo_kbo_app bug report by reproducing the bug on the Android emulator and capturing a screenshot of where it happens, the device information, and the exact reproduction path (screens, taps, inputs) recorded automatically, then hand over a prefilled GitHub issue link. Use when asked to report, file, or write up a bug, or when an /emulator-qa scenario fails.
---

# 버그 리포트 작성

에뮬레이터에서 버그를 직접 재현하면서 증거를 모으고, `.github/ISSUE_TEMPLATE/bug_report.md` 형식의 리포트와
미리 채워진 GitHub 이슈 링크를 만든다. 조작 도구는 `.claude/skills/emulator-qa/emu.sh`다.

## 완료 조건

아래 셋이 모두 있어야 리포트가 완성이다. 하나라도 없으면 무엇이 왜 빠졌는지 리포트와 답변에 적는다.

1. **스크린샷**: 버그가 화면에 보이는 순간의 캡처 (필수). 필요하면 시작 화면과 중간 단계 캡처를 추가한다.
2. **디바이스 정보**: `$E device` 출력 그대로 (기기, Android 버전, 화면, 네트워크, 앱 버전·빌드).
3. **재현 시나리오**: 시작 상태 + `$E steps`로 만든 단계 표 (화면 → 동작 → 대상 → 좌표). 사람이 같은 순서로 따라 하면 같은 버그가 나야 한다.

## 절차

### 1. 준비

```bash
E="bash .claude/skills/emulator-qa/emu.sh"
DIR="bug-reports/$(date +%Y%m%d)-<짧은-영문-설명>"   # 저장소 루트, .gitignore 대상
mkdir -p "$DIR"
export EMU_SHOTS="$DIR" EMU_TRACE="$DIR/trace.tsv"
```

에뮬레이터와 앱 준비는 emulator-qa 스킬의 "준비"와 같다 (`$E boot`, 디버그 빌드 설치). 디버그 빌드여야 API 요청 로그가 남는다.

### 2. 시작 상태 고정

`$E restart`로 앱을 새로 띄우고, 재현에 영향을 주는 상태를 확인해 "시작 상태"로 적는다. 즐겨찾기 팀(`$E badge`), 네트워크, 필요하면 오늘 날짜와 서버 데이터가 해당한다. `$E shot 01_start`로 시작 화면을 남긴다.

### 3. 재현

- 조작은 반드시 `emu.sh` 명령(`tab`, `tapt`, `tapx`, `tapinput`, `typeko`, `up`, `back`, `pull` 등)으로만 한다. `adb`를 직접 부르면 조작 기록(`trace.tsv`)에 남지 않는다.
- 버그가 보이는 순간 `$E shot NN_bug-<설명>`을 찍는다. 번호는 순서대로 붙인다.
- 시간이 걸리는 버그는 `$E wait "<텍스트>" <초>`로 걸린 시간을 재고, 요청 관련 버그는 동작 직전에 `$E logclear`, 직후에 `$E requests`로 실제 요청을 남긴다.
- 두 번 재현해서 같은 결과가 나오는지 확인한다. 재현되지 않으면 "재현 안 됨"으로 적고, 사용자에게 당시 상황(화면, 기기, 순서)을 묻는다.

### 4. 앱 문제인지 서버 문제인지 구분

화면이 비거나 데이터가 이상하면 `curl http://15.164.113.221:3651/<경로>`로 API 응답을 직접 본다. 서버가 잘못된 데이터를 주면 서버 저장소(`shot013/doo_kbo_scraping_server`) 이슈다. 앱이 정상 데이터를 잘못 보여주면 앱 저장소(`shot013/doo_kbo_app`) 이슈다.

### 5. 증거 정리

```bash
$E device > "$DIR/device.md"
$E steps  > "$DIR/steps.md"
```

스크린샷은 Read로 열어, 버그가 실제로 화면에 보이는지 확인한다. 안 보이면 다시 찍는다.

### 6. 중복 확인

같은 버그가 이미 등록됐는지 본다. 공개 저장소라 로그인 없이 조회된다.

```bash
curl -s "https://api.github.com/search/issues?q=repo:shot013/doo_kbo_app+is:issue+<핵심어>"
```

있으면 새로 만들지 말고, 그 이슈에 댓글로 붙일 내용(새 재현 정보, 스크린샷)을 정리해 준다.

### 7. 리포트 작성

`$DIR/report.md`를 이슈 템플릿 섹션 순서 그대로 쓴다.

- **스크린샷**: 파일 이름과 각 화면이 보여주는 것을 적는다. 예: `02_bug-preview-spinner.png — 404인데 스피너만 도는 프리뷰 화면 (재현 단계 4)`
- **재현 시나리오**: 시작 상태 + `steps.md` 표. 기록에서 버그와 무관한 조작(잘못 누른 뒤 되돌린 것 등)은 빼고 번호를 다시 매긴다.
- **디바이스 정보**: `device.md` 그대로
- **근거**: 요청 로그, 걸린 시간, 서버 응답
- **관련 시나리오**: `docs/TEST_SCENARIOS.md`의 시나리오 ID
- 본문 끝에 `<!-- bug-report: <DIR 이름> -->`를 넣어, 나중에 이슈 번호를 찾을 수 있게 한다.

### 8. 전달

- 이슈 링크를 만든다. `https://github.com/<저장소>/issues/new?labels=bug&title=<인코딩>&body=<인코딩>`이고, 인코딩은 node의 `encodeURIComponent`를 쓴다.
- **스크린샷은 링크로 첨부할 수 없다** (URL·API 모두 이미지 업로드를 지원하지 않음). 답변에 `$DIR`의 전체 경로와 "이슈 화면의 스크린샷 섹션에 이 파일들을 끌어다 놓기"를 함께 안내한다.
- `/emulator-qa` 실행 중 나온 결함이면 `docs/TEST_SCENARIOS.md`의 결함 표에도 한 줄 추가한다. 이슈 번호가 생기면 그 줄에 연결한다.

## 알아둘 것

- 화면 이름은 `emu.sh`가 덤프에서 자동으로 고른다. 순서는 시트·다이얼로그, 상세(뒤로 버튼과 제목), 활성 탭 순이다. 처음 보는 화면은 `(알 수 없는 화면)`으로 나오니, 리포트에서 직접 이름을 고쳐 적는다.
- 기록 중에는 조작할 때마다 화면 덤프를 한 번 더 떠서 명령당 약 2초가 더 걸린다.
- `emu.sh`의 화면 위치 기준값은 Pixel_10_Pro(1280×2856) 기준이다. 다른 기기에서는 하단 탭과 화면 이름 인식이 맞지 않을 수 있다.
- `bug-reports/`는 커밋하지 않는다. 스크린샷은 이슈에 첨부되는 것으로 충분하다.
