import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
    static let organizationName = "Junyoung"
    /// Helper function to create the Project for this ExampleApp
    public static func app(
        name: String,
        platform: Platform,
        dependencies: [TargetDependency]
    ) -> Project {
        var targets = makeAppTargets(
            name: name,
            platform: platform,
            dependencies: dependencies
        )
        var extensionTarget = makeAppExtensionTargets(
            appName: name,
            extensionName: "WidzetExtension",
            infoPlist: [
                "NSExtension": .dictionary([
                    "NSExtensionPointIdentifier": .string("com.apple.widgetkit-extension")
                ]),
                "NSAppTransportSecurity" : [
                    "NSAllowsArbitraryLoads": true
                ],
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
                       targets: targets + extensionTarget)
    }
    
    public static func makeAppExtensionTargets(
        appName: String,
        extensionName: String,
        infoPlist: [String: Plist.Value] = [:],
        dependencies: [TargetDependency],
        withTest: Bool = true
    ) -> [Target] {
        
        let targetName = "\(appName)\(extensionName)"
        
        let target = Target(
            name: targetName,
            destinations: .iOS,
            product: .appExtension,
            bundleId: "\(organizationName).\(appName).\(extensionName)",
            infoPlist: .extendingDefault(with: infoPlist),
            sources: [
                "AppExtensions/\(targetName)/Sources/**"
            ],
            resources: [
                "AppExtensions/\(targetName)/Resources/**"
            ],
            entitlements: Entitlements.file(path: "AppExtensions/\(targetName)/\(targetName).entitlements"),
            dependencies: dependencies,
            settings: .settings(configurations: [])
        )
        
        return [target]
    }
    
    public static func framework(
        name: String,
        resources: ResourceFileElements? = nil,
        packages: [Package],
        dependencies: [TargetDependency]
    ) -> Project {
        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            targets: [
                Target(
                    name: name,
                    destinations: .iOS,
                    product: .framework,
                    bundleId: "\(organizationName).\(name)",
                    infoPlist: .extendingDefault(with: [:]),
                    sources: ["Sources/**"],
                    resources: resources,
                    dependencies: dependencies
                )
            ]
        )
    }
    // MARK: - Private

    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(
        name: String,
        dependencies: [TargetDependency] = []
    ) -> [Target] {
        let sources = Target(
            name: name,
            destinations: .iOS,
            product: .framework,
            bundleId: "\(organizationName).\(name)",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: dependencies
        )
        return [sources]
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(name: String, platform: Platform, dependencies: [TargetDependency]) -> [Target] {
        let platform: Platform = platform
        let infoPlist: [String: Plist.Value] = [
            "UILaunchStoryboardName": "LaunchScreen",
            "UIApplicationSceneManifest": [
                "UIApplicationSupportsMultipleScenes": false,
                "UISceneConfigurations": []
            ],
            "NSAppTransportSecurity" : [
                "NSAllowsArbitraryLoads": true
            ],
            "NSLocationWhenInUseUsageDescription": "위치 정보 접근 허용이 필요합니다.",
            "NSLocationAlwaysAndWhenInUseUsageDescription": "위치 정보 접근 허용이 필요합니다."
        ]

        let mainTarget = Target(
            name: name,
            destinations: .iOS,
            product: .app,
            bundleId: "\(organizationName).\(name)",
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: Entitlements.file(path: "./MZMZ.entitlements"),
            dependencies: dependencies
        )

        return [mainTarget]
    }
}
