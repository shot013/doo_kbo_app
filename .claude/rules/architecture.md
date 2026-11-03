# 아키텍처 규칙 (항상 적용)

- `lib/features/*/domain/`은 Flutter SDK, `data/`, `presentation/`을 import하지 않는다.
- data layer는 예외(`core/error/exceptions.dart`)를 던지고, `data/repositories`에서만 `Result<T>`(`Ok`/`Err(AppFailure)`)로 변환한다. domain/presentation은 예외를 직접 catch하지 않는다.
- 상태 관리는 Riverpod(`Provider`/`Notifier`/`AsyncNotifier`)만 쓴다. `presentation`은 `AsyncValue.when(data:, loading:, error:)`로 분기한다.
- 새 feature/화면은 `lib/core/router/app_router.dart`에 라우트를 등록한다. 절차는 `/add-feature`.
- 색은 `core/theme/app_colors.dart`의 `AppColors`만 참조한다. 위젯에 `Color(0xFF...)`를 직접 쓰지 않는다.
- 원본 데이터를 표시용으로 가공하는 로직은 위젯에 inline으로 두지 않고 domain entity getter로 만들어 재사용한다 (예: `Game.homeTeamVisibleName`).
- go_router `extra`로 넘기는 Model은 중첩 Model까지 전부 `toJson()`을 구현한다. 없으면 디버거 부착 시 ANR (`ERRORS.md` 2026-09-08, 2026-09-21).
- 디버그 로깅이 응답 본문 전체를 동기 출력하지 않게 한다. `debugPrint` + 길이 제한.
