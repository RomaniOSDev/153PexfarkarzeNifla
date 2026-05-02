//
//  MainTabView.swift
//  153PexfarkarzeNifla
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var data: DesignDataManager

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground)
        appearance.shadowColor = UIColor(Color.appPrimary.opacity(0.35))
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                ExplorePatternsView()
            }
            .tabItem { Label("Explore", systemImage: "square.grid.3x3.fill") }

            NavigationStack {
                DesignVaultView()
            }
            .tabItem { Label("Vault", systemImage: "archivebox.fill") }

            NavigationStack {
                LiveCanvasTabView()
            }
            .tabItem { Label("Canvas", systemImage: "paintbrush.pointed.fill") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Color.appAccent)
    }
}

#Preview {
    MainTabView()
        .environmentObject(DesignDataManager())
}
