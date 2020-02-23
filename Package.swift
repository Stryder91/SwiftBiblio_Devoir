// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "biblio",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/IBM-Swift/Kitura", from: "2.9.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger", from: "1.9.0"),
        .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine", from:"1.11.1"),
        .package(url: "https://github.com/IBM-Swift/Swift-Kuery.git", from: "3.0.1"),
        .package(url: "https://github.com/IBM-Swift/Swift-Kuery-ORM.git", from: "0.0.1"),
        .package(url: "https://github.com/IBM-Swift/Swift-Kuery-SQLite.git", from: "2.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "biblio",
            dependencies: ["Kitura", "HeliumLogger", "KituraStencil","SwiftKuerySQLite","SwiftKuery","SwiftKueryORM"]),
        .testTarget(
            name: "biblioTests",
            dependencies: ["biblio"]),
    ]
)
