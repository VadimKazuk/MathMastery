import Foundation

final class DailyChallengeStorage {

    private let challengesKey = "daily_challenges"
       private let dateKey = "daily_challenges_date"
       private let versionKey = "daily_challenges_version"

       private let currentVersion = 1

    func load(
        for date: Date = Date()
    ) -> [DailyChallengeDefinition]? {

        guard
            let savedDate = UserDefaults.standard.object(
                forKey: dateKey
            ) as? Date
        else {
            return nil
        }

        guard Calendar.current.isDate(
            savedDate,
            inSameDayAs: date
        ) else {
            return nil
        }

        guard
            UserDefaults.standard.integer(
                forKey: versionKey
            ) == currentVersion
        else {
            return nil
        }

        guard
            let data = UserDefaults.standard.data(
                forKey: challengesKey
            )
        else {
            return nil
        }

        return try? JSONDecoder()
            .decode(
                [DailyChallengeDefinition].self,
                from: data
            )
    }

    func save(
        _ challenges: [DailyChallengeDefinition],
        date: Date = Date()
    ) {

        UserDefaults.standard.set(
            date,
            forKey: dateKey
        )

        UserDefaults.standard.set(
            currentVersion,
            forKey: versionKey
        )

        if let data = try? JSONEncoder()
            .encode(challenges) {

            UserDefaults.standard.set(
                data,
                forKey: challengesKey
            )
        }
    }

}
