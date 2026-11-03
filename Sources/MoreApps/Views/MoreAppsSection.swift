import SwiftUI

/// A Settings section with the featured apps and a "See All Apps" row.
///
/// Put it in a `List` or `Form` inside a `NavigationStack`:
///
/// ```swift
/// List {
///   // Your sections …
///   MoreAppsSection()
/// }
/// ```
public struct MoreAppsSection: View {
  @State private var model: MoreAppsModel

  public init(configuration: MoreAppsConfiguration = MoreAppsConfiguration()) {
    _model = State(initialValue: MoreAppsModel(configuration: configuration))
  }

  init(model: MoreAppsModel) {
    _model = State(initialValue: model)
  }

  public var body: some View {
    if !model.apps.isEmpty {
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
          MoreAppsView(model: model)
        } label: {
          HStack(spacing: 12) {
            FolderTileIcon(apps: model.folderApps, iconBundle: model.configuration.iconBundle)
            Text("moreApps.seeAll", bundle: .module)
              .foregroundStyle(.tint)
          }
          .padding(.vertical, 4)
        }
        .task { await model.refresh() }
      } header: {
        Text("moreApps.section.title", bundle: .module)
      } footer: {
        Text("moreApps.section.footer", bundle: .module)
      }
    }
  }
}
