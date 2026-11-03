import Foundation

/// Downloads and caches the remote catalog.
public struct CatalogClient: Sendable {
  /// The last catalog that `fetch` downloaded, if any.
  public var cached: @Sendable () -> Catalog?
  public var fetch: @Sendable (URL) async throws -> Catalog
  public var save: @Sendable (Catalog) -> Void

  public init(
    cached: @escaping @Sendable () -> Catalog?,
    fetch: @escaping @Sendable (URL) async throws -> Catalog,
    save: @escaping @Sendable (Catalog) -> Void
  ) {
    self.cached = cached
    self.fetch = fetch
    self.save = save
  }
}

extension CatalogClient {
  public static let live = CatalogClient(
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

  /// For tests and previews: uses the catalog source of the configuration, and never uses the network or the cache.
  public static let preview = CatalogClient(
    cached: { nil },
    fetch: { _ in throw URLError(.notConnectedToInternet) },
    save: { _ in }
  )

  private static let cacheURL = URL.cachesDirectory
    .appending(path: "SiblingApps", directoryHint: .isDirectory)
    .appending(path: "catalog.json")
}
