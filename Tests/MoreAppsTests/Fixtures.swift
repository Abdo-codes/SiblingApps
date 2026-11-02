import ConcurrencyExtras
import Dependencies
import Foundation
@testable import MoreApps

/// App Store IDs of the apps in the bundled catalog.
enum AppID {
  static let capybaraRush = 6766263673
  static let tateemi = 6760822504
  static let angryNona = 6819626561
  static let colorTalk = 6768992579
  static let wifiQR = 6776169783
  static let sajdah = 6759179587
  static let tally = 6760623633
  static let nightcap = 6769450957
}

enum Fixtures {
  static let bundledCatalog = CatalogClient.liveValue.bundled()
  static let hostBundleID = "com.abdoelrhman.WiFiQR"

  static func app(_ id: Int, platforms: [ApplePlatform] = [.iPhone, .iPad]) -> CatalogApp {
    CatalogApp(
      id: id,
      bundleID: "com.example.\(id)",
      name: LocalizedText(["en": "App \(id)"]),
      subtitle: LocalizedText(["en": "Subtitle"]),
      category: LocalizedText(["en": "Utilities"]),
      platforms: platforms
    )
  }

  /// Makes a model with the bundled catalog. Wi-Fi QR is the host app and Tateemi is installed.
  @MainActor
  static func model(
    platform: ApplePlatform = .iPhone,
    remoteCatalogURL: URL? = nil,
    providerToken: String? = nil,
    installedSchemes: Set<String> = ["tateemi"],
    events: LockIsolated<[MoreAppsEvent]>? = nil,
    dependencies: (inout DependencyValues) -> Void = { _ in }
  ) -> MoreAppsModel {
    withDependencies {
      $0.catalogClient.bundled = { bundledCatalog }
      $0.appLauncher.canOpen = { url in installedSchemes.contains(url.scheme ?? "") }
      dependencies(&$0)
    } operation: {
      MoreAppsModel(
        configuration: MoreAppsConfiguration(
          hostBundleID: hostBundleID,
          hostAppName: "Wi-Fi QR",
          remoteCatalogURL: remoteCatalogURL,
          providerToken: providerToken,
          onEvent: { event in events?.withValue { $0.append(event) } }
        ),
        devicePlatform: platform
      )
    }
  }
}
