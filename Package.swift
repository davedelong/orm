// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ORM",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "ORM", targets: ["ORM"]),
        .executable(name: "debug", targets: ["debug"])
    ],
    dependencies: [
        .package(url: "https://github.com/davedelong/SQLiteSyntax.git", branch: "main"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.3"),
//        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.4.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(name: "debug", dependencies: ["ORM"]),
        .target(name: "ORM", dependencies: [
            .product(name: "SQLiteSyntax", package: "SQLiteSyntax"),
            .product(name: "SQLite", package: "SQLite.swift"),
//            .product(name: "GRDB", package: "GRDB.swift")
        ]),
        .testTarget(name: "ORMTests", dependencies: ["ORM"]),
    ]
)
