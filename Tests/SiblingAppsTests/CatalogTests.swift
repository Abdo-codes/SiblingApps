import Foundation
import Testing
@testable import SiblingApps

struct CatalogTests {
  @Test func bundledCatalogHasAllAppsInOrder() {
    #expect(
      Fixtures.bundledCatalog.apps.map(\.id) == [
        AppID.capybaraRush, AppID.tateemi, AppID.angryNona, AppID.colorTalk,
        AppID.wifiQR, AppID.sajdah, AppID.tally, AppID.nightcap,
      ]
    )
  }

  @Test func bundledAppsHaveArabicSubtitlesAndCategories() {
    for app in Fixtures.bundledCatalog.apps {
      #expect(app.subtitle.values["ar"] != nil, "\(app.name.values["en"] ?? "")")
      #expect(app.category.values["ar"] != nil, "\(app.name.values["en"] ?? "")")
    }
  }

  @Test func decodingSkipsBadEntriesAndUnknownPlatforms() throws {
    let json = """
      {
        "schemaVersion": 1,
        "apps": [
          { "id": 1, "bundleID": "a", "name": {"en": "A"}, "subtitle": {"en": "S"},
            "category": {"en": "C"}, "platforms": ["iPhone", "vision"] },
          { "id": 2, "name": {"en": "No bundle ID"}, "subtitle": {"en": "S"},
            "category": {"en": "C"}, "platforms": ["iPhone"] }
        ]
      }
      """
    let catalog = try JSONDecoder().decode(Catalog.self, from: Data(json.utf8))
    #expect(catalog.apps.map(\.id) == [1])
    #expect(catalog.apps.first?.platforms == [.iPhone])
  }

  @Test func encodingRoundTrips() throws {
    let data = try JSONEncoder().encode(Fixtures.bundledCatalog)
    #expect(try JSONDecoder().decode(Catalog.self, from: data) == Fixtures.bundledCatalog)
  }

  @Test func localizedTextFallsBackToEnglishThenAnyValue() {
    let text = LocalizedText(["en": "Games", "ar": "الألعاب"])
    #expect(text.resolved(for: Locale(identifier: "ar_EG")) == "الألعاب")
    #expect(text.resolved(for: Locale(identifier: "fr")) == "Games")
    #expect(LocalizedText(["fr": "Jeux", "de": "Spiele"]).resolved(for: Locale(identifier: "ar")) == "Jeux")
    #expect(LocalizedText([:]).resolved(for: Locale(identifier: "en")) == "")
  }

  @Test func iPadRunsIPhoneApps() {
    #expect(Fixtures.app(1, platforms: [.iPhone]).runs(on: .iPad))
    #expect(!Fixtures.app(1, platforms: [.iPad]).runs(on: .iPhone))
    #expect(!Fixtures.app(1, platforms: [.appleTV]).runs(on: .iPad))
    #expect(!Fixtures.app(1, platforms: [.mac]).runs(on: .iPhone))
  }

  @Test func launchURLUsesTheScheme() {
    var app = Fixtures.app(1)
    #expect(app.launchURL == nil)
    app.urlScheme = "tateemi"
    #expect(app.launchURL == URL(string: "tateemi://"))
  }
}

@Test func rowTitleFollowsLocale() {
  #expect(SiblingAppsStrings.rowTitle(locale: Locale(identifier: "en")) == "More apps by us")
  #expect(SiblingAppsStrings.rowTitle(locale: Locale(identifier: "ar")) == "المزيد من تطبيقاتنا")
}
