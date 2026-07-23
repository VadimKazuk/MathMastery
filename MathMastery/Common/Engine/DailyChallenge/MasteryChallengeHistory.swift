import Foundation

final class MasteryChallengeHistory {

    private let key = "mastery_challenge_history"

    func load() -> [Int] {
        UserDefaults.standard.array(
            forKey: key
        ) as? [Int] ?? []
    }


    func save(
        table: Int
    ) {

        var history = load()

        history.append(table)

        // храним последние 7 дней
        if history.count > 7 {
            history.removeFirst()
        }

        UserDefaults.standard.set(
            history,
            forKey: key
        )
    }
}
