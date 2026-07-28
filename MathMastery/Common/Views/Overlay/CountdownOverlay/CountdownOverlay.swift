import SwiftUI

struct CountdownOverlay: View {
    let text: String

    @State private var numberScale: CGFloat = 1
    @State private var displayedText: String = ""

    var body: some View {
        ZStack {
            Color.black.opacity(0.32)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Get ready")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)

                Text(displayedText)
                    .font(
                        .system(
                            size: 74,
                            weight: .heavy,
                            design: .rounded
                        )
                    )
                    .frame(height: 90)
                    .foregroundColor(
                        displayedText == "GO!"
                        ? .green
                        : AppColor.commonAccentBlue
                    )
                    .monospacedDigit()
                    .scaleEffect(numberScale)
                    .animation(
                        .spring(
                            response: 0.3,
                            dampingFraction: 0.55
                        ),
                        value: numberScale
                    )
            }
            .padding(24)
            .frame(width: 320, height: 280)
            .background {
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
                .fill(Color(.systemBackground))
            }
        }
        .onAppear {
            displayedText = text
            animateNumber()
        }
        .onChange(of: text) { _, newValue in
            withAnimation(.easeOut(duration: 0.12)) {
                numberScale = 0.8
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                displayedText = newValue
                animateNumber()
            }
        }
    }

    private func animateNumber() {
        numberScale = 0.8

        withAnimation(
            .spring(
                response: 0.35,
                dampingFraction: 0.45
            )
        ) {
            numberScale = 1
        }
    }
}
