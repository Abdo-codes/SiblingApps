import SwiftUI

/// The 2×2 icon of the "See All Apps" row, for a row that a host app draws in its own style.
public struct MoreAppsIcon: View {
  @State private var model: MoreAppsModel
  private let size: CGFloat

  public init(configuration: MoreAppsConfiguration = MoreAppsConfiguration(), size: CGFloat = 48) {
    _model = State(initialValue: MoreAppsModel(configuration: configuration))
    self.size = size
  }

  public var body: some View {
    FolderTileIcon(apps: Array(model.apps.prefix(4)), size: size)
  }
}
