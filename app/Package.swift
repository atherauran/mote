// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Mote",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Mote", path: "Sources/Mote")
    ]
)
