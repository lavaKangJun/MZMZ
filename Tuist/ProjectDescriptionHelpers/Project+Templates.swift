import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
    static let organizationName = "Junyoung"
    /// Apple Developer 팀 ID.
    ///
    /// Xcode 에서 고른 값은 pbxproj 에만 남아 `tuist generate` 하면 날아간다.
    /// App Attest entitlement 서명에 이 팀이 필요하므로 여기 박아 둔다.
    static let developmentTeam = "KPUSDZ4348"

    /// 사용자에게 보이는 버전(CFBundleShortVersionString).
    /// 앱스토어 버전 표기에 쓰인다.
    static let marketingVersion = "1.0.0"
    /// 빌드 번호(CFBundleVersion).
    ///
    /// 앱과 위젯이 반드시 같은 값이어야 업로드가 통과한다.
    static let buildVersion = "4"
    /// Helper function to create the Project for this ExampleApp
    public static func app(
        name: String,
        platform: Platform,
        dependencies: [TargetDependency]
    ) -> Project {
        let targets = makeAppTargets(
            name: name,
            platform: platform,
            dependencies: dependencies
        )
        let extensionTarget = makeAppExtensionTargets(
            appName: name,
            extensionName: "WidzetExtension",
            infoPlist: [
                "KAKAO_REST_KEY": "$(KAKAO_REST_KEY)",
                "AIR_KOREA_KEY": "$(AIR_KOREA_KEY)",
                "CFBundleShortVersionString": .string(marketingVersion),
                "CFBundleVersion": .string(buildVersion),
                "NSExtension": .dictionary([
                    "NSExtensionPointIdentifier": .string("com.apple.widgetkit-extension")
                ]),
                // 앱 본체와 같은 값. 수출 규정 확인은 본체 Info.plist 를
                // 보지만, 익스텐션에도 두어 번들 간 값이 어긋나지 않게 한다.
                "ITSAppUsesNonExemptEncryption": false,
                "CFBundleDisplayName": "MZMZWidget"
            ],
            dependencies: [
                .project(target: "Domain", path: .relativeToCurrentFile("../../Domain")),
                .project(target: "Repository", path: .relativeToCurrentFile("../../Repository")),
                .project(target: "DustListView", path: .relativeToCurrentFile("../../DustListView"))
            ]
        )
        
        return Project(name: name,
                       organizationName: organizationName,
                       options: .options(
                        disableBundleAccessors: true,
                        disableSynthesizedResourceAccessors: true
                       ),
                       settings: .settings( base: [
                        "SWIFT_VERSION": "6.0",
                        "SWIFT_STRICT_CONCURRENCY": "minimal",
                        "DEVELOPMENT_TEAM": .string(developmentTeam)
                       ]),
                       targets: targets + extensionTarget,
                       resourceSynthesizers: [])
    }
    
    public static func makeAppExtensionTargets(
        appName: String,
        extensionName: String,
        infoPlist: [String: Plist.Value] = [:],
        dependencies: [TargetDependency],
        withTest: Bool = true
    ) -> [Target] {
        
        let targetName = "\(appName)\(extensionName)"
        
        return [.target(
            name: targetName,
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "\(organizationName).\(appName).\(extensionName)",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: [
                "AppExtensions/\(targetName)/Sources/**"
            ],
            resources: [
                "AppExtensions/\(targetName)/Resources/**"
            ],
            entitlements: Entitlements.file(path: "AppExtensions/\(targetName)/\(targetName).entitlements"),
            dependencies: dependencies,
            settings: .settings(configurations: [
                .debug(name: "Debug", xcconfig: "Secrets.xcconfig"),
                .release(name: "Release", xcconfig: "Secrets.xcconfig")
            ])
        )]
    }
    
    public static func framework(
        name: String,
        packages: [Package],
        dependencies: [TargetDependency]
    ) -> Project {
        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            settings: .settings( base: [
             "SWIFT_VERSION": "6.0",
             "PRODUCT_NAME": "\(name)",
             "PRODUCT_MODULE_NAME": "\(name)",
             "DEFINES_MODULE": "YES",
             "SWIFT_STRICT_CONCURRENCY": "minimal"
            ]),
            targets: [
                .target(name: name,
                        destinations: [.iPhone],
                        product: .framework,
                        bundleId: "\(organizationName).\(name)",
                        deploymentTargets: .iOS("18.0"),
                        infoPlist: .extendingDefault(with: [:]),
                        sources: ["Sources/**"],
                        resources: ["Resources/**"],
                        dependencies: dependencies
                       )
            ],
            resourceSynthesizers: []
        )
    }
    
    public static func frameworkWithTest(
        name: String,
        packages: [Package],
        dependencies: [TargetDependency]
    ) -> Project {
        return  Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            settings: .settings( base: [
             "SWIFT_VERSION": "6.0",
             "SWIFT_STRICT_CONCURRENCY": "minimal",
             "DEFINES_MODULE": "YES"
            ]),
            targets: [
                .target(
                    name: name,
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "\(organizationName).\(name)",
                    deploymentTargets: .iOS("18.0"),
                    infoPlist: .extendingDefault(with: [:]),
                    sources: ["Sources/**"],
                    resources: ["Resources/**"],
                    dependencies: dependencies
                ),
                .target(
                name: "\(name)Tests",
                destinations: [.iPhone],
                product: .unitTests,
                bundleId: "\(organizationName).\(name)Tests",
                deploymentTargets: .iOS("18.0"),
                infoPlist: .default,
                sources: ["Tests/**"],
                resources: ["Resources/**"],
                dependencies: dependencies
            )],
            resourceSynthesizers: []
        )
    }
    
    // MARK: - Private

    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(
        name: String,
        dependencies: [TargetDependency] = []
    ) -> [Target] {
        return [.target(
            name: name,
            destinations: [.iPhone],
            product: .framework,
            bundleId: "\(organizationName).\(name)",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: dependencies)
        ]
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(name: String, platform: Platform, dependencies: [TargetDependency]) -> [Target] {
        let platform: Platform = platform
        let infoPlist: [String: Plist.Value] = [
            "KAKAO_REST_KEY": "$(KAKAO_REST_KEY)",
            "AIR_KOREA_KEY": "$(AIR_KOREA_KEY)",
            "CFBundleShortVersionString": .string(marketingVersion),
            "CFBundleVersion": .string(buildVersion),
            // HTTPS 외에 별도 암호화를 쓰지 않아 수출 규정 면제 대상이다.
            // 선언해두면 업로드할 때마다 묻지 않는다.
            "ITSAppUsesNonExemptEncryption": false,
            "UILaunchStoryboardName": "LaunchScreen",
            "UIApplicationSceneManifest": [
                "UIApplicationSupportsMultipleScenes": false,
                "UISceneConfigurations": []
            ]
            // NSAppTransportSecurity 를 두지 않는다.
            //
            // 예전에는 에어코리아를 앱에서 직접 불러(http://apis.data.go.kr)
            // NSAllowsArbitraryLoads 가 필요했지만, 지금은 그 조회가 우리
            // 서버(nearestStation)로 넘어가 앱이 여는 연결은 전부 HTTPS 다.
            // 실제 호출부는 RepositoryImp 의 findLocation(카카오, https)과
            // nearestStation(https) 둘뿐이다.
            //
            // 평문 HTTP 를 열어두면 심사에서 사유를 요구받을 수 있어 닫는다.
            // Remote.Endpoint 에 남은 http:// 케이스들은 호출부가 없는
            // 죽은 코드다. 되살리려면 ATS 예외부터 다시 논의해야 한다.
        ]

        // 아이폰 전용.
        //
        // .iPad 를 넣으면 App Store Connect 가 13인치 아이패드 스크린샷을
        // 요구하고, 심사에서도 아이패드로 실행해 본다. UI 가 아이폰 기준
        // 고정 여백으로 짜여 있어(예: PulseLoader 150pt 고정) 큰 화면에서
        // 검증된 적이 없다. 다듬은 뒤 다음 버전에서 다시 넣는다.
        return [.target(name: name,
                        destinations: [.iPhone],
                        product: .app,
                        bundleId: "\(organizationName).\(name)",
                        deploymentTargets: .iOS("18.0"),
                        infoPlist: .extendingDefault(with: infoPlist),
                        sources: ["Sources/**"],
                        resources: ["Resources/**"],
                        entitlements: Entitlements.file(path: "./MZMZ.entitlements"),
                        dependencies: dependencies,
                        settings: .settings(configurations: [
                            .debug(name: "Debug", xcconfig: "Secrets.xcconfig"),
                            .release(name: "Release", xcconfig: "Secrets.xcconfig")
                        ])
                       )
        ]
    }
}
