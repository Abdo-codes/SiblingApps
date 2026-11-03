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
  @State private var model: SiblingAppsModel

  public init(configuration: SiblingAppsConfiguration = SiblingAppsConfiguration()) {
    _model = State(initialValue: SiblingAppsModel(configuration: configuration))
  }

  init(model: SiblingAppsModel) {
    _model = State(initialValue: model)
  }

  public var body: some View {
    Group {
      if !model.apps.isEmpty {
        content
      }
    }
    // Refresh also when the catalog is empty, so that a remote-only catalog can load the first time.
    .task { await model.refresh() }
  }

  private var content: some View {
    Section {
      ForEach(model.featuredApps) { app in
        Button {
          Task { await model.perform(app) }
        } label: {
          AppRow(
            app: app,
            action: model.action(for: app),
            style: .compact,
            devicePlatform: model.devicePlatform,
            iconBundle: model.configuration.iconBundle
          )
        }
      }
      NavigationLink {
        SiblingAppsView(model: model)
      } label: {
        HStack(spacing: 12) {
          FolderTileIcon(apps: model.folderApps, iconBundle: model.configuration.iconBundle)
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
