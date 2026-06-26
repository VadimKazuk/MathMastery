import SwiftUI

struct SplashView: View {
    @State private var hiddenProgress = true

    var body: some View {
        ZStack {
            VStack {
                Image("heading_math_mastery")
                    .padding(16)

                if !hiddenProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.red))
                        .scaleEffect(x: 1.5, y: 1.5)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut) {
                hiddenProgress = false
            }
        }
    }
}

#Preview {
    SplashView()
}

