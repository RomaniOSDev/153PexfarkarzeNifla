//
//  PixelWeaveViewModel.swift
//  153PexfarkarzeNifla
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class PixelWeaveViewModel: ObservableObject {
    @Published var gridDimension: Int
    @Published var paletteBreadth: Int
    @Published var cells: [Int]
    @Published var activeBrush: Int

    let tier: Int

    private var sessionStart: Date?
    private var undoStack: [[Int]] = []
    private let maxUndoDepth = 36
    private var strokeGestureActive = false

    static func defaultGridDimension(for tier: Int) -> Int {
        switch tier {
        case 0: return 6
        case 1: return 8
        default: return 10
        }
    }

    static func defaultPaletteBreadth(for tier: Int) -> Int {
        switch tier {
        case 0: return 3
        case 1: return 4
        default: return 5
        }
    }

    init(tier: Int, initialGridDimension: Int? = nil, initialPaletteBreadth: Int? = nil) {
        let dimLo = 4 + tier * 2
        let dimHi = 8 + tier * 2
        let dimension = min(
            max(initialGridDimension ?? Self.defaultGridDimension(for: tier), dimLo),
            dimHi
        )
        let palette = min(
            max(initialPaletteBreadth ?? Self.defaultPaletteBreadth(for: tier), 2),
            5
        )
        self.tier = tier
        gridDimension = dimension
        paletteBreadth = palette
        cells = Array(repeating: -1, count: dimension * dimension)
        activeBrush = 0
    }

    func beginSession() {
        sessionStart = Date()
    }

    func paletteColors() -> [Color] {
        let ramp = AppPalettes.weaveRamp()
        let breadth = max(2, min(paletteBreadth, ramp.count))
        return Array(ramp.prefix(breadth))
    }

    func resizeGridIfNeeded() {
        let target = gridDimension * gridDimension
        if cells.count == target { return }
        cells = Array(repeating: -1, count: target)
    }

    func beginStrokeGesture() {
        guard !strokeGestureActive else { return }
        strokeGestureActive = true
        pushUndoSnapshot()
    }

    func endStrokeGesture() {
        strokeGestureActive = false
    }

    func undoLastChange() {
        while let snapshot = undoStack.last {
            if snapshot.count == cells.count {
                undoStack.removeLast()
                cells = snapshot
                return
            } else {
                undoStack.removeLast()
            }
        }
    }

    private func pushUndoSnapshot() {
        undoStack.append(cells)
        if undoStack.count > maxUndoDepth {
            undoStack.removeFirst()
        }
    }

    func paint(at index: Int) {
        guard index >= 0, index < cells.count else { return }
        let breadth = paletteColors().count
        let brush = max(0, min(activeBrush, breadth - 1))
        cells[index] = brush
    }

    func cycleBrush() {
        let breadth = paletteColors().count
        activeBrush = (activeBrush + 1) % breadth
    }

    func resetCanvas() {
        cells = Array(repeating: -1, count: gridDimension * gridDimension)
        sessionStart = Date()
        undoStack.removeAll()
    }

    func buildOutcome(patternId: String, title: String, activityKind: String) -> SessionOutcome {
        let elapsed = Date().timeIntervalSince(sessionStart ?? Date())
        let baseTime = max(1.0, elapsed)
        let paintedIndices = cells.filter { $0 >= 0 }
        let paintedCount = paintedIndices.count
        let fillRatio = Double(paintedCount) / Double(max(1, cells.count))
        let unique = Set(paintedIndices).count
        let spread = Double(unique) * fillRatio
        let score = (Double(unique) * spread) / baseTime
        var stars = Self.mapScoreToStars(score: score, tier: tier)
        if paintedCount < max(3, gridDimension) {
            stars = max(1, stars - 1)
        }

        let stats = [
            "Unique ramps: \(unique)",
            String(format: "Coverage: %.0f%%", fillRatio * 100),
            String(format: "Elapsed: %.1fs", elapsed),
            String(format: "Score index: %.2f", score)
        ]

        return SessionOutcome(
            id: UUID(),
            patternId: patternId,
            activityKind: activityKind,
            displayTitle: title,
            stars: stars,
            statLines: stats,
            newlyUnlockedAchievementIDs: []
        )
    }

    private static func mapScoreToStars(score: Double, tier: Int) -> Int {
        let low: Double
        let high: Double
        switch tier {
        case 0:
            low = 0.22
            high = 0.62
        case 1:
            low = 0.32
            high = 0.82
        default:
            low = 0.42
            high = 1.05
        }
        if score < low { return 1 }
        if score < high { return 2 }
        return 3
    }
}
