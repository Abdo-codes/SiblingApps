import Foundation

/// Localized texts for a row that a host app draws in its own style.
public enum MoreAppsStrings {
  /// The header title of `MoreAppsSection`, in the current language.
  public static var rowTitle: String {
    String(localized: "moreApps.section.title", bundle: .module)
  }
}
