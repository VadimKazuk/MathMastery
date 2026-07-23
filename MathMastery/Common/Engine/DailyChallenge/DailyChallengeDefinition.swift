import Foundation

struct DailyChallengeDefinition: Codable {

    let type: DailyChallengeType
    let target: Int

    let mode: PracticeMode?
    let metadata: String?
}
