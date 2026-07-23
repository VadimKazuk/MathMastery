import Combine
import SwiftUI

extension RushPracticeView {

    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService
        private let swiftDB: SwiftDataService

        private let countdownTimer = CountdownTimer()

        private var sessionStartTime: Date?
        private var sessionEndTime: Date?

        private var questionStartTime = Date()
        private var responseTimes: [TimeInterval] = []

        private let timeLimit = 30

        private let maxTime = 45
        private let correctTimeBonus = 2
        private let wrongTimePenalty = 5

        @Published private(set) var secondsRemaining: Int
        @Published private(set) var lives = 3
        @Published private(set) var correctCount = 0
        @Published private(set) var solvedCount = 0
        @Published private(set) var currentStreak = 0
        @Published private(set) var longestStreak = 0

        @Published private(set) var currentQuestion = PracticeQuestion(left: 2, right: 2)
        @Published private(set) var answerOptions: [AnswerOption] = []
        @Published private(set) var answers: [PracticeAnswer] = []

        @Published private(set) var selectedAnswer: Int?
        @Published private(set) var answerResult: AnswerResult?

        private var isPaused = false
        private var isCountingDown = false
        @Published private(set) var isFinished = false
        @Published private(set) var isAcceptingAnswers = false
        @Published private(set) var shouldShowResult = false

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

            currentQuestion = makeSmartQuestion()
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
            lives = 3
            correctCount = 0
            solvedCount = 0
            currentStreak = 0
            longestStreak = 0
            answers = []

            isFinished = false
            isPaused = false

            selectedAnswer = nil
            answerResult = nil
            
            currentQuestion = makeSmartQuestion()
            updateAnswerOptions()

            isAcceptingAnswers = false

            start()
        }

        func finish(showResult: Bool = false) {
            guard !isFinished else { return }

            sessionEndTime = Date()

            stopTimer()

            isAcceptingAnswers = false
            isFinished = true

            if showResult {
                shouldShowResult = true
            }
        }

        private func tick() {
            guard !isFinished else {
                return
            }

            secondsRemaining -= 1

            if secondsRemaining <= 0 {
                secondsRemaining = 0
                finish(showResult: true)
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

            answers.append(
                PracticeAnswer(
                    left: currentQuestion.left,
                    right: currentQuestion.right,
                    correctAnswer: currentQuestion.answer,
                    userAnswer: answer,
                    mode: .rush
                )
            )

            solvedCount += 1

            if isCorrect {
                correctCount += 1
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)

                secondsRemaining = min(
                    secondsRemaining + correctTimeBonus,
                    maxTime
                )
            } else {
                lives -= 1
                currentStreak = 0
                secondsRemaining -= wrongTimePenalty

                if secondsRemaining <= 0 {
                    secondsRemaining = 0
                    finish(showResult: true)
                    return
                }
            }

            if lives <= 0 {
                finish(showResult: true)
                return
            }

            Task {
                try? await Task.sleep(for: .milliseconds(400))

                guard !isFinished else { return }

                selectedAnswer = nil
                answerResult = nil

                isAcceptingAnswers = true

                currentQuestion = makeSmartQuestion()
                questionStartTime = Date()
                updateAnswerOptions()
            }
        }

        private func makeSmartQuestion() -> PracticeQuestion {
            let history = swiftDB.fetchSessions().flatMap { $0.answers }
            let cell = SmartQuestionGenerator.generateSingleCell(allAnswers: history)
            let swap = Bool.random()

            return PracticeQuestion(
                left: swap ? cell.right : cell.left,
                right: swap ? cell.left : cell.right
            )
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

            var options = Array(distractors.prefix(3))
            options.append(answer)

            answerOptions = options.shuffled().map { AnswerOption(value: $0) }
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
