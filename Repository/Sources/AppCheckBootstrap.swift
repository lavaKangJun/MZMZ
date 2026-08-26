//
//  AppCheckBootstrap.swift
//  Repository
//
//  Firebase App Check 초기화.
//
//  서버(nearestStation)는 URL 만 알면 누구나 부를 수 있는 공개 엔드포인트라,
//  App Check 로 "등록된 이 앱이, 진짜 애플 기기에서" 보낸 요청인지 증명한다.
//  증명은 번들 ID 단위라 앱과 위젯이 각자 자기 GoogleService-Info.plist 로
//  따로 초기화한다(익스텐션의 Bundle.main 은 .appex 번들이다).
//

import Foundation
import FirebaseCore
import FirebaseAppCheck

public enum AppCheckBootstrap {
    /// 앱과 위젯 익스텐션 진입점에서 각각 한 번씩 호출한다.
    ///
    /// 공급자 팩토리는 반드시 `FirebaseApp.configure()` **전에** 지정해야
    /// 한다. 순서가 바뀌면 기본 공급자로 초기화돼 App Attest 가 안 걸린다.
    public static func configure() {
        // 이미 초기화된 뒤 또 부르면 Firebase 가 경고를 낸다.
        guard FirebaseApp.app() == nil else { return }

        #if DEBUG
        // 시뮬레이터와 디버그 빌드는 App Attest 를 못 쓴다. 콘솔에 찍히는
        // 디버그 토큰을 Firebase 콘솔에 등록해야 통과한다.
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(AppAttestProviderFactory())
        #endif

        FirebaseApp.configure()
    }
}

#if !DEBUG
/// App Attest(iOS 14+) 공급자 팩토리.
private final class AppAttestProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppAttestProvider(app: app)
    }
}
#endif
