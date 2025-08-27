# AI 코드 리뷰 자동화 설정 가이드

이 가이드는 GitHub PR에서 Claude AI가 자동으로 코드 리뷰를 해주는 시스템 설정 방법을 안내합니다.

## 📋 설정 완료 항목

✅ GitHub Actions 워크플로우 생성 (`.github/workflows/ai-code-review.yml`)  
✅ AI 코드 리뷰 스크립트 생성 (`.github/scripts/ai_code_review.py`)  
✅ PR 템플릿 생성 (`.github/pull_request_template.md`)  

## 🔧 필수 설정 단계

### 1. GitHub Repository Secrets 설정

GitHub 저장소에서 다음 시크릿을 설정해야 합니다:

1. **Repository Settings** → **Secrets and variables** → **Actions**로 이동

2. **New repository secret** 버튼 클릭하고 다음 시크릿들을 추가:

#### `ANTHROPIC_API_KEY`
```
Claude API 키를 여기에 입력
```

> 💡 Claude API 키는 [Anthropic Console](https://console.anthropic.com/)에서 발급받을 수 있습니다.

### 2. GitHub 저장소를 원격 저장소에 푸시

```bash
# 원격 저장소 추가 (GitHub에서 저장소를 먼저 생성해야 함)
git remote add origin https://github.com/사용자명/저장소명.git

# 파일들을 커밋
git add .
git commit -m "feat: AI 코드 리뷰 시스템 구축"

# 원격 저장소에 푸시
git push -u origin main
```

## 🚀 사용 방법

### 1. 새 기능 브랜치 생성
```bash
git checkout -b feature/새기능
```

### 2. 코드 작성 및 커밋
```bash
git add .
git commit -m "feat: 새로운 기능 구현"
git push origin feature/새기능
```

### 3. Pull Request 생성
- GitHub에서 PR 생성
- PR 템플릿에 따라 정보 작성
- PR 생성 즉시 AI 코드 리뷰가 자동으로 시작됩니다!

## 🤖 전문가급 AI 리뷰 결과

Kent Beck의 TDD, Robert Martin의 클린 아키텍처, Martin Fowler의 리팩터링 원칙을 기반으로 한 전문가 수준의 코드 리뷰를 제공합니다:

### 🧪 TDD (Test-Driven Development) 검토
- **Red-Green-Refactor** 사이클 준수 여부
- **Test First** 원칙 적용 확인
- **테스트 커버리지** 및 테스트 품질 평가
- **Given-When-Then** 구조 검사
- **FIRST** 원칙 (Fast, Independent, Repeatable, Self-validating, Timely)
- 프로덕션 코드에 대응하는 테스트 존재 여부

### 🏗️ Clean Architecture 검증
- **SOLID 원칙** 준수 (특히 의존성 역전)
- **레이어 간 의존성** 방향 검사
- **도메인 로직의 순수성** 확인
- **인터페이스를 통한 추상화** 검증
- **프레임워크 독립성** 평가
- 단일 책임 원칙 위반 감지

### 🔧 Refactoring (Code Smells) 탐지
- **Long Method** - 긴 메서드 감지
- **Large Class** - 거대한 클래스 탐지
- **Long Parameter List** - 긴 매개변수 목록
- **Duplicate Code** - 중복 코드 패턴
- **Feature Envy** - 긴 메서드 체인
- **Data Clumps** - 데이터 덩어리
- **God Class** - 만능 클래스

### 🛡️ 추가 품질 검사
- 성능 및 메모리 효율성
- 보안 취약점
- 예외 처리 및 에러 핸들링
- 동시성 안전성

### 📊 전문가 리뷰 형태
- **자동 감지된 이슈** 사전 표시
- **TDD/Clean Architecture/Refactoring 점수** (각 10점 만점)
- **구체적인 리팩터링 방법** 제시
- **원칙 위반 근거** 및 해결책
- **Best Practice 적용** 권장사항

## 🎯 지원 언어

현재 다음 언어들을 지원합니다:
- Python (.py)
- JavaScript (.js)
- TypeScript (.ts, .tsx)
- React (.jsx)
- Java (.java)
- Go (.go)
- Rust (.rs)
- C/C++ (.c, .cpp)
- C# (.cs)
- PHP (.php)
- Ruby (.rb)
- Swift (.swift)
- Kotlin (.kt)

## ⚙️ 고급 설정

### 워크플로우 커스터마이징

`.github/workflows/ai-code-review.yml` 파일을 수정하여:

- **특정 브랜치만 리뷰**: `branches: [main, develop]` 추가
- **특정 파일 제외**: `paths-ignore` 사용
- **리뷰 빈도 조절**: `types` 설정 변경

### 리뷰 품질 조정

`.github/scripts/ai_code_review.py`에서:

- **리뷰 깊이 조절**: `max_tokens` 값 변경 (현재: 2000)
- **검토 파일 크기**: `content[:5000]` 값 조정
- **코멘트 개수 제한**: `inline_comments[:5]` 숫자 변경

## 🔍 트러블슈팅

### API 키 오류
```
Error: Missing required API keys
```
→ GitHub Secrets에서 `ANTHROPIC_API_KEY`가 올바르게 설정되었는지 확인

### 권한 오류
```
403 Forbidden
```
→ Repository의 Actions 권한 설정 확인

### 스크립트 실행 오류
- **Actions** 탭에서 워크플로우 로그 확인
- Python 의존성 설치 실패 시 `requirements.txt` 파일 추가 고려

## 📈 사용 통계

GitHub Actions의 **Actions** 탭에서:
- 워크플로우 실행 횟수
- 평균 실행 시간
- 성공/실패율 확인 가능

## 💰 비용 안내

### Anthropic Claude API
- 사용량에 따른 과금
- 토큰당 요금: [Anthropic 가격 정책](https://www.anthropic.com/pricing) 참조

### GitHub Actions
- 퍼블릭 저장소: 무료
- 프라이빗 저장소: 월 2000분 무료, 초과 시 과금

## 🔄 업데이트

새로운 기능이나 개선사항이 있을 때:

1. `.github/scripts/ai_code_review.py` 업데이트
2. 변경사항을 커밋하고 푸시
3. 다음 PR부터 새로운 버전이 적용됩니다

---

## 🎉 설정 완료!

이제 PR을 생성할 때마다 Claude AI가 자동으로 코드를 리뷰해드립니다!

궁금한 점이나 문제가 발생하면:
1. GitHub Actions 로그 확인
2. 이슈를 생성하여 문의
3. 설정 가이드 재확인

**Happy Coding! 🚀**