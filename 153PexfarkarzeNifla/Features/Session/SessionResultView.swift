//
//  SessionResultView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct SessionResultView: View {
    @EnvironmentObject private var data: DesignDataManager
    let outcome: SessionOutcome
    let onRevise: () -> Void
    let onNextDesign: () -> Void
    let onSaveToVault: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var revealedStars = 0
    @State private var bannerOffset: CGFloat = -220
    @State private var didStoreInVault = false
    @State private var showVaultConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                if !outcome.newlyUnlockedAchievementIDs.isEmpty {
                    achievementBanner
                }

                Text("Session Summary")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appLabelStyle()

                starRow

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(outcome.statLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .foregroundStyle(Color.appTextSecondary)
                            .font(.body)
                            .appLabelStyle()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .appSurfaceCard(cornerRadius: 14)

                VStack(spacing: 12) {
                    Button(action: onNextDesign) {
                        Text("Next Design")
                            .appLabelStyle()
                            .foregroundStyle(Color.appTextOnVibrant)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .appPrimaryActionBackground(cornerRadius: 14)
                    }
                    .buttonStyle(.plain)

                    Button(action: onRevise) {
                        Text("Revise Creation")
                            .appLabelStyle()
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .appSecondaryActionBackground(cornerRadius: 12)
                    }
                    .buttonStyle(.plain)

                    Button(action: saveToVault) {
                        Text(didStoreInVault ? "Stored in Vault" : "Upload to Vault")
                            .appLabelStyle()
                            .foregroundStyle(Color.appTextOnVibrant)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .appAccentActionBackground(
                                cornerRadius: 12,
                                opacity: didStoreInVault ? 0.35 : 0.55
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(didStoreInVault)
                    .opacity(didStoreInVault ? 0.75 : 1)
                }
            }
            .padding(16)
        }
        .appScreenBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") {
                    dismiss()
                }
                .foregroundStyle(Color.appAccent)
            }
        }
        .alert("Saved to vault", isPresented: $showVaultConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can review it anytime under the Design Vault tab.")
        }
        .onAppear {
            animateStars()
            animateBanner()
            scheduleBannerHide()
        }
    }

    private var achievementBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Fresh Achievement")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .appLabelStyle()
            ForEach(outcome.newlyUnlockedAchievementIDs, id: \.self) { achievement in
                Text(achievement.title)
                    .foregroundStyle(Color.appTextSecondary)
                    .font(.subheadline)
                    .appLabelStyle()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(cornerRadius: 14)
        .shadow(color: Color.appAccent.opacity(0.45), radius: 18, x: 0, y: 8)
        .offset(y: bannerOffset)
    }

    private var starRow: some View {
        HStack(spacing: 18) {
            ForEach(0..<3, id: \.self) { index in
                let filled = index < outcome.stars && index < revealedStars
                ZStack {
                    Image(systemName: filled ? "star.fill" : "star")
                        .font(.system(size: 42))
                        .foregroundStyle(Color.appAccent)
                        .opacity(index < outcome.stars ? 1 : 0.35)
                        .shadow(color: filled ? Color.appAccent.opacity(0.9) : .clear, radius: filled ? 12 : 0)
                        .scaleEffect(filled ? 1.05 : 0.9)
                }
                .frame(width: 54, height: 54)
            }
        }
        .padding(.vertical, 10)
        .animation(AppAnimations.spring, value: revealedStars)
    }

    private func animateStars() {
        revealedStars = 0
        let target = max(0, min(3, outcome.stars))
        guard target > 0 else { return }
        for step in 1...target {
            let delay = Double(step - 1) * 0.15
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(AppAnimations.spring) {
                    revealedStars = step
                }
            }
        }
    }

    private func animateBanner() {
        withAnimation(AppAnimations.spring) {
            bannerOffset = 0
        }
    }

    private func scheduleBannerHide() {
        guard !outcome.newlyUnlockedAchievementIDs.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(AppAnimations.easeInOutShort) {
                bannerOffset = -220
            }
        }
    }

    private func saveToVault() {
        guard !didStoreInVault else { return }
        onSaveToVault()
        didStoreInVault = true
        showVaultConfirmation = true
        HapticFeedback.light(enabled: data.hapticsEnabled)
    }
}

#Preview {
    NavigationStack {
        SessionResultView(
            outcome: SessionOutcome(
                id: UUID(),
                patternId: "sample",
                activityKind: "sample",
                displayTitle: "Sample",
                stars: 3,
                statLines: ["Coverage: 80%", "Duration: 12s"],
                newlyUnlockedAchievementIDs: [.firstSpark]
            ),
            onRevise: {},
            onNextDesign: {},
            onSaveToVault: {}
        )
        .environmentObject(DesignDataManager())
    }
}
