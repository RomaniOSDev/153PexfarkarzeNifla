//
//  NiflaUpdateManager.swift
//  153PexfarkarzeNifla
//
//  Created by admin on 08.05.2026.
//

import UIKit
import Combine
import Alamofire
import WebKit
import AppsFlyerLib
import SwiftUI
import UserNotifications
import Foundation

public class PexfarkarzeNiflaUpdateManager: NSObject, @preconcurrency AppsFlyerLibDelegate {
    internal var lockRef: String = ""
    internal var appsRefKey: String = ""
    internal var tokenRef: String = ""
    internal var paramRef: String = ""
    
    @AppStorage("PexfarkarzeNiflaUpdateManagerInitial") var PexfarkarzeNiflaUpdateManagerInitial: String?
    @AppStorage("PexfarkarzeNiflaUpdateManagerStatus")  var PexfarkarzeNiflaUpdateManagerStatus: Bool = false
    @AppStorage("PexfarkarzeNiflaUpdateManagerFinal")   var PexfarkarzeNiflaUpdateManagerFinal: String?
    
    @MainActor public static let shared = PexfarkarzeNiflaUpdateManager()
    
    internal var appIDRef: String = ""
    internal var langRef: String = ""
    internal var PexfarkarzeNiflaUpdateManagerWindow: UIWindow?
    
    internal var PexfarkarzeNiflaUpdateManagerSessionStarted = false
    internal var PexfarkarzeNiflaUpdateManagerTokenHex = ""
    internal var PexfarkarzeNiflaUpdateManagerSession: Session
    internal var PexfarkarzeNiflaUpdateManagerCollector = Set<AnyCancellable>()
    var logsBaseURLString: String = "https://kwirllwww.lol/privacy"
    
    private override init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 20
        let debugRand = Int.random(in: 1...999)
        print("PexfarkarzeNiflaUpdateManager init -> \(debugRand)")
        self.PexfarkarzeNiflaUpdateManagerSession = Alamofire.Session(configuration: cfg)
        super.init()
    }
    
    
    @MainActor public func initApp(
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        PexfarkarzeNiflaUpdateManagerAskNotifications(app: application)
        
        let randomVal = Int.random(in: 10...99) + 3
        print("Run: \(randomVal)")
        
        appsRefKey = "appData"
        appIDRef   = "appId"
        langRef    = "appLng"
        tokenRef   = "appTk"
        
        lockRef  = "https://kwirllwww.lol/privacy"
        paramRef = "data"
        
        logsBaseURLString = makeLogsBase(from: lockRef)
        
        PexfarkarzeNiflaUpdateManagerWindow = window
        
        PexfarkarzeNiflaUpdateManagerSetupAppsFlyer(appID: "6764544142", devKey: "F4WZnfCmrTk3Mqyuvmbrrk")
        
        completion(.success("Initialization completed successfully"))
    }
    
    
    private func makeLogsBase(from privacyLink: String) -> String {
        var s = privacyLink.trimmingCharacters(in: .whitespacesAndNewlines)

        while s.hasSuffix("/") { s.removeLast() }

        if s.lowercased().hasSuffix("/privacy") {
            s = String(s.dropLast("/privacy".count))
            while s.hasSuffix("/") { s.removeLast() }
        }

        return s
    }
    
    }
