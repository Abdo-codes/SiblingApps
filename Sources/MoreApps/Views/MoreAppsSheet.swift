import SwiftUI

/// The full screen of apps in its own navigation stack, with a Done button.
///
/// Use it when the host Settings screen is not a `List` or `Form`, for example a themed card:
///
/// ```swift
/// Button("More apps by us") { showsMoreApps = true }
///   .sheet(isPresented: $showsMoreApps) { MoreAppsSheet() }
/// ```
public struct MoreAppsSheet: View {
  @State private var model: MoreAppsModel
  @Environment(\.dismiss) private var dismiss

  public init(configuration: MoreAppsConfiguration = MoreAppsConfiguration()) {
    _model = State(initialValue: MoreAppsModel(configuration: configuration))
  }

  init(model: MoreAppsModel) {
    _model = State(initialValue: model)
  }

  public var body: some View {
    NavigationStack {
      MoreAppsView(model: model)
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
