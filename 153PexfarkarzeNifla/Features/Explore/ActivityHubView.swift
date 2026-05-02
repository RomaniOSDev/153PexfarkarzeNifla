//
//  ActivityHubView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

enum ActivityKind: String, CaseIterable, Identifiable {
    case pixelWeave
    case mosaicMaker
    case dynamicDoodle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pixelWeave: return "Pixel Weave"
        case .mosaicMaker: return "Mosaic Maker"
        case .dynamicDoodle: return "Dynamic Doodle"
        }
    }

    var subtitle: String {
        switch self {
        case .pixelWeave: return "Lattice tapestry with drag and tap strokes."
        case .mosaicMaker: return "Place tiled geometry along guided rails."
        case .dynamicDoodle: return "Sketch evolving trails with timed dynamics."
        }
    }

    var prefix: String {
        switch self {
        case .pixelWeave: return "pixel_weave"
        case .mosaicMaker: return "mosaic_maker"
        case .dynamicDoodle: return "dynamic_doodle"
        }
    }

    init?(presetActivityKind: String) {
        guard let match = Self.allCases.first(where: { $0.prefix == presetActivityKind }) else { return nil }
        self = match
    }
}

struct ActivityHubView: View {
    @EnvironmentObject private var data: DesignDataManager
    @State private var expanded: ActivityKind?

    var body: some View {
        List {
            Section {
                Text("Choose a studio lane, expand details, then launch a calibrated session.")
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                    .listRowBackground(Color.appSurface)
            }

            ForEach(ActivityKind.allCases) { kind in
                Section {
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expanded == kind },
                            set: { expanded = $0 ? kind : nil }
                        )
                    ) {
                        NavigationLink {
                            ActivityConfigurationView(kind: kind)
                        } label: {
                            Text("Configure Session")
                                .appLabelStyle()
                        }
                        .listRowBackground(Color.appSurface)

                        TierStatusRows(kind: kind)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(kind.title)
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                                .appLabelStyle()
                            Text(kind.subtitle)
                                .font(.footnote)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowBackground(Color.appSurface)
            }
        }
        .scrollContentBackground(.hidden)
        .appScreenBackground()
        .navigationTitle("Studios")
        .navigationBarTitleDisplayMode(.inline)
        .featureHintOverlay(.exploreStudios, data: data)
    }
}

private struct TierStatusRows: View {
    @EnvironmentObject private var data: DesignDataManager
    let kind: ActivityKind

    private let titles = ["Foundational", "Balanced", "Advanced"]

    var body: some View {
        ForEach(0..<3, id: \.self) { tier in
            HStack {
                Text(titles[tier])
                    .foregroundStyle(Color.appTextPrimary)
                    .appLabelStyle()
                Spacer()
                if data.completedPatterns.contains("\(kind.prefix)_\(tier)") {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.appAccent)
                } else if data.isDifficultyUnlocked(activityPrefix: kind.prefix, tier: tier) {
                    Text("Ready")
                        .foregroundStyle(Color.appTextSecondary)
                        .font(.footnote)
                } else {
                    Text("Locked")
                        .foregroundStyle(Color.appTextSecondary)
                        .font(.footnote)
                }
            }
            .listRowBackground(Color.appSurface)
        }
    }
}

#Preview {
    NavigationStack {
        ActivityHubView()
            .environmentObject(DesignDataManager())
    }
}
