//
//  CreativeModels.swift
//  153PexfarkarzeNifla
//

import Foundation

struct CreativePreset: Codable, Identifiable, Equatable {
    var id: UUID
    var createdAt: Date
    var name: String
    var activityKind: String
    var tier: Int
    var weaveGrid: Int?
    var weavePalette: Int?
    var mosaicRows: Int?
    var mosaicCols: Int?
    var mosaicScale: Double?
    var doodleBrush: Double?
}

struct SessionGalleryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let createdAt: Date
    let activityKind: String
    let stars: Int
    let summary: String
}

struct WeeklyChallengeProgress: Codable, Equatable {
    var weekToken: String
    var starsEarned: Int
    var sessionsCompleted: Int
}

enum FeatureHintID: String, CaseIterable {
    case exploreStudios
    case activitySetup
    case pixelWeaveSession
    case mosaicSession
    case doodleSession

    var title: String {
        switch self {
        case .exploreStudios:
            return "Studios overview"
        case .activitySetup:
            return "Dial in parameters"
        case .pixelWeaveSession:
            return "Weave canvas"
        case .mosaicSession:
            return "Mosaic board"
        case .doodleSession:
            return "Dynamic strokes"
        }
    }

    var message: String {
        switch self {
        case .exploreStudios:
            return "Expand a studio row, then open Configure Session to adjust sliders before you launch."
        case .activitySetup:
            return "Use the preview block to feel density, then tap Begin Session when the lane matches your goal."
        case .pixelWeaveSession:
            return "Drag across cells to paint continuously, tap Cycle Brush for new ramps, and use Undo if a gesture goes wide."
        case .mosaicSession:
            return "Spin the shape wheel, align tiles with the ramp hint, and undo placements while refining coverage."
        case .doodleSession:
            return "Sketch with drags, long-press to toggle physics boost, and tune stroke weight for bolder trails."
        }
    }
}

enum WeeklyChallengeTargets {
    static let starsGoal = 6
    static let sessionsGoal = 3
}
