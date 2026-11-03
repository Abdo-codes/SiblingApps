import Foundation
@testable import SiblingApps
import SiblingAppsAbdoCatalog

/// App Store IDs of the apps in `AbdoCatalog`.
enum AppID {
  static let capybaraRush = 6766263673
  static let tateemi = 6760822504
  static let angryNona = 6819626561
  static let colorTalk = 6768992579
  static let wifiQR = 6776169783
  static let sajdah = 6759179587
  static let tally = 6760623633
  static let nightcap = 6769450957
  static let swingCoach = 6806616079
}

enum Fixtures {
  static let bundledCatalog = AbdoCatalog.source.load()
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

  /// Makes a view model with `AbdoCatalog`. Wi-Fi QR is the host app and Tateemi is installed.
  @MainActor
  static func viewModel(
    platform: ApplePlatform = .iPhone,
    remoteCatalogURL: URL? = nil,
    providerToken: String? = nil,
    installedSchemes: Set<String> = ["tateemi"],
    events: Locked<[SiblingAppsEvent]>? = nil,
    configure: (inout SiblingAppsConfiguration) -> Void = { _ in }
  ) -> SiblingAppsViewModel {
    var configuration = SiblingAppsConfiguration(
      hostBundleID: hostBundleID,
      hostAppName: "Wi-Fi QR",
      catalog: AbdoCatalog.source,
      remoteCatalogURL: remoteCatalogURL,
      providerToken: providerToken,
      catalogClient: .preview,
      appLauncher: .preview,
      onEvent: { event in events?.withValue { $0.append(event) } }
    )
    configuration.appLauncher.canOpen = { url in installedSchemes.contains(url.scheme ?? "") }
    configure(&configuration)
    return SiblingAppsViewModel(configuration: configuration, devicePlatform: platform)
  }
}
