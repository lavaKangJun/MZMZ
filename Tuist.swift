import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .exact("26.2"),
    plugins: [
        .local(path: .relativeToManifest("../Plugins/MZMZ")),
    ]
)
