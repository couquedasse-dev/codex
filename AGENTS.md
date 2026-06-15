# Repository Guidelines

## 현재 작업 환경
- 운영체제: `Windows_NT`
- 셸/터미널: `PowerShell 5.1.26100.8655`
- 프로젝트 루트: `C:\project_name\codex_practice0`
- 주요 런타임: `python`(C:\Users\dpavk\AppData\Local\Microsoft\WindowsApps\python.exe), `node`(C:\Program Files\nodejs\node.exe), `npm`(C:\Program Files\nodejs\npm.ps1), `git`(C:\Program Files\Git\cmd\git.exe)

## 기본 원칙
이 파일은 Codex가 이 프로젝트에서 항상 따라야 할 기본 원칙만 적는다. 이후 Codex의 설명, 계획, 보고는 기본적으로 한국어로 작성한다.

현재 작업 스코프는 `C:\project_name\codex_practice0`와 그 하위 파일로 제한한다. 프로젝트 내부 파일을 직접 읽고 판단하며, 추정으로 구현하지 않는다. 요구사항이 모호하면 먼저 짧게 확인하고, 확인이 어려우면 안전한 최소 범위로 작업한다.

필수 작업 원칙:
1. 필요한 경우 먼저 짧은 계획을 세운 뒤 작업한다.
2. 코드 수정 후 관련 테스트 또는 최소 검증을 수행한다.
3. 테스트를 실행할 수 없으면 그 이유를 명확히 기록한다.
4. 변경 내용과 검증 결과를 마지막에 짧게 요약한다.
5. TypeScript 파일을 수정한 뒤에는 `pnpm typecheck`와 관련 unit test를 실행한다.
6. API response field name은 하위 호환성을 위해 임의로 변경하지 않는다.
7. `legacy/`와 `generated/`는 요청받지 않으면 수정하지 않는다.
8. `.env`, secret, credential, API key, 인증 파일은 출력하거나 수정하지 않는다.
9. 프로젝트 스코프 밖 파일은 읽거나 수정하지 않는다.
10. 삭제, 강제 덮어쓰기, 원격 push 같은 파괴적 작업은 수행하지 않는다.
11. 사용자가 제공한 변수명, 함수명, 파일명은 임의로 바꾸지 않는다.
12. 불필요한 대규모 리팩토링은 하지 않는다.
13. 요청 범위 밖의 기능을 임의로 추가하지 않는다.

## 보고 형식
결과 보고는 변경 파일 목록과 검증 결과만 짧게 적는다. 자세한 설명은 필요할 때만 덧붙인다.
