import SwiftUI
import Lottie

struct SplashView: View {

    let state: SplashState
    let onFinished: () -> Void

    var body: some View {
        Group {
            switch state {

            case .loading:
                LottieView(
                    name: "smile_logo",
                    loop: true
                )
                .frame(height: 85)

            case .intro:
                LottieView(
                    name: "MM_logo",
                    loop: false,
                    completion: onFinished
                )
                .frame(height: 150)
            }
        }


    }
}

enum SplashState {
    case loading
    case intro
}

#Preview {
    SplashView(state: .intro, onFinished: {})
}

