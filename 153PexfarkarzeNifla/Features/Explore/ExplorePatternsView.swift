//
//  ExplorePatternsView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct ExplorePatternsView: View {
    @EnvironmentObject private var data: DesignDataManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pattern Lab")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .appLabelStyle()
                    .padding(.horizontal, 16)

                WeeklyMotivationCard()
                    .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    NavigationLink {
                        SessionGalleryView()
                    } label: {
                        exploreAccessoryRow(
                            title: "Session log",
                            subtitle: "Recent recognition marks and recap lines.",
                            symbol: "calendar.badge.clock"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PresetsLibraryView()
                    } label: {
                        exploreAccessoryRow(
                            title: "Saved presets",
                            subtitle: "Reopen tuned sliders for any studio lane.",
                            symbol: "square.stack.3d.down.right"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)

                if data.allStudioTiersComplete {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "seal.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appAccent)
                            .frame(width: 44, height: 44)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full studio sweep")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                                .appLabelStyle()
                            Text("You cleared every tier across all three creative lanes. Keep refining vault pieces or revisit any lane for new scores.")
                                .font(.footnote)
                                .foregroundStyle(Color.appTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appSurfaceCard(cornerRadius: 16)
                    .padding(.horizontal, 16)
                }

                TabView {
                    FeaturedSpotlightCard(
                        title: "Parametric Weave",
                        detail: "Paint modular grids with tactile gestures.",
                        accent: Color.appAccent
                    )
                    FeaturedSpotlightCard(
                        title: "Geometric Mosaic",
                        detail: "Arrange precise tiles along structured guides.",
                        accent: Color.appPrimary
                    )
                    FeaturedSpotlightCard(
                        title: "Fluid Trails",
                        detail: "Steer animated strokes that evolve while you move.",
                        accent: Color.appAccent
                    )
                }
                .frame(height: 200)
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Studio Gateways")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .appLabelStyle()
                        .padding(.horizontal, 16)

                    NavigationLink {
                        ActivityHubView()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Creative Tool Suite")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .appLabelStyle()
                                Text("Open categories, tune sliders, launch focused sessions.")
                                    .font(.footnote)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 12)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.appAccent)
                                .frame(width: 44, height: 44)
                        }
                        .padding(16)
                        .appSurfaceCard(cornerRadius: 16)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)

                    ParameterHighlightsGrid()
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 24)
            }
            .padding(.top, 12)
        }
        .appScreenBackground()
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct WeeklyMotivationCard: View {
    @EnvironmentObject private var data: DesignDataManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundStyle(Color.appAccent)
                Text("This week")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .appLabelStyle()
            }
            Text(data.weeklyChallengeHeadline)
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 6) {
                progressRow(
                    label: "Marks toward goal",
                    value: "\(min(data.weeklyChallenge.starsEarned, WeeklyChallengeTargets.starsGoal)) / \(WeeklyChallengeTargets.starsGoal)",
                    progress: data.weeklyStarsProgress
                )
                progressRow(
                    label: "Sessions toward goal",
                    value: "\(min(data.weeklyChallenge.sessionsCompleted, WeeklyChallengeTargets.sessionsGoal)) / \(WeeklyChallengeTargets.sessionsGoal)",
                    progress: data.weeklySessionsProgress
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(cornerRadius: 16)
    }

    private func progressRow(label: String, value: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text(value)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appBackground.opacity(0.9))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appPrimary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * progress))
                }
            }
            .frame(height: 8)
        }
    }
}

private func exploreAccessoryRow(title: String, subtitle: String, symbol: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
        Image(systemName: symbol)
            .font(.title3)
            .foregroundStyle(Color.appAccent)
            .frame(width: 40, height: 40)
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .appLabelStyle()
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        Spacer(minLength: 8)
        Image(systemName: "chevron.right")
            .foregroundStyle(Color.appAccent.opacity(0.9))
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .appSurfaceCard(cornerRadius: 16)
}

private struct FeaturedSpotlightCard: View {
    let title: String
    let detail: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .appLabelStyle()
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, accent.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [accent.opacity(0.75), accent.opacity(0.28)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
        .shadow(color: accent.opacity(0.38), radius: 14, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.28), radius: 7, x: 0, y: 3)
        .padding(.vertical, 4)
    }
}

private struct ParameterHighlightsGrid: View {
    let items: [(String, String)] = [
        ("Density Scaler", "Tune lattice resolution before weaving."),
        ("Gradient Rails", "Pick harmonious ramps per difficulty."),
        ("Motion Ink", "Blend physics boost with gesture rhythm.")
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, row in
                HStack(alignment: .top, spacing: 12) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.appPrimary.opacity(0.35))
                        .frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.0)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                            .appLabelStyle()
                        Text(row.1)
                            .font(.footnote)
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appSurfaceCard(cornerRadius: 14, elevated: false, subtle: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExplorePatternsView()
            .environmentObject(DesignDataManager())
    }
}
