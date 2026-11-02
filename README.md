# MoreApps

A SwiftUI package that shows our other App Store apps in the Settings screen of each app. It supports iPhone and iPad, iOS 17 and later, English and Arabic (RTL), and light and dark mode.

- **Settings section:** three featured apps and a "See All Apps" row.
- **All Apps screen:** a list on iPhone and a grid of cards on iPad. Apps for Apple TV and Mac are in a separate group.
- **App Store sheet:** a tap shows the App Store page in the app (`SKStoreProductViewController`). If an app is installed, the tap opens it.
- **No self-promotion:** the package hides the host app by its bundle ID.

## Add the package

1. In Xcode, select **File > Add Package Dependencies** and add the local path or the Git URL of this package.
2. Add the `MoreApps` library to the app target.

## Show the section

```swift
import MoreApps

List {
  // Your sections …
  MoreAppsSection()
}
```

The section must be in a `List` or `Form` inside a `NavigationStack`. To show the full screen yourself, push `MoreAppsView()`.

### Themed Settings screens

If the Settings screen is a custom layout (cards in a `ScrollView`, a game menu), draw one row in your own style and present `MoreAppsSheet` from it. The sheet has its own navigation stack and a Done button. `MoreAppsIcon` gives the 2×2 icon for the row.

```swift
Button {
  showsMoreApps = true
} label: {
  HStack {
    MoreAppsIcon(configuration: configuration, size: 40)
    Text(MoreAppsStrings.rowTitle)
  }
}
.sheet(isPresented: $showsMoreApps) {
  MoreAppsSheet(configuration: configuration)
}
```

## Configure

```swift
MoreAppsSection(
  configuration: MoreAppsConfiguration(
    remoteCatalogURL: URL(string: "https://example.com/more-apps.json"),
    featuredCount: 3,
    campaignToken: "settings",
    providerToken: "<App Store Connect provider ID>",
    onEvent: { event in Analytics.log(event) }
  )
)
```

All the values have defaults. `hostBundleID` and `hostAppName` come from `Bundle.main`.

## Show "Open" for installed apps

The package uses `canOpenURL` to find installed apps. Each app needs a `urlScheme` in the catalog. Add the schemes to the `Info.plist` of the host app:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tateemi</string>
</array>
```

If a scheme is not in this list, the app shows "Get".

## Add or change an app

1. Add the app to `Sources/MoreApps/Resources/catalog.json`. The order in the file is the display order.
2. Add a 180 × 180 px icon to `AppIcons.xcassets` with the name `appicon-<App Store ID>`. If there is no bundled icon, the package downloads `iconURL`.
3. Give `subtitle` and `category` values for `en` and `ar`. A missing language uses the English value.
4. Run the tests. If the screens changed, delete the old snapshots and run the tests two times to record them again.

If you set `remoteCatalogURL`, host the same JSON format there. New apps then appear without an app update. The package caches the last download and uses the bundled file when there is no cache.

## Test

```bash
xcodebuild test -scheme MoreApps -destination 'platform=iOS Simulator,name=iPhone 17'
```

The snapshot tests record on the first run and need the same simulator for each later run.
