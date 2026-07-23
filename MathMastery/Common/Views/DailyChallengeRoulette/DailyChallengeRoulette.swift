import SwiftUI

struct DailyChallengeRoulette: View {

    @Binding var isPresented: Bool
    let challenges: [DailyChallenge]

    private enum SpinState {
        case ready
        case spinning
        case completed
    }

    @State private var spinState: SpinState = .ready
    @State private var dotCount = 0
    @State private var timer: Timer? = nil

    @State private var offsets: [CGFloat] = []
    @State private var revealed: [Bool] = []

    let itemHeight: CGFloat = 70
    let spacing: CGFloat = 0
    let spinCount = 20

    private let dummyChallenges = [
        DailyChallenge(id: .questions, title: "Solve 20 Questions", icon: "ic_fire_daily", checkmark: "ic_check_red", current: 0, target: 20, mode: nil, metadata: nil),
        DailyChallenge(id: .accuracy, title: "Reach 100% Accuracy", icon: "ic_accuracy_daily", checkmark: "ic_check_green", current: 0, target: 90, mode: nil, metadata: "10+ questions"),
        DailyChallenge(id: .mode, title: "Complete Speed Mode", icon: "ic_heart_red", checkmark: "ic_check_yellow", current: 0, target: 1, mode: .speed, metadata: nil),
        DailyChallenge(id: .mastery, title: "Master ×8", icon: "ic_master_daily", checkmark: "ic_check_purple", current: 0, target: 100, mode: nil, metadata: nil),
        DailyChallenge(id: .survival, title: "Survive 3 Minutes", icon: "ic_pacman_daily", checkmark: "ic_check_orange", current: 0, target: 3, mode: .survival, metadata: "3 minutes"),
        DailyChallenge(id: .xp, title: "Earn 330 XP", icon: "ic_rocket_daily", checkmark: "ic_check_blue", current: 0, target: 330, mode: nil, metadata: nil),
        DailyChallenge(id: .streak, title: "20 Answer Streak", icon: "ic_rock_n_roll_daily", checkmark: "ic_check_green", current: 0, target: 20, mode: nil, metadata: nil),
        DailyChallenge(id: .noMistakes, title: "10 Perfect Answers", icon: "ic_done_folder_daily", checkmark: "ic_check_mint", current: 0, target: 10, mode: nil, metadata: nil),
        DailyChallenge(id: .modeMaster, title: "Complete All Modes", icon: "ic_task_daily", checkmark: "ic_check_indigo", current: 0, target: 4, mode: nil, metadata: "Speed, Focus, Rush, Survival")
    ]

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()
                    .onTapGesture {
                        close()
                    }

                VStack(spacing: 24) {

                    // Заголовок
                    VStack(spacing: 6) {
                        Text("Daily Challenges")
                            .font(.system(size: 24, weight: .bold, design: .rounded))

                        Text("Spin to reveal your tasks")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)

                    // Рулетка
                    VStack(spacing: 12) {
                        ForEach(Array(challenges.enumerated()), id: \.offset) { index, challenge in
                            slotContainer(challenge: challenge, index: index)
                                .frame(height: itemHeight)
                        }
                    }

                    // Кнопка SPIN
                    Button {
                        handleButtonTap()
                    } label: {
                        ZStack {
                            if spinState == .spinning {
                                HStack(spacing: 0) {
                                    Text("Spinning")

                                    HStack(spacing: 0) {
                                        if dotCount > 0 {
                                            Text(String(repeating: ".", count: dotCount))
                                                .foregroundColor(.white)
                                        }
                                        if 3 - dotCount > 0 {
                                            Text(String(repeating: ".", count: 3 - dotCount))
                                                .opacity(0)
                                        }
                                    }
                                }
                            } else {
                                Text(spinState == .ready ? "SPIN" : "Done")
                            }
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                    }
                    .buttonStyle(
                        DepthButtonStyle(
                            backgroundColor: spinState == .completed ? .green : AppColor.commonAccentBlue,
                            cornerRadius: 14,
                            depth: 5,
                            borderWidth: 1
                        )
                    )
                    .foregroundColor(.white)
                    .disabled(spinState == .spinning)
                }
                .padding(24)
                .frame(width: 360)
                .background {
                    RoundedRectangle(
                        cornerRadius: 24,
                        style: .continuous
                    )
                    .fill(Color(.systemBackground))
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .padding(16)
                    .disabled(spinState == .spinning)
                }
            }
            .hidesCustomTabBar()
            .transition(.opacity)
            .onAppear {
                setupInitialStates()
            }
            .onChange(of: challenges.count) {
                setupInitialStates()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }

    private func handleButtonTap() {
        switch spinState {
        case .ready:
            spin()
        case .completed:
            close()
        case .spinning:
            break
        }
    }

    private func slotContainer(challenge: DailyChallenge, index: Int) -> some View {
        let isRevealed = index < revealed.count && revealed[index]

        return ZStack {
            slot(challenge: challenge, index: index)
                .opacity(isRevealed ? 1 : 0)

            if !isRevealed {
                placeholderSlot
                    .transition(.opacity)
            }
        }
    }

    private var placeholderSlot: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemGray6).opacity(0.5))
            .overlay(
                Image(systemName: "questionmark")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(.systemGray3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(.systemGray4).opacity(0.6), lineWidth: 1)
            )
    }

    private func slot(challenge: DailyChallenge, index: Int) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: spacing) {
                ForEach(0..<spinCount, id: \.self) { itemIndex in
                    ChallengeRow(challenge: getDummyChallenge(for: itemIndex))
                        .frame(height: itemHeight)
                }

                ChallengeRow(challenge: challenge)
                    .frame(height: itemHeight)
            }
            .offset(y: index < offsets.count ? offsets[index] : 0)
            .padding(.horizontal, 4)
        }
        .frame(height: itemHeight, alignment: .top)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.systemGray4).opacity(0.6), lineWidth: 1)
        )
    }

    private func close() {
        guard spinState != .spinning else { return }
        stopTimer()
        isPresented = false
    }

    private func setupInitialStates() {
        stopTimer()
        spinState = .ready
        offsets = Array(repeating: 0, count: challenges.count)
        revealed = Array(repeating: false, count: challenges.count)
    }

    private func spin() {
        guard spinState == .ready, !challenges.isEmpty else { return }
        spinState = .spinning
        startTimer()

        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            offsets = Array(repeating: 0, count: challenges.count)
        }

        spinNext(index: 0)
    }

    private func spinNext(index: Int) {
        guard index < challenges.count else {
            stopTimer()
            spinState = .completed
            RouletteSoundManager.shared.playSuccess()
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            revealed[index] = true
        }

        let targetOffset = -CGFloat(spinCount) * (itemHeight + spacing)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            playSpinEffects()

            withAnimation(
                .timingCurve(0.1, 0.66, 0.66, 1, duration: 2.5)
            ) {
                if index < offsets.count {
                    offsets[index] = targetOffset
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            RouletteSoundManager.shared.playSlotStop()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if index + 1 < challenges.count {
                    spinNext(index: index + 1)
                } else {
                    stopTimer()
                    spinState = .completed
                    RouletteSoundManager.shared.playSuccess()
                }
            }
        }
    }

    /// Запуск 18 замедляющихся тиков (1104) во время прокрутки
    private func playSpinEffects() {
        let totalTicks = 18
        let duration: Double = 2.4 // Чуть меньше длительности анимации, чтобы последний звук был 1306

        for i in 0..<totalTicks {
            let progress = Double(i) / Double(totalTicks)
            let delay = pow(progress, 2.2) * duration

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if self.spinState == .spinning {
                    RouletteSoundManager.shared.playSpinTick()
                }
            }
        }
    }

    private func startTimer() {
        dotCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { _ in
            if dotCount >= 3 {
                dotCount = 0
            } else {
                dotCount += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func getDummyChallenge(for index: Int) -> DailyChallenge {
        dummyChallenges[index % dummyChallenges.count]
    }
}

import AudioToolbox
import UIKit

final class RouletteSoundManager {
    static let shared = RouletteSoundManager()

    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }

    func playSpinTick() {
        selectionFeedback.selectionChanged()
//        AudioServicesPlaySystemSound(1105)
    }

    func playSlotStop() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
//        AudioServicesPlaySystemSound(1105)
    }

    func playSuccess() {
        notificationFeedback.notificationOccurred(.success)

    }
}
