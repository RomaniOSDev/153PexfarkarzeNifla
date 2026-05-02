//
//  AppPalettes.swift
//  153PexfarkarzeNifla
//

import SwiftUI

/// Central palette lists keep heavy `Color` type-checking out of `@MainActor` view models (avoids compiler diagnostic failures).
enum AppPalettes {
    static func weaveRamp() -> [Color] {
        var colors: [Color] = []
        colors.reserveCapacity(5)
        colors.append(Color.appPrimary)
        colors.append(Color.appAccent)
        colors.append(Color.appSurface)
        colors.append(Color.appTextSecondary)
        colors.append(Color.appTextPrimary)
        return colors
    }

    static func mosaicRamp() -> [Color] {
        var colors: [Color] = []
        colors.reserveCapacity(4)
        colors.append(Color.appPrimary)
        colors.append(Color.appAccent)
        colors.append(Color.appSurface)
        colors.append(Color.appTextSecondary)
        return colors
    }

    static func doodleRamp() -> [Color] {
        mosaicRamp()
    }
}
