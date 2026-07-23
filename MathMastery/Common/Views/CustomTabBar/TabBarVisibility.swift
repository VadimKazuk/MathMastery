import SwiftUI
import Combine

final class TabBarVisibility: ObservableObject {
    @Published private(set) var isHidden = false
    @Published var measuredHeight: CGFloat = 0

    private var hideCount = 0

    func hide() { hideCount += 1; recalc() }
    func show() { hideCount = max(0, hideCount - 1); recalc() }

    private func recalc() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isHidden = hideCount > 0
        }
    }

    var reservedHeight: CGFloat {
        isHidden ? 0 : measuredHeight
    }
}

struct TabBarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct HidesCustomTabBar: ViewModifier {
    @EnvironmentObject var tabBarVisibility: TabBarVisibility

    func body(content: Content) -> some View {
        content
            .onAppear { tabBarVisibility.hide() }
            .onDisappear { tabBarVisibility.show() }
    }
}

extension View {
    func hidesCustomTabBar() -> some View {
        modifier(HidesCustomTabBar())
    }
}
