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
        .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "12.18.0"))
    ],
    dependencies: [
        .package(product: "Alamofire"),
        // App Check: 이 앱/기기에서 온 요청임을 서버가 검증할 수 있게 한다.
        .package(product: "FirebaseCore"),
        .package(product: "FirebaseAppCheck"),
        .project(target: "Domain", path: .relativeToCurrentFile("../Domain"))
    ]
)

