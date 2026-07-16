import SwiftUI

struct DeptButtonStyle: ButtonStyle {
    var backgroundColor: Color = AppColor.commonAccentBlue
    var cornerRadius: CGFloat = 20
    var depth: CGFloat = 6

    private var shadowColor: Color {
        backgroundColor.darker(by: 0.2)
    }

    func makeBody(configuration: Configuration) -> some View {
        PressableContent(
            configuration: configuration,
            backgroundColor: backgroundColor,
            shadowColor: shadowColor,
            cornerRadius: cornerRadius,
            depth: depth
        )
    }
}

private struct PressableContent: View {
    let configuration: ButtonStyleConfiguration
    let backgroundColor: Color
    let shadowColor: Color
    let cornerRadius: CGFloat
    let depth: CGFloat

    @State private var isPressed = false
    @State private var pressTask: Task<Void, Never>?

    var body: some View {
        let offset = isPressed ? depth : 0

        configuration.label
            .offset(y: offset)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(shadowColor)
                        .offset(y: depth)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .offset(y: offset)
                }
            }
            .animation(
                isPressed
                ? .easeOut(duration: 0.04)
                : .spring(response: 0.35, dampingFraction: 0.6),
                value: isPressed
            )
            .onChange(of: configuration.isPressed) { _, pressed in
                pressTask?.cancel()
                if pressed {
                    isPressed = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else {
                    pressTask = Task {
                        try? await Task.sleep(nanoseconds: 60_000_000)
                        if !Task.isCancelled {
                            isPressed = false
                        }
                    }
                }
            }
    }
}
