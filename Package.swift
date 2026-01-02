// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyDDL",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MyDDL", targets: ["MyDDL"])
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0")
    ],
    targets: [
        .executableTarget(
            name: "MyDDL",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "MyDDL"
        )
    ]
)
