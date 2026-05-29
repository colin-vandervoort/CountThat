import SwiftData
import SwiftUI

@main
struct CountThatApp: App {
  var body: some Scene {
    let inMemory = CommandLine.arguments.contains("--ui-testing")
    WindowGroup {
      ContentView()
    }
    .modelContainer(for: [Counter.self, Tag.self], inMemory: inMemory)
    //    .modelContainer(sharedModelContainer)
  }
}
