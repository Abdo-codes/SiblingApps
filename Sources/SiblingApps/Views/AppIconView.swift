import SwiftUI
import UIKit

/// An app icon with the App Store corner shape and a hairline border.
struct AppIconView: View {
  let app: CatalogApp
  let size: CGFloat
  let bundle: Bundle?

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: size * 0.2237, style: .continuous)
    image
      .frame(width: size, height: size)
      .clipShape(shape)
      .overlay { shape.strokeBorder(.primary.opacity(0.1), lineWidth: 0.5) }
      .accessibilityHidden(true)
  }

  @ViewBuilder
  private var image: some View {
    let name = "appicon-\(app.id)"
    if let bundle, UIImage(named: name, in: bundle, with: nil) != nil {
      Image(name, bundle: bundle).resizable()
    } else {
      // An app with no bundled icon, for example an app that only the remote catalog knows.
      AsyncImage(url: app.iconURL) { image in
        image.resizable()
      } placeholder: {
        Color(.tertiarySystemFill)
      }
    }
  }
}
