import SwiftUI

struct DropdownMenu<ID: Hashable, Item>: View
where Item: DropdownMenuItem & CaseIterable & Hashable {

    let id: ID
    let icon: String

    @Binding var selection: Item
    @Binding var expandedMenu: ID?

    private var isExpanded: Bool {
        expandedMenu == id
    }

    private var items: [Item] {
        Array(Item.allCases)
    }

    var body: some View {
        GeometryReader { geometry in
            labelButton
                .overlay(alignment: .topLeading) {
                    if isExpanded {
                        dropdown(width: geometry.size.width)
                            .offset(y: 38)
                            .transition(
                                .scale(scale: 0.95, anchor: .top)
                                .combined(with: .opacity)
                            )
                            .allowsHitTesting(true)
                    }
                }
        }
        .frame(height: 36) // высота твоей кнопки
        .zIndex(isExpanded ? 1000 : 0)
    }
}


// MARK: - Button

private extension DropdownMenu {

    var labelButton: some View {
        Button {
            withAnimation(.snappy(duration: 0.22)) {
                expandedMenu = isExpanded ? nil : id
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(selection.title)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(.black)
            .padding(8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            DepthButtonStyle(
                backgroundColor: .white,
                cornerRadius: 6,
                depth: 3,
                borderWidth: 0.5
            )
        )
    }
}


// MARK: - Dropdown

private extension DropdownMenu {

    func dropdown(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    selection = item
                    withAnimation(.snappy(duration: 0.22)) {
                        expandedMenu = nil
                    }
                } label: {
                    HStack {
                        Text(item.title)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                        Spacer()
                        if item == selection {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppColor.commonAccentBlue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if item != items.last {
                    Divider()
                }
            }
        }
        .frame(width: width) // ← вместо 170
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(
            color: .black.opacity(0.18),
            radius: 12,
            y: 6
        )
    }
}
