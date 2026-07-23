import SwiftUI

struct ShimmerTrophy: View {
    @State private var animate = false

    var size: CGFloat = 16
    let img = "ic_bage_first"
    let imgSized = "ic_bage_first_sized"

    var body: some View {
        Image(size == 16 ? img : imgSized)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
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
                    Image(size == 16 ? img : imgSized)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
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

