#!/usr/bin/env python3

import os
import sys
import json
from github import Github
from anthropic import Anthropic
import re

class AICodeReviewer:
    def __init__(self):
        self.github_token = os.environ.get('GITHUB_TOKEN')
        self.anthropic_api_key = os.environ.get('ANTHROPIC_API_KEY')
        self.pr_number = int(os.environ.get('PR_NUMBER', 0))
        self.repo_name = os.environ.get('GITHUB_REPOSITORY', '')
        self.changed_files = os.environ.get('CHANGED_FILES', '').split(',')
        
        if not self.github_token or not self.anthropic_api_key:
            print("Error: Missing required API keys")
            sys.exit(1)
        
        self.github = Github(self.github_token)
        self.anthropic = Anthropic(api_key=self.anthropic_api_key)
        self.repo = self.github.get_repo(self.repo_name)
        self.pr = self.repo.get_pull(self.pr_number)
        
        # 켄트 백의 TDD 원칙에 기반한 패턴들
        self.tdd_patterns = {
            'test_files': [r'.*test.*\.py$', r'.*_test\.js$', r'.*\.test\.ts$', r'.*\.spec\..*$', r'.*Tests?\..*$'],
            'test_keywords': ['test_', 'it(', 'describe(', 'context(', '@Test', 'should', 'when', 'given'],
            'assertion_keywords': ['assert', 'expect', 'should', 'verify', 'toBe', 'toEqual'],
            'red_green_refactor': {
                'red_indicators': ['failing', 'fail', 'error', 'broken'],
                'green_indicators': ['passing', 'pass', 'success'],
                'refactor_indicators': ['refactor', 'cleanup', 'improve']
            },
            'test_structure': {
                'arrange_act_assert': ['arrange', 'act', 'assert', 'given', 'when', 'then'],
                'four_phase_test': ['setup', 'exercise', 'verify', 'teardown']
            }
        }
        
        # 로버트 마틴의 클린 아키텍처와 SOLID 원칙
        self.clean_architecture_violations = {
            'dependency_inversion': {
                'patterns': [r'from.*\.infrastructure', r'import.*database', r'new Database', r'mysql', r'postgresql'],
                'description': '상위 모듈이 하위 모듈에 의존하면 안됩니다. 추상화에 의존하세요.'
            },
            'single_responsibility': {
                'patterns': [r'class.*Manager.*Controller', r'class.*Service.*Repository', r'def.*and.*or.*'],
                'description': '클래스는 하나의 책임만 가져야 합니다.'
            },
            'interface_segregation': {
                'patterns': [r'class.*Interface.*{[\s\S]*?def.*unused'],
                'description': '클라이언트는 자신이 사용하지 않는 메서드에 의존하면 안됩니다.'
            },
            'open_closed': {
                'patterns': [r'if.*isinstance', r'elif.*type', r'switch.*case'],
                'description': '확장에는 열려있고 수정에는 닫혀있어야 합니다.'
            },
            'liskov_substitution': {
                'patterns': [r'raise NotImplementedError', r'pass\s*#.*not.*implemented'],
                'description': '서브타입은 기반타입을 완전히 대체할 수 있어야 합니다.'
            },
            'layer_violations': {
                'ui_to_data': [r'from.*\.data', r'import.*repository.*in.*ui'],
                'domain_to_infra': [r'from.*\.infrastructure.*in.*domain'],
                'use_case_to_ui': [r'from.*\.ui.*in.*use.*case']
            }
        }
        
        # 마틴 파울러의 리팩터링 코드 스멜 확장
        self.code_smells = {
            'long_method': {'threshold': 20, 'description': '메서드가 너무 깁니다. Extract Method를 사용하세요.'},
            'long_parameter_list': {'threshold': 3, 'description': '매개변수가 너무 많습니다. Parameter Object 패턴을 고려하세요.'},
            'duplicate_code': {
                'patterns': [r'(.*\n){3,}\1{3,}'],
                'description': '중복 코드가 발견되었습니다. Extract Method/Class를 사용하세요.'
            },
            'large_class': {'threshold': 100, 'description': '클래스가 너무 큽니다. Extract Class를 고려하세요.'},
            'god_class': {
                'patterns': [r'class.*{[\s\S]*?(def.*\n){15,}'],
                'description': '신 클래스(God Class)가 발견되었습니다. 책임을 분산시키세요.'
            },
            'feature_envy': {
                'patterns': [r'\w+\.\w+\.\w+\.\w+', r'other_object\.[\w\.]+{3,}'],
                'description': '다른 객체의 기능에 과도하게 의존합니다. Move Method를 고려하세요.'
            },
            'data_clumps': {
                'patterns': [r'def.*\([^)]*,.*[^)]*,.*[^)]*,.*[^)]*\)'],
                'description': '데이터 덩어리가 발견되었습니다. Parameter Object를 만드세요.'
            },
            'primitive_obsession': {
                'patterns': [r'def.*\(.*str.*str.*str', r'id_\w+.*:.*int', r'email.*:.*str'],
                'description': '원시 타입 강박이 발견되었습니다. Value Object를 만드세요.'
            },
            'message_chains': {
                'patterns': [r'\w+\.get\w+\(\)\.get\w+\(\)\.get\w+\(\)'],
                'description': '메시지 체인이 발견되었습니다. Hide Delegate를 사용하세요.'
            },
            'middle_man': {
                'patterns': [r'def \w+\(.*\):\s*return self\.\w+\.\w+\('],
                'description': '중개자 패턴이 과도합니다. Remove Middle Man을 고려하세요.'
            },
            'inappropriate_intimacy': {
                'patterns': [r'\._\w+', r'friend\.\w+'],
                'description': '부적절한 친밀도가 발견되었습니다. Move Method/Field를 고려하세요.'
            }
        }
    
    def get_file_diff(self, file_path):
        """PR에서 파일의 변경사항 가져오기"""
        for file in self.pr.get_files():
            if file.filename == file_path:
                return file.patch if file.patch else ""
        return ""
    
    def get_file_content(self, file_path):
        """파일의 전체 내용 가져오기"""
        try:
            contents = self.repo.get_contents(file_path, ref=self.pr.head.sha)
            return contents.decoded_content.decode('utf-8')
        except:
            return ""
    
    def detect_tdd_violations(self, file_path, content, diff):
        """켄트 백의 TDD 원칙 기반 위반사항 검출 - 테스트 코드가 있을 때만"""
        violations = []
        
        # 테스트 파일인지 확인
        is_test_file = any(re.match(pattern, file_path) for pattern in self.tdd_patterns['test_files'])
        
        # 테스트 코드가 포함된 PR인지 확인
        has_test_files = any(any(re.match(pattern, f) for pattern in self.tdd_patterns['test_files']) 
                           for f in self.changed_files if f)
        
        # 테스트 코드가 없으면 TDD 관련 리뷰 생략
        if not has_test_files:
            return violations
        
        if is_test_file:
            # 테스트 파일에서만 TDD 품질 검사
            # Given-When-Then 또는 Arrange-Act-Assert 구조 검사
            has_structure = any(keyword in content.lower() for keyword in self.tdd_patterns['test_structure']['arrange_act_assert'])
            if not has_structure:
                violations.append("🟡 **[중간] TDD 테스트 구조**: Given-When-Then 또는 Arrange-Act-Assert 구조가 명확하지 않습니다.\n"
                                "  - **해결책**: 테스트를 세 단계로 명확히 구분하여 가독성 향상")
            
            # 어서션 품질 검사
            assertions = re.findall(r'(assert\w*|expect\w*|should\w*)', content, re.IGNORECASE)
            if len(assertions) < 1:
                violations.append("🔴 **[높음] TDD 검증 부족**: 테스트에 명시적인 어서션이 없습니다.\n"
                                "  - **근거**: 테스트의 핵심은 기대값과 실제값의 비교\n"
                                "  - **해결책**: 각 테스트마다 최소 하나의 명확한 어서션 추가")
            
            # 테스트 독립성 검사
            if 'setUp' in content and 'global' in content:
                violations.append("🟡 **[중간] TDD Independent 위반**: 전역 상태에 의존하는 테스트가 있습니다.\n"
                                "  - **해결책**: 각 테스트는 독립적으로 실행 가능하도록 격리")
        
        return violations
    
    def detect_clean_architecture_violations(self, content, file_path):
        """로버트 마틴의 클린 아키텍처와 SOLID 원칙 위반사항 검출"""
        violations = []
        
        # 1. 의존성 역전 원칙(DIP) 위반
        for pattern in self.clean_architecture_violations['dependency_inversion']['patterns']:
            if re.search(pattern, content, re.IGNORECASE):
                violations.append(f"🔴 **[높음] SOLID-DIP 위반**: {self.clean_architecture_violations['dependency_inversion']['description']}\n"
                                f"  - **근거**: 로버트 마틴의 의존성 역전 원칙\n"
                                f"  - **영향**: 결합도 증가, 테스트 어려움\n"
                                f"  - **해결책**: Repository 패턴, Dependency Injection 사용")
        
        # 2. 단일 책임 원칙(SRP) 위반
        for pattern in self.clean_architecture_violations['single_responsibility']['patterns']:
            if re.search(pattern, content, re.IGNORECASE):
                violations.append(f"🟡 **[중간] SOLID-SRP 위반**: {self.clean_architecture_violations['single_responsibility']['description']}\n"
                                f"  - **해결책**: Extract Class, Extract Method 적용")
        
        # 3. 리스코프 치환 원칙(LSP) 위반
        for pattern in self.clean_architecture_violations['liskov_substitution']['patterns']:
            if re.search(pattern, content, re.IGNORECASE):
                violations.append(f"🟡 **[중간] SOLID-LSP 위반**: {self.clean_architecture_violations['liskov_substitution']['description']}\n"
                                f"  - **해결책**: 상속보다 컴포지션 사용 고려")
        
        # 4. 레이어 경계 위반 검사 (Clean Architecture)
        if '/domain/' in file_path:
            for pattern in self.clean_architecture_violations['layer_violations']['domain_to_infra']:
                if re.search(pattern, content, re.IGNORECASE):
                    violations.append("🔴 **[높음] Clean Architecture 레이어 위반**: 도메인이 인프라에 의존합니다.\n"
                                    "  - **근거**: 내부 원은 외부 원을 알아서는 안됨\n"
                                    "  - **해결책**: 포트와 어댑터 패턴 적용")
        
        return violations
    
    def detect_code_smells(self, content, diff):
        """마틴 파울러의 리팩터링 냄새 탐지"""
        smells = []
        lines = content.split('\n')
        
        # Long Method 검사
        methods = re.findall(r'(def\s+\w+.*?(?=\n(?:def|class|$)))', content, re.DOTALL)
        for method in methods:
            if len(method.split('\n')) > self.code_smells['long_method']:
                method_name = re.search(r'def\s+(\w+)', method).group(1)
                line_count = len(method.split('\n'))
                smells.append(f"🔧 **Long Method**: {method_name} 메서드가 너무 깁니다 ({line_count}줄). Extract Method 리팩터링을 고려해주세요.")
        
        # Long Parameter List 검사
        param_matches = re.findall(r'def\s+\w+\(([^)]*)\)', content)
        for params in param_matches:
            param_count = len([p.strip() for p in params.split(',') if p.strip() and p.strip() != 'self'])
            if param_count > self.code_smells['long_parameter_list']:
                smells.append(f"🔧 **Long Parameter List**: 매개변수가 {param_count}개입니다. Parameter Object 패턴을 사용해주세요.")
        
        # Feature Envy 검사 (긴 메서드 체인)
        if re.search(r'\w+\.\w+\.\w+\.\w+', content):
            smells.append("🔧 **Feature Envy**: 긴 메서드 체인이 발견되었습니다. 데메테르 법칙을 고려해주세요.")
        
        # Duplicate Code 검사 (간단한 패턴)
        for i, line in enumerate(lines[:-3]):
            if line.strip() and lines[i+1:i+4] == [line] * 3:
                smells.append(f"🔧 **Duplicate Code**: {i+1}번째 줄 근처에 중복 코드가 있습니다. Extract Method를 사용해주세요.")
        
        # Large Class 검사
        class_matches = re.findall(r'(class\s+\w+.*?(?=\nclass|$))', content, re.DOTALL)
        for class_content in class_matches:
            if len(class_content.split('\n')) > self.code_smells['large_class']:
                class_name = re.search(r'class\s+(\w+)', class_content).group(1)
                smells.append(f"🔧 **Large Class**: {class_name} 클래스가 너무 큽니다. Extract Class 리팩터링을 고려해주세요.")
        
        return smells
    
    def _has_corresponding_tests(self, file_path):
        """해당 파일에 대응하는 테스트 파일이 있는지 확인"""
        base_name = os.path.splitext(os.path.basename(file_path))[0]
        test_patterns = [f'test_{base_name}.py', f'{base_name}_test.py', f'{base_name}.test.js']
        
        try:
            for pattern in test_patterns:
                try:
                    self.repo.get_contents(f'tests/{pattern}')
                    return True
                except:
                    try:
                        self.repo.get_contents(f'test/{pattern}')
                        return True
                    except:
                        continue
        except:
            pass
        return False
    
    def analyze_code(self, file_path, diff, content):
        """TDD, 클린 아키텍처, 리팩터링 원칙을 기반으로 한 고급 코드 분석"""
        
        # 파일 확장자에 따른 언어 판별
        ext = os.path.splitext(file_path)[1]
        language_map = {
            '.py': 'Python',
            '.js': 'JavaScript',
            '.ts': 'TypeScript',
            '.jsx': 'React',
            '.tsx': 'TypeScript React',
            '.java': 'Java',
            '.go': 'Go',
            '.rs': 'Rust',
            '.c': 'C',
            '.cpp': 'C++',
            '.cs': 'C#',
            '.php': 'PHP',
            '.rb': 'Ruby',
            '.swift': 'Swift',
            '.kt': 'Kotlin'
        }
        language = language_map.get(ext, 'Unknown')
        
        # 전문가 지식 기반 검사 실행
        tdd_violations = self.detect_tdd_violations(file_path, content, diff)
        architecture_violations = self.detect_clean_architecture_violations(content, file_path)
        code_smells = self.detect_code_smells(content, diff)
        structural_improvements = self.suggest_structural_improvements(content, file_path)
        
        # 종합적인 프롬프트 생성
        expert_insights = "\n".join(tdd_violations + architecture_violations + code_smells + structural_improvements)
        
        prompt = f"""
        당신은 켄트 백의 TDD, 로버트 마틴의 클린 아키텍처, 그리고 마틴 파울러의 리팩터링 원칙에 정통한 시니어 소프트웨어 아키텍트입니다.
        
        다음 {language} 코드를 검토하고, 전문가 수준의 피드백을 제공해주세요.
        
        📁 **파일**: {file_path}
        
        🔄 **변경사항 (diff)**:
        ```diff
        {diff}
        ```
        
        📋 **전체 파일 내용**:
        ```{language.lower()}
        {content[:4000]}
        ```
        
        🔍 **자동 감지된 이슈**:
        {expert_insights if expert_insights else '자동 감지된 이슈가 없습니다.'}
        
        ## 📊 분석 영역
        
        ### 🧪 TDD (Test-Driven Development) 관점
        - Red-Green-Refactor 사이클 준수 여부
        - 테스트 커버리지 및 테스트 품질
        - Test First 원칙 적용
        - 테스트 코드의 가독성 (Given-When-Then)
        - Fast, Independent, Repeatable, Self-validating, Timely 원칙
        
        ### 🏗️ Clean Architecture 관점
        - SOLID 원칙 준수 (특히 의존성 역전)
        - 레이어 간 의존성 방향
        - 도메인 로직의 순수성
        - 인터페이스를 통한 추상화
        - 프레임워크 독립성
        
        ### 🔧 Refactoring (코드 냄새) 관점
        - Long Method, Large Class
        - Duplicate Code, Dead Code
        - Feature Envy, Data Clumps
        - Long Parameter List
        - God Class, Shotgun Surgery
        - Comments (코드로 표현 가능한 것들)
        
        ### 🛡️ 추가 품질 검사
        - 성능 및 메모리 효율성
        - 보안 취약점
        - 예외 처리 및 에러 핸들링
        - 동시성 안전성
        
        ## 📝 응답 형식
        
        각 발견된 이슈에 대해:
        - 🔴 **[심각도]** 이슈 제목
          - **근거**: 어떤 원칙을 위반했는지
          - **영향**: 코드에 미치는 부정적 영향
          - **해결책**: 구체적인 리팩터링 방법
          - **예시 코드**: (필요한 경우)
        
        긍정적인 부분:
        - ✅ **잘 적용된 원칙들**
        
        ## 🎯 종합 평가
        - **TDD 점수**: /10
        - **Clean Architecture 점수**: /10  
        - **코드 품질 점수**: /10
        - **종합 추천사항**
        
        전문가 수준의 상세하고 실용적인 피드백을 마크다운으로 작성해주세요.
        """
        
        try:
            response = self.anthropic.messages.create(
                model="claude-3-opus-20240229",
                max_tokens=3000,
                temperature=0,
                messages=[
                    {"role": "user", "content": prompt}
                ]
            )
            return response.content[0].text
        except Exception as e:
            return f"코드 분석 중 오류 발생: {str(e)}"
    
    def parse_review_to_comments(self, review_text, file_path, diff):
        """리뷰 텍스트를 라인별 코멘트로 변환"""
        comments = []
        
        # diff에서 변경된 라인 번호 추출
        diff_lines = diff.split('\n')
        line_mapping = {}
        current_line = 0
        
        for line in diff_lines:
            if line.startswith('@@'):
                # @@ -old_start,old_count +new_start,new_count @@
                match = re.search(r'\+(\d+)', line)
                if match:
                    current_line = int(match.group(1))
            elif line.startswith('+') and not line.startswith('+++'):
                line_mapping[current_line] = line[1:]
                current_line += 1
            elif not line.startswith('-'):
                current_line += 1
        
        # 심각한 이슈들을 찾아서 라인 코멘트로 변환
        serious_issues = re.findall(r'🔴.*?(?=🔴|💡|✅|$)', review_text, re.DOTALL)
        
        for issue in serious_issues[:3]:  # 최대 3개의 주요 이슈만
            # 코드 스니펫이나 특정 패턴 찾기
            for line_num, line_content in line_mapping.items():
                # 이슈가 해당 라인과 관련이 있는지 간단히 체크
                if any(keyword in line_content.lower() for keyword in ['function', 'def', 'class', 'if', 'for', 'while', 'return']):
                    comments.append({
                        'path': file_path,
                        'line': line_num,
                        'body': issue.strip()
                    })
                    break
        
        return comments
    
    def post_review(self):
        """PR에 리뷰 코멘트 작성"""
        all_reviews = []
        inline_comments = []
        
        # 변경된 파일들 분석
        for file_path in self.changed_files:
            if not file_path or file_path.startswith('.'):
                continue
            
            print(f"Analyzing {file_path}...")
            
            diff = self.get_file_diff(file_path)
            content = self.get_file_content(file_path)
            
            if diff:
                review = self.analyze_code(file_path, diff, content)
                all_reviews.append(f"## 📁 {file_path}\n\n{review}")
                
                # 라인별 코멘트 생성
                file_comments = self.parse_review_to_comments(review, file_path, diff)
                inline_comments.extend(file_comments)
        
        # 전체 리뷰 요약 작성
        summary = self.create_summary(all_reviews)
        
        # PR에 리뷰 코멘트 작성
        try:
            # 전체 리뷰 코멘트
            review_body = f"""# 🤖 AI 코드 리뷰 결과

{summary}

---

{chr(10).join(all_reviews)}

---

*이 리뷰는 Claude AI에 의해 자동으로 생성되었습니다. 제안사항은 참고용이며, 최종 판단은 개발자가 해주세요.*
"""
            
            # PR 리뷰 생성
            self.pr.create_review(
                body=review_body,
                event='COMMENT'
            )
            
            # 라인별 코멘트 추가 (간단한 방법)
            for comment in inline_comments[:5]:  # 최대 5개 코멘트
                try:
                    self.pr.create_issue_comment(
                        f"**{comment['path']}** (Line {comment['line']}):\n{comment['body']}"
                    )
                except:
                    pass
            
            print("✅ 코드 리뷰가 성공적으로 작성되었습니다!")
            
        except Exception as e:
            print(f"❌ 리뷰 작성 중 오류 발생: {str(e)}")
            # 오류 발생 시에도 기본 코멘트는 남기기
            try:
                self.pr.create_issue_comment(
                    f"🤖 AI 코드 리뷰를 시도했으나 일부 오류가 발생했습니다.\n\n오류: {str(e)}"
                )
            except:
                pass
    
    def create_summary(self, reviews):
        """전체 리뷰 요약 생성"""
        high_priority = len(re.findall(r'🔴.*?높음', ''.join(reviews)))
        medium_priority = len(re.findall(r'🔴.*?중간', ''.join(reviews)))
        low_priority = len(re.findall(r'🔴.*?낮음', ''.join(reviews)))
        positive = len(re.findall(r'✅', ''.join(reviews)))
        
        summary = f"""## 📊 리뷰 요약

- 🔴 **높은 우선순위 이슈**: {high_priority}개
- 🟡 **중간 우선순위 이슈**: {medium_priority}개
- 🟢 **낮은 우선순위 이슈**: {low_priority}개
- ✅ **잘 작성된 부분**: {positive}개

### 📋 검토된 파일
{chr(10).join(f"- {f}" for f in self.changed_files if f and not f.startswith('.'))}
"""
        
        if high_priority > 0:
            summary += "\n⚠️ **높은 우선순위 이슈가 발견되었습니다. 머지 전 반드시 확인해주세요.**"
        
        return summary

def main():
    try:
        reviewer = AICodeReviewer()
        reviewer.post_review()
    except Exception as e:
        print(f"오류 발생: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()