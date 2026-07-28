import Foundation

enum QuestionDifficulty {
    case easy
    case normal
    case hard
}

final class QuestionDifficultyEngine {

    func difficulty(
        for mastery: FactMastery
    ) -> QuestionDifficulty {

        switch mastery.score {

        case 0..<40:
            return .easy

        case 40..<75:
            return .normal

        default:
            return .hard
        }
    }
}
