import SwiftUI

/// The 2×2 icon of the "See All Apps" row, for a row that a host app draws in its own style.
public struct SiblingAppsIcon: View {
  @State private var viewModel: SiblingAppsViewModel
  private let size: CGFloat

  public init(configuration: SiblingAppsConfiguration = SiblingAppsConfiguration(), size: CGFloat = 48) {
    _viewModel = State(initialValue: SiblingAppsViewModel(configuration: configuration))
    self.size = size
  }

  public var body: some View {
    FolderTileIcon(apps: Array(viewModel.state.apps.prefix(4)), iconBundle: viewModel.configuration.iconBundle, size: size)
      .task { await viewModel.send(.refresh) }
  }
}
