//
//  AppChrome.swift
//  153PexfarkarzeNifla
//

import SwiftUI

enum AppChrome {
    static let cardCorner: CGFloat = 16
}

extension View {
    /// Layered gradient ambient behind scroll content (replaces flat `Color.appBackground`).
    func appScreenBackground() -> some View {
        background {
            ZStack {
                Color.appBackground
                LinearGradient(
                    colors: [
                        Color.appPrimary.opacity(0.16),
                        Color.appBackground,
                        Color.appAccent.opacity(0.11)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [Color.appAccent.opacity(0.18), Color.clear],
                    center: .topTrailing,
                    startRadius: 20,
                    endRadius: 460
                )
                RadialGradient(
                    colors: [Color.appPrimary.opacity(0.14), Color.clear],
                    center: UnitPoint(x: 0.12, y: 0.92),
                    startRadius: 40,
                    endRadius: 380
                )
            }
            .ignoresSafeArea()
        }
    }

    /// Raised surface panel with gradient fill, rim light, and depth shadows.
    func appSurfaceCard(
        cornerRadius: CGFloat = AppChrome.cardCorner,
        elevated: Bool = true,
        subtle: Bool = false
    ) -> some View {
        let outerOpacity = subtle ? 0.2 : (elevated ? 0.42 : 0.3)
        let innerOpacity = subtle ? 0.12 : 0.22
        let radius = subtle ? 8.0 : (elevated ? 17.0 : 11.0)
        let y = subtle ? 4.0 : (elevated ? 11.0 : 6.0)
        let line: CGFloat = subtle ? 0.5 : 1

        return self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface,
                                Color.appBackground.opacity(0.62)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(subtle ? 0.07 : 0.13),
                                Color.appAccent.opacity(subtle ? 0.18 : 0.3),
                                Color.appPrimary.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: line
                    )
            }
            .shadow(color: Color.appPrimary.opacity(outerOpacity), radius: radius, x: 0, y: y)
            .shadow(color: Color.black.opacity(innerOpacity), radius: subtle ? 3 : 6, x: 0, y: subtle ? 2 : 4)
    }

    /// Inset plate for canvases / previews (soft gradient + rim).
    func appCanvasPlate(cornerRadius: CGFloat = 18) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.88),
                            Color.appBackground.opacity(0.42)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.appAccent.opacity(0.32),
                                    Color.appPrimary.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.38), radius: 12, x: 0, y: 6)
        .shadow(color: Color.appPrimary.opacity(0.18), radius: 8, x: 0, y: 4)
    }

    /// Primary CTA (filled gradient + glow).
    func appPrimaryActionBackground(cornerRadius: CGFloat = 14) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appPrimary.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.28), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.appPrimary.opacity(0.52), radius: 14, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.22), radius: 5, x: 0, y: 2)
    }

    /// Secondary / neutral control plate.
    func appSecondaryActionBackground(cornerRadius: CGFloat = 12) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, Color.appBackground.opacity(0.58)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.appPrimary.opacity(0.24), radius: 9, x: 0, y: 5)
        .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
    }

    /// Muted tertiary control (e.g. reset).
    func appMutedActionBackground(cornerRadius: CGFloat = 12) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.72),
                            Color.appBackground.opacity(0.48)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.15), lineWidth: 1)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.18), radius: 5, x: 0, y: 3)
    }

    /// Accent CTA (vault upload, highlights).
    func appAccentActionBackground(cornerRadius: CGFloat = 12, opacity: Double = 0.55) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appAccent.opacity(min(1, opacity + 0.12)),
                            Color.appAccent.opacity(opacity * 0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.appAccent.opacity(0.45), radius: 12, x: 0, y: 7)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
