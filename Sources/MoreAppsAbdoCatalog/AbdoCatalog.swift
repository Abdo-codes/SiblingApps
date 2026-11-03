import Foundation
import MoreApps

/// The catalog and icons of the apps by Abdo Eaita. These brand assets are not covered by the MIT license.
///
/// ```swift
/// MoreAppsSection(
///   configuration: MoreAppsConfiguration(catalog: AbdoCatalog.source, remoteCatalogURL: AbdoCatalog.remoteURL)
/// )
/// ```
public enum AbdoCatalog {
  /// The bundled `catalog.json`. Its bundle also has the app icons.
  public static let source = CatalogSource.bundled(.module)
  /// The hosted copy of the same catalog. New apps appear there without an app update.
  public static let remoteURL = URL(string: "https://yoloabdo.com/apps/catalog.json")!
}
