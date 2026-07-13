import SwiftUI

struct ShimmerTrophy: View {
    @State private var animate = false

    var size: CGFloat = 12
    let img = "trophy.fill"

    var body: some View {
        Image(systemName: img)
            .font(.system(size: size, weight: .bold))
            .foregroundColor(.yellow)
            .overlay {
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.9),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: animate ? 60 : -60)
                .mask {
                    Image(systemName: img)
                        .font(.system(size: size, weight: .bold))
                }
            }
            .onAppear {
                withAnimation(
                    .linear(duration: 3.5)
                        .repeatForever(autoreverses: false)
                ) {
                    animate = true
                }
            }
    }
}

