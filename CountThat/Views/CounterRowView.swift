import SwiftData
import SwiftUI

struct CounterRowView: View {
  @Bindable var counter: Counter
  let onEdit: () -> Void

  var body: some View {
    HStack(spacing: 16) {
      Button(action: onEdit) {
        VStack(alignment: .leading, spacing: 4) {
          Text(counter.name)
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(.primary)

          if !counter.desc.isEmpty {
            Text(counter.desc)
              .font(.caption)
              .foregroundStyle(.secondary)
              .lineLimit(2)
          }

          if let tags = counter.tags, !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 4) {
                ForEach(tags.sorted(by: { $0.name < $1.name })) { tag in
                  TagChip(name: tag.name)
                }
              }
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Edit \(counter.name)")

      HStack(spacing: 4) {
        Button {
          counter.count -= 1
        } label: {
          Image(systemName: "minus.circle.fill")
            .font(.title2)
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel("Decrement \(counter.name)")

        Text("\(counter.count)")
          .font(.title3.monospacedDigit())
          .fontWeight(.semibold)
          .frame(minWidth: 44, alignment: .center)
          .accessibilityIdentifier("count-\(counter.name)")

        Button {
          counter.count += 1
        } label: {
          Image(systemName: "plus.circle.fill")
            .font(.title2)
            .foregroundStyle(.tint)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel("Increment \(counter.name)")
      }
    }
    .padding(.vertical, 4)
  }
}

struct TagChip: View {
  let name: String

  var body: some View {
    Text(name)
      .font(.caption2)
      .padding(.horizontal, 8)
      .padding(.vertical, 3)
      .background(.quaternary)
      .clipShape(Capsule())
  }
}
