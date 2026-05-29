import Foundation
import SwiftData

@Model
final class Counter {
  var name: String = ""
  var desc: String = ""
  var count: Int = 0
  var createdAt: Date = Date.now

  @Relationship(deleteRule: .nullify, inverse: \Tag.counters)
  // CloudKit integration requires that all relationships be optional
  var tags: [Tag]? = []

  init(name: String, desc: String = "", count: Int = 0, tags: [Tag] = []) {
    self.name = name
    self.desc = desc
    self.count = count
    self.createdAt = .now
    self.tags = tags
  }
}
