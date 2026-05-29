import SwiftData
import SwiftUI

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var counters: [Counter] = []
  @State private var showingAddCounter = false
  @State private var counterToEdit: Counter?

  var body: some View {
    NavigationStack {
      List {
        ForEach(counters) { counter in
          CounterRowView(counter: counter) {
            counterToEdit = counter
          }
        }
        .onDelete(perform: deleteCounters)
      }
      .navigationTitle("Counters")
      .overlay {
        if counters.isEmpty {
          ContentUnavailableView(
            "No Counters",
            systemImage: "number.circle",
            description: Text("Tap + to add your first counter.")
          )
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddCounter = true
          } label: {
            Label("Add Counter", systemImage: "plus")
          }
        }
      }
      .onAppear(perform: fetchCounters)
      .sheet(isPresented: $showingAddCounter, onDismiss: fetchCounters) {
        CounterFormView()
      }
      .sheet(item: $counterToEdit) { counter in
        CounterFormView(counter: counter)
      }
      .onChange(of: counterToEdit) { _, new in
        if new == nil { fetchCounters() }
      }
    }
  }

  private func fetchCounters() {
    let descriptor = FetchDescriptor<Counter>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    counters = (try? modelContext.fetch(descriptor)) ?? []
  }

  private func deleteCounters(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(counters[index])
      }
      fetchCounters()
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: [Counter.self, Tag.self], inMemory: true)
}
