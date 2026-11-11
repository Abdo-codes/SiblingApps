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
  @State private var box: ViewModelBox
  @Environment(\.dismiss) private var dismiss

  public init(configuration: SiblingAppsConfiguration = SiblingAppsConfiguration()) {
    _box = State(initialValue: ViewModelBox(configuration: configuration))
  }

  /// Uses a view model that you keep. Views with the same view model share one catalog and one download.
  public init(viewModel: SiblingAppsViewModel) {
    _box = State(initialValue: ViewModelBox(viewModel: viewModel))
  }

  private var viewModel: SiblingAppsViewModel { box.viewModel }

  public var body: some View {
    NavigationStack {
      SiblingAppsView(viewModel: viewModel)
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
