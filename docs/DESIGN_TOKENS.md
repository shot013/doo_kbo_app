# 디자인 토큰

이 앱은 화면마다 색을 직접 `Color(0xFF...)`로 적지 않고, [`lib/core/theme/app_colors.dart`](../lib/core/theme/app_colors.dart)의
`AppColors`를 통해서만 참조합니다. **코드가 유일한 원본(source of truth)이고, 이 문서는 그
값을 사람이 읽기 쉬운 형태로 옮겨 적은 참고 자료입니다.** `app_colors.dart`를 바꾸면 이
문서도 같이 갱신하세요 — 스크린샷을 보고 색을 역추적하는 대신 이 표를 먼저 확인하면 됩니다.

## 컬러 팔레트

| 토큰 | 값 | 역할 | 주요 사용처 |
|---|---|---|---|
| `background` | `#0C1E38` | 앱 전체 배경(네이비). 앱 아이콘 브랜드 컬러와 통일 | `Scaffold`/`AppBar` 배경 (`MainShell`, 각 상세 화면) |
| `surface` | `#1B2C4D` | 카드/컨테이너 배경. `background`보다 밝게 해서 구분 | 카드형 섹션(오늘의 경기, 최근 경기 결과, 선수/팀 상세 등) |
| `surfaceHigh` | `#24365E` | 2차 표면. `surface` 안에서 한 번 더 구분이 필요한 요소 | 구분선, 비활성 토글/뱃지 배경 |
| `border` | `#3A4E73` | 테두리·구분선, 원형 뱃지 배경 | 리스트 행 번호 뱃지, 구분선 |
| `textPrimary` | `#FFFFFF` (`Colors.white`) | 기본(강조) 텍스트/아이콘 | 대부분의 제목·본문 텍스트 |
| `textMuted` | `#9E9E9E` | 보조 텍스트/아이콘, 비활성 상태 | 메타 정보, 비활성 탭/토글 텍스트 |
| `accent` | `#4ADE80` | 강조 액션 컬러(그린) | 즐겨찾기 아이콘, 기록/선수 필터 토글 활성 배경 |
| `onAccent` | `#000000` (`Colors.black`) | `accent`/`navActive`/`gold` 위에 올라가는 텍스트·아이콘 | 활성 토글 텍스트, bottom nav 활성 아이콘 |
| `gold` | `#FFC72C` | 브랜드 포인트 컬러 | 홈 앱바 배지, `ColorScheme.secondary` |
| `navActive` | `#38BDF8` | bottom navigation 활성 탭 전용 색 (하늘색) | `AppBottomNav`의 활성 탭 배경만 — 다른 곳에는 쓰지 않음 |

## 왜 `accent`와 `navActive`가 분리되어 있는가

`accent`(그린)는 기록/선수 필터 토글, 즐겨찾기 아이콘 등 앱 전반의 "활성/강조" 상태에
쓰입니다. `navActive`(하늘색)는 bottom navigation의 활성 탭에만 쓰는 별도 색으로,
사용자 요청으로 하늘색으로 바꾸면서 다른 `accent` 사용처(토글, 즐겨찾기)는 그대로
그린으로 남기기 위해 새 토큰을 추가했습니다. 두 색을 하나로 합치지 마세요.

## AppTheme과의 관계

[`lib/core/theme/app_theme.dart`](../lib/core/theme/app_theme.dart)는 `AppColors`를 조합해
Material 3 `ColorScheme`을 만듭니다(다크 테마 하나만 사용, `themeMode: ThemeMode.dark`로
[`app.dart`](../lib/app.dart)에서 고정). `AppBarTheme`에서 `surfaceTintColor: Colors.transparent`,
`scrolledUnderElevation: 0`을 명시적으로 꺼두는데, 이걸 빼면 Material 3 기본값(연보라
틴트)이 스크롤 시 AppBar에 덧씌워집니다.

## 새 색이 필요할 때

1. 정말 새로운 역할인지 먼저 확인하세요 — 기존 9개 토큰 중 하나로 표현되는 경우가
   대부분입니다.
2. `app_colors.dart`에 상수를 추가하고, 그 역할을 설명하는 이름을 붙이세요
   (`navActive`처럼 값이 아니라 용도로 이름 짓기 — `skyBlue`가 아니라 `navActive`).
3. 이 문서의 표에 한 줄 추가하세요.
