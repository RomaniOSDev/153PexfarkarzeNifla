//
//  DesignVaultView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct DesignVaultView: View {
    @EnvironmentObject private var data: DesignDataManager
    @State private var columnCount = 2
    @State private var selectedDetail: VaultItemRecord?

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: max(1, columnCount))
    }

    var body: some View {
        ScrollView {
            if data.vaultItems.isEmpty {
                emptyState
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    vaultToolbar
                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(data.vaultItems) { item in
                            VaultCard(item: item)
                                .onTapGesture {
                                    selectedDetail = item
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        data.removeVaultItem(id: item.id)
                                    } label: {
                                        Text("Remove")
                                    }
                                }
                        }
                    }
                }
                .padding(16)
            }
        }
        .appScreenBackground()
        .navigationTitle("Vault")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedDetail) { item in
            VaultItemDetailSheet(
                item: item,
                onClose: { selectedDetail = nil },
                onDelete: {
                    data.removeVaultItem(id: item.id)
                    selectedDetail = nil
                }
            )
            .environmentObject(data)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.65), Color.appPrimary.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(height: 160)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.appSurface.opacity(0.35))
                )
                .overlay(
                    Text("No saved pieces yet")
                        .foregroundStyle(Color.appTextSecondary)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                )
                .shadow(color: Color.appAccent.opacity(0.25), radius: 14, x: 0, y: 8)
            Text("Finish a session and choose Upload to Vault on the summary screen.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(24)
    }

    private var vaultToolbar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Grid density")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .appLabelStyle()
            Picker("Columns", selection: $columnCount) {
                Text("Compact").tag(2)
                Text("Roomy").tag(3)
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .appSurfaceCard(cornerRadius: 14)
    }
}

private struct VaultCard: View {
    let item: VaultItemRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.title)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .appLabelStyle()
            Text(formattedKind(item.activityKind))
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .appLabelStyle()
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < item.stars ? "star.fill" : "star")
                        .foregroundStyle(Color.appAccent)
                        .font(.caption)
                }
            }
            Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .appLabelStyle()
            VaultGlyphPreview(stars: item.stars)
                .frame(height: 90)
            Text("Tap for details")
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .appLabelStyle()
        }
        .padding()
        .appSurfaceCard(cornerRadius: 16)
    }

    private func formattedKind(_ raw: String) -> String {
        raw.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

private struct VaultItemDetailSheet: View {
    @EnvironmentObject private var data: DesignDataManager
    let item: VaultItemRecord
    let onClose: () -> Void
    let onDelete: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(formattedKind(item.activityKind))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .appLabelStyle()

                    Text(item.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .appLabelStyle()

                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < item.stars ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundStyle(Color.appAccent)
                        }
                    }

                    LabeledContent("Saved") {
                        Text(item.createdAt.formatted(date: .long, time: .shortened))
                            .foregroundStyle(Color.appTextSecondary)
                            .appLabelStyle()
                    }
                    .foregroundStyle(Color.appTextPrimary)

                    VaultGlyphPreview(stars: item.stars)
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .appSurfaceCard(cornerRadius: 16, elevated: false, subtle: true)

                    Button(role: .destructive) {
                        HapticFeedback.medium(enabled: data.hapticsEnabled)
                        onDelete()
                    } label: {
                        Text("Delete from Vault")
                            .appLabelStyle()
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .appScreenBackground()
            .navigationTitle("Piece Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        onClose()
                    }
                    .foregroundStyle(Color.appAccent)
                }
            }
        }
    }

    private func formattedKind(_ raw: String) -> String {
        raw.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

private struct VaultGlyphPreview: View {
    let stars: Int

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                path.move(to: CGPoint(x: w * 0.1, y: h * 0.55))
                path.addQuadCurve(
                    to: CGPoint(x: w * 0.9, y: h * 0.45),
                    control: CGPoint(x: w * 0.45, y: h * 0.12)
                )
                path.addQuadCurve(
                    to: CGPoint(x: w * 0.35, y: h * 0.85),
                    control: CGPoint(x: w * 0.75, y: h * 0.95)
                )
            }
            .stroke(Color.appAccent, style: StrokeStyle(lineWidth: CGFloat(2 + stars), lineCap: .round))
        }
    }
}

#Preview {
    NavigationStack {
        DesignVaultView()
            .environmentObject(DesignDataManager())
    }
}
