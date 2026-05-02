//
//  AppStorage.swift
//  153PexfarkarzeNifla
//

import Combine
import Foundation

extension Notification.Name {
    static let designDataDidReset = Notification.Name("designDataDidReset")
}

private enum StorageKeys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
    static let completedPatterns = "completedPatterns"
    static let userStars = "userStars"
    static let vaultItems = "vaultItemsData"
    static let defaultDifficultyIndex = "defaultDifficultyIndex"
    static let hapticsEnabled = "hapticsEnabled"
    static let creativePresets = "creativePresetsData"
    static let sessionGallery = "sessionGalleryData"
    static let weeklyChallenge = "weeklyChallengeProgress"
    static let dismissedHints = "dismissedFeatureHints"
}

struct VaultItemRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let createdAt: Date
    let title: String
    let stars: Int
    let activityKind: String
}

enum AchievementID: String, CaseIterable, Hashable {
    case firstSpark
    case starGatherer
    case vaultCurator
    case deepExplorer

    var title: String {
        switch self {
        case .firstSpark: return "First Spark"
        case .starGatherer: return "Gathered Brilliance"
        case .vaultCurator: return "Curated Collection"
        case .deepExplorer: return "Deep Exploration"
        }
    }

    var requirementSummary: String {
        switch self {
        case .firstSpark: return "Finish any creative session"
        case .starGatherer: return "Collect 12 recognition marks total"
        case .vaultCurator: return "Save 4 pieces to your vault"
        case .deepExplorer: return "Complete all difficulty tiers once"
        }
    }
}

@MainActor
final class DesignDataManager: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var completedPatterns: [String]
    @Published private(set) var userStars: [Int]
    @Published private(set) var vaultItems: [VaultItemRecord]
    @Published var defaultDifficultyIndex: Int
    @Published var hapticsEnabled: Bool
    @Published private(set) var creativePresets: [CreativePreset]
    @Published private(set) var sessionGallery: [SessionGalleryEntry]
    @Published private(set) var weeklyChallenge: WeeklyChallengeProgress
    @Published private(set) var dismissedHintIDs: Set<String>

    var totalStars: Int {
        userStars.reduce(0, +)
    }

    var completedSessionCount: Int {
        userStars.count
    }

    var unlockedAchievements: [AchievementID] {
        var list: [AchievementID] = []
        if !userStars.isEmpty { list.append(.firstSpark) }
        if totalStars >= 12 { list.append(.starGatherer) }
        if vaultItems.count >= 4 { list.append(.vaultCurator) }
        let requiredPrefixes = ["pixel_weave", "mosaic_maker", "dynamic_doodle"]
        let allTiersDone = requiredPrefixes.allSatisfy { prefix in
            (0...2).allSatisfy { tier in
                completedPatterns.contains("\(prefix)_\(tier)")
            }
        }
        if allTiersDone { list.append(.deepExplorer) }
        return list
    }

    var lockedAchievements: [AchievementID] {
        let unlocked = Set(unlockedAchievements)
        return AchievementID.allCases.filter { !unlocked.contains($0) }
    }

    var allStudioTiersComplete: Bool {
        let requiredPrefixes = ["pixel_weave", "mosaic_maker", "dynamic_doodle"]
        return requiredPrefixes.allSatisfy { prefix in
            (0...2).allSatisfy { tier in
                completedPatterns.contains("\(prefix)_\(tier)")
            }
        }
    }

    var weeklyStarsProgress: Double {
        let g = Double(WeeklyChallengeTargets.starsGoal)
        return min(1, Double(weeklyChallenge.starsEarned) / max(1, g))
    }

    var weeklySessionsProgress: Double {
        let g = Double(WeeklyChallengeTargets.sessionsGoal)
        return min(1, Double(weeklyChallenge.sessionsCompleted) / max(1, g))
    }

    var weeklyChallengeHeadline: String {
        "Earn \(WeeklyChallengeTargets.starsGoal) marks and finish \(WeeklyChallengeTargets.sessionsGoal) sessions this week."
    }

    init() {
        hasSeenOnboarding = defaults.bool(forKey: StorageKeys.hasSeenOnboarding)
        completedPatterns = Self.decodeArray(key: StorageKeys.completedPatterns) ?? []
        userStars = Self.decodeArray(key: StorageKeys.userStars) ?? []
        vaultItems = Self.decodeVault() ?? []
        defaultDifficultyIndex = defaults.object(forKey: StorageKeys.defaultDifficultyIndex) as? Int ?? 0
        hapticsEnabled = defaults.object(forKey: StorageKeys.hapticsEnabled) as? Bool ?? true
        creativePresets = Self.decodePresets() ?? []
        sessionGallery = Self.decodeGallery() ?? []
        weeklyChallenge = Self.decodeWeekly() ?? WeeklyChallengeProgress(
            weekToken: Self.computeWeekToken(for: Date()),
            starsEarned: 0,
            sessionsCompleted: 0
        )
        dismissedHintIDs = Self.decodeHints() ?? []
        normalizeWeeklyChallengeIfNeeded()
    }

    private static func computeWeekToken(for date: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.yearForWeekOfYear, from: date)
        let w = cal.component(.weekOfYear, from: date)
        return "\(y)-\(w)"
    }

    private func normalizeWeeklyChallengeIfNeeded() {
        let token = Self.computeWeekToken(for: Date())
        if weeklyChallenge.weekToken != token {
            weeklyChallenge = WeeklyChallengeProgress(weekToken: token, starsEarned: 0, sessionsCompleted: 0)
            persistWeekly()
            objectWillChange.send()
        }
    }

    private static func decodeArray<T: Decodable>(key: String) -> [T]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([T].self, from: data)
    }

    private static func decodeVault() -> [VaultItemRecord]? {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.vaultItems) else { return nil }
        return try? JSONDecoder().decode([VaultItemRecord].self, from: data)
    }

    private static func decodePresets() -> [CreativePreset]? {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.creativePresets) else { return nil }
        return try? JSONDecoder().decode([CreativePreset].self, from: data)
    }

    private static func decodeGallery() -> [SessionGalleryEntry]? {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.sessionGallery) else { return nil }
        return try? JSONDecoder().decode([SessionGalleryEntry].self, from: data)
    }

    private static func decodeWeekly() -> WeeklyChallengeProgress? {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.weeklyChallenge) else { return nil }
        return try? JSONDecoder().decode(WeeklyChallengeProgress.self, from: data)
    }

    private static func decodeHints() -> Set<String>? {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.dismissedHints) else { return nil }
        return try? JSONDecoder().decode(Set<String>.self, from: data)
    }

    func markOnboardingSeen() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: StorageKeys.hasSeenOnboarding)
        objectWillChange.send()
    }

    func recordSession(
        patternId: String,
        stars: Int,
        gallerySummary: String? = nil,
        galleryActivityKind: String? = nil
    ) {
        normalizeWeeklyChallengeIfNeeded()
        if !completedPatterns.contains(patternId) {
            completedPatterns.append(patternId)
        }
        userStars.append(stars)
        persistArrays()
        weeklyChallenge.starsEarned += stars
        weeklyChallenge.sessionsCompleted += 1
        persistWeekly()
        if let summary = gallerySummary, let kind = galleryActivityKind {
            appendGalleryEntry(activityKind: kind, stars: stars, summary: summary)
        }
        objectWillChange.send()
    }

    func addVaultItem(title: String, stars: Int, activityKind: String) {
        let item = VaultItemRecord(
            id: UUID(),
            createdAt: Date(),
            title: title,
            stars: stars,
            activityKind: activityKind
        )
        vaultItems.insert(item, at: 0)
        persistVault()
        objectWillChange.send()
    }

    func removeVaultItem(id: UUID) {
        vaultItems.removeAll { $0.id == id }
        persistVault()
        objectWillChange.send()
    }

    func addCreativePreset(_ preset: CreativePreset) {
        creativePresets.insert(preset, at: 0)
        persistPresets()
        objectWillChange.send()
    }

    func removeCreativePreset(id: UUID) {
        creativePresets.removeAll { $0.id == id }
        persistPresets()
        objectWillChange.send()
    }

    func clearGallery() {
        sessionGallery.removeAll()
        persistGallery()
        objectWillChange.send()
    }

    func removeGalleryEntry(id: UUID) {
        sessionGallery.removeAll { $0.id == id }
        persistGallery()
        objectWillChange.send()
    }

    private func appendGalleryEntry(activityKind: String, stars: Int, summary: String) {
        let entry = SessionGalleryEntry(
            id: UUID(),
            createdAt: Date(),
            activityKind: activityKind,
            stars: stars,
            summary: summary
        )
        var next = [entry] + sessionGallery
        if next.count > 30 {
            next = Array(next.prefix(30))
        }
        sessionGallery = next
        persistGallery()
    }

    func isHintDismissed(_ hint: FeatureHintID) -> Bool {
        dismissedHintIDs.contains(hint.rawValue)
    }

    func dismissHint(_ hint: FeatureHintID) {
        dismissedHintIDs.insert(hint.rawValue)
        persistHints()
        objectWillChange.send()
    }

    func isDifficultyUnlocked(activityPrefix: String, tier: Int) -> Bool {
        if tier == 0 { return true }
        let previous = "\(activityPrefix)_\(tier - 1)"
        return completedPatterns.contains(previous)
    }

    func resetAllProgress() {
        defaults.removeObject(forKey: StorageKeys.completedPatterns)
        defaults.removeObject(forKey: StorageKeys.userStars)
        defaults.removeObject(forKey: StorageKeys.vaultItems)
        defaults.removeObject(forKey: StorageKeys.creativePresets)
        defaults.removeObject(forKey: StorageKeys.sessionGallery)
        defaults.removeObject(forKey: StorageKeys.weeklyChallenge)
        defaults.removeObject(forKey: StorageKeys.dismissedHints)
        completedPatterns = []
        userStars = []
        vaultItems = []
        creativePresets = []
        sessionGallery = []
        weeklyChallenge = WeeklyChallengeProgress(
            weekToken: Self.computeWeekToken(for: Date()),
            starsEarned: 0,
            sessionsCompleted: 0
        )
        dismissedHintIDs = []
        persistWeekly()
        persistHints()
        objectWillChange.send()
        NotificationCenter.default.post(name: .designDataDidReset, object: nil)
    }

    func persistPreferences() {
        defaults.set(defaultDifficultyIndex, forKey: StorageKeys.defaultDifficultyIndex)
        defaults.set(hapticsEnabled, forKey: StorageKeys.hapticsEnabled)
    }

    private func persistArrays() {
        if let data = try? JSONEncoder().encode(completedPatterns) {
            defaults.set(data, forKey: StorageKeys.completedPatterns)
        }
        if let data = try? JSONEncoder().encode(userStars) {
            defaults.set(data, forKey: StorageKeys.userStars)
        }
    }

    private func persistVault() {
        if let data = try? JSONEncoder().encode(vaultItems) {
            defaults.set(data, forKey: StorageKeys.vaultItems)
        }
    }

    private func persistPresets() {
        if let data = try? JSONEncoder().encode(creativePresets) {
            defaults.set(data, forKey: StorageKeys.creativePresets)
        }
    }

    private func persistGallery() {
        if let data = try? JSONEncoder().encode(sessionGallery) {
            defaults.set(data, forKey: StorageKeys.sessionGallery)
        }
    }

    private func persistWeekly() {
        if let data = try? JSONEncoder().encode(weeklyChallenge) {
            defaults.set(data, forKey: StorageKeys.weeklyChallenge)
        }
    }

    private func persistHints() {
        if let data = try? JSONEncoder().encode(dismissedHintIDs) {
            defaults.set(data, forKey: StorageKeys.dismissedHints)
        }
    }
}
