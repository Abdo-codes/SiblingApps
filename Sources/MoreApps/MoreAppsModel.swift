import Dependencies
import Foundation
import Observation

/// Holds the catalog for one host app and decides what each app row shows.
@MainActor
@Observable
public final class MoreAppsModel {
  public let configuration: MoreAppsConfiguration
  /// The catalog apps without the host app, in catalog order.
  public private(set) var apps: [CatalogApp] = []
  private(set) var installedAppIDs: Set<Int> = []
  let devicePlatform: ApplePlatform

  @ObservationIgnored @Dependency(\.catalogClient) private var catalogClient
  @ObservationIgnored @Dependency(\.appLauncher) private var appLauncher

  public init(configuration: MoreAppsConfiguration, devicePlatform: ApplePlatform = .current) {
    self.configuration = configuration
    self.devicePlatform = devicePlatform
    // Use the cache only when a remote catalog is set. Else an old download can hide newer bundled apps.
    let cached = configuration.remoteCatalogURL == nil ? nil : catalogClient.cached()
    apply(cached ?? catalogClient.bundled())
  }

  /// Apps that a person can install on this device.
  public var deviceApps: [CatalogApp] {
    apps.filter { $0.runs(on: devicePlatform) }
  }

  /// Apps for other devices, for example Apple TV and Mac apps on an iPhone.
  public var otherDeviceApps: [CatalogApp] {
    apps.filter { !$0.runs(on: devicePlatform) }
  }

  /// The apps in the Settings section. Apps that are not installed come first.
  public var featuredApps: [CatalogApp] {
    let notInstalled = deviceApps.filter { !installedAppIDs.contains($0.id) }
    let installed = deviceApps.filter { installedAppIDs.contains($0.id) }
    return Array((notInstalled + installed).prefix(configuration.featuredCount))
  }

  /// Up to four apps for the icon of the "See All Apps" row. Apps that are not featured come first.
  var folderApps: [CatalogApp] {
    let featured = featuredApps
    let others = apps.filter { !featured.contains($0) }
    return Array((others + featured).prefix(4))
  }

  public func action(for app: CatalogApp) -> AppAction {
    if installedAppIDs.contains(app.id) { return .open }
    return app.runs(on: devicePlatform) ? .get : .view
  }

  /// Downloads the remote catalog, if one is set, and checks again which apps are installed.
  public func refresh() async {
    guard let url = configuration.remoteCatalogURL else {
      refreshInstalledApps()
      return
    }
    do {
      let catalog = try await catalogClient.fetch(url)
      catalogClient.save(catalog)
      apply(catalog)
    } catch {
      // Keep the current catalog. The next refresh tries again.
      refreshInstalledApps()
    }
  }

  public func perform(_ app: CatalogApp) async {
    let action = action(for: app)
    configuration.onEvent(.appTapped(appID: app.id, action: action))
    if action == .open, let url = app.launchURL {
      await appLauncher.open(url)
    } else {
      await appLauncher.showProductPage(app.id, configuration.campaignToken, configuration.providerToken)
    }
  }

  func didShowAllApps() {
    configuration.onEvent(.allAppsViewed)
  }

  private func apply(_ catalog: Catalog) {
    apps = catalog.apps.filter { $0.bundleID != configuration.hostBundleID }
    refreshInstalledApps()
  }

  private func refreshInstalledApps() {
    installedAppIDs = Set(
      apps.compactMap { app in
        guard let url = app.launchURL, appLauncher.canOpen(url) else { return nil }
        return app.id
      }
    )
  }
}
