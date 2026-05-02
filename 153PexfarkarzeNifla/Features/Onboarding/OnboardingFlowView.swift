//
//  OnboardingFlowView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct OnboardingFlowView: View {
    @ObservedObject var data: DesignDataManager
    @State private var page = 0

    private let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            symbol: .weave,
            title: "Three studio lanes",
            subtitle: "Pixel Weave, Mosaic Maker, and Dynamic Doodle each offer a different rhythm—grids, tiles, and living strokes you can steer in real time.",
            footnote: nil
        ),
        OnboardingPageModel(
            symbol: .mosaic,
            title: "Calibrate, earn marks, keep pieces",
            subtitle: "Choose a difficulty tier, complete sessions for recognition stars, save finished work to the vault, and reopen tuned setups from Explore presets.",
            footnote: nil
        ),
        OnboardingPageModel(
            symbol: .doodle,
            title: "Gentle guidance, your pace",
            subtitle: "The first time you open Studios, session setup, or the live canvas, a short overlay explains the controls. Tap Got it once and we remember your choice.",
            footnote: "After that, it is just you, the parameters, and export when you are ready—no extra noise."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, model in
                    OnboardingSlidePage(model: model)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(AppAnimations.spring, value: page)

            stepIndicator
                .padding(.vertical, 16)

            bottomActions
        }
        .appScreenBackground()
    }

    private var headerBar: some View {
        HStack {
            Text("Welcome")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Button("Skip") {
                finish()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.appAccent)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { i in
                Capsule()
                    .fill(i == page ? Color.appAccent : Color.appTextSecondary.opacity(0.28))
                    .frame(width: i == page ? 28 : 8, height: 8)
                    .animation(AppAnimations.spring, value: page)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomActions: some View {
        VStack(spacing: 14) {
            if page < pages.count - 1 {
                Button {
                    advance()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .appLabelStyle()
                        .foregroundStyle(Color.appTextOnVibrant)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .appPrimaryActionBackground(cornerRadius: 16)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: finish) {
                    Text("Get Started")
                        .font(.headline)
                        .appLabelStyle()
                        .foregroundStyle(Color.appTextOnVibrant)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .appPrimaryActionBackground(cornerRadius: 16)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
        .padding(.top, 8)
    }

    private func advance() {
        guard page < pages.count - 1 else { return }
        HapticFeedback.light(enabled: data.hapticsEnabled)
        withAnimation(AppAnimations.spring) {
            page += 1
        }
    }

    private func finish() {
        withAnimation(AppAnimations.easeInOutShort) {
            data.markOnboardingSeen()
        }
        HapticFeedback.medium(enabled: data.hapticsEnabled)
    }
}

// MARK: - Models

private struct OnboardingPageModel {
    let symbol: ObSymbol
    let title: String
    let subtitle: String
    let footnote: String?
}

private enum ObSymbol {
    case weave, mosaic, doodle
}

// MARK: - Slide

private struct OnboardingSlidePage: View {
    let model: OnboardingPageModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                OnboardingHeroPanel(kind: model.symbol)
                    .frame(height: 300)
                    .padding(.horizontal, 4)

                VStack(alignment: .leading, spacing: 14) {
                    Text(model.title)
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(model.subtitle)
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let footnote = model.footnote {
                        Text(footnote)
                            .font(.footnote)
                            .foregroundStyle(Color.appTextSecondary.opacity(0.95))
                            .padding(.top, 4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
            .padding(.top, 12)
        }
    }
}

// MARK: - Hero

private struct OnboardingHeroPanel: View {
    let kind: ObSymbol

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.92),
                            Color.appAccent.opacity(0.72),
                            Color.appSurface.opacity(0.38)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            OnboardingMeshBackdrop()
                .opacity(0.4)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            SymbolPathView(kind: kind, strokeColor: Color.white.opacity(0.92))
                .padding(32)

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(Color.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.25), radius: 6, y: 2)
                        .padding(16)
                }
                Spacer()
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.appAccent.opacity(0.45),
                            Color.white.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
        .shadow(color: Color.appPrimary.opacity(0.45), radius: 22, x: 0, y: 14)
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
    }
}

private struct OnboardingMeshBackdrop: View {
    var body: some View {
        Canvas { context, size in
            let step = size.width / 9
            for i in 0..<10 {
                let x = CGFloat(i) * step
                var p = Path()
                p.move(to: CGPoint(x: x, y: 0))
                p.addLine(to: CGPoint(x: x + step * 0.35, y: size.height))
                context.stroke(p, with: .color(.white.opacity(0.18)), lineWidth: 1)
            }
            for j in 0..<7 {
                let y = CGFloat(j) * (size.height / 6)
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y + step * 0.18))
                context.stroke(p, with: .color(.white.opacity(0.14)), lineWidth: 0.8)
            }
        }
    }
}

private struct SymbolPathView: View {
    let kind: ObSymbol
    var strokeColor: Color = Color.appAccent

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                switch kind {
                case .weave:
                    let step = max(w, h) / 10
                    var x: CGFloat = 0
                    while x <= w {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x + step * 0.5, y: h))
                        x += step
                    }
                    var y: CGFloat = 0
                    while y <= h {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: w, y: y + step * 0.35))
                        y += step
                    }
                case .mosaic:
                    let cols = 5
                    let rows = 4
                    let cw = w / CGFloat(cols)
                    let ch = h / CGFloat(rows)
                    for r in 0..<rows {
                        for c in 0..<cols {
                            let inset = (CGFloat((r + c) % 3)) * 2
                            let rect = CGRect(
                                x: CGFloat(c) * cw + inset,
                                y: CGFloat(r) * ch + inset,
                                width: cw - inset * 2,
                                height: ch - inset * 2
                            )
                            path.addRect(rect)
                        }
                    }
                case .doodle:
                    path.move(to: CGPoint(x: w * 0.1, y: h * 0.55))
                    path.addQuadCurve(
                        to: CGPoint(x: w * 0.9, y: h * 0.45),
                        control: CGPoint(x: w * 0.45, y: h * 0.1)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: w * 0.3, y: h * 0.85),
                        control: CGPoint(x: w * 0.75, y: h * 0.95)
                    )
                }
            }
            .stroke(strokeColor, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
        }
    }
}

#Preview {
    OnboardingFlowView(data: DesignDataManager())
}
