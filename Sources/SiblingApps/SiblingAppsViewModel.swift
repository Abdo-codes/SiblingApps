import Foundation
import Observation

/// Holds the catalog for one host app.
///
/// A view reads `state` and calls `send(_:)` with an `Input`. The view model gives each `Output` to `configuration.onEvent`.
@MainActor
@Observable
public final class SiblingAppsViewModel {
  /// What the view model tells the host app. The host app gets it in `SiblingAppsConfiguration.onEvent`.
  public typealias Output = SiblingAppsEvent

  public let configuration: SiblingAppsConfiguration
  public private(set) var state: State

  public init(configuration: SiblingAppsConfiguration, devicePlatform: ApplePlatform = .current) {
    self.configuration = configuration
    state = State(devicePlatform: devicePlatform, featuredCount: configuration.featuredCount)
    // Use the cache only when a remote catalog is set. Else an old download can hide newer bundled apps.
    let cached = configuration.remoteCatalogURL == nil ? nil : configuration.catalogClient.cached()
    apply(cached ?? configuration.catalog.load())
  }

  public func send(_ input: Input) async {
    switch input {
    case .refresh:
      await refresh()
    case let .appTapped(app):
      await perform(app)
    case .allAppsShown:
      configuration.onEvent(.allAppsViewed)
    }
  }

  /// Downloads the remote catalog, if one is set, and checks again which apps are installed.
  private func refresh() async {
    guard let url = configuration.remoteCatalogURL else {
      refreshInstalledApps()
      return
    }
    do {
      let catalog = try await configuration.catalogClient.fetch(url)
      configuration.catalogClient.save(catalog)
      apply(catalog)
    } catch {
      // Keep the current catalog. The next refresh tries again.
      refreshInstalledApps()
    }
  }

  private func perform(_ app: CatalogApp) async {
    let action = state.action(for: app)
    configuration.onEvent(.appTapped(appID: app.id, action: action))
    if action == .open, let url = app.launchURL {
      await configuration.appLauncher.open(url)
    } else {
      await configuration.appLauncher.showProductPage(app.id, configuration.campaignToken, configuration.providerToken)
    }
  }

  private func apply(_ catalog: Catalog) {
    state.apps = catalog.apps.filter { $0.bundleID != configuration.hostBundleID }
    refreshInstalledApps()
  }

  private func refreshInstalledApps() {
    state.installedAppIDs = Set(
      state.apps.compactMap { app in
        guard let url = app.launchURL, configuration.appLauncher.canOpen(url) else { return nil }
        return app.id
      }
    )
  }
}
