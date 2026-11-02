import Foundation

/// Settings that each host app gives to the package.
public struct MoreAppsConfiguration: Sendable {
  /// The package hides the app with this bundle ID, so that an app does not promote itself.
  public var hostBundleID: String
  /// The name in "From the makers of …".
  public var hostAppName: String
  /// A JSON file with the same format as the bundled `catalog.json`.
  /// If you set it, new apps appear without an update of the host app.
  public var remoteCatalogURL: URL?
  /// The number of apps in the Settings section.
  public var featuredCount: Int
  /// App Store Connect shows this token in App Analytics > Sources.
  public var campaignToken: String
  /// Your App Store Connect provider ID. App Analytics needs it to attribute campaigns.
  public var providerToken: String?
  public var onEvent: @MainActor @Sendable (MoreAppsEvent) -> Void

  public init(
    hostBundleID: String = Bundle.main.bundleIdentifier ?? "",
    hostAppName: String = Bundle.main.moreAppsDisplayName,
    remoteCatalogURL: URL? = nil,
    featuredCount: Int = 3,
    campaignToken: String = "more-apps",
    providerToken: String? = nil,
    onEvent: @escaping @MainActor @Sendable (MoreAppsEvent) -> Void = { _ in }
  ) {
    self.hostBundleID = hostBundleID
    self.hostAppName = hostAppName
    self.remoteCatalogURL = remoteCatalogURL
    self.featuredCount = featuredCount
    self.campaignToken = campaignToken
    self.providerToken = providerToken
    self.onEvent = onEvent
  }
}

extension Bundle {
  /// The localized display name of the bundle, for example "Wi-Fi QR".
  public var moreAppsDisplayName: String {
    let keys = ["CFBundleDisplayName", "CFBundleName"]
    for key in keys {
      if let name = localizedInfoDictionary?[key] as? String ?? infoDictionary?[key] as? String {
        return name
      }
    }
    return ""
  }
}
