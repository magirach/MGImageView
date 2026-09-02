// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MGImageView",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "MGImageView", targets: ["MGImageView"])
    ],
    targets: [
        .target(name: "MGImageView"),
        .testTarget(name: "MGImageViewTests", dependencies: ["MGImageView"])
    ]
)
