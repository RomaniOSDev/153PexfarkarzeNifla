//
//  HapticFeedback.swift
//  153PexfarkarzeNifla
//

import UIKit

enum HapticFeedback {
    static func light(enabled: Bool) {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium(enabled: Bool) {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
