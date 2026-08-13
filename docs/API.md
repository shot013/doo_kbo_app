# 백엔드 API

앱이 실제로 호출하는 REST API 정리입니다. 각 feature의 `data/datasources/*_remote_data_source.dart`
(`*RemoteDataSourceImpl`)에서 실제 호출 코드를, `data/models/*_model.dart`의 `fromJson`에서
정확한 응답 필드를 확인할 수 있습니다 — 이 문서는 그 둘을 요약한 참고용입니다.

## 공통 사항

- **Base URL**: `lib/core/constants/app_constants.dart`의 `AppConstants.baseUrl`
  (기본값 `http://15.164.113.221:3651`, `--dart-define=BASE_URL=...`로 로컬 서버 등으로 오버라이드 가능)
- **목록 응답 envelope**: 목록을 반환하는 엔드포인트는 전부 `{ "data": [...] }` 형태로 감싸져 있고,
  일부는 페이지네이션 메타데이터(`total`, `page`, `limit`, `totalPages`)도 함께 내려줍니다.
  클라이언트는 현재 `data` 배열만 사용합니다.
- **단건 응답**: `/teams/:code`, `/players/:id`처럼 단건 조회는 envelope 없이 객체를 바로 반환합니다.
- **에러 처리**: `DioException`은 데이터소스에서 `ServerException`으로 변환되고,
  repository에서 `AppFailure`(`Result<T>`의 `Err`)로 바뀌어 presentation까지 전달됩니다
  (`.claude/rules/architecture.md` 참고).
- 각 feature는 `RemoteDataSourceImpl`(실제 호출)과 `DummyDataSource`(고정 더미 데이터) 두 구현체를
  갖고 있고, `*_providers.dart`의 `xxxRemoteDataSourceProvider`가 둘 중 무엇을 쓸지 결정합니다.
  현재 `game`/`standing`/`record`/`team`/`player` 전부 `RemoteDataSourceImpl`(실제 API)로 연결되어 있습니다.

## 경기 (`game` feature)

### `GET /games`

| 쿼리 파라미터 | 타입 | 설명 |
|---|---|---|
| `seasonYear` | int? | 시즌 연도 |
| `gameDate` | string? | `yyyy-MM-dd`. 오늘의 경기(`todayGamesProvider`)에서 사용 |

응답 `data[]` 항목 (`GameModel`):

| 필드 | 타입 | 비고 |
|---|---|---|
| `id` | string | 예: `20260722NCLG0` |
| `seasonYear` | int | |
| `gameDate` | string | `yyyy-MM-dd` |
| `scheduledAt` | string | ISO8601 |
| `stadium` | string? | |
| `homeTeamCode` / `awayTeamCode` | string | 팀 코드 (아래 "팀 코드" 참고) |
| `homeTeamName` / `awayTeamName` | string | |
| `homeScore` / `awayScore` | int? | 경기 전에는 `null` |
| `currentInning` | string? | 진행 중 경기만 |
| `status` | string | `SCHEDULED` \| `IN_PROGRESS` \| `FINISHED` \| `CANCELLED` \| `POSTPONED` |

### `GET /game-stats?gameId={id}`

응답 `data[]` 항목 (`GameStatModel`) — 타자/투수 기록이 한 테이블에 섞여 있고 `statType`으로 구분:

| 필드 | 타입 | 비고 |
|---|---|---|
| `id` | int | |
| `gameId` | string | |
| `teamCode` | string | |
| `playerName` | string | |
| `playerNo` | string? | |
| `statType` | string | `BATTING` \| `PITCHING` |
| `atBats`, `hits`, `doubles`, `triples`, `homeRuns`, `rbi`, `runs`, `walks`, `strikeouts`, `stolenBases` | int? | 타자 기록 (statType=BATTING일 때만 값 존재) |
| `battingAverage` | string? | |
| `inningsPitched` | string? | 투수 기록 |
| `hitsAllowed`, `earnedRuns`, `strikeoutsPitched`, `walksAllowed`, `homeRunsAllowed` | int? | |
| `win`, `loss`, `save`, `hold` | bool | |
| `era` | string? | |

특정 경기에 아직 개인 기록이 스크래핑되지 않은 경우 `data: []`가 내려올 수 있습니다
(홈 화면의 "최근 경기 결과" 베스트 활약 표시가 조용히 생략되는 이유).

## 순위 (`standing` feature)

### `GET /standings`

| 쿼리 파라미터 | 타입 | 설명 |
|---|---|---|
| `seasonYear` | int? | |

응답 `data[]` 항목 (`StandingModel`):

| 필드 | 타입 | 비고 |
|---|---|---|
| `seasonYear` | int | |
| `teamCode` | string | |
| `teamName` | string | |
| `rank` | int | |
| `gamesPlayed`, `wins`, `losses`, `draws` | int | |
| `winRate` | string | 예: `"0.614"` |
| `gamesBehind` | string? | |
| `streak`, `last10`, `homeRecord`, `awayRecord` | string? | |

## 기록 (`record` feature)

### `GET /records/batters`

| 쿼리 파라미터 | 타입 |
|---|---|
| `seasonYear` | int? |

응답 `data[]` 항목 (`BatterRecordModel`): `rank`(int), `playerName`(string), `teamCode`(string),
`teamName`(string), `avg`(string), `games`(int), `homeRuns`(int), `rbi`(int)

### `GET /records/pitchers`

| 쿼리 파라미터 | 타입 |
|---|---|
| `seasonYear` | int? |

응답 `data[]` 항목 (`PitcherRecordModel`): `rank`(int), `playerName`(string), `teamCode`(string),
`teamName`(string), `era`(string), `games`(int), `wins`(int), `losses`(int), `saves`(int)

## 팀 (`team` feature)

### `GET /teams`

응답 `data[]` 항목 (`TeamSummaryModel`): `code`(string), `name`(string), `rank`(int), `wins`(int),
`losses`(int), `draws`(int), `winRate`(string), `gamesBehind`(string), `recentForm`(string[], 예:
`["W","W","L","W","W"]`)

### `GET /teams/{code}`

Envelope 없이 객체를 바로 반환 (`TeamDetailModel`):

```json
{
  "summary": { /* TeamSummaryModel과 동일 구조 */ },
  "roster": [ /* PlayerSummaryModel 배열 */ ]
}
```

## 선수 (`player` feature)

### `GET /players`

| 쿼리 파라미터 | 타입 | 설명 |
|---|---|---|
| `search` | string? | 이름 검색 |
| `teamCode` | string? | |
| `position` | string? | `pitcher` \| `catcher` \| `infielder` \| `outfielder` (`PlayerPosition.name`) |
| `limit` | string | 클라이언트가 항상 `"500"`으로 고정 전송 — 선수 탭은 서버 페이지네이션 없이 전체를 한 번에 받아 클라이언트에서 검색/필터링함 |

응답 `data[]` 항목 (`PlayerSummaryModel`): `id`(string), `name`(string), `teamCode`(string),
`teamName`(string), `position`(string, 위 4개 값 중 하나), `backNumber`(int), `primaryStat`(string,
목록에 표시할 대표 기록 한 줄 — 예: `"평균자책 81.00"`)

### `GET /players/{id}`

Envelope 없이 객체를 바로 반환 (`PlayerDetailModel`):

```json
{
  "id": "...", "name": "...", "teamCode": "...", "teamName": "...",
  "position": "pitcher", "backNumber": 21,
  "statLines": [{ "label": "평균자책", "value": "81.00" }, ...]
}
```

## 팀 코드

백엔드가 실제로 내려주는 `teamCode` 값 (10구단):

| 코드 | 구단 |
|---|---|
| `OB` | 두산 베어스 |
| `LG` | LG 트윈스 |
| `HT` | KIA 타이거즈 |
| `SS` | 삼성 라이온즈 |
| `SK` | SSG 랜더스 |
| `LT` | 롯데 자이언츠 |
| `HH` | 한화 이글스 |
| `NC` | NC 다이노스 |
| `KT` | kt wiz |
| `WO` | 키움 히어로즈 |

`lib/core/widgets/team_logo.dart`의 `TeamLogo`는 이 코드 외에 `DOOSAN`/`KIA`/`SAMSUNG`/`SSG`/
`LOTTE`/`HANWHA`/`KIWOOM` 같은 별칭도 함께 매핑해두어, 백엔드가 어떤 표기를 쓰든 대응합니다.
