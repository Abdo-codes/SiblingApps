import Foundation
import Testing
@testable import SiblingApps

@MainActor
struct SiblingAppsViewModelTests {
  @Test func hidesTheHostApp() {
    let model = Fixtures.viewModel()
    #expect(!model.state.apps.map(\.id).contains(AppID.wifiQR))
    #expect(model.state.apps.count == 8)
  }

  @Test func groupsAppsByDevice() {
    let model = Fixtures.viewModel()
    #expect(model.state.deviceApps.map(\.id) == [AppID.capybaraRush, AppID.tateemi, AppID.angryNona, AppID.colorTalk, AppID.swingCoach])
    #expect(model.state.otherDeviceApps.map(\.id) == [AppID.sajdah, AppID.tally, AppID.nightcap])
  }

  @Test func featuredAppsPutInstalledAppsLast() {
    let model = Fixtures.viewModel()
    #expect(model.state.featuredApps.map(\.id) == [AppID.capybaraRush, AppID.angryNona, AppID.colorTalk])
    #expect(model.state.folderApps.map(\.id) == [AppID.tateemi, AppID.swingCoach, AppID.sajdah, AppID.tally])
  }

  @Test func featuredAppsUseInstalledAppsWhenNoOthersAreLeft() {
    let model = Fixtures.viewModel(installedSchemes: [])
    #expect(model.state.featuredApps.map(\.id) == [AppID.capybaraRush, AppID.tateemi, AppID.angryNona])
  }

  @Test func actionsDependOnInstallStateAndDevice() throws {
    let model = Fixtures.viewModel()
    let app = { (id: Int) in try #require(model.state.apps.first { $0.id == id }) }
    #expect(model.state.action(for: try app(AppID.capybaraRush)) == .get)
    #expect(model.state.action(for: try app(AppID.tateemi)) == .open)
    #expect(model.state.action(for: try app(AppID.sajdah)) == .view)
    #expect(model.state.action(for: try app(AppID.nightcap)) == .view)
  }

  @Test func ignoresTheCacheWithoutARemoteCatalog() {
    let cacheReads = Locked(0)
    let model = Fixtures.viewModel {
      $0.catalogClient.cached = {
        cacheReads.withValue { $0 += 1 }
        return Catalog(schemaVersion: 1, apps: [Fixtures.app(1)])
      }
    }
    #expect(cacheReads.value == 0)
    #expect(model.state.apps.count == 8)
  }

  @Test func usesTheCacheWithARemoteCatalog() {
    let model = Fixtures.viewModel(remoteCatalogURL: URL(string: "https://example.com/catalog.json")) {
      $0.catalogClient.cached = { Catalog(schemaVersion: 1, apps: [Fixtures.app(1)]) }
    }
    #expect(model.state.apps.map(\.id) == [1])
  }

  @Test func refreshDownloadsAndSavesTheRemoteCatalog() async {
    let remote = Catalog(schemaVersion: 1, apps: [Fixtures.app(1), Fixtures.app(2, platforms: [.mac])])
    let saved = Locked<Catalog?>(nil)
    let model = Fixtures.viewModel(remoteCatalogURL: URL(string: "https://example.com/catalog.json")) {
      $0.catalogClient.cached = { nil }
      $0.catalogClient.fetch = { _ in remote }
      $0.catalogClient.save = { catalog in saved.setValue(catalog) }
    }
    await model.send(.refresh)
    #expect(model.state.apps.map(\.id) == [1, 2])
    #expect(saved.value == remote)
  }

  @Test func refreshKeepsTheCatalogWhenTheDownloadFails() async {
    let model = Fixtures.viewModel(remoteCatalogURL: URL(string: "https://example.com/catalog.json")) {
      $0.catalogClient.cached = { nil }
      $0.catalogClient.fetch = { _ in throw URLError(.notConnectedToInternet) }
    }
    await model.send(.refresh)
    #expect(model.state.apps.count == 8)
  }

  @Test func refreshWithoutARemoteCatalogOnlyChecksInstalledApps() async {
    let installed = Locked<Set<String>>([])
    let model = Fixtures.viewModel {
      $0.appLauncher.canOpen = { url in installed.value.contains(url.scheme ?? "") }
    }
    #expect(model.state.featuredApps.map(\.id).contains(AppID.tateemi))
    installed.setValue(["tateemi"])
    await model.send(.refresh)
    #expect(!model.state.featuredApps.map(\.id).contains(AppID.tateemi))
  }

  @Test func performShowsTheProductPageWithTokens() async throws {
    let pages = Locked<[String]>([])
    let events = Locked<[SiblingAppsEvent]>([])
    let model = Fixtures.viewModel(providerToken: "118", events: events) {
      $0.appLauncher.showProductPage = { id, campaign, provider in
        pages.withValue { $0.append("\(id) \(campaign) \(provider ?? "-")") }
      }
    }
    let sajdah = try #require(model.state.apps.first { $0.id == AppID.sajdah })
    await model.send(.appTapped(sajdah))
    #expect(pages.value == ["\(AppID.sajdah) more-apps 118"])
    #expect(events.value == [.appTapped(appID: AppID.sajdah, action: .view)])
  }

  @Test func performOpensAnInstalledApp() async throws {
    let opened = Locked<[URL]>([])
    let events = Locked<[SiblingAppsEvent]>([])
    let model = Fixtures.viewModel(events: events) {
      $0.appLauncher.open = { url in opened.withValue { $0.append(url) } }
    }
    let tateemi = try #require(model.state.apps.first { $0.id == AppID.tateemi })
    await model.send(.appTapped(tateemi))
    await model.send(.allAppsShown)
    #expect(opened.value == [URL(string: "tateemi://")!])
    #expect(events.value == [.appTapped(appID: AppID.tateemi, action: .open), .allAppsViewed])
  }
}
