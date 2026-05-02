//
//  SaveCreativePresetSheet.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct SaveCreativePresetSheet: View {
    @Environment(\.dismiss) private var dismiss
    let activityKind: String
    let tier: Int
    let weaveGrid: Int?
    let weavePalette: Int?
    let mosaicRows: Int?
    let mosaicCols: Int?
    let mosaicScale: CGFloat?
    let doodleBrush: CGFloat?
    let onSave: (CreativePreset) -> Void

    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Preset name", text: $name)
                        .textInputAutocapitalization(.words)
                } footer: {
                    Text("Saves the current lane, tier, and slider values so you can reopen them from Explore.")
                }
            }
            .scrollContentBackground(.hidden)
            .appScreenBackground()
            .navigationTitle("Save preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let label = trimmed.isEmpty ? "Untitled preset" : trimmed
                        let preset = CreativePreset(
                            id: UUID(),
                            createdAt: Date(),
                            name: label,
                            activityKind: activityKind,
                            tier: tier,
                            weaveGrid: weaveGrid,
                            weavePalette: weavePalette,
                            mosaicRows: mosaicRows,
                            mosaicCols: mosaicCols,
                            mosaicScale: mosaicScale.map { Double($0) },
                            doodleBrush: doodleBrush.map { Double($0) }
                        )
                        onSave(preset)
                        dismiss()
                    }
                }
            }
        }
    }
}
