//
//  LiveCanvasTabView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct LiveCanvasTabView: View {
    @EnvironmentObject private var data: DesignDataManager
    @State private var strokes: [[CGPoint]] = []
    @State private var strokeWidth: CGFloat = 3.5
    @State private var strokeTintIndex = 0

    private let strokeTints: [Color] = [
        Color.appAccent,
        Color.appPrimary,
        Color.appSurface,
        Color.appTextSecondary
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sketch freely with immediate strokes. Capture the sketch into your vault when it feels complete.")
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Canvas { context, _ in
                    for stroke in strokes where stroke.count > 1 {
                        var path = Path()
                        path.move(to: stroke[0])
                        for point in stroke.dropFirst() {
                            path.addLine(to: point)
                        }
                        let color = strokeTints[strokeTintIndex % strokeTints.count]
                        context.stroke(
                            path,
                            with: .color(color),
                            style: StrokeStyle(
                                lineWidth: strokeWidth,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                    }
                }
                .frame(minHeight: 340)
                .appCanvasPlate(cornerRadius: 18)
                .overlay(
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if strokes.isEmpty {
                                        strokes.append([value.location])
                                        return
                                    }
                                    var active = strokes.removeLast()
                                    active.append(value.location)
                                    strokes.append(active)
                                }
                        )
                )

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Line weight")
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                        Text(String(format: "%.1f pt", strokeWidth))
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .appLabelStyle()
                    Slider(value: $strokeWidth, in: 2...10, step: 0.5)
                        .tint(Color.appAccent)

                    HStack {
                        Text("Stroke tint")
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                        HStack(spacing: 6) {
                            ForEach(0..<strokeTints.count, id: \.self) { index in
                                Circle()
                                    .fill(strokeTints[index])
                                    .frame(width: index == strokeTintIndex % strokeTints.count ? 22 : 16,
                                           height: index == strokeTintIndex % strokeTints.count ? 22 : 16)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.appTextPrimary.opacity(0.35), lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        strokeTintIndex = index
                                        HapticFeedback.light(enabled: data.hapticsEnabled)
                                    }
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                            }
                        }
                    }
                    .appLabelStyle()
                }
                .padding()
                .appSurfaceCard(cornerRadius: 14)

                VStack(spacing: 12) {
                    Button(action: undoLastStroke) {
                        Text("Undo stroke")
                            .appLabelStyle()
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .appSecondaryActionBackground(cornerRadius: 12)
                    }
                    .buttonStyle(.plain)
                    .disabled(strokes.isEmpty)
                    .opacity(strokes.isEmpty ? 0.45 : 1)

                    HStack(spacing: 12) {
                        Button(action: clearCanvas) {
                            Text("Clear")
                                .appLabelStyle()
                                .foregroundStyle(Color.appTextPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                                .appSecondaryActionBackground(cornerRadius: 12)
                        }
                        .buttonStyle(.plain)

                        Button(action: saveSketch) {
                            Text("Save Sketch")
                                .appLabelStyle()
                                .foregroundStyle(Color.appTextOnVibrant)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                                .appPrimaryActionBackground(cornerRadius: 12)
                        }
                        .buttonStyle(.plain)
                        .disabled(strokes.isEmpty)
                        .opacity(strokes.isEmpty ? 0.45 : 1)
                    }
                }
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationTitle("Live Canvas")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func undoLastStroke() {
        guard !strokes.isEmpty else { return }
        strokes.removeLast()
        HapticFeedback.light(enabled: data.hapticsEnabled)
    }

    private func clearCanvas() {
        strokes.removeAll()
        HapticFeedback.light(enabled: data.hapticsEnabled)
    }

    private func saveSketch() {
        let stampCount = max(1, strokes.count / 2 + 1)
        data.addVaultItem(
            title: "Live Sketch",
            stars: min(3, stampCount),
            activityKind: "live_canvas"
        )
        HapticFeedback.medium(enabled: data.hapticsEnabled)
        strokes.removeAll()
    }
}

#Preview {
    NavigationStack {
        LiveCanvasTabView()
            .environmentObject(DesignDataManager())
    }
}
