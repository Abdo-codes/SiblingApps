/// What a tap on an app does.
public enum AppAction: Sendable, Hashable {
  /// Shows the App Store page. The app runs on this device.
  case get
  /// Opens the installed app.
  case open
  /// Shows the App Store page. The app runs only on other devices.
  case view
}
