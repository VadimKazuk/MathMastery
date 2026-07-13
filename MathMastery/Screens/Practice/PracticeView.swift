import SwiftUI
import Combine

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
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Text("MathMastery")
//                        .font(.system(size: 28, weight: .bold, design: .rounded))
//                        .foregroundColor(AppColor.commonAccentBlue)
//                        .fixedSize()
//                }
//                .sharedBackgroundVisibility(.hidden)
//
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        print("Profile tapped")
//                    } label: {
//                        Image(viewModel.avatarName)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 35, height: 35)
//                            .clipShape(Circle())
//                    }
//                }
//            }
//            .toolbarBackground(Color.white, for: .navigationBar)
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
        VStack(alignment: .leading, spacing: 24) {
//            statsHeaderRow

//            Text("Modes")
//                .font(.system(size: 16, weight: .bold, design: .rounded))
//                .padding(.top, 8)

            modesList
        }
    }

    var statsHeaderRow: some View {
        HStack(spacing: 12) {
            StatCard(title: "STREAK", value: "5 Days", icon: "flame.fill", iconColor: .orange)
            StatCard(title: "SOLVED", value: "42", icon: "checkmark.circle.fill", iconColor: .green)
            StatCard(title: "BEST SPEED", value: "18", icon: "bolt.fill", iconColor: .blue)
        }
    }

    func statHeaderCard(title: String, value: String, icon: String, iconColor: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)

            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    var modesList: some View {
        VStack(spacing: 16) {
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
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(AppColor.commonAccentBlue)
                .cornerRadius(16)
        }
    }

    func practiceModeCard(_ mode: PracticeMode) -> some View {
        let isSelected = viewModel.selectedMode == mode

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                viewModel.selectMode(mode)
            }
        } label: {
            HStack(alignment: .top, spacing: 16) {
//                AnimatedPracticeIcon(mode: mode)
////                    .foregroundColor(mode.accentColor)
//                    .background {
//                        Circle()
//                            .fill(mode.backgroundColor)
//                    }
//                LottieView(name: mode.lottieImage, loop: true)
//                    .frame(width: 56, height: 56)

                Image(systemName: mode.systemImage)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(mode.accentColor)
                    .frame(width: 56, height: 56)
                    .background {
                        Circle()
                            .fill(mode.backgroundColor)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        Text(mode.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Spacer()

                        Text(mode.timeTag) // Чисто из модели
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                    }

                    Text(mode.subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.trailing, 8)

                    HStack(spacing: 4) {
                        Image(systemName: mode.skillIcon) // Чисто из модели
                            .font(.system(size: 11, weight: .bold))
                        Text("Skill: \(mode.trainingFocus)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(mode.accentColor)
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? AppColor.commonAccentBlue : Color.clear, lineWidth: 3)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    func destinationView(for route: PracticeRoute) -> some View {
        switch route {

        case .focusTableSelection:
            FocusTableSelectionView(
                serviceContainer: serviceContainer
            ) { target in
                switch target {

                case .all:
                    viewModel.path.append(.focusPractice(table: nil))

                case .table(let table):
                    viewModel.path.append(.focusPractice(table: table))
                }
            }
            .toolbar(.hidden, for: .tabBar)


        case .focusPractice(let table):
            FocusPracticeView(
                viewModel: .init(
                    serviceContainer: serviceContainer,
                    mode: table == nil ? .all : .table(table!),
                    focusTable: table
                ),
                onComplete: { viewModel.showResult($0) }
            )
            .toolbar(.hidden, for: .tabBar)


        case .speed:
            SpeedPracticeView(
                viewModel: .init(serviceContainer: serviceContainer),
                onComplete: { viewModel.showResult($0) }
            )
            .toolbar(.hidden, for: .tabBar)


        case .survival:
            SurvivalPracticeView(
                viewModel: .init(serviceContainer: serviceContainer),
                onComplete: { viewModel.showResult($0) }
            )
            .toolbar(.hidden, for: .tabBar)


        case .rush:
            RushPracticeView(
                viewModel: .init(serviceContainer: serviceContainer),
                onComplete: { viewModel.showResult($0) }
            )
            .toolbar(.hidden, for: .tabBar)


        case .result(let session):
            PracticeResultView(
                viewModel: .init(
                    serviceContainer: serviceContainer,
                    session: session,
                    isPersonalBest: viewModel.isBest(session)
                ),
                retryAction: {

                    if session.mode == .focus {
                        viewModel.path = [
                            .focusTableSelection
                        ]
                    } else {
                        viewModel.retry(session.mode)
                    }

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

struct AnimatedPracticeIcon: View {
    let mode: PracticeMode

    @State private var animate = false

    // Speed
    @State private var speedFlash = false
    @State private var speedCounter = 0
    @State private var speedPause = false

    private let speedTimer = Timer.publish(
        every: 0.1,
        on: .main,
        in: .common
    ).autoconnect()


    var body: some View {
        Image(systemName: mode.systemImage)
            .font(.system(size: 24, weight: .regular))
            .frame(width: 56, height: 56)

            // Focus
            .symbolEffect(
                .breathe.pulse.byLayer,
                options: .repeat(.continuous),
                isActive: mode == .focus
            )

            // Speed
            .foregroundStyle(
                mode == .speed ? speedColor : mode.accentColor
            )
//            .symbolEffect(
//                .breathe.pulse.wholeSymbol,
//                options: .repeat(.continuous),
//                isActive: mode == .speed
//            )

            .symbolEffect(.wiggle.down.byLayer, options: .repeat(.periodic(delay: 1.8)), isActive: mode == .speed)

            // Rush
            .scaleEffect(x: rushScaleX, y: rushScaleY)
            .rotationEffect(.degrees(rushRotation))
            .offset(y: rushOffset)

            // Survival
            .symbolEffect(
                .bounce.up.byLayer,
                options: .repeat(.periodic(delay: 1.0)),
                isActive: mode == .survival
            )

            .animation(animation, value: animate)

            .onAppear {
                animate = true
            }

            .onReceive(speedTimer) { _ in
                guard mode == .speed else { return }

                if speedPause {
                    speedCounter += 1

                    // пауза ~2 секунды
                    if speedCounter >= 20 {
                        speedCounter = 0
                        speedPause = false
                    }

                    return
                }

                // быстрое мигание
                speedFlash.toggle()

                speedCounter += 1

                // серия 3-6 вспышек
                if speedCounter >= Int.random(in: 6...12) {
                    speedCounter = 0
                    speedPause = true
                    speedFlash = false
                }
            }
    }
}


// MARK: - Private

private extension AnimatedPracticeIcon {

    var animation: Animation {
        switch mode {

        case .focus:
            return .default

        case .speed:
            return .easeInOut(duration: 0.12)

        case .survival:
            return .default

        case .rush:
            return .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        }
    }


    // MARK: Speed

    var speedColor: Color {
        speedFlash ? Color(red: 1.0, green: 0.85, blue: 0.35) : mode.accentColor
    }


    // MARK: Rush

    var rushScaleX: CGFloat {
        mode == .rush
            ? (animate ? 0.96 : 1.03)
            : 1
    }

    var rushScaleY: CGFloat {
        mode == .rush
            ? (animate ? 1.05 : 0.95)
            : 1
    }

    var rushRotation: Double {
        mode == .rush
            ? (animate ? 2 : -2)
            : 0
    }

    var rushOffset: CGFloat {
        mode == .rush
            ? (animate ? -0.8 : 0.8)
            : 0
    }
}
