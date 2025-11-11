## MZMZ
원하는 지역의 미세먼지 정보를 보여주는 미세먼지 앱

### Tech stack
Clean Architecture, SwiftUI, async/await, Swift Testing, Combine, Tuist, GitHub Actions, Claude
  
### 프로젝트 구조
- 클린아키텍쳐 적용
<img width="725" height="443" alt="graph" src="https://github.com/user-attachments/assets/35d2b33e-7ef5-4860-9e00-565b69108f0f" />

#### Domain
Usecase와 Entity, 그리고 Usecase 구현에 필요한 Repository 인터페이스를 포함.
가장 안쪽에 있는 layer로 다른 모듈과 의존성을 갖고 있지 않음

#### Repository
Repository의 실체 구현 프레임 워크로, Remote/Local 에서 데이터를 가져옴

#### Presentations
각 화면을 구성하는 UI FrameWork
- DustListView: 추가된 지역의 미세먼지 리스트로 메인 화면
- CityDetail: 각 지역에 대한 미세먼지 상세 정보 화면
- AddCity: 지역 검색 화면

#### MZMZ
살제 MZMZ앱 프로젝트로 모든 프레임 워크들을 의존함.
홈 화면 위젯 기능을 포함.

