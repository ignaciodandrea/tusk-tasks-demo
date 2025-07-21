// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TuskApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TuskAppCore",
            targets: ["TuskAppCore"]
        ),
    ],
    dependencies: [
        // swift-testing is now included in Swift 6 toolchain
    ],
    targets: [
        .target(
            name: "TuskAppCore",
            dependencies: [],
            path: "TuskApp",
            sources: [
                "Task.swift",
                "TaskViewModel.swift"
            ]
        ),
        .testTarget(
            name: "TuskAppCoreTests",
            dependencies: [
                "TuskAppCore"
                // Testing framework is automatically available in Swift 6
            ],
            path: "Tests"
        ),
    ]
) 