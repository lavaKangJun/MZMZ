//
//  Project.swift
//  Manifests
//
//  Created by 강준영 on 2025/08/14.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.frameworkWithTest(
    name: "DustListView",
    packages: [
        .remote(url: "https://github.com/apple/swift-testing", requirement: .upToNextMajor(from: "0.10.0"))
    ],
    dependencies: [
        .project(target: "Domain", path: .relativeToCurrentFile("../Domain")),
        .project(target: "Repository", path: .relativeToCurrentFile("../Repository")),
        .project(target: "Scene", path: .relativeToCurrentFile("../Scene")),
        .project(target: "MZMZTesting", path: .relativeToCurrentFile("../MZMZTesting"))
    ]
)
