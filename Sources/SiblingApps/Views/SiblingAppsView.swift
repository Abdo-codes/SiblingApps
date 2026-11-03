import SwiftUI

/// The full screen of apps. It shows a list in compact width and a grid of cards in regular width.
///
/// `SiblingAppsSection` pushes this screen. You can also push or present it yourself.
public struct SiblingAppsView: View {
  @State private var model: SiblingAppsModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  public init(configuration: SiblingAppsConfiguration = SiblingAppsConfiguration()) {
    _model = State(initialValue: SiblingAppsModel(configuration: configuration))
  }

  init(model: SiblingAppsModel) {
    _model = State(initialValue: model)
  }

  public var body: some View {
    Group {
      if horizontalSizeClass == .regular {
        SiblingAppsGrid(model: model)
      } else {
        SiblingAppsList(model: model)
      }
    }
    .navigationTitle(Text("moreApps.title", bundle: .module))
    .navigationBarTitleDisplayMode(horizontalSizeClass == .regular ? .inline : .large)
    .task { await model.refresh() }
    .onAppear { model.didShowAllApps() }
  }
}
