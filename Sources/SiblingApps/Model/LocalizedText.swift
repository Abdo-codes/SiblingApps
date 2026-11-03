import Foundation

/// Text with one value for each language code, for example `["en": "Games", "ar": "الألعاب"]`.
public struct LocalizedText: Sendable, Hashable, Codable {
  public var values: [String: String]

  public init(_ values: [String: String]) {
    self.values = values
  }

  public init(from decoder: any Decoder) throws {
    values = try decoder.singleValueContainer().decode([String: String].self)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(values)
  }

  /// Returns the value for the language of `locale`. If there is none, returns English, then any value.
  public func resolved(for locale: Locale) -> String {
    if let code = locale.language.languageCode?.identifier, let value = values[code] {
      return value
    }
    return values["en"] ?? values.values.sorted().first ?? ""
  }
}
