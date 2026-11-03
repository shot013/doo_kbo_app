# 코드 스타일 규칙 (항상 적용)

`analysis_options.yaml`에 정의된 규칙을 코드 작성 시점부터 지킨다 (`flutter analyze` 실행 후 고치지 않는다):

`strict-casts`/`strict-inference`/`strict-raw-types`(JSON은 `as`로 명시 캐스트), `always_declare_return_types`, `avoid_print`(`debugPrint` 사용), `prefer_relative_imports`, `prefer_single_quotes`, `prefer_const_*`, `prefer_final_locals`, `directives_ordering`, `sort_child_properties_last`, `unawaited_futures`(`await` 또는 `unawaited()`), `cancel_subscriptions`.

포맷 항목은 `format-dart` 훅이 처리하므로 여기 적지 않는다. `logPrint: print`처럼 `print`를 함수 값으로 넘기면 `avoid_print`가 못 잡으니 직접 확인한다.
