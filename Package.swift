// swift-tools-version: 5.10

import PackageDescription

let cSettings: [CSetting] = [
    .unsafeFlags([
        "-target", "wasm32-none-wasm",
        "-nostdlib",
        "-Wno-incompatible-library-redeclaration"
    ])
 ]

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("Embedded"),
    .enableExperimentalFeature("SymbolLinkageMarkers"),
    .unsafeFlags([
        "-Xcc", "-fdeclspec",
        "-wmo",
        "-target", "wasm32-none-wasm",
        "-enable-builtin-module",
        "-disable-cmo", "-Xfrontend", "-gnone"
    ])
]


let linkerSettings: [LinkerSetting] = [
    .unsafeFlags([
        "-Xclang-linker", "-nostdlib",
        "-Xlinker", "--no-entry"
    ])
]

let package = Package(
    name: "Game",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "Runtime", path: "runtime", cSettings: cSettings),
        .executableTarget(
            name: "Game",
            dependencies: ["Runtime"],
            path: "src",
            cSettings: cSettings,
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings
        )
    ]
)
