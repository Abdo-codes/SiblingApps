import SwiftUI
import UIKit

/// An app icon with the App Store corner shape and a hairline border.
struct AppIconView: View {
  let app: CatalogApp
  let size: CGFloat

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
    if UIImage(named: name, in: .module, with: nil) != nil {
      Image(name, bundle: .module).resizable()
    } else {
      // An app that only the remote catalog knows has no bundled icon.
      AsyncImage(url: app.iconURL) { image in
        image.resizable()
      } placeholder: {
        Color(.tertiarySystemFill)
      }
    }
  }
}
