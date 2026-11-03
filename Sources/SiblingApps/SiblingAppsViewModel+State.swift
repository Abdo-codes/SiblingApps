extension SiblingAppsViewModel {
  /// What a view shows.
  public struct State: Equatable, Sendable {
    /// The catalog apps without the host app, in catalog order.
    public internal(set) var apps: [CatalogApp] = []
    var installedAppIDs: Set<Int> = []
    let devicePlatform: ApplePlatform
    let featuredCount: Int

    init(devicePlatform: ApplePlatform, featuredCount: Int) {
      self.devicePlatform = devicePlatform
      self.featuredCount = featuredCount
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
      return Array((notInstalled + installed).prefix(featuredCount))
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
  }
}
