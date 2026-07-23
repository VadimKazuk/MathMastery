import SwiftUI

struct ProgressRing<Content: View>: View {
    let progress: CGFloat
    let color: Color
    let lineWidth: CGFloat
    var depthOffset: CGSize? = nil
    var animated: Bool = true

    @ViewBuilder let content: () -> Content

    @State private var animatedProgress: CGFloat = 0
    @State private var hasAnimated = false

    private var offset: CGSize {
        depthOffset ?? CGSize(
            width: lineWidth * 0.18,
            height: -lineWidth * 0.22
        )
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.12),
                    lineWidth: lineWidth
                )

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color.darker(by: 0.3),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .offset(offset)

            content()
        }
        .onAppear {
            if animated {
                guard !hasAnimated else { return }
                hasAnimated = true
                animatedProgress = 0
                animate(to: progress)
            } else {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            if animated {
                animate(to: newValue)
            } else {
                animatedProgress = newValue
            }
        }
    }

    private func animate(to value: CGFloat) {
        withAnimation(
            .interactiveSpring(
                response: 0.9,
                dampingFraction: 0.8
            )
        ) {
            animatedProgress = value
        }
    }
}
