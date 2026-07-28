import SwiftUI

struct PracticeResultView: View {
    @StateObject var viewModel: ViewModel

    @State private var animatedAccuracy: CGFloat = 0

    let retryAction: (() -> Void)?
    let switchModeAction: (() -> Void)?
    let closeAction: (() -> Void)?

    init(
        viewModel: ViewModel,
        retryAction: (() -> Void)? = nil,
        switchModeAction: (() -> Void)? = nil,
        closeAction: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.retryAction = retryAction
        self.switchModeAction = switchModeAction
        self.closeAction = closeAction
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                hero
                metricsGrid
                mistakesSection
                actions
            }
            .padding(.horizontal, 22)
            .padding(.top, 26)
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
    }

    private var hero: some View {
        VStack(spacing: 20) {
            ProgressRing(
                progress: CGFloat(viewModel.session.accuracy) / 100,
                color: viewModel.session.mode.accentColor,
                lineWidth: 8
            ) {
                LottieView(name: viewModel.session.mode.lottieImage, loop: true)
                    .frame(width: 42, height: 42)
//                Image(viewModel.session.mode.icImageSized)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 42, height: 42)
            }
            .frame(width: 92, height: 92)
            .overlay(alignment: .bottomTrailing) {
                ZStack {
                    // Нижняя грань (depth)
                    Text("\(viewModel.session.accuracy)%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(viewModel.session.mode.accentColor.darker(by: 0.3))
                        .clipShape(Capsule())
                        .offset(x: -1, y: 1.5)

                    // Верхняя поверхность
                    Text("\(viewModel.session.accuracy)%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(viewModel.session.mode.accentColor)
                        .clipShape(Capsule())
                }
                .offset(x: 7, y: -5)
                .opacity(animatedAccuracy > 0 ? 1 : 0)
                .animation(.easeIn(duration: 0.2).delay(0.5), value: animatedAccuracy)
            }
            VStack(spacing: 8) {
                Text(viewModel.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                Text(viewModel.summary)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(Color.primary.opacity(0.68))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.top, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 5)
        }
        .overlay(alignment: .topTrailing) {
            if viewModel.isPersonalBest {
                ShimmerTrophy(size: 40)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
            }
        }
        .overlay(alignment: .topLeading) {
            if let closeAction {
                Button(action: closeAction) {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle().fill(Color.white)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
                .padding(.leading, 10)
            }
        }
        .onAppear {
            withAnimation(.interactiveSpring(response: 1.0, dampingFraction: 0.75, blendDuration: 0.5)) {
                animatedAccuracy = CGFloat(viewModel.session.accuracy) / 100.0
            }
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(viewModel.metrics) { metric in
                VStack(spacing: 8) {
                    Text(metric.value)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                    Text(metric.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .tracking(1.1)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                }
            }
        }
    }

    @ViewBuilder
    private var mistakesSection: some View {
        if !viewModel.mistakes.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text(viewModel.mistakeTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                ForEach(viewModel.mistakes) { mistake in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(mistake.question)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        HStack(spacing: 6) {
                            Text("Your:")
                                .foregroundColor(.secondary)
                            Text("\(mistake.userAnswer)")
                                .foregroundColor(.red)
                            Spacer()
                            Text("Correct:")
                                .foregroundColor(.secondary)
                            Text("\(mistake.correctAnswer)")
                                .foregroundColor(.green)
                        }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var actions: some View {
        VStack(spacing: 12) {

            if let retryAction {
                Button(action: retryAction) {
                    Text("Retry \(viewModel.session.mode.title)")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColor.commonAccentBlue)
                        }
                }
                .buttonStyle(.plain)
            }

            if let switchModeAction {
                Button(action: switchModeAction) {
                    Text("Switch Mode")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        }
                }
                .buttonStyle(.plain)
            }

        }
    }
}
