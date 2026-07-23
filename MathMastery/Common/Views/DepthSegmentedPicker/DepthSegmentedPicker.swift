import SwiftUI

struct DepthSegmentedPicker<T: Hashable>: View {
    let items: [T]
    @Binding var selection: T
    let title: (T) -> String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button {
                    guard selection != item else { return }
                    selection = item
                } label: {
                    SegmentText(
                        text: title(item),
                        isSelected: selection == item
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(
                    SegmentDepthStyle(
                        isSelected: selection == item
                    )
                )
            }
        }
        .frame(height: 42)
    }
}

private struct SegmentText: View {
    let text: String
    let isSelected: Bool

    var body: some View {
        ZStack {
            Text(text)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .opacity(isSelected ? 0 : 1)

            Text(text)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .opacity(isSelected ? 1 : 0)
        }
        .animation(.spring(response: 0.27, dampingFraction: 0.8), value: isSelected)
    }
}
