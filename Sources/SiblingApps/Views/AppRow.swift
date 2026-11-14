import SwiftUI
import UIKit

/// One app: icon, name, subtitle, and the action capsule.
struct AppRow: View {
  enum Style {
    /// Up to three lines and a 48 pt icon, for the Settings section.
    case compact
    /// Up to four lines and a 60 pt icon, for the full list and the iPad cards.
    case regular
  }

  let app: CatalogApp
  let action: AppAction
  let style: Style
  let devicePlatform: ApplePlatform
  let iconBundle: Bundle?

  @Environment(\.locale) private var locale
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    HStack(spacing: style == .compact ? 12 : 14) {
      AppIconView(app: app, size: style == .compact ? 48 : 60, bundle: iconBundle)
      VStack(alignment: .leading, spacing: style == .compact ? 1 : 2) {
        Text(app.name.resolved(for: locale))
          .font(style == .compact ? .callout.weight(.semibold) : .body.weight(.semibold))
          .foregroundStyle(Color.primary)
          .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
          .fixedSize(horizontal: false, vertical: true)
        Text(app.subtitle.resolved(for: locale))
          .font(.subheadline)
          .foregroundStyle(Self.subtitleColor)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)
        if style == .regular {
          detail
            .font(.footnote)
            .foregroundStyle(Color.secondary)
            .lineLimit(1)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      ActionButtonLabel(action: action, minWidth: style == .compact ? 64 : 72)
    }
    .padding(.vertical, style == .compact ? 4 : 2)
    .contentShape(.rect)
    .accessibilityElement(children: .combine)
  }

  /// The category, or the platform for an app that does not run on this device.
  @ViewBuilder
  private var detail: some View {
    if !app.runs(on: devicePlatform),
      let platform = app.platforms.first(where: { $0 != .iPhone && $0 != .iPad }) {
      HStack(spacing: 4) {
        Image(systemName: platform.systemImage)
        Text(platform.displayName)
      }
    } else {
      Text(app.category.resolved(for: locale))
    }
  }

  /// A gray with more contrast than `.secondary`, from the design.
  private static let subtitleColor = Color(
    uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(red: 0x98 / 255, green: 0x98 / 255, blue: 0x9F / 255, alpha: 1)
        : UIColor(red: 0x6C / 255, green: 0x6C / 255, blue: 0x70 / 255, alpha: 1)
    }
  )
}
