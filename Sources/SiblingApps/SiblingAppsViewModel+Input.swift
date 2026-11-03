extension SiblingAppsViewModel {
  /// What a view tells the view model.
  public enum Input: Sendable {
    /// Downloads the remote catalog, if one is set, and checks again which apps are installed.
    case refresh
    /// Opens an installed app, or else shows its App Store page.
    case appTapped(CatalogApp)
    /// The All Apps screen is on screen.
    case allAppsShown
  }
}
