import SwiftUI

/// The App Store style capsule: "Get", "Open", or "View". It uses the tint of the host app.
struct ActionButtonLabel: View {
  let action: AppAction
  var minWidth: CGFloat = 64

  var body: some View {
    title
      .font(.subheadline.bold())
      .lineLimit(1)
      .padding(.horizontal, 12)
      .frame(minWidth: minWidth, minHeight: 30)
      .foregroundStyle(action == .open ? AnyShapeStyle(.white) : AnyShapeStyle(.tint))
      .background {
        Capsule().fill(action == .open ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(.tertiarySystemFill)))
      }
      .fixedSize()
  }

  private var title: Text {
    switch action {
    case .get: Text("moreApps.action.get", bundle: .module)
    case .open: Text("moreApps.action.open", bundle: .module)
    case .view: Text("moreApps.action.view", bundle: .module)
    }
  }
}
