import SwiftUI

/// A Settings section with the featured apps and a "See All Apps" row.
///
/// Put it in a `List` or `Form` inside a `NavigationStack`:
///
/// ```swift
/// List {
///   // Your sections …
///   SiblingAppsSection()
/// }
/// ```
public struct SiblingAppsSection: View {
  @State private var box: ViewModelBox
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
      if !viewModel.state.apps.isEmpty {
        content
      }
    }
    // Refresh also when the catalog is empty, so that a remote-only catalog can load the first time.
    .task { await viewModel.send(.refresh) }
    .onChange(of: scenePhase) { _, phase in
      // A person can install an app and come back. Check again which apps are installed.
      if phase == .active {
        Task { await viewModel.send(.refresh) }
      }
    }
  }

  private var content: some View {
    Section {
      ForEach(viewModel.state.featuredApps) { app in
        Button {
          Task { await viewModel.send(.appTapped(app)) }
        } label: {
          AppRow(
            app: app,
            action: viewModel.state.action(for: app),
            style: .compact,
            devicePlatform: viewModel.state.devicePlatform,
            iconBundle: viewModel.configuration.iconBundle
          )
        }
      }
      NavigationLink {
        SiblingAppsView(viewModel: viewModel)
      } label: {
        HStack(spacing: 12) {
          FolderTileIcon(apps: viewModel.state.folderApps, iconBundle: viewModel.configuration.iconBundle)
          Text("moreApps.seeAll", bundle: .module)
            .foregroundStyle(.tint)
        }
        .padding(.vertical, 4)
      }
    } header: {
      Text("moreApps.section.title", bundle: .module)
    } footer: {
      Text("moreApps.section.footer", bundle: .module)
    }
  }
}
