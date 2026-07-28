import SwiftUI

struct GameOverOverlay: View {

    let title: String
    let subtitle: String
    let icon: String
    let streak: Int?
    let onResult: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 22) {

                LottieView(name: icon, loop: true)
                    .frame(width: 60, height: 60)

                Text(title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)

                Text(subtitle)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)

                if let streak {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)

                        Text("\(streak) streak")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background {
                        Capsule()
                            .fill(Color.orange.opacity(0.15))
                    }
                }

                CommonButton(
                    title: "View Results",
                    rightImage: "chevron.right",
                    action: onResult
                )
            }
            .padding(30)
            .frame(maxWidth: 330)
            .background {
                RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
                .fill(Color.white)
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 20,
                    y: 10
                )
            }
            .transition(
                .scale(scale: 0.85)
                .combined(with: .opacity)
            )
        }
    }
}
