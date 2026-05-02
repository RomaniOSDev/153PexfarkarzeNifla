//
//  ContentView.swift
//  153PexfarkarzeNifla
//
//  Created by Roman on 5/1/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var designData = DesignDataManager()

    var body: some View {
        Group {
            if designData.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingFlowView(data: designData)
            }
        }
        .environmentObject(designData)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
