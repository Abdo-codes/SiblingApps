import Foundation
import Testing
@testable import SiblingApps
import SiblingAppsAbdoCatalog

@MainActor
struct CatalogSourceTests {
  @Test func defaultConfigurationShowsNoApps() {
    let configuration = SiblingAppsConfiguration(hostBundleID: "com.example.host")
    #expect(configuration.catalog.load() == .empty)
    #expect(configuration.iconBundle == nil)
    #expect(SiblingAppsViewModel(configuration: configuration).state.apps.isEmpty)
  }

  /// The README example: a catalog in code, with remote icons.
  @Test func inlineCatalogShowsItsApps() {
    let catalog = Catalog(
      schemaVersion: 1,
      apps: [
        CatalogApp(
          id: 1,
          bundleID: "com.example.notes",
          name: LocalizedText(["en": "Notes Pro"]),
          subtitle: LocalizedText(["en": "Write anything"]),
          category: LocalizedText(["en": "Productivity"]),
          platforms: [.iPhone, .iPad],
          iconURL: URL(string: "https://example.com/notes.png")
        )
      ]
    )
    let configuration = SiblingAppsConfiguration(hostBundleID: "com.example.host", catalog: .inline(catalog))
    #expect(configuration.iconBundle == nil)
    #expect(SiblingAppsViewModel(configuration: configuration).state.apps.map(\.id) == [1])
  }

  @Test func bundledCatalogUsesItsBundleForIcons() {
    let configuration = SiblingAppsConfiguration(catalog: AbdoCatalog.source)
    #expect(configuration.iconBundle == AbdoCatalog.source.bundle)
    #expect(configuration.iconBundle != nil)
  }

  @Test func explicitIconBundleWins() {
    let configuration = SiblingAppsConfiguration(catalog: AbdoCatalog.source, iconBundle: .main)
    #expect(configuration.iconBundle == .main)
  }

  @Test func missingResourceGivesAnEmptyCatalog() {
    #expect(CatalogSource.bundled(.main, resource: "no-such-file").load() == .empty)
  }
}
