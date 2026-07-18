import SwiftUI

struct DeptButtonStyle: ButtonStyle {
    var backgroundColor: Color = AppColor.commonAccentBlue
    var cornerRadius: CGFloat = 20
    var depth: CGFloat = 6
    var borderWidth: CGFloat = 0 // по дефолту без бордера

    private var shadowColor: Color {
        backgroundColor.darker(by: 0.2)
    }

    func makeBody(configuration: Configuration) -> some View {
        PressableContent(
            configuration: configuration,
            backgroundColor: backgroundColor,
            shadowColor: shadowColor,
            cornerRadius: cornerRadius,
            depth: depth,
            borderWidth: borderWidth
        )
    }
}

private struct PressableContent: View {
    let configuration: ButtonStyleConfiguration
    let backgroundColor: Color
    let shadowColor: Color
    let cornerRadius: CGFloat
    let depth: CGFloat
    let borderWidth: CGFloat

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
                        .overlay {
                            if borderWidth > 0 {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(
                                        Color.black.opacity(0.08),
                                        lineWidth: borderWidth
                                    )
                            }
                        }
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

                    // нижняя часть кнопки
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                    .fill(bottomColor)
                    .offset(y: depth)


                    // верхняя часть
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
