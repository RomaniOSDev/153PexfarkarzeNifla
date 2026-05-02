//
//  PresetsLibraryView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct PresetsLibraryView: View {
    @EnvironmentObject private var data: DesignDataManager

    var body: some View {
        Group {
            if data.creativePresets.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "square.stack.3d.down.right")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.appAccent.opacity(0.85))
                    Text("No presets yet")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .appLabelStyle()
                    Text("Save a configuration from Pixel Weave, Mosaic Maker, or Dynamic Doodle using Save Preset.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(32)
            } else {
                List {
                    ForEach(data.creativePresets) { preset in
                        if let kind = ActivityKind(presetActivityKind: preset.activityKind) {
                            NavigationLink {
                                ActivityConfigurationView(kind: kind, appliedPreset: preset)
                            } label: {
                                presetRow(preset, kind: kind)
                            }
                            .listRowBackground(Color.appSurface)
                        } else {
                            presetRow(preset, kind: nil)
                                .listRowBackground(Color.appSurface)
                        }
                    }
                    .onDelete(perform: deletePresets)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .appScreenBackground()
        .navigationTitle("Presets")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deletePresets(at offsets: IndexSet) {
        let ids = offsets.map { data.creativePresets[$0].id }
        ids.forEach { data.removeCreativePreset(id: $0) }
    }

    private func presetRow(_ preset: CreativePreset, kind: ActivityKind?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(preset.name)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .appLabelStyle()
            if let kind {
                Text(kind.title)
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
            }
            Text(preset.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        PresetsLibraryView()
            .environmentObject(DesignDataManager())
    }
}
