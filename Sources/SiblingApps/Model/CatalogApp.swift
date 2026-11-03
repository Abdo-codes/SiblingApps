import Foundation

/// One app in the catalog.
public struct CatalogApp: Sendable, Hashable, Identifiable, Codable {
  /// The App Store ID, for example `6766263673`.
  public var id: Int
  public var bundleID: String
  public var name: LocalizedText
  public var subtitle: LocalizedText
  public var category: LocalizedText
  public var platforms: [ApplePlatform]
  /// A remote icon. The package uses it only when no icon is bundled for this app.
  public var iconURL: URL?
  /// A URL scheme that the app registers. The host uses it to find out if the app is installed.
  public var urlScheme: String?

  public init(
    id: Int,
    bundleID: String,
    name: LocalizedText,
    subtitle: LocalizedText,
    category: LocalizedText,
    platforms: [ApplePlatform],
    iconURL: URL? = nil,
    urlScheme: String? = nil
  ) {
    self.id = id
    self.bundleID = bundleID
    self.name = name
    self.subtitle = subtitle
    self.category = category
    self.platforms = platforms
    self.iconURL = iconURL
    self.urlScheme = urlScheme
  }

  /// Returns true if a person can install the app on `platform`. iPad also runs iPhone apps.
  public func runs(on platform: ApplePlatform) -> Bool {
    switch platform {
    case .iPad: platforms.contains(.iPad) || platforms.contains(.iPhone)
    default: platforms.contains(platform)
    }
  }

  /// The URL that opens the installed app, if the app has a URL scheme.
  var launchURL: URL? {
    urlScheme.flatMap { URL(string: "\($0)://") }
  }

  private enum CodingKeys: String, CodingKey {
    case id, bundleID, name, subtitle, category, platforms, iconURL, urlScheme
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int.self, forKey: .id)
    bundleID = try container.decode(String.self, forKey: .bundleID)
    name = try container.decode(LocalizedText.self, forKey: .name)
    subtitle = try container.decode(LocalizedText.self, forKey: .subtitle)
    category = try container.decode(LocalizedText.self, forKey: .category)
    // Ignore platform names that this version of the package does not know.
    platforms = try container.decode([String].self, forKey: .platforms)
      .compactMap(ApplePlatform.init(rawValue:))
    iconURL = try container.decodeIfPresent(URL.self, forKey: .iconURL)
    urlScheme = try container.decodeIfPresent(String.self, forKey: .urlScheme)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(bundleID, forKey: .bundleID)
    try container.encode(name, forKey: .name)
    try container.encode(subtitle, forKey: .subtitle)
    try container.encode(category, forKey: .category)
    try container.encode(platforms.map(\.rawValue), forKey: .platforms)
    try container.encodeIfPresent(iconURL, forKey: .iconURL)
    try container.encodeIfPresent(urlScheme, forKey: .urlScheme)
  }
}
