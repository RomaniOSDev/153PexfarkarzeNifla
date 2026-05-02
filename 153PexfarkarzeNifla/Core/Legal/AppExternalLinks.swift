//
//  AppExternalLinks.swift
//  153PexfarkarzeNifla
//

import Foundation
import StoreKit
import UIKit

/// Central place for outbound URLs used from Settings.
enum AppExternalLink: String, CaseIterable {
    case privacyPolicy = "https://pexfarkarzenifla153.site/privacy/135"
    case termsOfUse = "https://pexfarkarzenifla153.site/terms/135"

    var url: URL? {
        URL(string: rawValue)
    }

    var menuTitle: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfUse:
            return "Terms of Use"
        }
    }
}

enum AppSettingsActions {
    static func openPolicy() {
        if let url = URL(string: AppExternalLink.privacyPolicy.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    static func openTerms() {
        if let url = AppExternalLink.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }

    static func open(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    static func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
