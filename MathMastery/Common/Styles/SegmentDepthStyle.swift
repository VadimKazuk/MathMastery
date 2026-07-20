import SwiftUI

struct SegmentDepthStyle: ButtonStyle {

    let isSelected: Bool

    var selectedColor: Color = AppColor.commonAccentBlue
    var unselectedColor: Color = Color(.systemGray5)

    var depth: CGFloat = 5
    var cornerRadius: CGFloat = 12

    func makeBody(configuration: Configuration) -> some View {
        SegmentDepthContent(
            configuration: configuration,
            isSelected: isSelected,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            depth: depth,
            cornerRadius: cornerRadius
        )
    }
}


private struct SegmentDepthContent: View {
    let configuration: ButtonStyleConfiguration
    let isSelected: Bool
    let selectedColor: Color
    let unselectedColor: Color
    let depth: CGFloat
    let cornerRadius: CGFloat

    @State private var pressed = false

    private var backgroundColor: Color {
        isSelected ? selectedColor : unselectedColor
    }

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
            .animation(
                .spring(
                    response: 0.29,
                    dampingFraction: 0.72,
                    blendDuration: 0.08
                ),
                value: isDown
            )
            .animation(
                .spring(
                    response: 0.27,
                    dampingFraction: 0.75
                ),
                value: isSelected
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

