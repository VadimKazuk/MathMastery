import SwiftUI

struct TabBarDepthButtonStyle: ButtonStyle {

    let isSelected: Bool

    var backgroundColor: Color = .white
    var depth: CGFloat = 6
    var cornerRadius: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        ButtonDepthContent(
            configuration: configuration,
            isSelected: isSelected,
            backgroundColor: backgroundColor,
            depth: depth,
            cornerRadius: cornerRadius
        )
    }
}

private struct ButtonDepthContent: View {

    let configuration: ButtonStyleConfiguration
    let isSelected: Bool
    let backgroundColor: Color
    let depth: CGFloat
    let cornerRadius: CGFloat

    @State private var pressed = false

    private var bottomColor: Color {
        backgroundColor.darker(by: 0.18)
    }

    var body: some View {

        let isDown = pressed || !isSelected

        configuration.label
            .offset(
                y: isDown ? depth : 0
            )
            .background {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                    .fill(bottomColor)
                    .offset(y: depth)

                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                    .fill(backgroundColor)
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: cornerRadius,
                            style: .continuous
                        )
                        .stroke(
                            Color.black.opacity(0.08),
                            lineWidth: 1
                        )
                    }
                    .offset(
                        y: isDown ? depth : 0
                    )
                }
            }
            .scaleEffect(
                pressed ? 0.94 : 1
            )
            .animation(
                pressed
                ? .easeIn(duration: 0.06)
                : .spring(
                    response: 0.25,
                    dampingFraction: 0.45,
                    blendDuration: 0.1
                ),
                value: pressed
            )
            .onChange(of: configuration.isPressed) { _, value in

                pressed = value

                if value {
                    UIImpactFeedbackGenerator(
                        style: .medium
                    )
                    .impactOccurred()
                }
            }
    }
}

