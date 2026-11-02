/// An event that the host app can send to its analytics.
public enum MoreAppsEvent: Sendable, Hashable {
  case appTapped(appID: Int, action: AppAction)
  case allAppsViewed
}
