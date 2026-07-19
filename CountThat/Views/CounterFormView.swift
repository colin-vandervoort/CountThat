import SwiftData
import SwiftUI

struct CounterFormView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  let counter: Counter?

  @Query(sort: \Tag.name) private var allTags: [Tag]

  @State private var name: String
  @State private var desc: String
  @State private var count: Int
  @State private var selectedTagIDs: Set<PersistentIdentifier>
  @State private var newTagName = ""

  init(counter: Counter? = nil) {
    self.counter = counter
    _name = State(initialValue: counter?.name ?? "")
    _desc = State(initialValue: counter?.desc ?? "")
    _count = State(initialValue: counter?.count ?? 0)
    _selectedTagIDs = State(initialValue: Set(counter?.tags?.map(\.persistentModelID) ?? []))
  }

  private var isEditing: Bool { counter != nil }

  var body: some View {
    NavigationStack {
      Form {
        Section("Details") {
          TextField("Name", text: $name)
            .accessibilityIdentifier("counter-name-field")
          TextField("Description", text: $desc, axis: .vertical)
            .lineLimit(3, reservesSpace: false)
            .accessibilityIdentifier("counter-desc-field")
          Stepper("Count: \(count)", value: $count)
        }

        Section("Tags") {
          ForEach(allTags) { tag in
            Button {
              if selectedTagIDs.contains(tag.persistentModelID) {
                selectedTagIDs.remove(tag.persistentModelID)
              } else {
                selectedTagIDs.insert(tag.persistentModelID)
              }
            } label: {
              HStack {
                Text(tag.name)
                  .foregroundStyle(.primary)
                Spacer()
                if selectedTagIDs.contains(tag.persistentModelID) {
                  Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                }
              }
            }
            .accessibilityAddTraits(
              selectedTagIDs.contains(tag.persistentModelID) ? .isSelected : []
            )
          }

          HStack {
            TextField("New tag…", text: $newTagName)
              .onSubmit(addTag)
            Button("Add", action: addTag)
              .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
          }
        }
      }
      .navigationTitle(isEditing ? "Edit Counter" : "New Counter")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel) { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save", action: save)
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
      }
    }
  }

  private func addTag() {
    let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { return }

    // Reuse existing tag if name matches
    if let existing = allTags.first(where: {
      $0.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame
    }) {
      selectedTagIDs.insert(existing.persistentModelID)
    } else {
      let tag = Tag(name: trimmed)
      modelContext.insert(tag)
      selectedTagIDs.insert(tag.persistentModelID)
    }
    newTagName = ""
  }

  private func save() {
    let selectedTags = allTags.filter { selectedTagIDs.contains($0.persistentModelID) }

    if let counter {
      counter.name = name.trimmingCharacters(in: .whitespaces)
      counter.desc = desc
      counter.count = count
      counter.tags = selectedTags
      do { try modelContext.save() } catch { assertionFailure("Save failed: \(error)") }
    } else {
      let newCounter = Counter(
        name: name.trimmingCharacters(in: .whitespaces),
        desc: desc,
        count: count
      )
      modelContext.insert(newCounter)
      newCounter.tags = selectedTags
    }
    do { try modelContext.save() } catch { assertionFailure("Save failed: \(error)") }
    dismiss()
  }
}
