// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "KoreanKeyboardCore",
  platforms: [
    .iOS(.v16),
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "KoreanKeyboardCore",
      targets: ["KoreanKeyboardCore"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "KoreanKeyboardCore",
      path: "KeyboardCore/Sources"
    ),
    .testTarget(
      name: "KoreanKeyboardCoreTests",
      dependencies: ["KoreanKeyboardCore"],
      path: "KeyboardCoreTests/Sources"
    )
  ]
)
