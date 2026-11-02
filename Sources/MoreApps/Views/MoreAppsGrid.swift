import SwiftUI

/// The regular-width layout of `MoreAppsView`: cards in adaptive columns, for iPad.
struct MoreAppsGrid: View {
  let model: MoreAppsModel

  private let columns = [GridItem(.adaptive(minimum: 320), spacing: 16)]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        VStack(alignment: .leading, spacing: 4) {
          Text("moreApps.subtitle \(model.configuration.hostAppName)", bundle: .module)
            .font(.title.bold())
          Text("moreApps.section.footer", bundle: .module)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        cardSection(model.deviceApps, title: SectionTitles.thisDevice)
        cardSection(model.otherDeviceApps, title: SectionTitles.otherDevices(model.otherDeviceApps))
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
              Task { await model.perform(app) }
            } label: {
              AppRow(
                app: app,
                action: model.action(for: app),
                style: .regular,
                devicePlatform: model.devicePlatform
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
