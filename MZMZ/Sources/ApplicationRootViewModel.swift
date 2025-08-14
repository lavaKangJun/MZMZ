//
//  ApplicationRootViewModel.swift
//  MZMZ
//
//  Created by 강준영 on 2025/03/08.
//

import Foundation

//@unchecked Sendable은 매우 신중하게 사용해야 하는 기능입니다.
//Swift의 동시성 모델에서는 Sendable 프로토콜을 사용해 여러 스레드 간에 안전하게 전달될 수 있는 타입을 정의합니다.
//기본적으로 Swift 컴파일러는 타입이 Sendable을 준수하는지 자동으로 검사합니다.
//Sendable을 준수하기 위해서는 타입이 동시성 상황에서 데이터 레이스와 같은 문제를 발생시키지 않도록 스레드 안전하게 설계되어야 합니다.
//그러나 일부 경우에는 타입이 실제로는 스레드 안전하지만, 컴파일러가 그 안전성을 자동으로 확인할 수 없는 경우가 있습니다.
//예를 들어, 특정 내부 구현이 스레드 안전한 경우입니다. 이럴 때는 개발자가 해당 타입이 Sendable임을 컴파일러에게 명시할 수 있지만, @unchecked를 붙여 컴파일러가 자동 검사를 생략하도록 지시할 수 있습니다.
//컴파일러가 스레드 안전성을 확인하지 않으므로, 동시성 문제를 스스로 철저히 검토해야 합니다.
//아래의 경우에 사용될 수 있습니다:
//ㄴ 타입의 내부가 실제로 스레드 안전하게 설계되었지만, 컴파일러가 이를 자동으로 인식하지 못하는 경우.
//ㄴ 타입이 주로 불변이거나, 동시성을 고려한 구조로 되어 있을 때.

final class ApplicationRootViewModel: @unchecked Sendable {
    var router: ApplicationRouter?
    
    func prepareInitialScene() {
        self.router?.setupInitScene()
    }
}
