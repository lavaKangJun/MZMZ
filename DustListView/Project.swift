//
//  Project.swift
//  Manifests
//
//  Created by 강준영 on 2025/08/14.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "DustListView",
    resources: ["Resources/**"],
    packages: [],
    dependencies: [
        .project(target: "Domain", path: .relativeToCurrentFile("../Domain")),
        .project(target: "Repository", path: .relativeToCurrentFile("../Repository")),
        .project(target: "Scene", path: .relativeToCurrentFile("../Scene"))
    ]
)
