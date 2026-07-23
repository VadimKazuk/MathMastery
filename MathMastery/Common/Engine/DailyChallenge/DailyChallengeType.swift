enum DailyChallengeType: String, Codable, CaseIterable, Identifiable {
    case questions
    case accuracy
    case mode
    case mastery
    case xp
    case survival
    case streak
    case noMistakes
    case modeMaster
    case personalBest
    
    var id: Self { self }
}
