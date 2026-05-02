//
//  HomeView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var data: DesignDataManager

    private let gridSpacing: CGFloat = 14
    private let tileCorner: CGFloat = 22

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: gridSpacing),
            GridItem(.flexible(), spacing: gridSpacing)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: gridSpacing) {
                HomeHeroBanner()
                    .padding(.horizontal, gridSpacing)

                NavigationLink {
                    ExplorePatternsView()
                } label: {
                    HomeWideLabTile(title: "Explore", subtitle: "Pattern Lab")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, gridSpacing)

                NavigationLink {
                    ActivityHubView()
                } label: {
                    HomeMomentumStrip(title: "Studios")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, gridSpacing)

                LazyVGrid(columns: columns, spacing: gridSpacing) {
                    NavigationLink {
                        ActivityConfigurationView(kind: .pixelWeave)
                    } label: {
                        HomeStudioTile(
                            title: ActivityKind.pixelWeave.title,
                            gradient: [Color.appPrimary, Color.appAccent],
                            miniArt: { HomeWeaveGlyph() },
                            icon: "square.grid.3x3.topleft.filled"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ActivityConfigurationView(kind: .mosaicMaker)
                    } label: {
                        HomeStudioTile(
                            title: ActivityKind.mosaicMaker.title,
                            gradient: [Color.appAccent, Color.appPrimary.opacity(0.85)],
                            miniArt: { HomeMosaicGlyph() },
                            icon: "circle.grid.3x3.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ActivityConfigurationView(kind: .dynamicDoodle)
                    } label: {
                        HomeStudioTile(
                            title: ActivityKind.dynamicDoodle.title,
                            gradient: [Color.appSurface, Color.appAccent.opacity(0.7)],
                            miniArt: { HomeDoodleGlyph() },
                            icon: "scribble.variable"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        LiveCanvasTabView()
                    } label: {
                        HomeLiveCanvasTile(title: "Live Canvas")
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        DesignVaultView()
                    } label: {
                        HomeVaultTile(title: "Vault", count: data.vaultItems.count)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SessionGalleryView()
                    } label: {
                        HomeGalleryTile(title: "Session log", recentStars: data.sessionGallery.first?.stars)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PresetsLibraryView()
                    } label: {
                        HomePresetsTile(title: "Presets", count: data.creativePresets.count)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, gridSpacing)

                Spacer(minLength: 28)
            }
            .padding(.top, 8)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.appAccent, Color.appPrimary.opacity(0.45))
            }
        }
    }
}

// MARK: - Hero

private struct HomeHeroBanner: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.95),
                            Color.appAccent.opacity(0.75),
                            Color.appSurface.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    HomeHeroMesh()
                        .opacity(0.35)
                }
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 120, height: 120)
                        .offset(x: 24, y: -40)
                        .blur(radius: 1)
                }

            HStack(alignment: .bottom, spacing: 0) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .frame(height: 168)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.appPrimary.opacity(0.25), radius: 20, y: 10)
    }
}

private struct HomeHeroMesh: View {
    var body: some View {
        Canvas { context, size in
            let step = size.width / 9
            for i in 0..<10 {
                let x = CGFloat(i) * step
                var p = Path()
                p.move(to: CGPoint(x: x, y: 0))
                p.addLine(to: CGPoint(x: x + step * 0.35, y: size.height))
                context.stroke(p, with: .color(.white), lineWidth: 1.2)
            }
            for j in 0..<7 {
                let y = CGFloat(j) * (size.height / 6)
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y + step * 0.2))
                context.stroke(p, with: .color(.white), lineWidth: 1)
            }
        }
    }
}

// MARK: - Wide tiles

private struct HomeWideLabTile: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appSurface)
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appAccent.opacity(0.5), Color.appPrimary.opacity(0.45)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 88, height: 88)
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.appTextPrimary.opacity(0.9))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .appLabelStyle()
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.appAccent.opacity(0.9))
            }
            .padding(16)
        }
        .frame(height: 118)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
        )
    }
}

private struct HomeMomentumStrip: View {
    @EnvironmentObject private var data: DesignDataManager
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .appLabelStyle()
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.8))
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 4)
            HStack(spacing: 0) {
                metricVisual(
                    icon: "star.fill",
                    fill: data.weeklyStarsProgress,
                    tint: Color.appAccent
                )
                Rectangle()
                    .fill(Color.appBackground.opacity(0.5))
                    .frame(width: 1, height: 56)
                metricVisual(
                    icon: "figure.run",
                    fill: data.weeklySessionsProgress,
                    tint: Color.appPrimary
                )
            }
            .padding(.bottom, 12)
            .padding(.horizontal, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appSurface)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.4), Color.appPrimary.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1.5
                )
        )
    }

    private func metricVisual(icon: String, fill: Double, tint: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(tint.opacity(0.25), lineWidth: 6)
                    .frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: fill)
                    .stroke(tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(tint)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Studio & feature tiles

private struct HomeStudioTile<Art: View>: View {
    let title: String
    let gradient: [Color]
    @ViewBuilder let miniArt: () -> Art
    let icon: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            miniArt()
                .frame(maxHeight: 88)
                .padding(.horizontal, 6)
                .padding(.top, 36)
                .opacity(0.98)
            VStack {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.98))
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.forward")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(6)
                        .background(Circle().fill(.white.opacity(0.18)))
                }
                Spacer()
            }
            .padding(12)
        }
        .frame(minHeight: 156)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: gradient.first?.opacity(0.35) ?? .clear, radius: 12, y: 6)
    }
}

private struct HomeWeaveGlyph: View {
    private let cols = 6

    var body: some View {
        let ramp = AppPalettes.weaveRamp()
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: cols),
            spacing: 3
        ) {
            ForEach(0..<(cols * cols), id: \.self) { i in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(ramp[i % ramp.count].opacity(0.9))
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct HomeMosaicGlyph: View {
    var body: some View {
        let ramp = AppPalettes.mosaicRamp()
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 4),
            spacing: 4
        ) {
            ForEach(0..<12, id: \.self) { i in
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(ramp[i % ramp.count])
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct HomeDoodleGlyph: View {
    var body: some View {
        ZStack {
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 8, y: size.height * 0.55))
                path.addQuadCurve(
                    to: CGPoint(x: size.width - 8, y: size.height * 0.35),
                    control: CGPoint(x: size.width * 0.45, y: 8)
                )
                path.addQuadCurve(
                    to: CGPoint(x: size.width * 0.35, y: size.height - 6),
                    control: CGPoint(x: size.width * 0.85, y: size.height * 0.92)
                )
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [Color.appTextPrimary, Color.appAccent]),
                        startPoint: .zero,
                        endPoint: CGPoint(x: size.width, y: size.height)
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .padding(4)
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct HomeLiveCanvasTile: View {
    let title: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.appPrimary.opacity(0.95),
                            Color.appAccent,
                            Color.appSurface,
                            Color.appPrimary.opacity(0.95)
                        ]),
                        center: .center,
                        startAngle: .degrees(-20),
                        endAngle: .degrees(340)
                    )
                )
            VStack(spacing: 10) {
                Image(systemName: "paintbrush.pointed.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(radius: 4)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            }
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(10)
                }
                Spacer()
            }
        }
        .frame(minHeight: 148)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.appAccent.opacity(0.35), radius: 12, y: 6)
    }
}

private struct HomeVaultTile: View {
    let title: String
    let count: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.appSurface)
            VStack(spacing: 8) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity)
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appPrimary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                HStack(spacing: 4) {
                    ForEach(0..<min(count, 5), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.appAccent.opacity(0.65))
                            .frame(width: 14, height: 18)
                    }
                }
                .opacity(count == 0 ? 0.35 : 1)
            }
            VStack {
                HStack {
                    Spacer()
                    if count > 0 {
                        Text("\(count)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.appBackground.opacity(0.85)))
                    }
                    Image(systemName: "arrow.up.forward")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(8)
                }
                Spacer()
            }
        }
        .frame(minHeight: 148)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct HomeGalleryTile: View {
    let title: String
    let recentStars: Int?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, Color.appBackground.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(spacing: 10) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 34))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.appAccent, Color.appPrimary.opacity(0.6))
                if let recentStars {
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < recentStars ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                } else {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary.opacity(0.6))
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(10)
                }
                Spacer()
            }
        }
        .frame(minHeight: 148)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.appPrimary.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct HomePresetsTile: View {
    let title: String
    let count: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.appPrimary.opacity(0.22))
            VStack(spacing: 6) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.appAccent.opacity(0.45))
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(-8))
                        .offset(x: -10, y: 2)
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.appSurface)
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title3)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                }
                .frame(height: 64)
            }
            VStack {
                HStack {
                    Spacer()
                    Text("\(count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.appSurface.opacity(0.95)))
                        .padding(.trailing, 4)
                }
                .padding(.top, 8)
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(10)
                }
            }
        }
        .frame(minHeight: 148)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(DesignDataManager())
    }
}
