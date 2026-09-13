import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

/// firebase-ios-sdk 패키지 선언.
///
/// Crashlytics 를 import 하는 모듈이 각자 이 패키지를 선언해야 한다.
/// 선언한 타깃이 둘 이상이면 Xcode 가 정적 링크 대신 PackageFrameworks 의
/// 동적 프레임워크로 바꿔 한 벌만 공유한다. 반대로 선언하지 않고 다른
/// 모듈을 통해 얻어걸리게 두면, 링크 방식이 바뀌는 순간 undefined symbol 로
/// 깨진다.
///
/// 버전을 여기 한 곳에만 두어 프로젝트마다 어긋나지 않게 한다.
extension Package {
    public static let firebase = Package.remote(
        url: "https://github.com/firebase/firebase-ios-sdk",
        requirement: .upToNextMajor(from: "12.18.0")
    )
}

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
    static let buildVersion = "7"

    /// Crashlytics dSYM 업로드 빌드 스크립트를 만든다.
    ///
    /// 크래시 리포트를 파일명·줄번호까지 풀어 보려면 빌드가 만든 dSYM 을
    /// 올려야 한다. 안 올리면 콘솔에 주소값만 남은 스택이 쌓인다.
    ///
    /// 파이어베이스가 같이 주는 `run` 래퍼를 쓰지 않는다. 그쪽은
    /// `DWARF_DSYM_FILE_NAME` 하나만 보고 자기 타깃 dSYM 만 올리는데,
    /// 이 프로젝트는 코드가 거의 전부 동적 프레임워크에 있어(앱 본체 6파일 대
    /// 프레임워크 41파일) 정작 크래시가 나는 쪽이 빠진다.
    /// 대신 `upload-symbols` 를 직접 불러 dSYM 폴더를 통째로 넘긴다.
    /// 폴더를 주면 재귀로 훑어 프레임워크 dSYM 까지 전부 올린다.
    ///
    /// 동기로 돌아 업로드가 실패하면 빌드가 깨진다. `run` 은 백그라운드로
    /// 던져(`> /dev/null 2>&1 &`) 실패해도 조용히 넘어가는데, 그러면 심볼이
    /// 빠진 걸 크래시가 올라온 뒤에야 알게 된다. 아카이브가 조금 느려지는
    /// 대신 그 자리에서 알아채는 쪽을 택했다.
    ///
    /// - Parameter googleServicePlist: 이 타깃의 GoogleService-Info.plist
    ///   경로(SRCROOT 기준). 앱과 위젯이 서로 다른 파이어베이스 앱이라
    ///   각자 자기 plist 로 올려야 한다.
    private static func crashlyticsUploadScript(
        googleServicePlist: String
    ) -> TargetScript {
        .post(
            script: #"""
            # Debug 는 dSYM 을 만들지 않는다(DEBUG_INFORMATION_FORMAT = dwarf).
            # 올릴 게 없는데 upload-symbols 를 부르면 빈 폴더라고 실패하므로
            # 여기서 끊는다. 실제 업로드는 Release/아카이브에서만 일어난다.
            if [ "$DEBUG_INFORMATION_FORMAT" != "dwarf-with-dsym" ]; then
                echo "note: dSYM 을 만들지 않는 구성이라 Crashlytics 업로드를 건너뛴다"
                exit 0
            fi

            # SPM 을 Xcode 네이티브 통합으로 쓰고 있어 실행 파일이 저장소가 아니라
            # DerivedData 의 체크아웃에 있다. BUILD_DIR 이
            # .../DerivedData/MZMZ-xxx/Build/Products/... 라 /Build/ 뒤를 잘라내면
            # 형제 디렉터리인 SourcePackages 를 가리킨다.
            UPLOAD_SYMBOLS="${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"

            "$UPLOAD_SYMBOLS" \
                -gsp "$SRCROOT/\#(googleServicePlist)" \
                -p ios \
                "$DWARF_DSYM_FOLDER_PATH"
            """#,
            name: "Upload Crashlytics dSYMs",
            inputPaths: [
                "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}"
            ],
            // 출력물이 없는 스크립트라 Xcode 가 "매 빌드 실행된다" 고 경고한다.
            // 빌드마다 dSYM 이 새로 나오니 매번 도는 게 맞고, 이 플래그로
            // 의도한 동작임을 알려 경고를 없앤다.
            basedOnDependencyAnalysis: false
        )
    }

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
                .package(product: "FirebaseCrashlytics"),
                .project(target: "Domain", path: .relativeToCurrentFile("../../Domain")),
                .project(target: "Repository", path: .relativeToCurrentFile("../../Repository")),
                .project(target: "DustListView", path: .relativeToCurrentFile("../../DustListView")),
                .project(target: "MZMZTesting", path: .relativeToCurrentFile("../../MZMZTesting"))
            ]
        )
        
        return Project(name: name,
                       organizationName: organizationName,
                       options: .options(
                        disableBundleAccessors: true,
                        disableSynthesizedResourceAccessors: true
                       ),
                       packages: [.firebase],
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
            scripts: [crashlyticsUploadScript(
                googleServicePlist: "AppExtensions/\(targetName)/Resources/GoogleService-Info.plist"
            )],
            dependencies: dependencies
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
            // 실제 호출부는 RepositoryImp 의 findLocation 과 nearestStation
            // 둘뿐이고, 지금은 둘 다 우리 서버(https)다.
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
                        // 앱 본체는 Crashlytics 를 import 하지 않지만 반드시 선언해야 한다.
                        // 선언한 타깃이 둘 이상이면 Xcode 가 이 제품을 PackageFrameworks 의
                        // 동적 프레임워크로 빌드하는데, 그걸 앱 번들에 넣는 건 앱 타깃뿐이다.
                        // 빼면 빌드는 통과하고 이 맥의 시뮬레이터에서도 돈다. dyld 가
                        // rpath 에 박힌 DerivedData 절대경로로 찾아내기 때문이다.
                        // 실기기·아카이브·다른 맥에서는 Library not loaded 로 죽는다.
                        scripts: [crashlyticsUploadScript(
                            googleServicePlist: "Resources/GoogleService-Info.plist"
                        )],
                        dependencies: dependencies + [.package(product: "FirebaseCrashlytics")]
                       )
        ]
    }
}
