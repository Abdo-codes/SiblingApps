// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "SiblingApps",
  defaultLocalization: "en",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "SiblingApps", targets: ["SiblingApps"]),
    .library(name: "SiblingAppsAbdoCatalog", targets: ["SiblingAppsAbdoCatalog"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.11.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0"),
  ],
  targets: [
    .target(
      name: "SiblingApps",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "SiblingAppsAbdoCatalog",
      dependencies: ["SiblingApps"],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "SiblingAppsTests",
      dependencies: [
        "SiblingApps",
        "SiblingAppsAbdoCatalog",
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: ["__Snapshots__"]
    ),
  ]
)
