import SwiftUI

struct CustomTabBar: View {
    @Binding var selection: ContentContainerView.ContentViewType

    private let items: [TabBarItem] = [
        .init(
            type: .home,
            title: "Home",
            icon: "ic_home",
            selectedIcon: "ic_home_blue"
        ),
        .init(
            type: .learn,
            title: "Learn",
            icon: "ic_dictionary",
            selectedIcon: "ic_dictionary_blue"
        ),
        .init(
            type: .practice,
            title: "Practice",
            icon: "ic_calculator",
            selectedIcon: "ic_calculator_blue"
        ),
        .init(
            type: .profile,
            title: "Profile",
            icon: "ic_user",
            selectedIcon: "ic_user_blue"
        )
    ]

    var body: some View {
        HStack {
            ForEach(items) { item in
                Button {
                    guard selection != item.type else { return }

                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selection = item.type
                    }

                } label: {

                    VStack {
                        TabBarIcon(
                            item: item,
                            isSelected: selection == item.type
                        )
                    }
                    .frame(width: 55, height: 45)
                    .foregroundStyle(.black)
                }
                .buttonStyle(
                    TabBarDepthButtonStyle(
                        isSelected: selection == item.type
                    )
                )

                if item.type != items.last?.type {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 50)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 28,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 28
            )
            .fill(.white)
            .shadow(
                color: .black.opacity(0.08),
                radius: 12,
                y: -2
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

private struct TabBarIcon: View {

    let item: TabBarItem
    let isSelected: Bool

    var body: some View {
        ZStack {
            Image(item.icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .opacity(isSelected && item.selectedIcon != nil ? 0 : 1)

            if let selectedIcon = item.selectedIcon {
                Image(selectedIcon)
                    .resizable()
                    .scaledToFit()
                    .opacity(isSelected ? 1 : 0)
                    .scaleEffect(isSelected ? 1 : 0.92)
            }
        }
        .frame(width: 22, height: 22)
        .animation(
            .spring(response: 0.28, dampingFraction: 0.82),
            value: isSelected
        )
    }
}


// MARK: - Item

private struct TabBarItem: Identifiable {

    let type: ContentContainerView.ContentViewType
    let title: String
    let icon: String
    let selectedIcon: String?

    var id: ContentContainerView.ContentViewType {
        type
    }

    func imageName(isSelected: Bool) -> String {
        if isSelected, let selectedIcon {
            return selectedIcon
        }

        return icon
    }
}
