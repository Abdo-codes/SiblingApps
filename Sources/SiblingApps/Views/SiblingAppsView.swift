import SwiftUI

/// The full screen of apps. It shows a list in compact width and a grid of cards in regular width.
///
/// `SiblingAppsSection` pushes this screen. You can also push or present it yourself.
public struct SiblingAppsView: View {
  @State private var box: ViewModelBox
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.scenePhase) private var scenePhase

  public init(configuration: SiblingAppsConfiguration = SiblingAppsConfiguration()) {
    _box = State(initialValue: ViewModelBox(configuration: configuration))
  }

  /// Uses a view model that you keep. Views with the same view model share one catalog and one download.
  public init(viewModel: SiblingAppsViewModel) {
    _box = State(initialValue: ViewModelBox(viewModel: viewModel))
  }

  private var viewModel: SiblingAppsViewModel { box.viewModel }

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
    .onChange(of: scenePhase) { _, phase in
      // A person can install an app and come back. Check again which apps are installed.
      if phase == .active {
        Task { await viewModel.send(.refresh) }
      }
    }
    .onAppear { Task { await viewModel.send(.allAppsShown) } }
  }
}
