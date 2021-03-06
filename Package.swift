// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DVTUIKit",

    platforms: [
        .iOS(.v10),
    ],

    products: [
        .library(
            name: "DVTUIKit",
            targets: ["DVTUIKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/darvintang/DVTFoundation.git", .upToNextMajor(from: "1.0.2")),
    ],
    targets: [

        .target(
            name: "DVTUIKit",
            dependencies: ["DVTFoundation"],
            path: "Sources"
        ),
        .testTarget(
            name: "DVTUIKitTests",
            dependencies: ["DVTUIKit"]),
    ]
)
