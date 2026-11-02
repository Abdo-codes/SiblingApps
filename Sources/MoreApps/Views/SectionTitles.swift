import SwiftUI

/// Group titles that the full list and the iPad grid share.
enum SectionTitles {
  static var thisDevice: Text {
    Text("moreApps.group.thisDevice", bundle: .module)
  }

  /// "For Apple TV", "For Mac", or "For Apple TV & Mac", from the platforms of `apps`.
  static func otherDevices(_ apps: [CatalogApp]) -> Text {
    let platforms = Set(apps.flatMap(\.platforms))
    switch (platforms.contains(.appleTV), platforms.contains(.mac)) {
    case (true, false): return Text("moreApps.group.appleTV", bundle: .module)
    case (false, true): return Text("moreApps.group.mac", bundle: .module)
    default: return Text("moreApps.group.otherDevices", bundle: .module)
    }
  }
}
