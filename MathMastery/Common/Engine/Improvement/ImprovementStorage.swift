import Foundation

final class ImprovementStorage {

    private let currentTableKey = "currentImprovementTable"
    private let previousTableKey = "previousImprovementTable"
    private let completedTableKey = "completedImprovementTable"

    var table: Int? {
        get {
            UserDefaults.standard.object(
                forKey: currentTableKey
            ) as? Int
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: currentTableKey
            )
        }
    }

    var previousTable: Int? {
        get {
            UserDefaults.standard.object(forKey: previousTableKey) as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: previousTableKey)
        }
    }

    var completedTable: Int? {
        get {
            UserDefaults.standard.object(
                forKey: completedTableKey
            ) as? Int
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: completedTableKey
            )
        }
    }


    func clear() {
        UserDefaults.standard.removeObject(
            forKey: currentTableKey
        )
    }
}
