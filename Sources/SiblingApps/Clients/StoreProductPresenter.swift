import StoreKit
import UIKit

/// Shows an App Store page in a sheet, so that the person stays in the host app.
@MainActor
final class StoreProductPresenter: NSObject, SKStoreProductViewControllerDelegate {
  static let shared = StoreProductPresenter()

  func present(appID: Int, campaignToken: String, providerToken: String?) async {
    let webURL = URL(string: "https://apps.apple.com/app/id\(appID)")!
    guard let presenter = Self.topViewController() else {
      await UIApplication.shared.open(webURL)
      return
    }

    // Present first, so that the sheet appears at once and shows a spinner while the page loads.
    let controller = SKStoreProductViewController()
    controller.delegate = self
    presenter.present(controller, animated: true)

    var parameters: [String: Any] = [
      SKStoreProductParameterITunesItemIdentifier: NSNumber(value: appID),
      SKStoreProductParameterCampaignToken: campaignToken,
    ]
    if let providerToken {
      parameters[SKStoreProductParameterProviderToken] = providerToken
    }
    do {
      try await controller.loadProduct(withParameters: parameters)
    } catch {
      // The sheet cannot show some pages, for example an Apple TV app on iPhone. Use the web page.
      controller.dismiss(animated: true)
      await UIApplication.shared.open(webURL)
    }
  }

  nonisolated func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    // StoreKit calls this delegate method on the main thread.
    MainActor.assumeIsolated {
      viewController.dismiss(animated: true)
    }
  }

  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    var top = scene?.keyWindow?.rootViewController
    while let presented = top?.presentedViewController, !presented.isBeingDismissed {
      top = presented
    }
    return top
  }
}
