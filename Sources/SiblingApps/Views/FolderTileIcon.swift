import SwiftUI

/// Four small icons on a gray tile, like a folder in the App Library.
struct FolderTileIcon: View {
  let apps: [CatalogApp]
  let iconBundle: Bundle?
  var size: CGFloat = 48

  var body: some View {
    let spacing = size / 12
    let iconSize = (size - spacing * 3) / 2
    VStack(spacing: spacing) {
      HStack(spacing: spacing) {
        slot(0, size: iconSize)
        slot(1, size: iconSize)
      }
      HStack(spacing: spacing) {
        slot(2, size: iconSize)
        slot(3, size: iconSize)
      }
    }
    .frame(width: size, height: size)
    .background(
      Color(.tertiarySystemFill),
      in: .rect(cornerRadius: size * 0.2237, style: .continuous)
    )
    .accessibilityHidden(true)
  }

  @ViewBuilder
  private func slot(_ index: Int, size: CGFloat) -> some View {
    if apps.indices.contains(index) {
      AppIconView(app: apps[index], size: size, bundle: iconBundle)
    } else {
      Color.clear.frame(width: size, height: size)
    }
  }
}
