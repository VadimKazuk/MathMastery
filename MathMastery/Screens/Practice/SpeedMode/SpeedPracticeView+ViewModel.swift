import Combine
import SwiftUI
import SwiftData

extension SpeedPracticeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService

        private let countdownTimer = CountdownTimer()

        @Published private(set) var secondsRemaining = sessionDuration
        @Published private(set) var solvedCount = 0
        @Published private(set) var correctCount = 0
        @Published private(set) var bestStreak = 0
        @Published private(set) var currentStreak = 0
        @Published private(set) var questionIndex = 0

        @Published private(set) var currentQuestion = PracticeQuestion(left: 2, right: 2)
        @Published private(set) var answerOptions: [AnswerOption] = []

        @Published private(set) var isFinished = false
        @Published private(set) var isAcceptingAnswers = false
        @Published private(set) var blinkToggle = false
        @Published private(set) var didComplete = false
        @Published private(set) var shouldShowResult = false

        @Published private(set) var answers: [PracticeAnswer] = []

        private var wasCountdown = false
        private var isPaused = false
        private static let sessionDuration = 17

        private var questionStartTime = Date()
        private var responseTimes: [TimeInterval] = []
        private var averageResponseTime: Double = 0.0

        private var timerCancellable: AnyCancellable?
        private var blinkCancellable: AnyCancellable?

        private var subscriptions = Set<AnyCancellable>()

        private let swiftDB: SwiftDataService

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.accountService = serviceContainer.resolve(AccountService.self)

            countdownTimer.$text
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &subscriptions)

            currentQuestion = makeSmartQuestion()
            updateAnswerOptions()
        }

        var countdownValue: String? {
            countdownTimer.text
        }

        var isWarningPhase: Bool {
            secondsRemaining <= 10
        }

        var timerColor: Color {
            secondsRemaining <= 15
                ? .red
                : AppColor.commonAccentBlue
        }

        var timerForegroundColor: Color {
            isWarningPhase ? .white : timerColor
        }

        var progress: Double {
            Double(secondsRemaining) / Double(Self.sessionDuration)
        }

        var averageResponseTimeValue: Double {
            guard !responseTimes.isEmpty else { return 0 }
            return responseTimes.reduce(0, +) / Double(responseTimes.count)
        }

        var averageResponseTimeText: String {
            String(format: "%.1fs", averageResponseTimeValue)
        }

        var badgeBackgroundColor: Color {
            guard isWarningPhase else { return .white }

            return blinkToggle
                ? .red
                : .red.opacity(0.4)
        }

        func finish(showResult: Bool = false) {
            guard !didComplete else { return }

            didComplete = true

            countdownTimer.stop()

            isAcceptingAnswers = false
            isFinished = true

            if showResult {
                shouldShowResult = true
            }

            stopTimer()
        }

        private func resetSession() {
            stopTimer()

            didComplete = false
            secondsRemaining = Self.sessionDuration
            solvedCount = 0
            correctCount = 0
            bestStreak = 0
            currentStreak = 0
            questionIndex = 0
            isFinished = false
            isAcceptingAnswers = false

            answers = []

            currentQuestion = makeSmartQuestion()
            updateAnswerOptions()
        }

        func pause() {
            guard !isPaused else { return }

            isPaused = true
            isAcceptingAnswers = false

            wasCountdown = countdownTimer.text != nil

            timerCancellable?.cancel()
            timerCancellable = nil

            countdownTimer.stop()
        }

        func resume() {
            guard isPaused else { return }

            isPaused = false

            if wasCountdown {
                beginCountdown()
            } else {
                startTimer()
            }
        }

        func restart() {
            shouldShowResult = false
            didComplete = false
            isFinished = false

            resetSession()
            beginCountdown()
        }

        private func startBlinking() {
            guard blinkCancellable == nil else { return }

            blinkCancellable = Timer
                .publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self else { return }
                    self.blinkToggle.toggle()
                }
        }

        private func stopBlinking() {
            blinkCancellable?.cancel()
            blinkCancellable = nil
        }

        private func startTimer() {
            guard timerCancellable == nil, !isFinished else { return }

            isAcceptingAnswers = true

            timerCancellable = Timer
                .publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.tick()
                }
        }

        func stopTimer() {
            countdownTimer.stop()

            timerCancellable?.cancel()
            timerCancellable = nil
        }

        func beginCountdown() {
            if isFinished {
                didComplete = false
                resetSession()
            }

            guard !isAcceptingAnswers else { return }

            countdownTimer.start(from: 3) {
                self.startTimer()
            }
        }

        @MainActor
        func selectAnswer(_ answer: Int) {
            guard isAcceptingAnswers, !isFinished else { return }

            let time = Date().timeIntervalSince(questionStartTime)
            responseTimes.append(time)

            isAcceptingAnswers = false

            let isCorrect = answer == currentQuestion.answer

            answers.append(
                PracticeAnswer(
                    left: currentQuestion.left,
                    right: currentQuestion.right,
                    correctAnswer: currentQuestion.answer,
                    userAnswer: answer,
                    mode: .speed
                )
            )

            if let index = answerOptions.firstIndex(where: { $0.value == currentQuestion.answer }) {
                answerOptions[index].state = .correct
            }

            if !isCorrect,
               let index = answerOptions.firstIndex(where: { $0.value == answer }) {
                answerOptions[index].state = .wrong
            }

            Task {
                try? await Task.sleep(for: .milliseconds(400))
                advance(answer)
            }
        }

        private func advance(_ answer: Int) {
            solvedCount += 1

            if answer == currentQuestion.answer {
                correctCount += 1
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 0
            }

            questionIndex += 1

            currentQuestion = makeSmartQuestion()
            questionStartTime = Date()

            updateAnswerOptions()
            isAcceptingAnswers = true
        }

        // MARK: - Smart Question Generator Integration

        private func makeSmartQuestion() -> PracticeQuestion {
            // 1. Извлекаем историю ответов
            let allAnswers = swiftDB.fetchSessions().flatMap { $0.answers }

            // 2. Делегируем логику единому генератору
            let selectedCell = SmartQuestionGenerator.generateSingleCell(allAnswers: allAnswers)

            // 3. Рандомизируем отображение (зеркальное переворачивание)
            let shouldSwap = Bool.random()
            return PracticeQuestion(
                left: shouldSwap ? selectedCell.right : selectedCell.left,
                right: shouldSwap ? selectedCell.left : selectedCell.right
            )
        }

        func backgroundColor(for option: AnswerOption) -> Color {
            switch option.state {
            case .normal:
                return .white
            case .correct:
                return .green.opacity(0.25)
            case .wrong:
                return .red.opacity(0.25)
            }
        }

        private func tick() {
            guard !isFinished else { return }

            secondsRemaining = max(secondsRemaining - 1, 0)

            if secondsRemaining <= 10 {
                if blinkCancellable == nil {
                    blinkToggle = false
                    startBlinking()
                }
            }

            if secondsRemaining > 10 {
                stopBlinking()
            }

            if secondsRemaining == 0 {
                finish(showResult: true)
            }
        }

        private func updateAnswerOptions() {
            let answer = currentQuestion.answer

            var distractors: Set<Int> = []

            func add(_ value: Int) {
                guard value > 0, value != answer else { return }
                distractors.insert(value)
            }

            let left = currentQuestion.left
            let right = currentQuestion.right

            for offset in 1...3 {
                add(answer + offset)
                add(answer - offset)
            }

            add((left + 1) * right)
            add((left - 1) * right)
            add(left * (right + 1))
            add(left * (right - 1))

            add(answer + left)
            add(answer - left)
            add(answer + right)
            add(answer - right)

            while distractors.count < 3 {
                let offset = Int.random(in: 1...10)
                let sign = Bool.random() ? 1 : -1
                add(answer + offset * sign)
            }

            var finalOptions = Array(distractors.prefix(3))
            finalOptions.append(answer)

            answerOptions = finalOptions.shuffled()
                .map { AnswerOption(value: $0) }
        }

        func saveSession() -> PracticeSession {
            let session = PracticeSession(
                mode: .speed,
                duration: Self.sessionDuration,
                correctAnswers: correctCount,
                questionsCount: solvedCount,
                longestStreak: bestStreak,
                averageResponseTime: averageResponseTimeValue
            )

            answers.forEach {
                $0.session = session
            }

            session.answers = answers

            let xp = XPSystem.xp(for: session)
            accountService.addXP(xp)
            
            swiftDB.saveSession(session)

            return session
        }

        func makeResult() -> PracticeSession {
            let session = saveSession()

            return session
        }
    }
}
