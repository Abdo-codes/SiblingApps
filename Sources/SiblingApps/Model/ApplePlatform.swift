import UIKit

/// A device family that a catalog app runs on.
public enum ApplePlatform: String, Sendable, Hashable, CaseIterable {
  case iPhone
  case iPad
  case appleTV
  case mac

  /// The platform of the device that runs the host app.
  @MainActor
  public static var current: ApplePlatform {
    UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
  }

  /// The brand name. Apple does not translate these names.
  var displayName: String {
    switch self {
    case .iPhone: "iPhone"
    case .iPad: "iPad"
    case .appleTV: "Apple TV"
    case .mac: "Mac"
    }
  }

  var systemImage: String {
    switch self {
    case .iPhone: "iphone"
    case .iPad: "ipad"
    case .appleTV: "appletv"
    case .mac: "laptopcomputer"
    }
  }
}
