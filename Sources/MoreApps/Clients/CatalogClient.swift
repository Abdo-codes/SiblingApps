import Dependencies
import Foundation

/// Loads, downloads, and caches the catalog.
public struct CatalogClient: Sendable {
  /// The catalog in the package bundle. It is always available.
  public var bundled: @Sendable () -> Catalog
  /// The last catalog that `fetch` downloaded, if any.
  public var cached: @Sendable () -> Catalog?
  public var fetch: @Sendable (URL) async throws -> Catalog
  public var save: @Sendable (Catalog) -> Void

  public init(
    bundled: @escaping @Sendable () -> Catalog,
    cached: @escaping @Sendable () -> Catalog?,
    fetch: @escaping @Sendable (URL) async throws -> Catalog,
    save: @escaping @Sendable (Catalog) -> Void
  ) {
    self.bundled = bundled
    self.cached = cached
    self.fetch = fetch
    self.save = save
  }
}

extension CatalogClient: DependencyKey {
  public static let liveValue = CatalogClient(
    bundled: { bundledCatalog },
    cached: {
      guard let data = try? Data(contentsOf: cacheURL) else { return nil }
      return try? JSONDecoder().decode(Catalog.self, from: data)
    },
    fetch: { url in
      let (data, response) = try await URLSession.shared.data(from: url)
      guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
      }
      return try JSONDecoder().decode(Catalog.self, from: data)
    },
    save: { catalog in
      guard let data = try? JSONEncoder().encode(catalog) else { return }
      try? FileManager.default.createDirectory(
        at: cacheURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try? data.write(to: cacheURL, options: .atomic)
    }
  )

  /// Host-app tests and previews render the bundled catalog and never use the network or the cache.
  public static let testValue = CatalogClient(
    bundled: { bundledCatalog },
    cached: { nil },
    fetch: { _ in throw URLError(.notConnectedToInternet) },
    save: { _ in }
  )

  public static let previewValue = testValue

  private static let bundledCatalog: Catalog = {
    guard
      let url = Bundle.module.url(forResource: "catalog", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let catalog = try? JSONDecoder().decode(Catalog.self, from: data)
    else {
      reportIssue("MoreApps: the bundled catalog.json is missing or does not decode.")
      return .empty
    }
    return catalog
  }()

  private static let cacheURL = URL.cachesDirectory
    .appending(path: "MoreApps", directoryHint: .isDirectory)
    .appending(path: "catalog.json")
}

extension DependencyValues {
  public var catalogClient: CatalogClient {
    get { self[CatalogClient.self] }
    set { self[CatalogClient.self] = newValue }
  }
}
