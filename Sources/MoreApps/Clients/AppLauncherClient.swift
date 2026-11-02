import Dependencies
import UIKit

/// Finds installed apps, opens them, and shows App Store pages.
public struct AppLauncherClient: Sendable {
  /// Returns true if an installed app handles `url`.
  /// The host app must list the URL scheme in `LSApplicationQueriesSchemes`.
  public var canOpen: @MainActor @Sendable (URL) -> Bool
  public var open: @MainActor @Sendable (URL) async -> Void
  /// Shows the App Store page of the app with this App Store ID.
  public var showProductPage: @MainActor @Sendable (_ appID: Int, _ campaignToken: String, _ providerToken: String?) async -> Void

  public init(
    canOpen: @escaping @MainActor @Sendable (URL) -> Bool,
    open: @escaping @MainActor @Sendable (URL) async -> Void,
    showProductPage: @escaping @MainActor @Sendable (_ appID: Int, _ campaignToken: String, _ providerToken: String?) async -> Void
  ) {
    self.canOpen = canOpen
    self.open = open
    self.showProductPage = showProductPage
  }
}

extension AppLauncherClient: DependencyKey {
  public static let liveValue = AppLauncherClient(
    canOpen: { UIApplication.shared.canOpenURL($0) },
    open: { _ = await UIApplication.shared.open($0) },
    showProductPage: { appID, campaignToken, providerToken in
      await StoreProductPresenter.shared.present(
        appID: appID,
        campaignToken: campaignToken,
        providerToken: providerToken
      )
    }
  )

  /// Host-app tests see no installed apps, and taps do nothing.
  public static let testValue = previewValue

  public static let previewValue = AppLauncherClient(
    canOpen: { _ in false },
    open: { _ in },
    showProductPage: { _, _, _ in }
  )
}

extension DependencyValues {
  public var appLauncher: AppLauncherClient {
    get { self[AppLauncherClient.self] }
    set { self[AppLauncherClient.self] = newValue }
  }
}
