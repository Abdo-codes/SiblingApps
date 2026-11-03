import SwiftUI

/// The compact-width layout of `SiblingAppsView`: grouped rows, one group for each kind of device.
struct SiblingAppsList: View {
  let viewModel: SiblingAppsViewModel

  var body: some View {
    List {
      Text("moreApps.subtitle \(viewModel.configuration.hostAppName)", bundle: .module)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)

      appSection(viewModel.state.deviceApps, title: SectionTitles.thisDevice)
      appSection(viewModel.state.otherDeviceApps, title: SectionTitles.otherDevices(viewModel.state.otherDeviceApps))
    }
    .listStyle(.insetGrouped)
  }

  @ViewBuilder
  private func appSection(_ apps: [CatalogApp], title: Text) -> some View {
    if !apps.isEmpty {
      Section {
        ForEach(apps) { app in
          Button {
            Task { await viewModel.send(.appTapped(app)) }
          } label: {
            AppRow(
              app: app,
              action: viewModel.state.action(for: app),
              style: .regular,
              devicePlatform: viewModel.state.devicePlatform,
              iconBundle: viewModel.configuration.iconBundle
            )
          }
        }
      } header: {
        title
      }
    }
  }
}
