//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 강준영 on 2025/08/14.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
    name: "MZMZ",
    platform: .iOS,
    dependencies: [
        .target(name: "MZMZWidzetExtension"),
        .project(target: "Domain", path: .relativeToCurrentFile("../Domain")),
        .project(target: "Repository", path: .relativeToCurrentFile("../Repository")),
        .project(target: "Scene", path: .relativeToCurrentFile("../Scene")),
        .project(target: "MZMZTesting", path: .relativeToCurrentFile("../MZMZTesting")),
        .project(target: "AddCity", path: .relativeToCurrentFile("../AddCity")),
        .project(target: "CityDetail", path: .relativeToCurrentFile("../CityDetail")),
        .project(target: "DustListView", path: .relativeToCurrentFile("../DustListView"))
    ])
