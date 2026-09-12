//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 강준영 on 2025/08/14.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Repository",
    packages: [
        .remote(url: "https://github.com/Alamofire/Alamofire", requirement: .upToNextMajor(from: "5.10.2")),
        .firebase
    ],
    dependencies: [
        .package(product: "Alamofire"),
        // App Check: 이 앱/기기에서 온 요청임을 서버가 검증할 수 있게 한다.
        .package(product: "FirebaseCore"),
        .package(product: "FirebaseAppCheck"),
        // Crashlytics: 배포 빌드에서 난 크래시를 콘솔로 모은다.
        // 앱과 위젯이 이 모듈을 함께 링크하므로 둘 다 리포트가 올라간다.
        .package(product: "FirebaseCrashlytics"),
        .project(target: "Domain", path: .relativeToCurrentFile("../Domain"))
    ]
)

