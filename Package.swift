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
    targets: [
        .executableTarget(
            name: "MyDDL",
            path: "MyDDL"
        )
    ]
)
