//
//  DynamicDoodleViewModel.swift
//  153PexfarkarzeNifla
//

import Combine
import SwiftUI

struct DoodleStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    let paletteIndex: Int
}

@MainActor
final class DynamicDoodleViewModel: ObservableObject {
    @Published var strokes: [DoodleStroke] = []
    @Published var boostPulse = false
    @Published private(set) var physicsPhase: CGFloat = 0
    @Published var brushLineWidth: CGFloat

    let tier: Int

    private var sessionStart: Date?
    private var bearingSamples: [CGFloat] = []
    private var cancellables = Set<AnyCancellable>()

    static func defaultBrushWidth(for tier: Int) -> CGFloat {
        switch tier {
        case 0: return 3.0
        case 1: return 3.5
        default: return 4.0
        }
    }

    init(tier: Int, initialBrushWidth: CGFloat? = nil) {
        self.tier = tier
        if let w = initialBrushWidth {
            brushLineWidth = min(max(w, 2), 12)
        } else {
            brushLineWidth = Self.defaultBrushWidth(for: tier)
        }
        let interval: TimeInterval = tier == 0 ? 0.08 : tier == 1 ? 0.06 : 0.045
        Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.advancePhysics()
            }
            .store(in: &cancellables)
    }

    func beginSession() {
        sessionStart = Date()
    }

    func paletteColors() -> [Color] {
        AppPalettes.doodleRamp()
    }

    func beginStroke(at point: CGPoint) {
        let paletteCount = paletteColors().count
        let index = Int.random(in: 0..<max(1, paletteCount))
        strokes.append(DoodleStroke(points: [point], paletteIndex: index))
    }

    func appendPoint(_ point: CGPoint) {
        guard var last = strokes.last else {
            beginStroke(at: point)
            return
        }
        if last.points.count > 520 {
            beginStroke(at: point)
            return
        }
        last.points.append(point)
        strokes[strokes.count - 1] = last
        recordBearing(with: point)
    }

    func toggleBoost() {
        boostPulse.toggle()
    }

    func resetSession() {
        strokes.removeAll()
        bearingSamples.removeAll()
        physicsPhase = 0
        sessionStart = Date()
    }

    func removeLastStroke() {
        guard !strokes.isEmpty else { return }
        strokes.removeLast()
    }

    private func recordBearing(with point: CGPoint) {
        guard var last = strokes.last, last.points.count > 2 else { return }
        let prev = last.points[last.points.count - 2]
        let bearing = atan2(point.y - prev.y, point.x - prev.x)
        bearingSamples.append(bearing)
        if bearingSamples.count > 120 {
            bearingSamples.removeFirst(bearingSamples.count - 120)
        }
    }

    private func advancePhysics() {
        physicsPhase += 0.08
        guard boostPulse else { return }
        guard !strokes.isEmpty else { return }
        for index in strokes.indices {
            var stroke = strokes[index]
            for pointIndex in stroke.points.indices {
                var point = stroke.points[pointIndex]
                let swirl = sin(physicsPhase + CGFloat(index) * 0.12 + CGFloat(pointIndex) * 0.05)
                point.x += swirl * 1.4
                point.y += cos(physicsPhase * 0.85 + CGFloat(pointIndex) * 0.08) * 1.2
                stroke.points[pointIndex] = point
            }
            strokes[index] = stroke
        }
    }

    private func varianceScore() -> CGFloat {
        guard bearingSamples.count > 4 else { return 0.12 }
        let mean = bearingSamples.reduce(0, +) / CGFloat(bearingSamples.count)
        let spread = bearingSamples
            .map { pow($0 - mean, 2) }
            .reduce(0, +) / CGFloat(bearingSamples.count)
        return sqrt(spread)
    }

    func buildOutcome(patternId: String, title: String, activityKind: String) -> SessionOutcome {
        let duration = Date().timeIntervalSince(sessionStart ?? Date())
        let variance = Double(varianceScore())
        let strokeFactor = Double(max(1, strokes.count))
        let weighted = duration * max(0.05, variance) * strokeFactor / 24.0
        let stars = Self.mapWeightedScore(weighted, tier: tier, duration: duration)

        let stats = [
            String(format: "Duration: %.1fs", duration),
            String(format: "Motion variance: %.2f", variance),
            String(format: "Active strokes: %d", strokes.count),
            String(format: "Dynamics index: %.2f", weighted)
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

    private static func mapWeightedScore(_ value: Double, tier: Int, duration: TimeInterval) -> Int {
        if duration < 2.0 { return 1 }
        let low: Double
        let high: Double
        switch tier {
        case 0:
            low = 1.1
            high = 2.4
        case 1:
            low = 1.5
            high = 3.1
        default:
            low = 2.0
            high = 4.2
        }
        if value < low { return 1 }
        if value < high { return 2 }
        return 3
    }
}
