import Foundation

struct MultiplicationFact: Hashable {
    let left: Int
    let right: Int

    var answer: Int {
        left * right
    }
}
