// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "MoreApps",
  defaultLocalization: "en",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "MoreApps", targets: ["MoreApps"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.11.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0"),
  ],
  targets: [
    .target(
      name: "MoreApps",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "MoreAppsTests",
      dependencies: [
        "MoreApps",
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: ["__Snapshots__"]
    ),
  ]
)
