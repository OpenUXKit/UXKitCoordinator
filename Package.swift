// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

enum MxIrisStudioWorkspace {
    static let relativeForkDirectory = "../../../../Fork"

    static let relativePersonalDirectory = "../../../../Personal"
}

extension Package.Dependency {
    enum LocalSearchPath {
        case package(path: String, isRelative: Bool, isEnabled: Bool)
    }

    static func package(local localSearchPaths: LocalSearchPath..., remote: Package.Dependency) -> Package.Dependency {
        let currentFilePath = #filePath
        let isClonedDependency = currentFilePath.contains("/checkouts/") ||
            currentFilePath.contains("/SourcePackages/") ||
            currentFilePath.contains("/.build/")

        if isClonedDependency {
            return remote
        }
        for local in localSearchPaths {
            switch local {
            case .package(let path, let isRelative, let isEnabled):
                guard isEnabled else { continue }
                let url = if isRelative, let resolvedURL = URL(string: path, relativeTo: URL(fileURLWithPath: #filePath)) {
                    resolvedURL
                } else {
                    URL(fileURLWithPath: path)
                }

                if FileManager.default.fileExists(atPath: url.path) {
                    return .package(path: url.path)
                }
            }
        }
        return remote
    }
}

let package = Package(
    name: "UXKitCoordinator",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "OpenUXKitCoordinator",
            targets: ["OpenUXKitCoordinator"]
        ),
        .library(
            name: "UXKitCoordinator",
            targets: ["UXKitCoordinator"]
        ),
    ],
    dependencies: [
        .package(
            local: .package(
                path: "../CocoaCoordinator",
                isRelative: true,
                isEnabled: true
            ),
            remote: .package(
                url: "https://github.com/Mx-Iris/CocoaCoordinator",
                branch: "main"
            )
        ),
        .package(
            local: .package(
                path: "\(MxIrisStudioWorkspace.relativePersonalDirectory)/Library/macOS/OpenUXKit",
                isRelative: true,
                isEnabled: true
            ),
            remote: .package(
                url: "https://github.com/OpenUXKit/OpenUXKit",
                branch: "main"
            )
        ),
    ],
    targets: [
        .target(
            name: "OpenUXKitCoordinator",
            dependencies: [
                .product(name: "CocoaCoordinator", package: "CocoaCoordinator"),
                .product(name: "OpenUXKit", package: "OpenUXKit"),
            ]
        ),
        .target(
            name: "UXKitCoordinator",
            dependencies: [
                .product(name: "CocoaCoordinator", package: "CocoaCoordinator"),
                .product(name: "UXKit", package: "OpenUXKit"),
            ]
        ),
    ]
)
