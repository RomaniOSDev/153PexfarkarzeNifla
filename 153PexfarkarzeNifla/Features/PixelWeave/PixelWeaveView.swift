//
//  PixelWeaveView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct PixelWeaveView: View {
    @EnvironmentObject private var data: DesignDataManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PixelWeaveViewModel
    @State private var outcome: SessionOutcome?
    @State private var weaveDragActive = false
    @State private var showSavePreset = false

    private let patternPrefix = "pixel_weave"

    init(tier: Int, initialGridDimension: Int? = nil, initialPaletteBreadth: Int? = nil) {
        _viewModel = StateObject(
            wrappedValue: PixelWeaveViewModel(
                tier: tier,
                initialGridDimension: initialGridDimension,
                initialPaletteBreadth: initialPaletteBreadth
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                controls
                weaveCanvas
                actionBar
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationTitle("Pixel Weave")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    if let url = GridExportService.exportWeavePNG(
                        cells: viewModel.cells,
                        dimension: viewModel.gridDimension,
                        palette: viewModel.paletteColors()
                    ) {
                        ShareLink(item: url) {
                            Label("Share PNG", systemImage: "square.and.arrow.up")
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                Button {
                    showSavePreset = true
                } label: {
                    Image(systemName: "bookmark")
                }
            }
        }
        .sheet(isPresented: $showSavePreset) {
            SaveCreativePresetSheet(
                activityKind: patternPrefix,
                tier: viewModel.tier,
                weaveGrid: viewModel.gridDimension,
                weavePalette: viewModel.paletteBreadth,
                mosaicRows: nil,
                mosaicCols: nil,
                mosaicScale: nil,
                doodleBrush: nil,
                onSave: { data.addCreativePreset($0) }
            )
        }
        .onAppear {
            viewModel.beginSession()
        }
        .onChange(of: viewModel.gridDimension) { _ in
            viewModel.resizeGridIfNeeded()
        }
        .navigationDestination(isPresented: Binding(
            get: { outcome != nil },
            set: { active in
                if !active {
                    outcome = nil
                }
            }
        )) {
            Group {
                if let value = outcome {
                    SessionResultView(
                        outcome: value,
                        onRevise: { outcome = nil },
                        onNextDesign: {
                            outcome = nil
                            dismiss()
                        },
                        onSaveToVault: {
                            data.addVaultItem(
                                title: value.displayTitle,
                                stars: value.stars,
                                activityKind: value.activityKind
                            )
                        }
                    )
                } else {
                    EmptyView()
                }
            }
        }
        .featureHintOverlay(.pixelWeaveSession, data: data)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lattice & Palette")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            HStack {
                Text("Grid span")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(viewModel.gridDimension)")
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(
                value: Binding(
                    get: { Double(viewModel.gridDimension) },
                    set: { viewModel.gridDimension = Int($0) }
                ),
                in: Double(4 + viewModel.tier * 2)...Double(8 + viewModel.tier * 2),
                step: 1
            )
            .tint(Color.appAccent)

            HStack {
                Text("Palette depth")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(viewModel.paletteBreadth)")
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(
                value: Binding(
                    get: { Double(viewModel.paletteBreadth) },
                    set: { viewModel.paletteBreadth = Int($0) }
                ),
                in: 2...5,
                step: 1
            )
            .tint(Color.appAccent)
        }
        .padding()
        .appSurfaceCard(cornerRadius: 16)
    }

    private var weaveCanvas: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.width)
            let dim = max(2, viewModel.gridDimension)
            let cell = side / CGFloat(dim)
            ZStack(alignment: .topLeading) {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: 2),
                        count: dim
                    ),
                    spacing: 2
                ) {
                    ForEach(0..<viewModel.cells.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(color(at: index))
                            .frame(width: max(4, cell - 2), height: max(4, cell - 2))
                            .accessibilityLabel("Weave cell")
                    }
                }
                .frame(width: side, height: side, alignment: .topLeading)

                Color.clear
                    .frame(width: side, height: side)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if !weaveDragActive {
                                    viewModel.beginStrokeGesture()
                                    weaveDragActive = true
                                }
                                let col = Int(value.location.x / cell)
                                let row = Int(value.location.y / cell)
                                guard col >= 0, row >= 0,
                                      col < dim,
                                      row < dim else { return }
                                let idx = row * dim + col
                                viewModel.paint(at: idx)
                            }
                            .onEnded { _ in
                                weaveDragActive = false
                                viewModel.endStrokeGesture()
                            }
                    )
            }
            .frame(width: geo.size.width, height: side, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
        .appCanvasPlate(cornerRadius: 18)
    }

    private var actionBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.cycleBrush()
                    HapticFeedback.light(enabled: data.hapticsEnabled)
                }) {
                    Text("Cycle Brush")
                        .appLabelStyle()
                        .foregroundStyle(Color.appTextOnVibrant)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .appPrimaryActionBackground(cornerRadius: 12)
                }
                .buttonStyle(.plain)

                Button(action: {
                    viewModel.undoLastChange()
                    HapticFeedback.light(enabled: data.hapticsEnabled)
                }) {
                    Text("Undo")
                        .appLabelStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .appSecondaryActionBackground(cornerRadius: 12)
                }
                .buttonStyle(.plain)

                Button(action: {
                    viewModel.resetCanvas()
                    HapticFeedback.medium(enabled: data.hapticsEnabled)
                }) {
                    Text("Reset")
                        .appLabelStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .appMutedActionBackground(cornerRadius: 12)
                }
                .buttonStyle(.plain)
            }

            Button(action: finalizeSession) {
                Text("Complete Weave")
                    .appLabelStyle()
                    .foregroundStyle(Color.appTextOnVibrant)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .appPrimaryActionBackground(cornerRadius: 14)
            }
            .buttonStyle(.plain)
        }
    }

    private func color(at index: Int) -> Color {
        let palette = viewModel.paletteColors()
        let value = viewModel.cells[index]
        if value < 0 {
            return Color.appSurface.opacity(0.35)
        }
        return palette[max(0, min(value, palette.count - 1))]
    }

    private func finalizeSession() {
        let before = Set(data.unlockedAchievements)
        let patternId = "\(patternPrefix)_\(viewModel.tier)"
        let draft = viewModel.buildOutcome(
            patternId: patternId,
            title: "Pixel Weave",
            activityKind: patternPrefix
        )
        data.recordSession(
            patternId: patternId,
            stars: draft.stars,
            gallerySummary: draft.statLines.first,
            galleryActivityKind: patternPrefix
        )
        let unlocked = data.unlockedAchievements.filter { achievement in
            !before.contains(achievement)
        }
        outcome = draft.withUnlockedAchievements(unlocked)
        HapticFeedback.medium(enabled: data.hapticsEnabled)
    }
}

#Preview {
    NavigationStack {
        PixelWeaveView(tier: 0)
            .environmentObject(DesignDataManager())
    }
}
