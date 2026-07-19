import Foundation
import SwiftData

@Model
final class Tag {
  // CloudKit integration does not support unique constraints
  var name: String = ""
  // CloudKit integration requires that all relationships be optional
  // swiftlint:disable:next discouraged_optional_collection
  var counters: [Counter]? = []

  init(name: String, counters: [Counter] = []) {
    self.name = name
    self.counters = counters
  }
}
