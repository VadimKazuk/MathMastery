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
            .navigationDestination(for: PracticeRoute.self) { route in
                destinationView(for: route)
            }
        }
    }
}

// MARK: - Content

private extension PracticeView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: 24) {
            modesList
        }
        .background(ScrollViewConfigurator())
    }

    var modesList: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.modes) { mode in
                practiceModeCard(mode)
            }
        }
    }

    func practiceModeCard(_ mode: PracticeMode) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(mode.title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        }
                        Text(mode.subtitle)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: 4) {
                    Image(mode.icImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)

                    Text("Skill: \(mode.trainingFocus)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .foregroundColor(mode.accentColor)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(mode.timeTag)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)

                Spacer()
                Button(action: {
                    viewModel.selectMode(mode)
                    viewModel.startSelectedMode()
                }) {
                    HStack {
                        Image("ic_play")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    .frame(width: 60, height: 42)
                }
                .buttonStyle(DeptButtonStyle())
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(
            color: Color.black.opacity(0.02),
            radius: 10,
            x: 0,
            y: 5
        )
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
            .hidesCustomTabBar()

        case .focusPractice(let table):
            FocusPracticeView(
                viewModel: .init(
                    serviceContainer: serviceContainer,
                    mode: table == nil ? .all : .table(table!),
                    focusTable: table
                ),
                onComplete: { viewModel.showResult($0) }
            )
            .hidesCustomTabBar()

        case .speed:
            SpeedPracticeView(
                viewModel: .init(serviceContainer: serviceContainer),
                onComplete: { viewModel.showResult($0) }
            )
            .hidesCustomTabBar()

        case .survival:
            SurvivalPracticeView(
                viewModel: .init(serviceContainer: serviceContainer),
                onComplete: { viewModel.showResult($0) }
            )
            .hidesCustomTabBar()

        case .rush:
            RushPracticeView(
                viewModel: .init(serviceContainer: serviceContainer),
                onComplete: { viewModel.showResult($0) }
            )
            .hidesCustomTabBar()

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
            .hidesCustomTabBar()
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
