# TODO

## 엔지니어링/인프라
- [x] 로컬 빌드 환경 고정(cmdline-tools 설치) 또는 CI에 `flutter build appbundle`/`ipa` 단계 추가 — 릴리스 빌드를 사람 손이 아닌 파이프라인이 보장하도록
  - Android 미서명 빌드 검증만 CI에 추가함 (PR: chore/ci-release-build-verification). 실서명/iOS는 별도 결정 필요해 보류
- [ ] 백엔드 HTTPS 전환 + 환경변수 기반 base URL (현재 `core/constants`에 하드코딩된 것으로 추정)
- [ ] 크래시 리포팅 최소 1종 도입 — 프로덕션 가시성 없이 배포량만 늘리는 건 리스크
  - [x] (클라이언트, doo_kbo_app) Firebase Analytics + Crashlytics 연동, 에뮬레이터에서 초기화 확인 (PR: feat/firebase-analytics-crashlytics)
  - [ ] (클라이언트) iOS Xcode 프로젝트에 GoogleService-Info.plist 리소스 등록 (Windows에서 Xcode 실행 불가로 보류)
  - [ ] (백엔드 스크래핑 모듈, 별도 저장소) Sentry 연동
- [ ] 통합 테스트 인프라 구축 (`integration_test` 패키지) — 현재 위젯 테스트는 렌더링 확인 수준이지 실제 네비게이션/상태 전이 검증이 아님
- [ ] 디자인 토큰을 코드가 아닌 별도 스펙 문서/파일로 고정 — 매번 스크린샷 대조로 색을 역추적하는 현재 방식은 확장 안 됨
- [ ] main의 orphaned 커밋(`54115cd`) 정리 — 다음 안전한 시점에 rebase
- [ ] 리뷰 프로세스 실질화 — 단일 작업자 구조라면 문서상 "1명 승인" 요건을 현실에 맞게 재정의하거나, 실제 두 번째 검토자를 두는 방안 검토
