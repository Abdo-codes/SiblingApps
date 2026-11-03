import SwiftUI

/// The full screen of apps. It shows a list in compact width and a grid of cards in regular width.
///
/// `SiblingAppsSection` pushes this screen. You can also push or present it yourself.
public struct SiblingAppsView: View {
  @State private var viewModel: SiblingAppsViewModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  public init(configuration: SiblingAppsConfiguration = SiblingAppsConfiguration()) {
    _viewModel = State(initialValue: SiblingAppsViewModel(configuration: configuration))
  }

  init(viewModel: SiblingAppsViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  public var body: some View {
    Group {
      if horizontalSizeClass == .regular {
        SiblingAppsGrid(viewModel: viewModel)
      } else {
        SiblingAppsList(viewModel: viewModel)
      }
    }
    .navigationTitle(Text("moreApps.title", bundle: .module))
    .navigationBarTitleDisplayMode(horizontalSizeClass == .regular ? .inline : .large)
    .task { await viewModel.send(.refresh) }
    .onAppear { Task { await viewModel.send(.allAppsShown) } }
  }
}
