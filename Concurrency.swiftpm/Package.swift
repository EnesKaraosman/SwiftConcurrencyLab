// swift-tools-version: 5.8

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Concurrency",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Concurrency",
            targets: ["AppModule"],
            bundleIdentifier: "com.hepsiburada.Concurrency",
            teamIdentifier: "S9G77G3MZ9",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .running),
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)