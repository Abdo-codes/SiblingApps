import SnapshotTesting
import SwiftUI
import Testing
@testable import SiblingApps
import SiblingAppsAbdoCatalog

/// Renders the screens of the Paper design: light, dark, and Arabic RTL on iPhone, and the iPad grid.
/// The tests run only on the simulator of `SnapshotEnvironment`.
@MainActor
@Suite(.serialized, .enabled(if: SnapshotEnvironment.isCurrent, Comment(rawValue: SnapshotEnvironment.skipReason)))
struct SnapshotTests {
  @Test(arguments: Variant.allCases)
  func settingsSection(_ variant: Variant) {
    let view = NavigationStack {
      List {
        Section {
          Label("General", systemImage: "gear")
        }
        SiblingAppsSection(viewModel: Fixtures.viewModel())
      }
      .navigationTitle(variant.settingsTitle)
    }
    assertSnapshot(of: variant.apply(to: view), as: variant.strategy(.iPhone13), named: variant.rawValue)
  }

  @Test(arguments: Variant.allCases)
  func allAppsList(_ variant: Variant) {
    let view = NavigationStack {
      SiblingAppsView(viewModel: Fixtures.viewModel())
    }
    assertSnapshot(of: variant.apply(to: view), as: variant.strategy(.iPhone13), named: variant.rawValue)
  }

  @Test(arguments: [Variant.light, .arabic])
  func sheet(_ variant: Variant) {
    let view = SiblingAppsSheet(viewModel: Fixtures.viewModel())
    assertSnapshot(of: variant.apply(to: view), as: variant.strategy(.iPhone13), named: variant.rawValue)
  }

  /// A subtitle that is longer than one line must wrap to a second line, and the capsule must stay centered.
  @Test(arguments: [Variant.light, .arabic])
  func longSubtitle(_ variant: Variant) {
    let app = CatalogApp(
      id: AppID.wifiQR,
      bundleID: "com.example.long",
      name: LocalizedText(["en": "Wi-Fi QR", "ar": "واي فاي كيو آر"]),
      subtitle: LocalizedText([
        "en": "Share your Wi-Fi with guests using a QR code",
        "ar": "شارك شبكة الواي فاي مع ضيوفك برمز سريع",
      ]),
      category: LocalizedText(["en": "Utilities", "ar": "أدوات"]),
      platforms: [.iPhone, .iPad]
    )
    func row(_ style: AppRow.Style) -> some View {
      AppRow(app: app, action: .get, style: style, devicePlatform: .iPhone, iconBundle: nil)
    }
    let view = List {
      row(.compact)
      row(.regular)
    }
    assertSnapshot(of: variant.apply(to: view), as: variant.strategy(.iPhone13), named: variant.rawValue)
  }

  @Test func icon() {
    let view = SiblingAppsIcon(
      configuration: SiblingAppsConfiguration(
        hostBundleID: Fixtures.hostBundleID,
        catalog: AbdoCatalog.source,
        catalogClient: .preview,
        appLauncher: .preview
      ),
      size: 60
    )
    .padding()
    assertSnapshot(of: view, as: .image)
  }

  @Test(arguments: [Variant.light, .dark])
  func iPadGrid(_ variant: Variant) {
    let view = NavigationStack {
      SiblingAppsView(viewModel: Fixtures.viewModel(platform: .iPad))
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
