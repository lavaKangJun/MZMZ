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
        .remote(url: "https://github.com/Alamofire/Alamofire", requirement: .upToNextMajor(from: "5.10.2"))
    ],
    dependencies: [
        .package(product: "Alamofire"),
        .project(target: "Domain", path: .relativeToCurrentFile("../Domain"))
    ]
)

