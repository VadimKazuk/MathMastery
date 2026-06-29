import SwiftUI

struct HomeView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel
    let progress: Double = 0.75
        let minutesLeft: Int = 5
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    HStack {
                        Text("Good morning,")
                            .font(.system(size: 16, weight: .regular, design: .rounded))

                        Spacer()
                    }
                    HStack {
                        Text("Alex")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(AppColor.commonAccentBlue)
//                            .padding()
                        Spacer()
                        steakView
                    }
                    VStack(alignment: .leading, spacing: 20) {
                                // Верхняя строчка
                                HStack {
                                    Text("Daily Progress")
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundColor(Color(.darkGray))

                                    Spacer()

                                    Text("\(Int(progress * 100))%")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color(red: 0.15, green: 0.35, blue: 0.75))
                                }

                                // --- ТУТ ИСПОЛЬЗУЕТСЯ НАШ ОТДЕЛЬНЫЙ КОМПОНЕНТ ---
//                                AnimatedProgressBar(progress: progress)

                                // Нижняя строчка
                                HStack {
                                    Spacer()
                                    Text("Just \(minutesLeft) more minutes to hit your goal!")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Color(red: 0.25, green: 0.32, blue: 0.41))
                                    Spacer()
                                }
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(.systemGray6), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)

                }
                .padding(16)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("MathMastery")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                        .fixedSize()
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("Profile tapped")
                    } label: {
                        Image("img_profile_\(Int.random(in: 1...12))")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                    }
                }
            }

            .toolbarBackground(Color.white, for: .navigationBar)
        }
    }

    private var steakView: some View {
        Text("🔥12 days")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(AppColor.commonRedDark)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColor.commonPinkSoft)
            )

    }

}

#Preview {
    HomeView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
}



//struct AnimatedProgressBar: View {
//    let progress: Double
//
//    private let palettes: [[Color]] = [
//        [Color.red, Color.orange],
//        [Color.yellow, Color.orange],
//        [Color.blue, Color.purple],
//        [Color.green, Color.yellow],
//        [Color.pink, Color.red]
//    ]
//
//    @State private var index: Int = 0
//
//    private var gradient: LinearGradient {
//        LinearGradient(
//            colors: palettes[index],
//            startPoint: .leading,
//            endPoint: .trailing
//        )
//    }
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .leading) {
//
//                Capsule()
//                    .frame(width: geometry.size.width, height: 14)
//                    .foregroundColor(Color(.systemGray5))
//
//                Capsule()
//                    .fill(gradient)
//                    .frame(width: geometry.size.width * CGFloat(progress), height: 14)
//                    .animation(.easeInOut(duration: 2.5), value: index)
//            }
//        }
//        .frame(height: 14)
//        .onAppear {
//            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//                index = (index + 1) % palettes.count
//            }
//        }
//    }
//}
