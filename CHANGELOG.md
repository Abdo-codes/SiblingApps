# Changelog

This project uses [Semantic Versioning](https://semver.org). Before 1.0.0, a minor version can break the API.

## 0.5.0

### Breaking

- The package has no third-party dependencies. A host app no longer gets `swift-dependencies`, `swift-clocks`, `combine-schedulers`, `swift-custom-dump`, `swift-concurrency-extras`, `swift-issue-reporting` and `swift-syntax` from this package. The test target still uses `swift-snapshot-testing`, and a host app does not get it.
- `SiblingAppsModel` is now `SiblingAppsViewModel`, with `Input`, `State` and `Output`:

| Old | New |
|-----|-----|
| `model.apps`, `model.featuredApps`, `model.deviceApps`, `model.otherDeviceApps` | `viewModel.state.apps` and the same names |
| `model.action(for:)` | `viewModel.state.action(for:)` |
| `await model.refresh()` | `await viewModel.send(.refresh)` |
| `await model.perform(app)` | `await viewModel.send(.appTapped(app))` |
| `withDependencies { $0.appLauncher = … }` | `SiblingAppsConfiguration(appLauncher: …)` |
| `withDependencies { $0.catalogClient = … }` | `SiblingAppsConfiguration(catalogClient: …)` |
| `.liveValue`, `.previewValue`, `.testValue` | `.live`, `.preview` |

- Tests and previews no longer get safe clients automatically. Pass `.preview` for `catalogClient` and `appLauncher`.
- A missing or bad catalog file now logs an error with `OSLog`. It no longer reports a runtime issue.

### Added

- `SiblingAppsAbdoCatalog` lists SwingCoach, with its icon.

## 0.4.0

### Breaking: the package is now SiblingApps

The package, products, modules and public types have new names. The behavior is the same as 0.3.0.

| Old (0.3.0) | New (0.4.0) |
|-------------|-------------|
| `https://github.com/Abdo-codes/MoreApps` | `https://github.com/Abdo-codes/SiblingApps` |
| `import MoreApps` | `import SiblingApps` |
| `import MoreAppsAbdoCatalog` | `import SiblingAppsAbdoCatalog` |
| `MoreAppsSection`, `MoreAppsView`, `MoreAppsSheet`, `MoreAppsIcon` | `SiblingAppsSection`, `SiblingAppsView`, `SiblingAppsSheet`, `SiblingAppsIcon` |
| `MoreAppsConfiguration`, `MoreAppsModel`, `MoreAppsEvent`, `MoreAppsStrings` | `SiblingAppsConfiguration`, `SiblingAppsModel`, `SiblingAppsEvent`, `SiblingAppsStrings` |
| `Bundle.moreAppsDisplayName` | `Bundle.siblingAppsDisplayName` |

To migrate:

1. Change the package URL to `https://github.com/Abdo-codes/SiblingApps` and the version to `from: "0.4.0"`.
2. Change the product names: `.product(name: "SiblingApps", package: "SiblingApps")`.
3. Replace `MoreApps` with `SiblingApps` in your imports and type names.

The cache folder of the remote catalog is now `Caches/SiblingApps`. The first launch after the update downloads the catalog again.

### Added

- A logo, a GitHub social preview, and a new README.

## 0.3.0

### Breaking

- The `MoreApps` product has no built-in apps. Give the apps with the new `MoreAppsConfiguration.catalog` setting. The default is an empty catalog, and the section then shows nothing.
- `CatalogClient.bundled` is removed. The model reads `configuration.catalog`.
- The author's catalog and icons moved to the new `MoreAppsAbdoCatalog` product. To keep the 0.2 behavior, add that product and pass `catalog: AbdoCatalog.source`.

### Added

- `CatalogSource`: `.bundled(Bundle, resource:)` reads a JSON file, `.inline(Catalog)` takes a catalog from code.
- `MoreAppsConfiguration.iconBundle`: the bundle with the `appicon-<App Store ID>` images. The default is the bundle of a `.bundled` catalog.
- `MoreAppsAbdoCatalog`: `AbdoCatalog.source` and `AbdoCatalog.remoteURL`.
- MIT `LICENSE`, `NOTICE`, this changelog, and a CI workflow.

## 0.2.1

- The `testValue` of the dependencies is safe for host-app tests: no network and no cache.
- `MoreAppsStrings.rowTitle(locale:)`.

## 0.2.0

- `MoreAppsSheet`, `MoreAppsIcon` and `MoreAppsStrings` for themed Settings screens.

## 0.1.0

- First version: `MoreAppsSection`, `MoreAppsView`, the App Store sheet, and English and Arabic text.
