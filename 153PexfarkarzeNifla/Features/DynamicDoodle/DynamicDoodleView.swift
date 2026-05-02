//
//  DynamicDoodleView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct DynamicDoodleView: View {
    @EnvironmentObject private var data: DesignDataManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DynamicDoodleViewModel
    @State private var outcome: SessionOutcome?
    @State private var isDrawingStroke = false
    @State private var showSavePreset = false

    private let patternPrefix = "dynamic_doodle"

    init(tier: Int, initialBrushWidth: CGFloat? = nil) {
        _viewModel = StateObject(
            wrappedValue: DynamicDoodleViewModel(tier: tier, initialBrushWidth: initialBrushWidth)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                instructions
                doodleCanvas
                controls
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationTitle("Dynamic Doodle")
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
                mosaicRows: nil,
                mosaicCols: nil,
                mosaicScale: nil,
                doodleBrush: viewModel.brushLineWidth,
                onSave: { data.addCreativePreset($0) }
            )
        }
        .onAppear {
            viewModel.beginSession()
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
        .featureHintOverlay(.doodleSession, data: data)
    }

    private var instructions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gesture Guide")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text("Drag to sketch flowing strokes. Long-press the canvas to alternate physics boost.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Circle()
                    .fill(viewModel.boostPulse ? Color.appAccent : Color.appSurface)
                    .frame(width: 14, height: 14)
                Text(viewModel.boostPulse ? "Boost engaged" : "Boost idle")
                    .foregroundStyle(Color.appTextSecondary)
                    .font(.footnote)
                    .appLabelStyle()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(cornerRadius: 16)
    }

    private var doodleCanvas: some View {
        let palette = viewModel.paletteColors()
        return Canvas { context, size in
            for stroke in viewModel.strokes {
                guard stroke.points.count > 1 else { continue }
                var path = Path()
                path.move(to: stroke.points[0])
                for point in stroke.points.dropFirst() {
                    path.addLine(to: point)
                }
                let color = palette[max(0, min(stroke.paletteIndex, palette.count - 1))]
                context.stroke(
                    path,
                    with: .color(color),
                    style: StrokeStyle(
                        lineWidth: viewModel.brushLineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            }
        }
        .frame(minHeight: 320)
        .appCanvasPlate(cornerRadius: 18)
        .overlay(
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isDrawingStroke {
                                isDrawingStroke = true
                                viewModel.beginStroke(at: value.location)
                            } else {
                                viewModel.appendPoint(value.location)
                            }
                        }
                        .onEnded { _ in
                            isDrawingStroke = false
                        }
                )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.4)
                        .onEnded { _ in
                            viewModel.toggleBoost()
                            HapticFeedback.medium(enabled: data.hapticsEnabled)
                        }
                )
        )
    }

    private var controls: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Stroke weight")
                        .foregroundStyle(Color.appTextSecondary)
                    Spacer()
                    Text(String(format: "%.1f", viewModel.brushLineWidth))
                        .foregroundStyle(Color.appTextPrimary)
                }
                .appLabelStyle()
                Slider(
                    value: Binding(
                        get: { Double(viewModel.brushLineWidth) },
                        set: { viewModel.brushLineWidth = CGFloat($0) }
                    ),
                    in: 2...12,
                    step: 0.5
                )
                .tint(Color.appAccent)
            }
            .padding()
            .appSurfaceCard(cornerRadius: 14, elevated: false)

            HStack(spacing: 12) {
                Button(action: {
                    viewModel.removeLastStroke()
                    HapticFeedback.light(enabled: data.hapticsEnabled)
                }) {
                    Text("Undo stroke")
                        .appLabelStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .appSecondaryActionBackground(cornerRadius: 12)
                }
                .buttonStyle(.plain)

                Button(action: {
                    viewModel.resetSession()
                    HapticFeedback.light(enabled: data.hapticsEnabled)
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
                Text("Wrap Session")
                    .appLabelStyle()
                    .foregroundStyle(Color.appTextOnVibrant)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .appPrimaryActionBackground(cornerRadius: 14)
            }
            .buttonStyle(.plain)
        }
    }

    private func finalizeSession() {
        let before = Set(data.unlockedAchievements)
        let patternId = "\(patternPrefix)_\(viewModel.tier)"
        let draft = viewModel.buildOutcome(
            patternId: patternId,
            title: "Dynamic Doodle",
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
        DynamicDoodleView(tier: 0)
            .environmentObject(DesignDataManager())
    }
}
