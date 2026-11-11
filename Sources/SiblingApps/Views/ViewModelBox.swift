/// Makes the view model the first time that a view body reads it.
///
/// SwiftUI runs the `init` of a view each time the parent view draws, but `@State` keeps only the first box.
/// The box is cheap to make. Thus the catalog is read one time for each view on screen, not one time for each draw.
@MainActor
final class ViewModelBox {
  private let make: @MainActor () -> SiblingAppsViewModel
  private(set) lazy var viewModel = make()

  init(configuration: SiblingAppsConfiguration) {
    make = { SiblingAppsViewModel(configuration: configuration) }
  }

  init(viewModel: SiblingAppsViewModel) {
    make = { viewModel }
  }
}
