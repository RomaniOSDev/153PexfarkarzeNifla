//
//  NiflaModels.swift
//  153PexfarkarzeNifla
//
//  Created by admin on 08.05.2026.
//

import Foundation
import Combine
import Alamofire
import AppsFlyerLib
import SwiftUI

    extension PexfarkarzeNiflaUpdateManager {
    
    public func PexfarkarzeNiflaUpdateManagerPrivacyAndTermsReq(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let debugLocalRand = code.count + Int.random(in: 1...30)
        print("runCheckDataFlow -> \(debugLocalRand)")
        
        let parameters = [paramRef: code]
        PexfarkarzeNiflaUpdateManagerSession.request(lockRef, method: .get, parameters: parameters)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let htmlResponse):
                    
                    guard let base64Res = self.extractBase64(from: htmlResponse) else {
                        completion(.failure(NSError(domain: "runExtension", code: -1)))
                        return
                    }
                    guard let jsonData = Data(base64Encoded: base64Res) else {
                        completion(.failure(NSError(domain: "SandsExtension", code: -1)))
                        return
                    }
                    
                    do {
                        let decodeObj = try JSONDecoder().decode(PexfarkarzeNiflaUpdateManagerResponse.self, from: jsonData)
                        
                        self.sendLog(
                            step: "LogStep6",
                            userID: self.appIDRef,
                            message: "response model ready -> \(decodeObj)",
                        )
                        
                        self.PexfarkarzeNiflaUpdateManagerStatus = decodeObj.first_link
                        
                        if self.PexfarkarzeNiflaUpdateManagerInitial == nil {
                            self.PexfarkarzeNiflaUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else if decodeObj.link == self.PexfarkarzeNiflaUpdateManagerInitial {
                            completion(.success(self.PexfarkarzeNiflaUpdateManagerFinal ?? decodeObj.link))
                        } else if self.PexfarkarzeNiflaUpdateManagerStatus {
                            self.PexfarkarzeNiflaUpdateManagerFinal   = nil
                            self.PexfarkarzeNiflaUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else {
                            self.PexfarkarzeNiflaUpdateManagerInitial = decodeObj.link
                            completion(.success(self.PexfarkarzeNiflaUpdateManagerFinal ?? decodeObj.link))
                        }
                        
                    } catch {
                        self.sendLog(
                            step: "LogStep7",
                            userID: self.appIDRef,
                            message: "Server json decode model error -> \(error.localizedDescription)",
                        )
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    self.sendLog(
                        step: "LogStep5",
                        userID: self.appIDRef,
                        message: "link not found on page",
                        data: error.localizedDescription
                    )
                    completion(.failure(error))
                }
            }
    }
    
    public func PexfarkarzeNiflaUpdateManagerLocalMathCompute(_ x: Int) -> Int {
        let result = (x * 4) - 2
        print("PexfarkarzeNiflaUpdateManagerLocalMathCompute -> base \(x), result \(result)")
        return result
    }
    
    func extractBase64(from html: String) -> String? {
        let pattern = #"<p\s+style="display:none;">([^<]+)</p>"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            if let match = regex.firstMatch(in: html, options: [], range: range),
               match.numberOfRanges > 1,
               let captureRange = Range(match.range(at: 1), in: html) {
                sendLog(
                    step: "LogStep3",
                    userID: appIDRef,
                    message: "link extracted suucesfully -> \(String(html[captureRange]))",
                )
                return String(html[captureRange])
            }
        } catch {
            print("extractBase64 -> Regex error: \(error)")
        }
        sendLog(
            step: "LogStep4",
            userID: AppsFlyerLib.shared().getAppsFlyerUID() ?? "",
            message: "base64 link not found on page",
        )
        return nil
    }
    
    public func DoubleToLine(_ arr: [Double]) -> String {
        let line = arr.map { String($0) }.joined(separator: ",")
        print("runDoubleToLine -> \(line)")
        return line
    }
    
    public struct PexfarkarzeNiflaUpdateManagerResponse: Codable {
        var link:       String
        var naming:     String
        var first_link: Bool
    }
    
    public func PexfarkarzeNiflaUpdateManagerParseNetSnippet() {
        let snippet = "{\"sxNet\":555}"
        if let d = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed)
                print("PexfarkarzeNiflaUpdateManagerParseNetSnippet -> keys: \(obj)")
            } catch {
                print("runParseNetSnippet -> error: \(error)")
            }
        }
    }
    
    public func PexfarkarzeNiflaUpdateManagerPartialNetInspect(_ info: [String: Any]) {
        print("PexfarkarzeNiflaUpdateManagerPartialNetInspect -> keys: \(info.keys.count)")
    }
    
    public struct PexfarkarzeNiflaUpdateManagerUI: UIViewControllerRepresentable {
        
        public var PexfarkarzeNiflaUpdateManagerInfo: String
        
        public init(PexfarkarzeNiflaUpdateManagerInfo: String) {
            self.PexfarkarzeNiflaUpdateManagerInfo = PexfarkarzeNiflaUpdateManagerInfo
        }
        
        public func makeUIViewController(context: Context) -> PexfarkarzeNiflaUpdateManagerSceneController {
            let ctrl = PexfarkarzeNiflaUpdateManagerSceneController()
            ctrl.fruitErrorURL = PexfarkarzeNiflaUpdateManagerInfo
            return ctrl
        }
        
        public func updateUIViewController(_ uiViewController: PexfarkarzeNiflaUpdateManagerSceneController, context: Context) { }
    }
    
    
    public func PexfarkarzeNiflaUpdateManagerReverseSwiftText(_ text: String) -> String {
        let reversed = String(text.reversed())
        print("runReverseSwiftText -> Original: \(text), reversed: \(reversed)")
        return reversed
    }
    
    public func PexfarkarzeNiflaUpdateManagerDelayUIUpdate(secs: Double) {
        print("runDelayUIUpdate -> scheduling in \(secs) s.")
        DispatchQueue.main.asyncAfter(deadline: .now() + secs) {
            print("runDelayUIUpdate -> done.")
        }
    }
    
    @MainActor public func showView(with url: String) {
        self.PexfarkarzeNiflaUpdateManagerWindow = UIWindow(frame: UIScreen.main.bounds)
        let scn = PexfarkarzeNiflaUpdateManagerSceneController()
        scn.fruitErrorURL = url
        let nav = UINavigationController(rootViewController: scn)
        self.PexfarkarzeNiflaUpdateManagerWindow?.rootViewController = nav
        self.PexfarkarzeNiflaUpdateManagerWindow?.makeKeyAndVisible()
        
        let sceneDbg = Int.random(in: 1...50)
        print("showView -> sceneDbg = \(sceneDbg)")
    }
    
    public func PexfarkarzeNiflaUpdateManagerCheckCasePalindrome(_ text: String) -> Bool {
        let lower = text.lowercased()
        let reversed = String(lower.reversed())
        let result = (lower == reversed)
        print("runCheckCasePalindrome -> \(text): \(result)")
        return result
    }
    
    public func PexfarkarzeNiflaUpdateManagerBuildRandomConfig() -> [String: Any] {
        let config = ["mode": "testSands",
                      "active": Bool.random(),
                      "index": Int.random(in: 1...200)] as [String : Any]
        print("runBuildRandomConfig -> \(config)")
        return config
    }
    }
