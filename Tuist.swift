import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .exact("16.4"),
    plugins: [
        .local(path: .relativeToManifest("../Plugins/MZMZ")),
    ]
)
