# 아키텍처 규칙 (항상 적용)

- `lib/{feature}/domain/`은 Flutter SDK, `data/`, `presentation/`를 import하지 않는다. 위반하는 코드를 작성하지 않는다.
- 새 feature는 `lib/features/example/`을 복사해서 시작한다. `domain → data → presentation` 순서로 작성한다.
- 에러는 data layer에서 예외(`ServerException` 등, `core/error/exceptions.dart`)로 던지고, `data/repositories`에서 `Result<T>` (`Ok`/`Err`, `core/utils/result.dart`)로 변환해 상위 레이어로 전달한다. domain/presentation에서 예외를 직접 catch하지 않는다.
- 상태 관리는 Riverpod(`Provider`/`Notifier`/`AsyncNotifier`)만 사용한다. 다른 상태관리 라이브러리를 추가하지 않는다.
- `presentation`은 `AsyncValue.when(data:, loading:, error:)`로 상태를 분기한다.
- 새 feature 추가 시 `lib/core/router/app_router.dart`에 라우트를 반드시 등록한다.
- 원본 데이터를 화면 표시용으로 가공하는 로직(예: 팀 정식명에서 축약 표시명 추출)은 `presentation` 위젯에 inline으로 두지 않고 해당 `domain` entity의 getter로 만든다. 여러 화면에서 같은 가공이 필요해지면 중복 구현하지 말고 이 getter를 재사용한다 (예: `Standing.teamVisibleName`, `Game`/`GameResult`의 `homeTeamVisibleName`/`awayTeamVisibleName`). 색상도 같은 원칙 — `Color(0xFF...)`를 위젯에 직접 쓰지 않고 `core/theme/app_colors.dart`의 `AppColors` 상수만 참조한다 (`docs/DESIGN_TOKENS.md` 참고).
