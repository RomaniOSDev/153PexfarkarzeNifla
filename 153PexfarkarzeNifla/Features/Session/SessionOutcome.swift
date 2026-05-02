//
//  SessionOutcome.swift
//  153PexfarkarzeNifla
//

import Foundation

struct SessionOutcome: Hashable, Identifiable {
    let id: UUID

    let patternId: String
    let activityKind: String
    let displayTitle: String
    let stars: Int
    let statLines: [String]
    let newlyUnlockedAchievementIDs: [AchievementID]

    func withUnlockedAchievements(_ ids: [AchievementID]) -> SessionOutcome {
        SessionOutcome(
            id: id,
            patternId: patternId,
            activityKind: activityKind,
            displayTitle: displayTitle,
            stars: stars,
            statLines: statLines,
            newlyUnlockedAchievementIDs: ids
        )
    }
}
