---
name: emulator-qa
description: Run doo_kbo_app's QA scenarios (docs/TEST_SCENARIOS.md) on the Android emulator by tapping through the real app with adb, checking screen text via the accessibility dump and API calls via logcat, and report pass/fail per scenario. Use when asked to verify features on the emulator, run the test scenarios, QA the app end to end, or confirm a UI change on a device.
---

# 에뮬레이터 QA

`docs/TEST_SCENARIOS.md`의 시나리오를 에뮬레이터에서 직접 조작하며 확인하고, 시나리오별 결과표를 낸다.
조작은 같은 폴더의 `emu.sh`로 한다.

## 준비

```bash
E="bash .claude/skills/emulator-qa/emu.sh"
export EMU_SHOTS="<세션 scratchpad>/emu-shots"   # 스크린샷은 저장소 밖에 둔다
$E boot                                          # 에뮬레이터가 없으면 Pixel_10_Pro를 띄운다
flutter build apk --debug && $E install && $E restart
$E wait "오늘의 경기" 30
$E badge                                         # 시작 시 즐겨찾기 팀. 끝나고 되돌린다
```

- 디버그 빌드를 쓴다. API 요청 로그(`requests`)는 디버그 빌드의 dio 로그로 확인하기 때문이다.
- 네트워크가 켜져 있는지 확인한다 (`$E net on`).

## 실행 규칙

- 시나리오를 문서 순서대로 실행한다. 각 시나리오: 단계 실행 → 기대 결과 확인(`expect`, `wait`, `requests`) → `$E shot <ID>` → 스크린샷을 Read로 열어 잘림·겹침·빈 화면이 없는지 본다.
- 판정은 셋 중 하나다.
  - **통과**: 기대 결과와 같다.
  - **실패**: 기대 결과와 다르다. 문서의 알려진 결함이면 그 ID를 적고, 처음 보는 문제면 "새 결함"으로 적는다.
  - **보류**: 시나리오의 데이터 조건이 맞지 않아 실행할 수 없다 (예: 기록 데이터 없음).
- 서버 데이터는 날마다 다르다. 시나리오의 "데이터 조건"을 먼저 확인하고 그에 맞는 기대 결과로 판정한다.
- 화면이 비었거나 데이터가 이상하면, 앱 결함으로 판정하기 전에 `curl http://15.164.113.221:3651/<경로>`로 API 응답을 직접 확인해 서버 데이터 문제인지 구분한다.
- 텍스트가 바로 안 보이면 실패로 보지 말고 `$E wait "<텍스트>" <초>`로 기다리고, 걸린 시간을 결과에 적는다. 오류 화면은 재시도 때문에 늦게 뜨므로(BUG-09) 60초까지 기다린다.
- 시나리오에 없는 이상을 보면 "추가 발견"으로 적는다.

## emu.sh 명령

| 명령 | 하는 일 |
|---|---|
| `boot [AVD]`, `install`, `launch`, `restart`, `background` | 에뮬레이터·앱 준비, 강제 종료 후 재실행, 홈 키 |
| `net on\|off` | Wi-Fi·모바일 데이터 켜기/끄기 |
| `dump` | 화면의 텍스트 노드 목록 (`라벨<TAB>x1 y1 x2 y2`, 줄바꿈은 ` \| `) |
| `shot <이름>` | 스크린샷을 `$EMU_SHOTS/<이름>.png`로 저장 |
| `badge` | 앱바에 표시된 즐겨찾기 팀 코드 (없으면 빈 줄) |
| `logclear`, `requests` | 요청 로그 비우기, 그 이후 앱이 보낸 API URL (디코딩됨) |
| `tapt <텍스트> [n]` | 라벨에 텍스트가 들어간 n번째 노드를 탭 |
| `tapx <라벨> [최소 y]` | 라벨이 정확히 같은 노드를 탭. 화면 아래쪽 시트 안처럼 범위를 좁힐 때 (예: 즐겨찾기 시트의 팀 `tapx LG 1900`) |
| `tab <0-4>`, `tabs` | 하단 탭 누르기 (0=HOME 1=순위 2=기록 3=팀 4=선수), 탭 버튼 수 세기 |
| `tapinput`, `type <영문>`, `typeko <한글>`, `erase [n]` | 입력창 탭, 입력, 지우기 |
| `back`, `up`, `down`, `pull` | 뒤로, 스크롤, 당겨서 새로고침 |
| `wait <텍스트> [초]`, `expect <텍스트>`, `expectno <텍스트>` | 확인 (실패 시 exit 1) |
| `screen`, `device`, `steps` | 지금 화면 이름, 디바이스 정보, 조작 기록(`EMU_TRACE`)을 재현 단계 표로. 주로 `/bug-report`에서 쓴다 |

## 알아둘 것

- 비활성 하단 탭은 접근성 라벨이 없어 텍스트로 못 찾는다. `tab <번호>`를 쓴다.
- 에뮬레이터 키보드가 한글(두벌식) 모드라 `type LG`는 `ㅣㅎ`로 입력된다. 한글은 `typeko`, 영문 그대로가 필요하면 키보드 언어를 바꾼다.
- 직접 `adb`를 부를 때는 `MSYS_NO_PATHCONV=1`을 붙인다. Git Bash가 `/sdcard/...`를 Windows 경로로 바꿔버린다.
- `requests`는 마지막 `logclear` 이후 요청만 보여준다. 확인하려는 동작 직전에 `logclear`한다.
- 상세에서 뒤로 오면 이전 화면의 스크롤 위치가 그대로라 섹션 제목이 화면 밖일 수 있다. 앱바 제목처럼 항상 보이는 요소로 확인한다. 덤프는 화면에 그려진 노드만 담는다.
- 한 번 연 상세 화면(팀·선수·프리뷰)은 provider가 캐시해서 다시 열어도 요청하지 않는다. 요청을 확인하려면 처음 여는 대상을 고르거나 `restart`한다.

## 정리

`$E net on`, 즐겨찾기 팀을 시작 상태로 되돌린다(앱바 배지 → 팀 선택 또는 `즐겨찾기 해제`), 검색어를 지운다.

## 결과 보고

| ID | 시나리오 | 결과 | 근거 (확인한 텍스트·요청·걸린 시간) |
|---|---|---|---|

표 아래에 실패·보류 요약, 추가 발견, 서버 데이터 문제를 따로 적는다. 알려진 결함이 고쳐져 통과했다면 `docs/TEST_SCENARIOS.md`의 결함 표에서 지우자고 제안한다. 처음 보는 결함은 `/bug-report` 스킬로 이슈용 리포트를 만든다.
