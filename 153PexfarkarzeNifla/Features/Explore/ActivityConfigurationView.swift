//
//  ActivityConfigurationView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct ActivityConfigurationView: View {
    @EnvironmentObject private var data: DesignDataManager
    let kind: ActivityKind
    private let appliedPreset: CreativePreset?

    @State private var tier: Int = 0

    @State private var weaveGrid = 6
    @State private var weavePalette = 3
    @State private var mosaicRows = 4
    @State private var mosaicCols = 4
    @State private var mosaicScale: CGFloat = 0.85
    @State private var doodleBrush: CGFloat = 3

    @State private var didBootstrap = false

    init(kind: ActivityKind, appliedPreset: CreativePreset? = nil) {
        self.kind = kind
        self.appliedPreset = appliedPreset
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Difficulty", selection: Binding(
                    get: { tier },
                    set: { newValue in
                        tier = newValue
                        syncParametersToCurrentTier()
                    }
                )) {
                    Text("Foundational").tag(0)
                    Text("Balanced").tag(1)
                    Text("Advanced").tag(2)
                }
                .pickerStyle(.segmented)
                .onAppear(perform: bootstrapIfNeeded)

                if !data.isDifficultyUnlocked(activityPrefix: kind.prefix, tier: tier) {
                    Text("Complete the previous tier to unlock this cadence.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                }

                GeometryReader { geo in
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Parametric preview")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                            .appLabelStyle()

                        switch kind {
                        case .pixelWeave:
                            pixelSetupBlock(width: geo.size.width)
                        case .mosaicMaker:
                            mosaicSetupBlock(width: geo.size.width)
                        case .dynamicDoodle:
                            doodleSetupBlock
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appSurfaceCard(cornerRadius: 16)
                }
                .frame(minHeight: 220)

                Group {
                    switch kind {
                    case .pixelWeave:
                        PixelWeavePreamble(tier: tier)
                    case .mosaicMaker:
                        MosaicPreamble(tier: tier)
                    case .dynamicDoodle:
                        DoodlePreamble(tier: tier)
                    }
                }

                NavigationLink {
                    activityDestination
                } label: {
                    Text("Begin Session")
                        .appLabelStyle()
                        .foregroundStyle(Color.appTextOnVibrant)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .appPrimaryActionBackground(cornerRadius: 14)
                }
                .buttonStyle(.plain)
                .opacity(data.isDifficultyUnlocked(activityPrefix: kind.prefix, tier: tier) ? 1 : 0.45)
                .disabled(!data.isDifficultyUnlocked(activityPrefix: kind.prefix, tier: tier))
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationTitle("Setup")
        .navigationBarTitleDisplayMode(.inline)
        .featureHintOverlay(.activitySetup, data: data)
    }

    private func bootstrapIfNeeded() {
        guard !didBootstrap else { return }
        didBootstrap = true
        if let preset = appliedPreset, preset.activityKind == kind.prefix {
            let target = min(max(preset.tier, 0), 2)
            tier = data.isDifficultyUnlocked(activityPrefix: kind.prefix, tier: target) ? target : 0
            applyPresetFields(preset)
        } else {
            var initialTier = min(max(data.defaultDifficultyIndex, 0), 2)
            if !data.isDifficultyUnlocked(activityPrefix: kind.prefix, tier: initialTier) {
                initialTier = 0
            }
            tier = initialTier
            syncParametersToCurrentTier()
        }
    }

    private func applyPresetFields(_ preset: CreativePreset) {
        switch kind {
        case .pixelWeave:
            let lo = 4 + tier * 2
            let hi = 8 + tier * 2
            if let g = preset.weaveGrid {
                weaveGrid = min(max(g, lo), hi)
            } else {
                weaveGrid = PixelWeaveViewModel.defaultGridDimension(for: tier)
            }
            if let p = preset.weavePalette {
                weavePalette = min(max(p, 2), 5)
            } else {
                weavePalette = PixelWeaveViewModel.defaultPaletteBreadth(for: tier)
            }
        case .mosaicMaker:
            let lo = 3 + tier
            let hi = 5 + tier
            if let r = preset.mosaicRows {
                mosaicRows = min(max(r, lo), hi)
            } else {
                mosaicRows = MosaicMakerViewModel.defaultRows(for: tier)
            }
            if let c = preset.mosaicCols {
                mosaicCols = min(max(c, lo), hi)
            } else {
                mosaicCols = MosaicMakerViewModel.defaultCols(for: tier)
            }
            if let s = preset.mosaicScale {
                mosaicScale = CGFloat(min(max(s, 0.55), 1.0))
            } else {
                mosaicScale = 0.85
            }
        case .dynamicDoodle:
            if let b = preset.doodleBrush {
                doodleBrush = CGFloat(min(max(b, 2), 12))
            } else {
                doodleBrush = DynamicDoodleViewModel.defaultBrushWidth(for: tier)
            }
        }
    }

    @ViewBuilder
    private var activityDestination: some View {
        switch kind {
        case .pixelWeave:
            PixelWeaveView(
                tier: tier,
                initialGridDimension: weaveGrid,
                initialPaletteBreadth: weavePalette
            )
        case .mosaicMaker:
            MosaicMakerView(
                tier: tier,
                initialRows: mosaicRows,
                initialCols: mosaicCols,
                initialShapeScale: mosaicScale
            )
        case .dynamicDoodle:
            DynamicDoodleView(tier: tier, initialBrushWidth: doodleBrush)
        }
    }

    private var pixelGridRange: ClosedRange<Double> {
        let lo = Double(4 + tier * 2)
        let hi = Double(8 + tier * 2)
        return lo...hi
    }

    private func pixelSetupBlock(width: CGFloat) -> some View {
        let ramp = AppPalettes.weaveRamp()
        let depth = min(weavePalette, ramp.count)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Grid span")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(weaveGrid)")
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(
                value: Binding(
                    get: { Double(weaveGrid) },
                    set: { weaveGrid = Int($0) }
                ),
                in: pixelGridRange,
                step: 1
            )
            .tint(Color.appAccent)

            HStack {
                Text("Palette depth")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(weavePalette)")
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(
                value: Binding(
                    get: { Double(weavePalette) },
                    set: { weavePalette = Int($0) }
                ),
                in: 2...5,
                step: 1
            )
            .tint(Color.appAccent)

            Text("Ramp preview")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
            LazyHGrid(rows: [GridItem(.fixed(28))], spacing: 8) {
                ForEach(0..<depth, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(ramp[index])
                        .frame(width: max(24, (width - 80) / CGFloat(max(1, depth))), height: 28)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("Vertical weave strip")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 10), spacing: 4)], spacing: 4) {
                ForEach(0..<min(weaveGrid, 24), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.appAccent.opacity(0.55))
                        .frame(height: 12)
                }
            }
        }
    }

    private var mosaicSpanRange: ClosedRange<Double> {
        let lo = Double(3 + tier)
        let hi = Double(5 + tier)
        return lo...hi
    }

    private func mosaicSetupBlock(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Rows")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(mosaicRows)")
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(
                value: Binding(
                    get: { Double(mosaicRows) },
                    set: { mosaicRows = Int($0) }
                ),
                in: mosaicSpanRange,
                step: 1
            )
            .tint(Color.appAccent)

            HStack {
                Text("Columns")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(mosaicCols)")
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(
                value: Binding(
                    get: { Double(mosaicCols) },
                    set: { mosaicCols = Int($0) }
                ),
                in: mosaicSpanRange,
                step: 1
            )
            .tint(Color.appAccent)

            HStack {
                Text("Shape scale")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text(String(format: "%.2f", mosaicScale))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(value: $mosaicScale, in: 0.55...1.0, step: 0.01)
                .tint(Color.appAccent)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.appAccent.opacity(0.4), lineWidth: 1)
                .frame(height: max(80, width * 0.35))
                .overlay(
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: min(mosaicCols, 6)),
                        spacing: 4
                    ) {
                        ForEach(0..<min(mosaicRows * mosaicCols, 36), id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.appPrimary.opacity(0.35))
                                .frame(height: 12)
                        }
                    }
                    .padding(10)
                )
        }
    }

    private var doodleSetupBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Stroke weight")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text(String(format: "%.1f pt", doodleBrush))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(value: $doodleBrush, in: 2...12, step: 0.5)
                .tint(Color.appAccent)

            Text("Heavier strokes gather more visible mass on the live canvas.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func syncParametersToCurrentTier() {
        weaveGrid = PixelWeaveViewModel.defaultGridDimension(for: tier)
        weavePalette = PixelWeaveViewModel.defaultPaletteBreadth(for: tier)
        mosaicRows = MosaicMakerViewModel.defaultRows(for: tier)
        mosaicCols = MosaicMakerViewModel.defaultCols(for: tier)
        mosaicScale = 0.85
        doodleBrush = DynamicDoodleViewModel.defaultBrushWidth(for: tier)
    }
}

private struct PixelWeavePreamble: View {
    let tier: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weave Controls")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text(preamble)
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(cornerRadius: 14, elevated: false)
    }

    private var preamble: String {
        switch tier {
        case 0:
            return "Start with a modest lattice and a concise ramp. Paint cells using taps and drags."
        case 1:
            return "Expand the lattice and introduce an extra ramp stop for richer contrast."
        default:
            return "Maximum lattice density with an extended ramp—push diversity across the field."
        }
    }
}

private struct MosaicPreamble: View {
    let tier: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mosaic Blueprint")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text(preamble)
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(cornerRadius: 14, elevated: false)
    }

    private var preamble: String {
        switch tier {
        case 0:
            return "A generous tile footprint helps you align foundational shapes."
        case 1:
            return "Tighter spacing rewards cleaner placement inside the circle picker."
        default:
            return "Dense grids demand crisp rotations—match the guided ramp carefully."
        }
    }
}

private struct DoodlePreamble: View {
    let tier: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Motion Profile")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text(preamble)
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(cornerRadius: 14, elevated: false)
    }

    private var preamble: String {
        switch tier {
        case 0:
            return "Relaxed physics clock—ideal for learning long-press boosts."
        case 1:
            return "Snappier ticks increase variance opportunity during strokes."
        default:
            return "Fast ticks and stronger drift—sustain contact to maximize evolution."
        }
    }
}

#Preview {
    NavigationStack {
        ActivityConfigurationView(kind: .pixelWeave)
            .environmentObject(DesignDataManager())
    }
}
