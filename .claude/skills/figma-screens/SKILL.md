---
name: figma-screens
description: Move doo_kbo_app screens into the Figma file "직관 앱 화면" (or update them there) by rebuilding each Flutter screen from shared components bound to AppColors variables, with sample data and tab prototype links. Use when asked to draw, sync, update, or prototype app screens or components in Figma.
---

# 앱 화면을 Figma로 옮기기

`lib/features/*/presentation/`의 화면을 Figma 파일에 컴포넌트 기반으로 다시 그리고, 탭별 화면 흐름을 프로토타입으로 연결한다.
코드가 원본이고 Figma는 그 사본이다. Figma에서 바뀐 디자인을 코드로 옮기는 일은 이 스킬이 아니라 Figma의 `/figma-design-to-code` 스킬을 쓴다.

## 대상 파일

- 파일: **직관 앱 화면** — https://www.figma.com/design/58VucFweRPMV2RL7bfrr58 (fileKey `58VucFweRPMV2RL7bfrr58`)
- 페이지 `컴포넌트`: 변수, 텍스트 스타일, 재사용 컴포넌트
- 페이지 `탭 화면`: 탭별 화면 프레임과 프로토타입 연결

새 파일을 만들지 않는다. 같은 화면이 이미 있으면 새로 그리지 말고 그 프레임을 고친다.

## 시작 전 (필수)

1. Figma 스킬을 먼저 로드한다: `/figma-use`(use_figma 호출 전 필수), `/figma-generate-design`(화면 생성 절차).
   플러그인 스킬이 없으면 MCP 리소스 `skill://figma/figma-use/SKILL.md`, `skill://figma/figma-generate-design/SKILL.md`를 읽는다.
2. `create_session`을 fileKey와 짧은 작업 설명으로 한 번 호출하고, 받은 sessionId를 이후 모든 파일 도구 호출에 넘긴다.
3. 기존 상태를 먼저 읽는다: `get_metadata`로 두 페이지의 프레임/컴포넌트 목록, `get_variable_defs`로 변수.
   이미 있는 컴포넌트·변수는 재사용하고, 없는 것만 만든다.

## 호출 한도 (중요)

Figma MCP 호출은 좌석 등급마다 한도가 있다. 한도를 넘기면 그날(또는 그달) 작업이 멈춘다.

| 좌석 | 한도 |
|---|---|
| Starter 또는 View 좌석 | 월 약 20회 |
| Professional Full/Dev 좌석 | 하루 200회, 분당 10회 |

- `use_figma` 한 번에 화면 한 장(또는 컴포넌트 여러 개)을 통째로 만든다. 노드마다 호출하지 않는다.
- 확인용 `get_screenshot`은 탭 하나를 끝낼 때 한 번만 찍는다.
- 시작할 때 이번 작업의 예상 호출 수를 사용자에게 알리고, 한도에 걸리면 어디까지 했는지 남기고 멈춘다.

## 디자인 기준

### 색: AppColors → Figma 변수

`lib/core/theme/app_colors.dart`의 다크 팔레트를 컬렉션 `AppColors`의 색 변수로 등록한다. 이름은 Dart 필드명을 그대로 쓴다.
값은 작업 시점의 `app_colors.dart`를 읽어서 맞춘다 (아래는 참고용).

| 변수 | 값 |
|---|---|
| `background` | `#0C1E38` |
| `surface` | `#1B2C4D` |
| `surfaceHigh` | `#24365E` |
| `border` | `#3A4E73` |
| `textPrimary` | `#FFFFFF` |
| `textMuted` | `#9E9E9E` |
| `accent` | `#4ADE80` |
| `onAccent` | `#000000` |
| `gold` | `#FFC72C` |
| `navActive` | `#38BDF8` |

모든 레이어의 fill/stroke는 이 변수를 참조한다. hex 값을 레이어에 직접 넣지 않는다 (코드의 `Color(0xFF...)` 금지 규칙과 같다).
`app_colors.dart`에 없는 색이 필요하면 변수를 임의로 늘리지 말고, 코드에 먼저 추가할지 사용자에게 묻는다.

### 프레임과 글자

- 화면 프레임: 393×852, fill `background`, Auto Layout 세로.
- 글꼴: Noto Sans KR. 텍스트 스타일 12개를 `컴포넌트` 페이지에 정의하고 모든 텍스트가 스타일을 참조한다. 이탤릭은 쓰지 않는다.
- 하단 탭 영역(`BottomNavSpacer`)만큼 스크롤 콘텐츠 아래 여백을 둔다.

### 팀 로고

`assets/images/teams/`의 로고를 쓴다 (`lib/core/widgets/team_logo.dart`가 팀과 파일을 매핑).
SVG 8개는 그대로 올리고, PNG인 SSG(`ssg.png`)와 키움(`kiwoom.png`)은 업로드가 막히므로 `TeamLogo`의 `_FallbackBadge`처럼 원형 이니셜 배지로 그린다.
배지 fill은 `_FallbackBadge`의 `Colors.primaries`가 `AppColors`에 없으므로 `surfaceHigh`, 글자는 `textPrimary` 변수를 쓴다.
팀 로고 컴포넌트는 팀별 variant 10개로 만든다.

### 데이터

예시 데이터만 쓴다. 실제 선수 기록·경기 결과·순위를 API나 웹에서 가져와 넣지 않는다.
팀명과 화면 문구는 코드의 표시용 getter(예: `Game.homeTeamVisibleName`)와 같은 형식으로 맞춘다.

## 컴포넌트 (`컴포넌트` 페이지)

코드 위젯 하나에 Figma 컴포넌트 하나를 대응시킨다. 화면은 이 인스턴스로만 조립한다.

| Figma 컴포넌트 | 코드 |
|---|---|
| 팀 로고 (variant 10) | `lib/core/widgets/team_logo.dart` |
| 아이콘 | Material 아이콘 (`app_bottom_nav.dart` 등에서 쓰는 것) |
| 앱 바 | `lib/features/home/presentation/widgets/home_app_bar.dart` |
| 하단 탭 (상태 5개: HOME/순위/기록/팀/선수) | `lib/core/widgets/app_bottom_nav.dart` |
| 칩 (너비 Hug) | `player_section.dart`의 `_PositionFilterChips`, `record_category_toggle.dart` |
| 경기 카드 | `today_game_section.dart`의 `_GameCard` |
| 최근 경기 카드 | `recent_game_section.dart`의 `_RecentGameCard` |
| 순위 행 | `lib/features/standing/presentation/widgets/standing_table.dart` |
| 기록 행 | `player_detail_screen.dart`의 `_StatRow`, `batter_record_table.dart`/`pitcher_record_table.dart` |
| 팀 카드 | `team_section.dart`의 `_TeamCard` |
| 선수 행 | `lib/core/widgets/player_list_row.dart` |

위젯 파일명이 바뀌었을 수 있으니 표를 믿지 말고 작업 전에 `lib/`에서 확인한다. 새 공용 위젯이 생겼으면 컴포넌트도 추가한다.

## 탭 화면과 프로토타입 (`탭 화면` 페이지)

탭 이름과 순서는 `app_bottom_nav.dart`의 `_tabs`, 라우트는 `lib/core/router/app_router.dart`를 따른다.
탭마다 행(row)을 하나 두고 화면을 흐름 순서대로 왼쪽에서 오른쪽으로 놓는다. 하단 탭 인스턴스는 각 탭으로 서로 연결한다.

| 탭 | 화면 (코드) | 프로토타입 연결 |
|---|---|---|
| HOME (`/`) | `home_body.dart`, `game_preview_screen.dart`, `favorite_team_picker_sheet.dart` | 경기 카드 → 경기 프리뷰, 응원팀 배지 → 응원팀 선택 시트(오버레이) |
| 순위 (`/standings`) | `standing_section.dart` | 순위표만 (연결 없음) |
| 기록 (`/records`) | `record_section.dart`, `player_detail_screen.dart` | 타자/투수 토글 → 각 상태 화면, 기록 행 → 선수 상세 |
| 팀 (`/teams`) | `team_section.dart`, `team_detail_screen.dart`, `player_detail_screen.dart` | 팀 카드 → 팀 상세 → 로스터의 선수 → 선수 상세 |
| 선수 (`/players`) | `player_section.dart`, `player_detail_screen.dart` | 선수 행 → 선수 상세 |

상세 화면의 뒤로가기는 "Back" 동작으로 연결한다.

## 절차

1. 시작 전 단계를 마치고, 대상 탭(또는 화면)과 예상 호출 수를 정한다.
2. 대상 화면의 Dart 파일을 읽어 레이아웃(위젯 트리 순서, 간격, 색 참조, 문구)을 파악한다.
3. 빠진 변수/텍스트 스타일/컴포넌트를 `use_figma` 한 번에 묶어 만든다.
4. 화면 프레임을 `use_figma`로 인스턴스만 써서 조립한다. 탭 하나의 화면들을 가능하면 한 호출에 만든다.
5. 프로토타입 연결을 건다.
6. `get_screenshot`으로 탭 단위로 확인하고, 코드 화면(필요하면 에뮬레이터 스크린샷)과 다른 점을 고친다.
7. 완료 보고에 만든/고친 프레임 링크(`?node-id=`), 사용한 호출 수, 남은 일을 적는다.

## 완료 조건

- 모든 fill/stroke가 `AppColors` 변수, 모든 텍스트가 텍스트 스타일을 참조한다 (detach된 값 없음).
- 화면은 컴포넌트 인스턴스로만 조립되어 있다.
- 위 표의 프로토타입 연결이 모두 동작한다.
- 실제 데이터가 들어가 있지 않다.
