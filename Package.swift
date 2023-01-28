// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DVTUIKit",

    platforms: [
        .iOS(.v13)
    ],
    
    products: [
        .library(
            name: "DVTUIKit",
            targets: ["DVTUIKit"]
        ),
        .library(
            name: "DVTUIKitButton",
            targets: ["DVTUIKitButton"]
        ),
        .library(
            name: "DVTUIKitCollection",
            targets: ["DVTUIKitCollection"]
        ),
        .library(
            name: "DVTUIKitNavigation",
            targets: ["DVTUIKitNavigation"]
        ),
        .library(
            name: "DVTUIKitProgressView",
            targets: ["DVTUIKitProgressView"]
        ),
        .library(
            name: "DVTUIKitPublic",
            targets: ["DVTUIKitPublic"]
        ),
        .library(
            name: "DVTUIKitExtension",
            targets: ["DVTUIKitExtension"]
        )
    ],
    
    dependencies: [
        .package(url: "https://github.com/darvintang/DVTFoundation.git", .upToNextMinor(from: "2.0.5")),
        .package(url: "https://github.com/darvintang/DVTLoger.git", .upToNextMinor(from: "2.0.2"))
    ],
    
    targets: [
        .target(
            name: "DVTUIKit",
            dependencies: [
                "DVTUIKitExtension",
                "DVTUIKitProgressView",
                "DVTUIKitButton",
                "DVTUIKitCollection",
                "DVTUIKitNavigation"
            ],
            path: "Sources",
            exclude: ["Advanced", "Extension"]
        ),
        .target(
            name: "DVTUIKitButton",
            dependencies: [
                "DVTUIKitExtension",
            ],
            path: "Sources/Advanced/Button"
        ),
        .target(
            name: "DVTUIKitCollection",
            dependencies: [
                "DVTUIKitExtension",
            ],
            path: "Sources/Advanced/Collection"
        ),
        .target(
            name: "DVTUIKitNavigation",
            dependencies: [
                "DVTUIKitExtension",
            ],
            path: "Sources/Advanced/Navigation"
        ),
        .target(
            name: "DVTUIKitProgressView",
            dependencies: [
                "DVTUIKitExtension",
                "DVTUIKitPublic",
            ],
            path: "Sources/Advanced/ProgressView"
        ),
        .target(
            name: "DVTUIKitPublic",
            path: "Sources/Advanced/Public"
        ),
        .target(
            name: "DVTUIKitExtension",
            dependencies: ["DVTFoundation", "DVTLoger"],
            path: "Sources/Extension"
        ),
        .testTarget(
            name: "DVTUIKitTests",
            dependencies: ["DVTUIKit"]
        )
    ]
)
