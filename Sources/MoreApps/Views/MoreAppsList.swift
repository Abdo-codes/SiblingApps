import SwiftUI

/// The compact-width layout of `MoreAppsView`: grouped rows, one group for each kind of device.
struct MoreAppsList: View {
  let model: MoreAppsModel

  var body: some View {
    List {
      Text("moreApps.subtitle \(model.configuration.hostAppName)", bundle: .module)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)

      appSection(model.deviceApps, title: SectionTitles.thisDevice)
      appSection(model.otherDeviceApps, title: SectionTitles.otherDevices(model.otherDeviceApps))
    }
    .listStyle(.insetGrouped)
  }

  @ViewBuilder
  private func appSection(_ apps: [CatalogApp], title: Text) -> some View {
    if !apps.isEmpty {
      Section {
        ForEach(apps) { app in
          Button {
            Task { await model.perform(app) }
          } label: {
            AppRow(
              app: app,
              action: model.action(for: app),
              style: .regular,
              devicePlatform: model.devicePlatform,
              iconBundle: model.configuration.iconBundle
            )
          }
        }
      } header: {
        title
      }
    }
  }
}
