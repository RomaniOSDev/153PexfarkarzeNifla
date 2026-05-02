//
//  MosaicMakerView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct MosaicMakerView: View {
    @EnvironmentObject private var data: DesignDataManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MosaicMakerViewModel
    @State private var outcome: SessionOutcome?
    @State private var showSavePreset = false

    private let patternPrefix = "mosaic_maker"

    init(
        tier: Int,
        initialRows: Int? = nil,
        initialCols: Int? = nil,
        initialShapeScale: CGFloat? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: MosaicMakerViewModel(
                tier: tier,
                initialRows: initialRows,
                initialCols: initialCols,
                initialShapeScale: initialShapeScale
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                sliders
                mosaicBoard
                circularPalette
                controls
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationTitle("Mosaic Maker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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
                weaveGrid: nil,
                weavePalette: nil,
                mosaicRows: viewModel.rows,
                mosaicCols: viewModel.cols,
                mosaicScale: viewModel.shapeScale,
                doodleBrush: nil,
                onSave: { data.addCreativePreset($0) }
            )
        }
        .onAppear {
            viewModel.beginSession()
            viewModel.syncPlacements()
        }
        .onChange(of: viewModel.rows) { _ in
            viewModel.syncPlacements()
        }
        .onChange(of: viewModel.cols) { _ in
            viewModel.syncPlacements()
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
        .featureHintOverlay(.mosaicSession, data: data)
    }

    private var sliders: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Template Density")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            HStack {
                Text("Rows")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(viewModel.rows)")
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(
                value: Binding(
                    get: { Double(viewModel.rows) },
                    set: { viewModel.rows = Int($0) }
                ),
                in: Double(3 + viewModel.tier)...Double(5 + viewModel.tier),
                step: 1
            )
            .tint(Color.appAccent)

            HStack {
                Text("Columns")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(viewModel.cols)")
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(
                value: Binding(
                    get: { Double(viewModel.cols) },
                    set: { viewModel.cols = Int($0) }
                ),
                in: Double(3 + viewModel.tier)...Double(5 + viewModel.tier),
                step: 1
            )
            .tint(Color.appAccent)

            HStack {
                Text("Shape scale")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text(String(format: "%.2f", viewModel.shapeScale))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(value: $viewModel.shapeScale, in: 0.55...1.0, step: 0.01)
                .tint(Color.appAccent)
        }
        .padding()
        .appSurfaceCard(cornerRadius: 16)
    }

    private var mosaicBoard: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let cellSide = width / CGFloat(max(1, viewModel.cols))
            let gridHeight = cellSide * CGFloat(max(1, viewModel.rows))

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: viewModel.cols),
                spacing: 6
            ) {
                ForEach(0..<viewModel.placements.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.appSurface.opacity(0.5))
                            )
                        if let piece = viewModel.placements[index] {
                            MosaicShapeView(piece: piece, colors: viewModel.paletteColors())
                                .padding(6)
                        }
                    }
                    .frame(height: cellSide)
                    .onTapGesture {
                        viewModel.place(at: index)
                        HapticFeedback.light(enabled: data.hapticsEnabled)
                    }
                }
            }
            .frame(width: width, height: gridHeight, alignment: .top)
        }
        .aspectRatio(CGFloat(viewModel.cols) / CGFloat(viewModel.rows), contentMode: .fit)
        .padding()
        .appCanvasPlate(cornerRadius: 18)
    }

    private var circularPalette: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shape Wheel")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            ZStack {
                Circle()
                    .stroke(Color.appAccent.opacity(0.45), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .rotationEffect(viewModel.wheelRotation)
                    .gesture(
                        RotationGesture()
                            .onChanged { viewModel.wheelRotation = $0 }
                    )

                ForEach(Array(MosaicShapeKind.allCases.enumerated()), id: \.element.id) { index, shape in
                    let angle = (Double(index) / Double(MosaicShapeKind.allCases.count)) * Double.pi * 2
                    let radius: CGFloat = 78
                    let twist = viewModel.wheelRotation.radians
                    Button {
                        viewModel.selectedShape = shape
                        HapticFeedback.light(enabled: data.hapticsEnabled)
                    } label: {
                        Text(shape.title.prefix(1))
                            .font(.headline)
                            .foregroundStyle(
                                viewModel.selectedShape == shape
                                    ? Color.appTextOnVibrant
                                    : Color.appTextPrimary
                            )
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(
                                    viewModel.selectedShape == shape ? Color.appPrimary : Color.appSurface
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .offset(
                        x: CGFloat(cos(angle + Double(twist))) * radius,
                        y: CGFloat(sin(angle + Double(twist))) * radius
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

            HStack {
                Text("Color stop")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(viewModel.colorIndex)")
                    .foregroundStyle(Color.appTextPrimary)
            }
            .appLabelStyle()
            Slider(
                value: Binding(
                    get: { Double(viewModel.colorIndex) },
                    set: { viewModel.colorIndex = Int($0) }
                ),
                in: 0...Double(max(0, viewModel.paletteColors().count - 1)),
                step: 1
            )
            .tint(Color.appAccent)
        }
        .padding()
        .appSurfaceCard(cornerRadius: 16)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.undoLastPlacement()
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
                    viewModel.clearAll()
                    HapticFeedback.medium(enabled: data.hapticsEnabled)
                }) {
                    Text("Clear")
                        .appLabelStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .appMutedActionBackground(cornerRadius: 12)
                }
                .buttonStyle(.plain)
            }

            Button(action: finalize) {
                Text("Finalize Mosaic")
                    .appLabelStyle()
                    .foregroundStyle(Color.appTextOnVibrant)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .appPrimaryActionBackground(cornerRadius: 14)
            }
            .buttonStyle(.plain)
        }
    }

    private func finalize() {
        let before = Set(data.unlockedAchievements)
        let patternId = "\(patternPrefix)_\(viewModel.tier)"
        let draft = viewModel.buildOutcome(
            patternId: patternId,
            title: "Mosaic Maker",
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

private struct MosaicShapeView: View {
    let piece: MosaicPiece
    let colors: [Color]

    var body: some View {
        let fill = colors[max(0, min(piece.colorIndex, colors.count - 1))]
        Group {
            switch piece.shape {
            case .disk:
                Circle().fill(fill)
            case .block:
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(fill)
            case .wedge:
                Path { path in
                    path.move(to: CGPoint(x: 20, y: 4))
                    path.addLine(to: CGPoint(x: 36, y: 32))
                    path.addLine(to: CGPoint(x: 4, y: 32))
                    path.closeSubpath()
                }
                .fill(fill)
            }
        }
        .scaleEffect(piece.scale)
    }
}

#Preview {
    NavigationStack {
        MosaicMakerView(tier: 0)
            .environmentObject(DesignDataManager())
    }
}
