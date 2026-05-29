import Foundation
import SwiftData

@Model
final class Tag {
  // CloudKit integration does not support unique constraints
  var name: String = ""
  var counters: [Counter]? = []

  init(name: String, counters: [Counter] = []) {
    self.name = name
    self.counters = counters
  }
}
