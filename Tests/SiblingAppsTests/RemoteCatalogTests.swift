import Foundation
import Testing
@testable import SiblingApps

/// The rules for a downloaded catalog: which files the view model accepts, and how often it downloads.
@MainActor
struct RemoteCatalogTests {
  static let url = URL(string: "https://example.com/catalog.json")

  /// Makes a view model with a remote catalog. `downloads` counts the calls of `fetch`.
  private func viewModel(
    remote: Catalog,
    downloads: Locked<Int> = Locked(0),
    saved: Locked<Catalog?> = Locked(nil),
    interval: Duration = .seconds(3600)
  ) -> SiblingAppsViewModel {
    Fixtures.viewModel(remoteCatalogURL: Self.url) {
      $0.remoteCatalogRefreshInterval = interval
      $0.catalogClient.cached = { nil }
      $0.catalogClient.fetch = { _ in
        downloads.withValue { $0 += 1 }
        return remote
      }
      $0.catalogClient.save = { catalog in saved.setValue(catalog) }
    }
  }

  @Test func refreshIgnoresARemoteCatalogWithNoApps() async {
    let saved = Locked<Catalog?>(nil)
    let model = viewModel(remote: .empty, saved: saved)
    await model.send(.refresh)
    #expect(model.state.apps.count == 8)
    #expect(saved.value == nil)
  }

  @Test func refreshIgnoresANewerSchemaVersion() async {
    let saved = Locked<Catalog?>(nil)
    let newer = Catalog(schemaVersion: Catalog.supportedSchemaVersion + 1, apps: [Fixtures.app(1)])
    let model = viewModel(remote: newer, saved: saved)
    await model.send(.refresh)
    #expect(model.state.apps.count == 8)
    #expect(saved.value == nil)
  }

  @Test func ignoresACacheWithNoApps() {
    let model = Fixtures.viewModel(remoteCatalogURL: Self.url) {
      $0.catalogClient.cached = { .empty }
    }
    #expect(model.state.apps.count == 8)
  }

  @Test func refreshDownloadsOneTimeInTheInterval() async {
    let downloads = Locked(0)
    let model = viewModel(remote: Catalog(schemaVersion: 1, apps: [Fixtures.app(1)]), downloads: downloads)
    await model.send(.refresh)
    await model.send(.refresh)
    #expect(downloads.value == 1)
    #expect(model.state.apps.map(\.id) == [1])
  }

  @Test func refreshDownloadsAgainAfterTheInterval() async {
    let downloads = Locked(0)
    let model = viewModel(
      remote: Catalog(schemaVersion: 1, apps: [Fixtures.app(1)]),
      downloads: downloads,
      interval: .zero
    )
    await model.send(.refresh)
    await model.send(.refresh)
    #expect(downloads.value == 2)
  }

  @Test func refreshTriesAgainAfterAFailedDownload() async {
    let downloads = Locked(0)
    let model = Fixtures.viewModel(remoteCatalogURL: Self.url) {
      $0.catalogClient.cached = { nil }
      $0.catalogClient.fetch = { _ in
        downloads.withValue { $0 += 1 }
        throw URLError(.notConnectedToInternet)
      }
    }
    await model.send(.refresh)
    await model.send(.refresh)
    #expect(downloads.value == 2)
  }

  @Test func aViewReadsTheCatalogOnlyWhenItDraws() {
    let reads = Locked(0)
    var configuration = SiblingAppsConfiguration(
      hostBundleID: Fixtures.hostBundleID,
      remoteCatalogURL: Self.url,
      catalogClient: .preview,
      appLauncher: .preview
    )
    configuration.catalogClient.cached = {
      reads.withValue { $0 += 1 }
      return nil
    }
    let box = ViewModelBox(configuration: configuration)
    #expect(reads.value == 0)
    _ = box.viewModel
    _ = box.viewModel
    #expect(reads.value == 1)
  }
}
