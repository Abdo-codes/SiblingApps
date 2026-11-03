import Foundation

/// Settings that each host app gives to the package.
public struct SiblingAppsConfiguration: Sendable {
  /// The package hides the app with this bundle ID, so that an app does not promote itself.
  public var hostBundleID: String
  /// The name in "From the makers of …".
  public var hostAppName: String
  /// The apps to show when there is no downloaded catalog. The default is an empty catalog.
  public var catalog: CatalogSource
  /// The bundle with the app icons, named `appicon-<App Store ID>`. The default is the bundle of a `.bundled` catalog.
  /// If a bundle has no icon for an app, the package downloads `iconURL`.
  public var iconBundle: Bundle?
  /// A JSON file with the same format as the catalog.
  /// If you set it, new apps appear without an update of the host app.
  public var remoteCatalogURL: URL?
  /// The number of apps in the Settings section.
  public var featuredCount: Int
  /// App Store Connect shows this token in App Analytics > Sources.
  public var campaignToken: String
  /// Your App Store Connect provider ID. App Analytics needs it to attribute campaigns.
  public var providerToken: String?
  public var onEvent: @MainActor @Sendable (SiblingAppsEvent) -> Void

  public init(
    hostBundleID: String = Bundle.main.bundleIdentifier ?? "",
    hostAppName: String = Bundle.main.siblingAppsDisplayName,
    catalog: CatalogSource = .inline(.empty),
    iconBundle: Bundle? = nil,
    remoteCatalogURL: URL? = nil,
    featuredCount: Int = 3,
    campaignToken: String = "more-apps",
    providerToken: String? = nil,
    onEvent: @escaping @MainActor @Sendable (SiblingAppsEvent) -> Void = { _ in }
  ) {
    self.hostBundleID = hostBundleID
    self.hostAppName = hostAppName
    self.catalog = catalog
    self.iconBundle = iconBundle ?? catalog.bundle
    self.remoteCatalogURL = remoteCatalogURL
    self.featuredCount = featuredCount
    self.campaignToken = campaignToken
    self.providerToken = providerToken
    self.onEvent = onEvent
  }
}

extension Bundle {
  /// The localized display name of the bundle, for example "Wi-Fi QR".
  public var siblingAppsDisplayName: String {
    let keys = ["CFBundleDisplayName", "CFBundleName"]
    for key in keys {
      if let name = localizedInfoDictionary?[key] as? String ?? infoDictionary?[key] as? String {
        return name
      }
    }
    return ""
  }
}
