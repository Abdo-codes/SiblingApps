import Foundation

/// The simulator that recorded the snapshots: an iPhone 17 with iOS 27.2.
///
/// A `List` has different margins on other iPhone models, and each iOS version draws its own style.
/// Thus the snapshots match only on this simulator, and the snapshot tests do not run on a different one.
enum SnapshotEnvironment {
  static let modelIdentifier = "iPhone18,3"
  static let osVersion = "27.2"
  static let skipReason: String = "The snapshots need an iPhone 17 simulator with iOS 27.2."

  /// Returns true on the simulator that recorded the snapshots.
  /// CI sets `SNAPSHOT_TESTS_REQUIRED`, so that a wrong simulator there fails the tests and does not skip them.
  static var isCurrent: Bool {
    let environment = ProcessInfo.processInfo.environment
    if environment["SNAPSHOT_TESTS_REQUIRED"] != nil { return true }
    let version = environment["SIMULATOR_RUNTIME_VERSION"] ?? ""
    return environment["SIMULATOR_MODEL_IDENTIFIER"] == modelIdentifier
      && (version == osVersion || version.hasPrefix(osVersion + "."))
  }
}
