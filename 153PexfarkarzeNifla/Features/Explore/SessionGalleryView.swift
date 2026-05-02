//
//  SessionGalleryView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct SessionGalleryView: View {
    @EnvironmentObject private var data: DesignDataManager

    var body: some View {
        Group {
            if data.sessionGallery.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.appAccent.opacity(0.85))
                    Text("No sessions logged yet")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .appLabelStyle()
                    Text("Complete a studio session to see recognition marks and a short recap here.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(32)
            } else {
                List {
                    Section {
                        Text(data.weeklyChallengeHeadline)
                            .font(.footnote)
                            .foregroundStyle(Color.appTextSecondary)
                            .listRowBackground(Color.appSurface)
                    }

                    ForEach(data.sessionGallery) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(formattedKind(entry.activityKind))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .appLabelStyle()
                                Spacer()
                                starRow(entry.stars)
                            }
                            Text(entry.summary)
                                .font(.footnote)
                                .foregroundStyle(Color.appTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.appSurface)
                    }
                    .onDelete(perform: deleteEntries)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .appScreenBackground()
        .navigationTitle("Session log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !data.sessionGallery.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) {
                        data.clearGallery()
                    }
                }
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        let ids = offsets.map { data.sessionGallery[$0].id }
        ids.forEach { data.removeGalleryEntry(id: $0) }
    }

    private func formattedKind(_ raw: String) -> String {
        raw.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func starRow(_ stars: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(Color.appAccent)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SessionGalleryView()
            .environmentObject(DesignDataManager())
    }
}
