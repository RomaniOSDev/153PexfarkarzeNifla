//
//  MosaicMakerViewModel.swift
//  153PexfarkarzeNifla
//

import Combine
import Foundation
import SwiftUI

enum MosaicShapeKind: Int, CaseIterable, Identifiable {
    case disk
    case block
    case wedge

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .disk: return "Disk"
        case .block: return "Block"
        case .wedge: return "Wedge"
        }
    }
}

struct MosaicPiece: Equatable {
    let shape: MosaicShapeKind
    let colorIndex: Int
    let scale: CGFloat
}

@MainActor
final class MosaicMakerViewModel: ObservableObject {
    @Published var rows: Int
    @Published var cols: Int
    @Published var placements: [MosaicPiece?]
    @Published var selectedShape: MosaicShapeKind = .disk
    @Published var colorIndex: Int = 0
    @Published var shapeScale: CGFloat = 0.85
    @Published var wheelRotation: Angle = .degrees(0)

    let tier: Int

    private var sessionStart: Date?
    private let patternStride: [Int]
    private var undoStack: [[MosaicPiece?]] = []
    private let maxUndoDepth = 32

    static func defaultRows(for tier: Int) -> Int {
        switch tier {
        case 0: return 4
        case 1: return 5
        default: return 6
        }
    }

    static func defaultCols(for tier: Int) -> Int {
        defaultRows(for: tier)
    }

    init(
        tier: Int,
        initialRows: Int? = nil,
        initialCols: Int? = nil,
        initialShapeScale: CGFloat? = nil
    ) {
        let baseRows: Int
        let baseCols: Int
        let stride: [Int]
        switch tier {
        case 0:
            baseRows = 4
            baseCols = 4
            stride = [0, 1, 2, 1]
        case 1:
            baseRows = 5
            baseCols = 5
            stride = [0, 1, 2, 2, 1]
        default:
            baseRows = 6
            baseCols = 6
            stride = [0, 2, 1, 2, 0, 1]
        }
        let spanLo = 3 + tier
        let spanHi = 5 + tier
        let rowsClamped = min(max(initialRows ?? baseRows, spanLo), spanHi)
        let colsClamped = min(max(initialCols ?? baseCols, spanLo), spanHi)
        self.tier = tier
        rows = rowsClamped
        cols = colsClamped
        patternStride = stride
        placements = Array(repeating: nil, count: rowsClamped * colsClamped)
        shapeScale = min(max(initialShapeScale ?? 0.85, 0.55), 1.0)
    }

    func beginSession() {
        sessionStart = Date()
    }

    func paletteColors() -> [Color] {
        AppPalettes.mosaicRamp()
    }

    func syncPlacements() {
        let target = rows * cols
        guard placements.count != target else { return }
        placements = Array(repeating: nil, count: target)
    }

    func undoLastPlacement() {
        while let snapshot = undoStack.last {
            if snapshot.count == placements.count {
                undoStack.removeLast()
                placements = snapshot
                return
            } else {
                undoStack.removeLast()
            }
        }
    }

    private func pushUndoSnapshot() {
        undoStack.append(placements)
        if undoStack.count > maxUndoDepth {
            undoStack.removeFirst()
        }
    }

    func place(at index: Int) {
        guard index >= 0, index < placements.count else { return }
        pushUndoSnapshot()
        let paletteCount = paletteColors().count
        let color = max(0, min(colorIndex, paletteCount - 1))
        placements[index] = MosaicPiece(
            shape: selectedShape,
            colorIndex: color,
            scale: shapeScale
        )
    }

    func clearAll() {
        placements = Array(repeating: nil, count: rows * cols)
        sessionStart = Date()
        undoStack.removeAll()
    }

    func expectedColorIndex(at index: Int) -> Int {
        patternStride[index % patternStride.count]
    }

    func buildOutcome(patternId: String, title: String, activityKind: String) -> SessionOutcome {
        let elapsed = Date().timeIntervalSince(sessionStart ?? Date())
        let totalSlots = max(1, placements.count)
        let filled = placements.compactMap { $0 }.count
        let coverage = Double(filled) / Double(totalSlots)

        var matchScore = 0.0
        var compared = 0
        for idx in placements.indices {
            guard let piece = placements[idx] else { continue }
            let expected = expectedColorIndex(at: idx)
            compared += 1
            if piece.colorIndex == expected {
                matchScore += 1
            }
        }
        let gradientFit = compared == 0 ? 0 : matchScore / Double(compared)

        let composite = coverage * 0.55 + gradientFit * 0.45
        let stars = Self.mapCompositeToStars(composite: composite, tier: tier, coverage: coverage)

        let stats = [
            String(format: "Coverage: %.0f%%", coverage * 100),
            String(format: "Ramp match: %.0f%%", gradientFit * 100),
            String(format: "Elapsed: %.1fs", elapsed),
            String(format: "Blend index: %.2f", composite)
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

    private static func mapCompositeToStars(composite: Double, tier: Int, coverage: Double) -> Int {
        if coverage < 0.25 { return 1 }
        let low: Double
        let high: Double
        switch tier {
        case 0:
            low = 0.42
            high = 0.68
        case 1:
            low = 0.5
            high = 0.78
        default:
            low = 0.58
            high = 0.86
        }
        if composite < low { return 1 }
        if composite < high { return 2 }
        return 3
    }
}
