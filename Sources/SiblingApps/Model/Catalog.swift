import Foundation

/// The list of apps to show. The order of `apps` is the display order.
public struct Catalog: Sendable, Hashable, Codable {
  public var schemaVersion: Int
  public var apps: [CatalogApp]

  /// The newest schema version that this version of the package can read.
  public static let supportedSchemaVersion = 1
  public static let empty = Catalog(schemaVersion: supportedSchemaVersion, apps: [])

  /// Returns true if the package can show this downloaded catalog.
  /// A newer schema or a catalog with no apps is a sign of a bad file, because the decoder skips bad entries.
  var isUsableDownload: Bool {
    schemaVersion <= Self.supportedSchemaVersion && !apps.isEmpty
  }

  public init(schemaVersion: Int, apps: [CatalogApp]) {
    self.schemaVersion = schemaVersion
    self.apps = apps
  }

  private enum CodingKeys: String, CodingKey {
    case schemaVersion, apps
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
    // Skip an app entry that does not decode, so that one bad entry does not hide all apps.
    apps = try container.decode([LossyApp].self, forKey: .apps).compactMap(\.app)
  }
}

private struct LossyApp: Decodable {
  let app: CatalogApp?

  init(from decoder: any Decoder) throws {
    app = try? CatalogApp(from: decoder)
  }
}
