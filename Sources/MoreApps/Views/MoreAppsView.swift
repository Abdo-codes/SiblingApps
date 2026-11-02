import SwiftUI

/// The full screen of apps. It shows a list in compact width and a grid of cards in regular width.
///
/// `MoreAppsSection` pushes this screen. You can also push or present it yourself.
public struct MoreAppsView: View {
  @State private var model: MoreAppsModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  public init(configuration: MoreAppsConfiguration = MoreAppsConfiguration()) {
    _model = State(initialValue: MoreAppsModel(configuration: configuration))
  }

  init(model: MoreAppsModel) {
    _model = State(initialValue: model)
  }

  public var body: some View {
    Group {
      if horizontalSizeClass == .regular {
        MoreAppsGrid(model: model)
      } else {
        MoreAppsList(model: model)
      }
    }
    .navigationTitle(Text("moreApps.title", bundle: .module))
    .navigationBarTitleDisplayMode(horizontalSizeClass == .regular ? .inline : .large)
    .task { await model.refresh() }
    .onAppear { model.didShowAllApps() }
  }
}
