import Dependencies
import Foundation

/// Where the package finds the catalog when there is no downloaded copy.
public enum CatalogSource: Sendable {
  /// A JSON file in a bundle, for example `.bundled(.main)` for `catalog.json` in the host app.
  case bundled(Bundle, resource: String = "catalog")
  /// A catalog that you make in code.
  case inline(Catalog)

  /// The bundle of a `.bundled` source. The package also looks for the app icons in it.
  public var bundle: Bundle? {
    switch self {
    case let .bundled(bundle, _): bundle
    case .inline: nil
    }
  }

  /// Reads the catalog. If the file is missing or does not decode, it reports an issue and returns an empty catalog.
  public func load() -> Catalog {
    switch self {
    case let .inline(catalog):
      return catalog
    case let .bundled(bundle, resource):
      guard
        let url = bundle.url(forResource: resource, withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let catalog = try? JSONDecoder().decode(Catalog.self, from: data)
      else {
        reportIssue("MoreApps: \(resource).json is missing from \(bundle.bundleURL.lastPathComponent) or does not decode.")
        return .empty
      }
      return catalog
    }
  }
}
