import Combine
import SwiftUI
import SwiftData

extension SpeedPracticeView {
    final class ViewModel: ObservableObject {

        private let serviceContainer: ServiceContainer
        private let accountService: AccountService

        private let adaptiveQuestionEngine = AdaptiveQuestionEngine()
        private let questionDifficultyEngine = QuestionDifficultyEngine()
        private let factMasteryEngine = FactMasteryEngine()
        private let answerOptionEngine = AnswerOptionEngine()

        private let countdownTimer = CountdownTimer()

        @Published private(set) var secondsRemaining = timeLimit
        @Published private(set) var solvedCount = 0
        @Published private(set) var correctCount = 0
        @Published private(set) var bestStreak = 0
        @Published private(set) var currentStreak = 0
        @Published private(set) var questionIndex = 0

        @Published private(set) var currentQuestion = PracticeQuestion(left: 2, right: 2)
        @Published private(set) var answerOptions: [AnswerOption] = []

        @Published private(set) var isFinished = false
        @Published private(set) var isAcceptingAnswers = false

        @Published private(set) var didComplete = false
        @Published private(set) var showGameOver = false

        @Published private(set) var selectedAnswer: Int?
        @Published private(set) var answerResult: AnswerResult?

        @Published private(set) var answers: [PracticeAnswer] = []

        private var allAnswers: [PracticeAnswer] = []

        private var wasCountdown = false
        private var isPaused = false
        private static let timeLimit = 17

        private var questionStartTime = Date()
        private var averageResponseTime: Double = 0.0
        private var sessionStartTime: Date?
        private var sessionEndTime: Date?

        private var timerCancellable: AnyCancellable?

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

            allAnswers = swiftDB.fetchSessions().flatMap(\.answers)

            currentQuestion = generateQuestion()
            updateAnswerOptions()
        }

        var questionExpression: String {
            "\(currentQuestion.left) × \(currentQuestion.right) = "
        }

        var selectedAnswerText: String {
            selectedAnswer.map(String.init) ?? "?"
        }

        var questionText: String {
            guard let selectedAnswer else {
                return "\(currentQuestion.left) × \(currentQuestion.right) = ?"
            }

            return "\(currentQuestion.left) × \(currentQuestion.right) = \(selectedAnswer)"
        }

        var formattedTime: String {
            let minutes = secondsRemaining / 60
            let seconds = secondsRemaining % 60

            return "\(minutes):\(String(format: "%02d", seconds))"
        }

        var answerTextColor: Color {
            switch answerResult {
            case .correct:
                return .green

            case .wrong:
                return .red

            case .none:
                return AppColor.commonAccentBlue
            }
        }

        private var sessionDuration: Int {
            guard
                let start = sessionStartTime,
                let end = sessionEndTime
            else {
                return 0
            }

            return Int(end.timeIntervalSince(start))
        }

        var fastestResponseTimeValue: Double {
            answers.map(\.responseTime).min() ?? 0
        }

        var answersPerMinuteValue: Double {

            guard
                let start = sessionStartTime,
                let end = sessionEndTime
            else {
                return 0
            }

            let duration = end.timeIntervalSince(start)

            guard duration > 0 else {
                return 0
            }

            return Double(solvedCount) / duration * 60
        }

        var countdownValue: String? {
            countdownTimer.text
        }

        var timerColor: Color {
            secondsRemaining <= 15
                ? .red
                : AppColor.commonAccentBlue
        }

        var progress: Double {
            Double(secondsRemaining) / Double(Self.timeLimit)
        }

        var averageResponseTimeValue: Double {
            guard !answers.isEmpty else {
                return 0
            }

            return answers.reduce(0) {
                $0 + $1.responseTime
            } / Double(answers.count)
        }

        var averageResponseTimeText: String {
            String(format: "%.1fs", averageResponseTimeValue)
        }

        var badgeBackgroundColor: Color {
            .white
        }

        func finish() {
            guard !didComplete else { return }

            didComplete = true

            sessionEndTime = Date()

            countdownTimer.stop()

            isAcceptingAnswers = false
            isFinished = true

            withAnimation(.spring()) {
                showGameOver = true
            }

            stopTimer()
        }

        private func resetSession() {
            stopTimer()

            isPaused = false

            sessionStartTime = nil
            sessionEndTime = nil

            didComplete = false
            secondsRemaining = Self.timeLimit
            solvedCount = 0
            correctCount = 0
            bestStreak = 0
            currentStreak = 0
            questionIndex = 0
            isFinished = false
            isAcceptingAnswers = false

            answers = []

            currentQuestion = generateQuestion()
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
            didComplete = false
            isFinished = false
            isPaused = false

            resetSession()
            beginCountdown()
        }


        private func startTimer() {
            guard !isPaused else { return }
            guard timerCancellable == nil, !isFinished else { return }

            if sessionStartTime == nil {
                sessionStartTime = Date()
            }

            questionStartTime = Date()

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

            countdownTimer.start(from: 3) { [weak self] in
                guard let self else { return }

                DispatchQueue.main.async {
                    guard !self.isPaused else { return }
                    self.startTimer()
                }
            }
        }

        @MainActor
        func selectAnswer(_ answer: Int) {
            guard isAcceptingAnswers, !isFinished else { return }

            isAcceptingAnswers = false

            selectedAnswer = answer

            let isCorrect = answer == currentQuestion.answer

            answerResult = isCorrect
                ? .correct
                : .wrong

            answers.append(
                PracticeAnswer(
                    left: currentQuestion.left,
                    right: currentQuestion.right,
                    correctAnswer: currentQuestion.answer,
                    userAnswer: answer,
                    mode: .speed,
                    responseTime: Date().timeIntervalSince(questionStartTime)
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
                try? await Task.sleep(for: .milliseconds(500))
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

            selectedAnswer = nil
            answerResult = nil

            currentQuestion = generateQuestion()
            questionStartTime = Date()

            updateAnswerOptions()
            isAcceptingAnswers = true
        }

        private func generateQuestion() -> PracticeQuestion {
            adaptiveQuestionEngine.nextPracticeQuestion(
                from: allAnswers + answers
            )
        }

        func backgroundColor(for option: AnswerOption) -> Color {
            switch option.state {
            case .normal: return .white
            case .correct: return .green
            case .wrong: return .red
            }
        }

        private func tick() {
            guard !isFinished else { return }

            secondsRemaining = max(secondsRemaining - 1, 0)

            if secondsRemaining == 0 {
                finish()
            }
        }

        private func updateAnswerOptions() {

            let mastery = factMasteryEngine.mastery(
                for: currentQuestion,
                answers: allAnswers
            )

            let difficulty = questionDifficultyEngine.difficulty(
                for: mastery
            )

            answerOptions = answerOptionEngine.generate(
                for: currentQuestion,
                difficulty: difficulty
            )
        }

        func saveSession() -> PracticeSession {
            let session = PracticeSession(
                mode: .speed,
                duration: sessionDuration,
                correctAnswers: correctCount,
                questionsCount: solvedCount,
                longestStreak: bestStreak,
                averageResponseTime: averageResponseTimeValue,
                fastestResponseTime: fastestResponseTimeValue,
                answersPerMinute: answersPerMinuteValue
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
