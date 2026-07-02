import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                contentView
                    .padding(.horizontal, 24)
                    .padding(.top, 22)
                    .padding(.bottom, 24)
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
                        Image(viewModel.avatarName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(Color.white, for: .navigationBar)
            .navigationDestination(for: PracticeRoute.self) { route in
                destinationView(for: route)
            }
            .safeAreaInset(edge: .bottom) {
                if viewModel.selectedMode != nil {
                    startButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

// MARK: - Content

private extension PracticeView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: 28) {
            //            statsSection
            titleSection
            modesGrid
        }
    }

    var statsSection: some View {
        HStack(spacing: 16) {
            statCard(
                title: "CURRENT STREAK",
                value: "\(viewModel.currentStreak) Days",
                systemImage: "flame",
                accentColor: Color(red: 0.10, green: 0.46, blue: 0.22),
                iconBackground: Color(red: 0.36, green: 0.95, blue: 0.45),
                backgroundColor: Color(red: 0.91, green: 0.98, blue: 0.94)
            )

            statCard(
                title: "BEST SCORE",
                value: "\(viewModel.bestScore.formatted()) pts",
                systemImage: "trophy",
                accentColor: .white,
                iconBackground: AppColor.commonAccentBlue,
                backgroundColor: Color(red: 0.88, green: 0.93, blue: 1.0)
            )
        }
    }

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Practice")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary)

            Text("Choose your training grounds and sharpen your mind.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color.primary.opacity(0.72))
                .lineSpacing(6)
        }
    }

    var modesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ],
            spacing: 20
        ) {
            ForEach(viewModel.modes) { mode in
                practiceModeCard(mode)
            }
        }
    }

    var startButton: some View {
        Button {
            viewModel.startSelectedMode()
        } label: {
            Text("Start Practice")
                .font(.system(size: 23, weight: .regular, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 45)
        }
        .buttonStyle(.glassProminent)
        .tint(AppColor.commonAccentBlue)
    }

    func statCard(
        title: String,
        value: String,
        systemImage: String,
        accentColor: Color,
        iconBackground: Color,
        backgroundColor: Color
    ) -> some View {
        VStack(spacing: 22) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(accentColor)
                .frame(width: 76, height: 76)
                .background {
                    Circle()
                        .fill(iconBackground)
                }

            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(Color.primary.opacity(0.72))
                    .multilineTextAlignment(.center)

                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(Color.primary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 254)
        .background {
            RoundedRectangle(cornerRadius: 28)
                .fill(backgroundColor)
        }
    }

    func practiceModeCard(_ mode: PracticeMode) -> some View {
        let isSelected = viewModel.selectedMode == mode

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                viewModel.selectMode(mode)
            }
        } label: {
            VStack(spacing: 26) {
                ZStack(alignment: .topTrailing) {
                    //                    LottieView(name: mode.lottieImage, loop: true)
                    //                        .frame(width: 40, height: 40)
                    //                        .padding(25)
                    //                        .background {
                    //                            Circle()
                    //                                .fill(mode.backgroundColor)
                    //                        }
                    //                        .frame(maxWidth: .infinity)
                    Image(systemName: mode.systemImage)
                        .font(.system(size: 39, weight: .regular))
                        .foregroundColor(mode.accentColor)
                        .frame(width: 74, height: 74)
                        .background {
                            Circle()
                                .fill(mode.backgroundColor)
                        }
                        .frame(maxWidth: .infinity)
                }

                VStack(spacing: 14) {
                    Text(mode.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(mode.trainingFocus.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(mode.accentColor)

                    Text(mode.subtitle)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(Color.primary.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 36)
            .padding(.bottom, 30)
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .background {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 5)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(isSelected ? AppColor.commonAccentBlue : Color.clear, lineWidth: 3)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func destinationView(for route: PracticeRoute) -> some View {
        switch route {
        case .speed:
            SpeedPracticeView(
                viewModel: .init(serviceContainer: serviceContainer),
                onComplete: { result in
                    viewModel.showResult(result)
                }
            )
            .toolbar(.hidden, for: .tabBar)
        case .classic:
            ClassicPracticeView(
                viewModel: .init(serviceContainer: serviceContainer),
                onComplete: { result in
                    viewModel.showResult(result)
                }
            )
            .toolbar(.hidden, for: .tabBar)
        case .survival:
            SurvivalPracticeView(
                viewModel: .init(serviceContainer: serviceContainer),
                onComplete: { result in
                    viewModel.showResult(result)
                }
            )
            .toolbar(.hidden, for: .tabBar)
        case .boss:
            BossPracticeView(
                viewModel: .init(),
                onComplete: { result in
                    viewModel.showResult(result)
                }
            )
            .toolbar(.hidden, for: .tabBar)
        case .result(let session):
            PracticeResultView(
                viewModel: .init(serviceContainer: serviceContainer, session: session),
                retryAction: {
                    viewModel.retry(session.mode)
                },
                switchModeAction: {
                    viewModel.returnToHub()
                },
                hubAction: {
                    viewModel.returnToHub()
                }
            )
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    PracticeView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
}
