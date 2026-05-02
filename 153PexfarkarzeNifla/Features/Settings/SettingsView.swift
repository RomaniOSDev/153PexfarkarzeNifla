//
//  SettingsView.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var data: DesignDataManager
    @State private var showResetConfirm = false

    var body: some View {
        List {
            Section {
                Toggle(isOn: bindingHaptics) {
                    Text("Subtle feedback")
                        .foregroundStyle(Color.appTextPrimary)
                        .appLabelStyle()
                }
                .tint(Color.appAccent)

                Picker(selection: bindingDifficulty) {
                    Text("Foundational").tag(0)
                    Text("Balanced").tag(1)
                    Text("Advanced").tag(2)
                } label: {
                    Text("Default tier")
                        .foregroundStyle(Color.appTextPrimary)
                }
                .pickerStyle(.menu)
            } header: {
                Text("Workflow")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .listRowBackground(Color.appSurface)

            Section {
                LabeledContent("Sessions logged") {
                    Text("\(data.completedSessionCount)")
                        .foregroundStyle(Color.appTextSecondary)
                        .appLabelStyle()
                }
                LabeledContent("Recognition marks") {
                    Text("\(data.totalStars)")
                        .foregroundStyle(Color.appTextSecondary)
                        .appLabelStyle()
                }
                LabeledContent("Vault pieces") {
                    Text("\(data.vaultItems.count)")
                        .foregroundStyle(Color.appTextSecondary)
                        .appLabelStyle()
                }
            } header: {
                Text("Insights")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .listRowBackground(Color.appSurface)

            Section {
                if data.unlockedAchievements.isEmpty {
                    Text("Complete sessions to reveal milestones.")
                        .foregroundStyle(Color.appTextSecondary)
                        .font(.footnote)
                } else {
                    ForEach(data.unlockedAchievements, id: \.self) { achievement in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(achievement.title)
                                .foregroundStyle(Color.appTextPrimary)
                                .appLabelStyle()
                            Text(achievement.requirementSummary)
                                .font(.footnote)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("Milestones")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .listRowBackground(Color.appSurface)

            Section {
                if data.lockedAchievements.isEmpty {
                    Text("Every milestone is unlocked. Keep creating to raise your totals.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                } else {
                    ForEach(data.lockedAchievements, id: \.self) { achievement in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(achievement.title)
                                    .foregroundStyle(Color.appTextPrimary)
                                    .appLabelStyle()
                                Spacer()
                                Text("Locked")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Text(achievement.requirementSummary)
                                .font(.footnote)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("Upcoming milestones")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .listRowBackground(Color.appSurface)

            Section {
                Button {
                    AppSettingsActions.rateApp()
                    HapticFeedback.light(enabled: data.hapticsEnabled)
                } label: {
                    HStack {
                        Text("Rate Us")
                            .foregroundStyle(Color.appTextPrimary)
                            .appLabelStyle()
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.appAccent)
                            .frame(width: 44, height: 44)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    AppSettingsActions.openPolicy()
                    HapticFeedback.light(enabled: data.hapticsEnabled)
                } label: {
                    legalRow(title: "Privacy Policy")
                }
                .buttonStyle(.plain)

                Button {
                    AppSettingsActions.openTerms()
                    HapticFeedback.light(enabled: data.hapticsEnabled)
                } label: {
                    legalRow(title: "Terms of Use")
                }
                .buttonStyle(.plain)
            } header: {
                Text("Support & Legal")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .listRowBackground(Color.appSurface)

            Section {
                Button(role: .destructive) {
                    showResetConfirm = true
                } label: {
                    Text("Reset All Progress")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .appLabelStyle()
                }
            }
            .listRowBackground(Color.appSurface)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .appScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset all creative progress?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                data.resetAllProgress()
                HapticFeedback.medium(enabled: data.hapticsEnabled)
            }
        } message: {
            Text("This clears saved sessions, vault pieces, and milestones on this device.")
        }
    }

    private func legalRow(title: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextPrimary)
                .appLabelStyle()
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 44, height: 44)
        }
    }

    private var bindingHaptics: Binding<Bool> {
        Binding(
            get: { data.hapticsEnabled },
            set: { newValue in
                data.hapticsEnabled = newValue
                data.persistPreferences()
            }
        )
    }

    private var bindingDifficulty: Binding<Int> {
        Binding(
            get: { data.defaultDifficultyIndex },
            set: { newValue in
                data.defaultDifficultyIndex = newValue
                data.persistPreferences()
            }
        )
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(DesignDataManager())
    }
}
