//
//  ContentView.swift
//  153PexfarkarzeNifla
//
//  Created by Roman on 5/1/26.
//



import SwiftUI
import Network

struct ContentView: View {
    @State private var requestNotifications = true
    @State private var somethingWentWrong = false
    @State private var supportMessage = ""
    @StateObject private var designData = DesignDataManager()


    var body: some View {
        Group {
            if requestNotifications {
                PexfarkarzeNiflaLoadingView()
            } else {
                if somethingWentWrong {
                    Text("")
                    PexfarkarzeNiflaUpdateManager.PexfarkarzeNiflaUpdateManagerUI(PexfarkarzeNiflaUpdateManagerInfo: supportMessage)
                        .ignoresSafeArea()
                } else {
                    if designData.hasSeenOnboarding {
                        MainTabView()
                    } else {
                        OnboardingFlowView(data: designData)
                    }
                }
            }
        }
        .environmentObject(designData)
        .preferredColorScheme(.dark)
        .onAppear {
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                if path.status != .satisfied {
                    Task { @MainActor in
                        self.somethingWentWrong = false
                        self.requestNotifications = false
                    }
                }
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue.global(qos: .utility))

            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("RemMess"),
                object: nil,
                queue: .main
            ) { notification in
                if let info = notification.userInfo as? [String: String],
                   let data = info["notificationMessage"] {
                    Task { @MainActor in
                        if data == "Error occurred" {
                            self.somethingWentWrong = false
                        } else {
                            self.supportMessage = data
                            self.somethingWentWrong = true
                        }
                        self.requestNotifications = false
                    }
                } else {
                    Task { @MainActor in
                        self.somethingWentWrong = false
                        self.requestNotifications = false
                    }
                }
            }
        }
    }
}


struct PexfarkarzeNiflaLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.8)
                    .padding(.top, 30)
            }
        }
    }
}
