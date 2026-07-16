import SwiftUI

struct PressEffect: ViewModifier {
    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1)
            .shadow(
                color: .black.opacity(isPressed ? 0.03 : 0.18),
                radius: isPressed ? 0 : 2,
                x: 0,
                y: isPressed ? 0 : 3
            )
            .animation(
                .easeOut(duration: 0.1),
                value: isPressed
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { value, state, _ in
                        let distance = sqrt(
                            value.translation.width * value.translation.width +
                            value.translation.height * value.translation.height
                        )

                        state = distance < 10
                    }
            )
    }
}

extension View {
    func pressEffect() -> some View {
        modifier(PressEffect())
    }
}

