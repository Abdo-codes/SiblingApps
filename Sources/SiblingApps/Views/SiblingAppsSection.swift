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
  @State private var viewModel: SiblingAppsViewModel

  public init(configuration: SiblingAppsConfiguration = SiblingAppsConfiguration()) {
    _viewModel = State(initialValue: SiblingAppsViewModel(configuration: configuration))
  }

  init(viewModel: SiblingAppsViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  public var body: some View {
    Group {
      if !viewModel.state.apps.isEmpty {
        content
      }
    }
    // Refresh also when the catalog is empty, so that a remote-only catalog can load the first time.
    .task { await viewModel.send(.refresh) }
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
