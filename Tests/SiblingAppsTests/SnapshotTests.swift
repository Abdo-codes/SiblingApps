import Dependencies
import SnapshotTesting
import SwiftUI
import Testing
@testable import SiblingApps
import SiblingAppsAbdoCatalog

/// Renders the screens of the Paper design: light, dark, and Arabic RTL on iPhone, and the iPad grid.
@MainActor
@Suite(.serialized)
struct SnapshotTests {
  @Test(arguments: Variant.allCases)
  func settingsSection(_ variant: Variant) {
    let view = NavigationStack {
      List {
        Section {
          Label("General", systemImage: "gear")
        }
        SiblingAppsSection(model: Fixtures.model())
      }
      .navigationTitle(variant.settingsTitle)
    }
    assertSnapshot(of: variant.apply(to: view), as: variant.strategy(.iPhone13), named: variant.rawValue)
  }

  @Test(arguments: Variant.allCases)
  func allAppsList(_ variant: Variant) {
    let view = NavigationStack {
      SiblingAppsView(model: Fixtures.model())
    }
    assertSnapshot(of: variant.apply(to: view), as: variant.strategy(.iPhone13), named: variant.rawValue)
  }

  @Test(arguments: [Variant.light, .arabic])
  func sheet(_ variant: Variant) {
    let view = SiblingAppsSheet(model: Fixtures.model())
    assertSnapshot(of: variant.apply(to: view), as: variant.strategy(.iPhone13), named: variant.rawValue)
  }

  @Test func icon() {
    let view = withDependencies {
      $0.appLauncher.canOpen = { _ in false }
    } operation: {
      SiblingAppsIcon(
        configuration: SiblingAppsConfiguration(hostBundleID: Fixtures.hostBundleID, catalog: AbdoCatalog.source),
        size: 60
      )
    }
    .padding()
    assertSnapshot(of: view, as: .image)
  }

  @Test(arguments: [Variant.light, .dark])
  func iPadGrid(_ variant: Variant) {
    let view = NavigationStack {
      SiblingAppsView(model: Fixtures.model(platform: .iPad))
    }
    assertSnapshot(
      of: variant.apply(to: view),
      as: variant.strategy(.iPadPro11(.landscape)),
      named: variant.rawValue
    )
  }

  enum Variant: String, CaseIterable, Sendable {
    case light, dark, arabic

    var settingsTitle: String {
      self == .arabic ? "الإعدادات" : "Settings"
    }

    func strategy<V: View>(_ config: ViewImageConfig) -> Snapshotting<V, UIImage> {
      let style: UIUserInterfaceStyle = self == .dark ? .dark : .light
      return .image(
        layout: .device(config: config),
        traits: UITraitCollection(userInterfaceStyle: style)
      )
    }

    func apply(to view: some View) -> some View {
      view
        .environment(\.locale, Locale(identifier: self == .arabic ? "ar" : "en"))
        .environment(\.layoutDirection, self == .arabic ? .rightToLeft : .leftToRight)
    }
  }
}
