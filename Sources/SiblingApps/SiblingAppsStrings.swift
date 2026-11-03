import Foundation

/// Localized texts for a row that a host app draws in its own style.
public enum SiblingAppsStrings {
  /// The header title of `SiblingAppsSection`, in the current language.
  public static var rowTitle: String {
    rowTitle(locale: .current)
  }

  /// The header title of `SiblingAppsSection` in `locale`.
  /// Use it when the app has its own language setting, for example `rowTitle(locale: environmentLocale)`.
  public static func rowTitle(locale: Locale) -> String {
    let resource = LocalizedStringResource(
      "moreApps.section.title",
      locale: locale,
      bundle: .atURL(Bundle.module.bundleURL)
    )
    return String(localized: resource)
  }
}
