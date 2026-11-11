import SwiftUI

/// The 2×2 icon of the "See All Apps" row, for a row that a host app draws in its own style.
public struct SiblingAppsIcon: View {
  @State private var box: ViewModelBox
  private let size: CGFloat

  public init(configuration: SiblingAppsConfiguration = SiblingAppsConfiguration(), size: CGFloat = 48) {
    _box = State(initialValue: ViewModelBox(configuration: configuration))
    self.size = size
  }

  /// Uses a view model that you keep. Views with the same view model share one catalog and one download.
  public init(viewModel: SiblingAppsViewModel, size: CGFloat = 48) {
    _box = State(initialValue: ViewModelBox(viewModel: viewModel))
    self.size = size
  }

  private var viewModel: SiblingAppsViewModel { box.viewModel }

  public var body: some View {
    FolderTileIcon(apps: Array(viewModel.state.apps.prefix(4)), iconBundle: viewModel.configuration.iconBundle, size: size)
      .task { await viewModel.send(.refresh) }
  }
}
