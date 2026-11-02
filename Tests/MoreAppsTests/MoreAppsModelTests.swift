import ConcurrencyExtras
import Dependencies
import Foundation
import Testing
@testable import MoreApps

@MainActor
struct MoreAppsModelTests {
  @Test func hidesTheHostApp() {
    let model = Fixtures.model()
    #expect(!model.apps.map(\.id).contains(AppID.wifiQR))
    #expect(model.apps.count == 7)
  }

  @Test func groupsAppsByDevice() {
    let model = Fixtures.model()
    #expect(model.deviceApps.map(\.id) == [AppID.capybaraRush, AppID.tateemi, AppID.angryNona, AppID.colorTalk])
    #expect(model.otherDeviceApps.map(\.id) == [AppID.sajdah, AppID.tally, AppID.nightcap])
  }

  @Test func featuredAppsPutInstalledAppsLast() {
    let model = Fixtures.model()
    #expect(model.featuredApps.map(\.id) == [AppID.capybaraRush, AppID.angryNona, AppID.colorTalk])
    #expect(model.folderApps.map(\.id) == [AppID.tateemi, AppID.sajdah, AppID.tally, AppID.nightcap])
  }

  @Test func featuredAppsUseInstalledAppsWhenNoOthersAreLeft() {
    let model = Fixtures.model(installedSchemes: [])
    #expect(model.featuredApps.map(\.id) == [AppID.capybaraRush, AppID.tateemi, AppID.angryNona])
  }

  @Test func actionsDependOnInstallStateAndDevice() throws {
    let model = Fixtures.model()
    let app = { (id: Int) in try #require(model.apps.first { $0.id == id }) }
    #expect(model.action(for: try app(AppID.capybaraRush)) == .get)
    #expect(model.action(for: try app(AppID.tateemi)) == .open)
    #expect(model.action(for: try app(AppID.sajdah)) == .view)
    #expect(model.action(for: try app(AppID.nightcap)) == .view)
  }

  @Test func ignoresTheCacheWithoutARemoteCatalog() {
    let cacheReads = LockIsolated(0)
    let model = Fixtures.model {
      $0.catalogClient.cached = {
        cacheReads.withValue { $0 += 1 }
        return Catalog(schemaVersion: 1, apps: [Fixtures.app(1)])
      }
    }
    #expect(cacheReads.value == 0)
    #expect(model.apps.count == 7)
  }

  @Test func usesTheCacheWithARemoteCatalog() {
    let model = Fixtures.model(remoteCatalogURL: URL(string: "https://example.com/catalog.json")) {
      $0.catalogClient.cached = { Catalog(schemaVersion: 1, apps: [Fixtures.app(1)]) }
    }
    #expect(model.apps.map(\.id) == [1])
  }

  @Test func refreshDownloadsAndSavesTheRemoteCatalog() async {
    let remote = Catalog(schemaVersion: 1, apps: [Fixtures.app(1), Fixtures.app(2, platforms: [.mac])])
    let saved = LockIsolated<Catalog?>(nil)
    let model = Fixtures.model(remoteCatalogURL: URL(string: "https://example.com/catalog.json")) {
      $0.catalogClient.cached = { nil }
      $0.catalogClient.fetch = { _ in remote }
      $0.catalogClient.save = { catalog in saved.setValue(catalog) }
    }
    await model.refresh()
    #expect(model.apps.map(\.id) == [1, 2])
    #expect(saved.value == remote)
  }

  @Test func refreshKeepsTheCatalogWhenTheDownloadFails() async {
    let model = Fixtures.model(remoteCatalogURL: URL(string: "https://example.com/catalog.json")) {
      $0.catalogClient.cached = { nil }
      $0.catalogClient.fetch = { _ in throw URLError(.notConnectedToInternet) }
    }
    await model.refresh()
    #expect(model.apps.count == 7)
  }

  @Test func refreshWithoutARemoteCatalogOnlyChecksInstalledApps() async {
    let installed = LockIsolated<Set<String>>([])
    let model = Fixtures.model {
      $0.appLauncher.canOpen = { url in installed.value.contains(url.scheme ?? "") }
    }
    #expect(model.featuredApps.map(\.id).contains(AppID.tateemi))
    installed.setValue(["tateemi"])
    await model.refresh()
    #expect(!model.featuredApps.map(\.id).contains(AppID.tateemi))
  }

  @Test func performShowsTheProductPageWithTokens() async throws {
    let pages = LockIsolated<[String]>([])
    let events = LockIsolated<[MoreAppsEvent]>([])
    let model = Fixtures.model(providerToken: "118", events: events) {
      $0.appLauncher.showProductPage = { id, campaign, provider in
        pages.withValue { $0.append("\(id) \(campaign) \(provider ?? "-")") }
      }
    }
    let sajdah = try #require(model.apps.first { $0.id == AppID.sajdah })
    await model.perform(sajdah)
    #expect(pages.value == ["\(AppID.sajdah) more-apps 118"])
    #expect(events.value == [.appTapped(appID: AppID.sajdah, action: .view)])
  }

  @Test func performOpensAnInstalledApp() async throws {
    let opened = LockIsolated<[URL]>([])
    let events = LockIsolated<[MoreAppsEvent]>([])
    let model = Fixtures.model(events: events) {
      $0.appLauncher.open = { url in opened.withValue { $0.append(url) } }
    }
    let tateemi = try #require(model.apps.first { $0.id == AppID.tateemi })
    await model.perform(tateemi)
    model.didShowAllApps()
    #expect(opened.value == [URL(string: "tateemi://")!])
    #expect(events.value == [.appTapped(appID: AppID.tateemi, action: .open), .allAppsViewed])
  }
}
