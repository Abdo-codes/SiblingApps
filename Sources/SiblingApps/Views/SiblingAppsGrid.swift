import SwiftUI

/// The regular-width layout of `SiblingAppsView`: cards in adaptive columns, for iPad.
struct SiblingAppsGrid: View {
  let viewModel: SiblingAppsViewModel

  private let columns = [GridItem(.adaptive(minimum: 320), spacing: 16)]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        VStack(alignment: .leading, spacing: 4) {
          Text("moreApps.subtitle \(viewModel.configuration.hostAppName)", bundle: .module)
            .font(.title.bold())
          Text("moreApps.section.footer", bundle: .module)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        cardSection(viewModel.state.deviceApps, title: SectionTitles.thisDevice)
        cardSection(viewModel.state.otherDeviceApps, title: SectionTitles.otherDevices(viewModel.state.otherDeviceApps))
      }
      .padding(32)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .background(Color(.systemGroupedBackground))
  }

  @ViewBuilder
  private func cardSection(_ apps: [CatalogApp], title: Text) -> some View {
    if !apps.isEmpty {
      VStack(alignment: .leading, spacing: 12) {
        title
          .font(.footnote)
          .foregroundStyle(.secondary)
          .padding(.horizontal, 16)
        LazyVGrid(columns: columns, spacing: 16) {
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
              .padding(16)
              .background(
                Color(.secondarySystemGroupedBackground),
                in: .rect(cornerRadius: 14, style: .continuous)
              )
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }
}
