import Foundation

final class SmartQuestionGenerator {
    private static let questionRange = 2...9

    /// Генерирует одну случайную ячейку на основе весов (используется в Speed и Survival модах)
    static func generateSingleCell(allAnswers: [PracticeAnswer]) -> (left: Int, right: Int) {
        let weightedCells = calculateWeights(allAnswers: allAnswers)
        return lottery(weightedCells: weightedCells)
    }

    /// Генерирует массив уникальных ячеек для раунда (используется в Classic моде)
    static func generateSessionCells(allAnswers: [PracticeAnswer], amount: Int) -> [(left: Int, right: Int)] {
        var weightedCells = calculateWeights(allAnswers: allAnswers)
        var selectedCells: [(left: Int, right: Int)] = []

        // Пытаемся вытащить уникальные ячейки без дубликатов в рамках одной сессии
        while selectedCells.count < amount && !weightedCells.isEmpty {
            let totalWeight = weightedCells.reduce(0) { $0 + $1.weight }
            guard totalWeight > 0 else { break }

            var randomWeightPoint = Int.random(in: 1...totalWeight)

            for index in weightedCells.indices {
                randomWeightPoint -= weightedCells[index].weight
                if randomWeightPoint <= 0 {
                    selectedCells.append(weightedCells[index].cell)
                    weightedCells.remove(at: index) // Удаляем ячейку, чтобы она не повторилась в раунде
                    break
                }
            }
        }

        // Фолбэк (fallback) на случай, если нам не хватило ячеек
        while selectedCells.count < amount {
            let randomCell = (
                left: questionRange.randomElement() ?? 2,
                right: questionRange.randomElement() ?? 2
            )
            selectedCells.append(randomCell)
        }

        return selectedCells
    }

    // MARK: - Внутренние методы расчёта

    private static func calculateWeights(allAnswers: [PracticeAnswer]) -> [(cell: (left: Int, right: Int), weight: Int)] {
        var weightedCells: [(cell: (left: Int, right: Int), weight: Int)] = []

        for left in questionRange {
            for right in questionRange where left <= right { // Зеркальные пары (7х8 и 8х7) нормализуем

                let cellAnswers = allAnswers.filter {
                    let minL = min($0.left, $0.right)
                    let maxR = max($0.left, $0.right)
                    return minL == left && maxR == right
                }

                let recentAnswers = cellAnswers.sorted { $0.date > $1.date }.prefix(5)
                let total = recentAnswers.count

                let weight: Int
                if total == 0 {
                    weight = 100 // Еще не встречалось: максимальный приоритет
                } else {
                    let correct = recentAnswers.filter { $0.isCorrect }.count
                    let accuracy = Int(((Double(correct) / Double(total)) * 100).rounded())

                    switch accuracy {
                    case 100:   weight = 5   // Освоено идеально
                    case 70...99: weight = 20  // Редкие ошибки
                    case 40...69: weight = 60  // Проблемная зона
                    default:      weight = 90  // Постоянные ошибки
                    }
                }

                weightedCells.append((cell: (left, right), weight: weight))
            }
        }

        return weightedCells
    }

    private static func lottery(weightedCells: [(cell: (left: Int, right: Int), weight: Int)]) -> (left: Int, right: Int) {
        let totalWeight = weightedCells.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else {
            return (left: questionRange.randomElement() ?? 2, right: questionRange.randomElement() ?? 2)
        }

        var randomWeightPoint = Int.random(in: 1...totalWeight)
        for item in weightedCells {
            randomWeightPoint -= item.weight
            if randomWeightPoint <= 0 {
                return item.cell
            }
        }

        return (left: 2, right: 2)
    }
}
