import Foundation

/// A value that test closures can read and change from any thread.
final class Locked<Value>: @unchecked Sendable {
  private let lock = NSLock()
  private var stored: Value

  init(_ value: Value) {
    stored = value
  }

  var value: Value {
    lock.withLock { stored }
  }

  func setValue(_ value: Value) {
    lock.withLock { stored = value }
  }

  func withValue(_ change: (inout Value) -> Void) {
    lock.withLock { change(&stored) }
  }
}
