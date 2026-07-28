import Combine
import SwiftUI

extension RushPracticeView {

    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService
        private let swiftDB: SwiftDataService

        private let adaptiveQuestionEngine = AdaptiveQuestionEngine()
        private let factMasteryEngine = FactMasteryEngine()
        private let questionDifficultyEngine = QuestionDifficultyEngine()
        private let answerOptionEngine = AnswerOptionEngine()

        private let countdownTimer = CountdownTimer()

        private var sessionStartTime: Date?
        private var sessionEndTime: Date?

        private var questionStartTime = Date()
        private var allAnswers: [PracticeAnswer] = []
        private var responseTimes: [TimeInterval] = []

        private let timeLimit = 60
        private let correctTimeBonus = 1
        private let wrongTimePenalty = 2

        @Published var timeChangeText: String?
        @Published var timeChangeIsPositive = true

        @Published private(set) var secondsRemaining: Int
        @Published private(set) var correctCount = 0
        @Published private(set) var solvedCount = 0
        @Published private(set) var currentStreak = 0
        @Published private(set) var longestStreak = 0
        @Published private(set) var currentMistakesStreak = 0

        @Published private(set) var currentQuestion = PracticeQuestion(left: 2, right: 2)
        @Published private(set) var answerOptions: [AnswerOption] = []
        @Published private(set) var answers: [PracticeAnswer] = []

        @Published private(set) var selectedAnswer: Int?
        @Published private(set) var answerResult: AnswerResult?

        private var isPaused = false
        private var isCountingDown = false

        @Published private(set) var isFinished = false
        @Published private(set) var isAcceptingAnswers = false

        @Published private(set) var showGameOver = false

        private var subscriptions = Set<AnyCancellable>()

        private var timer: AnyCancellable?

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.accountService = serviceContainer.resolve(AccountService.self)

            self.secondsRemaining = timeLimit

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

        var maxTime: Int {
            timeLimit + 30
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

        private func showTimeChange(_ value: Int) {
            timeChangeIsPositive = value > 0
            timeChangeText = value > 0 ? "+\(value)" : "\(value)"

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.timeChangeText = nil
            }
        }

        var formattedTime: String {
            let minutes = secondsRemaining / 60
            let seconds = secondsRemaining % 60

            return "\(minutes):\(String(format: "%02d", seconds))"
        }

        private var sessionDuration: Int {
            guard let start = sessionStartTime else {
                return 0
            }

            let end = sessionEndTime ?? Date()

            return Int(end.timeIntervalSince(start))
        }

        private var averageResponseTimeValue: Double {
            guard !responseTimes.isEmpty else {
                return 0
            }

            return responseTimes.reduce(0,+) / Double(responseTimes.count)
        }

        private var fastestResponseTimeValue: Double {
            responseTimes.min() ?? 0
        }

        private var answersPerMinuteValue: Double {
            guard sessionDuration > 0 else {
                return 0
            }

            return Double(solvedCount) / Double(sessionDuration) * 60
        }

        var countdownValue: String? {
            countdownTimer.text
        }

        func start() {
            isCountingDown = true

            countdownTimer.start(from: 3) { [weak self] in
                guard let self else { return }

                DispatchQueue.main.async {
                    self.isCountingDown = false

                    guard !self.isPaused else { return }

                    self.sessionStartTime = Date()
                    self.questionStartTime = Date()
                    self.startTimer()
                }
            }
        }

        private func startTimer() {
            guard !isPaused else { return }
            guard timer == nil else { return }

            timer =
            Timer.publish(
                every: 1,
                on: .main,
                in: .common
            )
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }

            isAcceptingAnswers = true
        }

        func stopTimer() {
            countdownTimer.stop()

            timer?.cancel()
            timer = nil
        }

        func pause() {
            guard !isPaused else { return }

            isPaused = true
            isAcceptingAnswers = false

            timer?.cancel()
            timer = nil

            countdownTimer.stop()
        }

        func resume() {
            guard isPaused else { return }

            isPaused = false

            if isCountingDown {
                start()
            } else {
                startTimer()
            }
        }

        func restart() {
            stopTimer()

            sessionStartTime = nil
            sessionEndTime = nil
            responseTimes.removeAll()

            secondsRemaining = timeLimit

            correctCount = 0
            solvedCount = 0
            currentStreak = 0
            longestStreak = 0
            currentMistakesStreak = 0

            answers = []

            allAnswers = swiftDB.fetchSessions().flatMap(\.answers)

            isFinished = false
            isPaused = false
            isCountingDown = false

            selectedAnswer = nil
            answerResult = nil

            currentQuestion = generateQuestion()
            updateAnswerOptions()

            isAcceptingAnswers = false

            start()
        }

        func finish() {
            guard !isFinished else { return }

            sessionEndTime = Date()

            stopTimer()

            isAcceptingAnswers = false
            isFinished = true

            withAnimation(.spring()) {
                showGameOver = true
            }
        }

        private func tick() {
            guard !isFinished else {
                return
            }

            secondsRemaining -= 1

            if secondsRemaining <= 0 {
                secondsRemaining = 0
                finish()
            }
        }

        @MainActor
        func selectAnswer(_ answer: Int) {
            guard isAcceptingAnswers, !isFinished else { return }

            let responseTime = Date()
                .timeIntervalSince(questionStartTime)

            responseTimes.append(responseTime)

            isAcceptingAnswers = false

            selectedAnswer = answer

            let isCorrect = answer == currentQuestion.answer

            answerResult = isCorrect
                ? .correct
                : .wrong

            if let index = answerOptions.firstIndex(where: { $0.value == currentQuestion.answer }) {
                answerOptions[index].state = .correct
            }

            if !isCorrect,
               let index = answerOptions.firstIndex(where: { $0.value == answer }) {
                answerOptions[index].state = .wrong
            }

            let practiceAnswer = PracticeAnswer(
                left: currentQuestion.left,
                right: currentQuestion.right,
                correctAnswer: currentQuestion.answer,
                userAnswer: answer,
                mode: .rush,
                responseTime: Date().timeIntervalSince(questionStartTime)
            )

            answers.append(practiceAnswer)
            allAnswers.append(practiceAnswer)

            solvedCount += 1

            if isCorrect {

                correctCount += 1
                currentStreak += 1

                currentMistakesStreak = 0

                longestStreak = max(
                    longestStreak,
                    currentStreak
                )

                var bonus = correctTimeBonus

                if currentStreak >= 25 {
                    bonus += 4
                } else if currentStreak >= 15 {
                    bonus += 3
                } else if currentStreak >= 5 {
                    bonus += 1
                }

                let oldTime = secondsRemaining

                secondsRemaining = min(
                    secondsRemaining + bonus,
                    maxTime
                )

                let addedTime = secondsRemaining - oldTime

                if addedTime > 0 {
                    showTimeChange(addedTime)
                }

            } else {

                currentStreak = 0
                currentMistakesStreak += 1

                var penalty = wrongTimePenalty

                if currentMistakesStreak >= 4 {
                    penalty += 3
                } else if currentMistakesStreak >= 3 {
                    penalty += 2
                } else if currentMistakesStreak >= 2 {
                    penalty += 1
                }

                secondsRemaining -= penalty

                showTimeChange(-penalty)

                if secondsRemaining <= 0 {
                    secondsRemaining = 0
                    finish()
                    return
                }
            }


            Task {
                try? await Task.sleep(for: .milliseconds(400))

                guard !isFinished else { return }

                selectedAnswer = nil
                answerResult = nil

                isAcceptingAnswers = true

                currentQuestion = generateQuestion()
                updateAnswerOptions()
                questionStartTime = Date()
            }
        }

        private func generateQuestion() -> PracticeQuestion {
            adaptiveQuestionEngine.nextPracticeQuestion(
                from: allAnswers + answers
            )
        }

        private func updateAnswerOptions() {
            let mastery = factMasteryEngine.mastery(
                for: currentQuestion,
                answers: allAnswers  + answers
            )

            let difficulty = questionDifficultyEngine.difficulty(
                for: mastery
            )

            answerOptions = answerOptionEngine.generate(
                for: currentQuestion,
                difficulty: difficulty
            )
        }

        func makeResult() -> PracticeSession {
            let session = PracticeSession(
                mode: .rush,
                duration: sessionDuration,
                difficulty: nil,
                correctAnswers: correctCount,
                questionsCount: solvedCount,
                longestStreak: longestStreak,
                averageResponseTime: averageResponseTimeValue,
                fastestResponseTime: fastestResponseTimeValue,
                answersPerMinute: answersPerMinuteValue,
                answers: answers
            )

            let xp = XPSystem.xp(for: session)
            accountService.addXP(xp)

            swiftDB.saveSession(session)
            
            return session
        }

        func backgroundColor(for option: AnswerOption) -> Color {
            switch option.state {
            case .normal:
                return .white
            case .correct:
                return .green
            case .wrong:
                return .red
            }
        }
    }
}
