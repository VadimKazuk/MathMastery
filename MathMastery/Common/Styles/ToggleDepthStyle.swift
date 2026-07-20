import SwiftUI

struct ToggleDepthStyle: ButtonStyle {
    let isSelected: Bool

    var selectedColor: Color = AppColor.commonAccentBlue
    var unselectedColor: Color = Color(.systemGray5)

    var depth: CGFloat = 6
    var cornerRadius: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        ToggleDepthContent(
            configuration: configuration,
            isSelected: isSelected,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            depth: depth,
            cornerRadius: cornerRadius
        )
    }
}

private struct ToggleDepthContent: View {
    let configuration: ButtonStyleConfiguration
    let isSelected: Bool
    let selectedColor: Color
    let unselectedColor: Color
    let depth: CGFloat
    let cornerRadius: CGFloat

    @State private var pressed = false
    @State private var pressTask: Task<Void, Never>?

    private var backgroundColor: Color {
        isSelected ? selectedColor : unselectedColor
    }

    private var bottomColor: Color {
        backgroundColor.darker(by: 0.18)
    }

    private var contentColor: Color {
        isSelected ? .white : .black
    }

    private var isDown: Bool {
        pressed || !isSelected
    }

    var body: some View {
        configuration.label
            .foregroundColor(contentColor)
            .offset(y: isDown ? depth : 0)
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
            .onChange(of: configuration.isPressed) { _, newValue in
                pressTask?.cancel()

                if newValue {
                    // Мгновенное нажатие
                    withAnimation(.easeOut(duration: 0.035)) {
                        pressed = true
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else {
                    let task = Task {
                        try? await Task.sleep(nanoseconds: 16_000_000)
                        if !Task.isCancelled {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                pressed = false
                            }
                        }
                    }
                    pressTask = task
                }
            }
    }
}
