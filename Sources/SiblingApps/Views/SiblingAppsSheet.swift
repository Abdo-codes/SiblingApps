import SwiftUI

/// The full screen of apps in its own navigation stack, with a Done button.
///
/// Use it when the host Settings screen is not a `List` or `Form`, for example a themed card:
///
/// ```swift
/// Button("More apps by us") { showsSiblingApps = true }
///   .sheet(isPresented: $showsSiblingApps) { SiblingAppsSheet() }
/// ```
public struct SiblingAppsSheet: View {
  @State private var model: SiblingAppsModel
  @Environment(\.dismiss) private var dismiss

  public init(configuration: SiblingAppsConfiguration = SiblingAppsConfiguration()) {
    _model = State(initialValue: SiblingAppsModel(configuration: configuration))
  }

  init(model: SiblingAppsModel) {
    _model = State(initialValue: model)
  }

  public var body: some View {
    NavigationStack {
      SiblingAppsView(model: model)
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button {
              dismiss()
            } label: {
              Text("moreApps.done", bundle: .module)
            }
          }
        }
    }
  }
}
