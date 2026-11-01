// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DeviceControlDoctor",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "DeviceControlDoctor", targets: ["DeviceControlDoctor"])],
    targets: [
        .target(name: "DoctorCore"),
        .executableTarget(name: "DeviceControlDoctor", dependencies: ["DoctorCore"]),
        .testTarget(name: "DoctorCoreTests", dependencies: ["DoctorCore"]),
        .testTarget(name: "DoctorIntegrationTests", dependencies: ["DeviceControlDoctor"])
    ],
    swiftLanguageModes: [.v5]
)
