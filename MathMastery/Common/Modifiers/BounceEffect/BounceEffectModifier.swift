import SwiftUI

struct BounceEffect: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 0.94 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.4),
                value: isAnimating
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        isAnimating = true

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            isAnimating = false
                        }
                    }
            )
    }
}

extension View {
    func bounceEffect() -> some View {
        modifier(BounceEffect())
    }
}
