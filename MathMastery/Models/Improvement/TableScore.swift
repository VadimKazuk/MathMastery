struct TableScore {

    let table: Int

    let correct: Int
    let total: Int

    var accuracy: Double {
        guard total > 0 else {
            return 1
        }

        return Double(correct) / Double(total)
    }

    var attempts: Int {
        total
    }
}
