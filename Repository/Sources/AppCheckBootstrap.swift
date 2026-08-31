//
//  AppCheckBootstrap.swift
//  Repository
//
//  Firebase App Check 초기화.
//
//  서버(nearestStation)는 URL 만 알면 누구나 부를 수 있는 공개 엔드포인트라,
//  App Check 로 정품 애플 기기에서 온 요청인지 증명한다.
//  증명은 번들 ID 단위라 앱과 위젯이 각자 자기 GoogleService-Info.plist 로
//  따로 초기화한다(익스텐션의 Bundle.main 은 .appex 번들이다).
//

import Foundation
import FirebaseCore
import FirebaseAppCheck

public enum AppCheckBootstrap {
    /// 증명 방식.
    ///
    /// App Attest 가 더 강하지만(기기 + 앱 바이너리 무결성) 앱 익스텐션에서는
    /// 쓸 수 없다. 위젯에서 시도하면 Firebase 가
    /// "The attestation provider AppAttestProvider is not supported on
    /// current platform and OS version" 으로 실패한다.
    /// 그래서 익스텐션은 기기 정품 여부만 보는 DeviceCheck 를 쓴다.
    /// 서버·봇·시뮬레이터를 막는 실효는 둘이 사실상 같다.
    public enum Attestation {
        /// 앱 본체용.
        case appAttest
        /// 위젯 등 앱 익스텐션용.
        case deviceCheck
    }

    /// 앱과 위젯 익스텐션 진입점에서 각각 한 번씩 호출한다.
    ///
    /// 공급자 팩토리는 반드시 `FirebaseApp.configure()` **전에** 지정해야
    /// 한다. 순서가 바뀌면 기본 공급자로 초기화돼 지정한 방식이 안 걸린다.
    /// - Parameter attestation: 이 프로세스에서 쓸 증명 방식
    public static func configure(_ attestation: Attestation) {
        // 이미 초기화된 뒤 또 부르면 Firebase 가 경고를 낸다.
        guard FirebaseApp.app() == nil else { return }

        #if DEBUG
        // 시뮬레이터와 디버그 빌드는 App Attest / DeviceCheck 를 못 쓴다.
        // 콘솔에 찍히는 디버그 토큰을 Firebase 콘솔에 등록해야 통과한다.
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        switch attestation {
        case .appAttest:
            AppCheck.setAppCheckProviderFactory(MZMZAppAttestFactory())
        case .deviceCheck:
            AppCheck.setAppCheckProviderFactory(MZMZDeviceCheckFactory())
        }
        #endif

        FirebaseApp.configure()
    }
}

#if !DEBUG
/// App Attest 공급자 팩토리. 앱 본체에서만 동작한다.
private final class MZMZAppAttestFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppAttestProvider(app: app)
    }
}

/// DeviceCheck 공급자 팩토리. 익스텐션에서 쓴다.
private final class MZMZDeviceCheckFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return DeviceCheckProvider(app: app)
    }
}
#endif
