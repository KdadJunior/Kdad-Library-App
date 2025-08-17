//
//  ThemeManager.swift
//  Kdad-Library-App
//
//  Created by user on 8/16/25.
//

import Foundation
import UIKit

enum AppAppearance: Int {
    case system = 0, light, dark
}

enum AppTint: Int, CaseIterable {
    case indigo = 0, blue, green, orange, pink

    var color: UIColor {
        switch self {
        case .indigo: return .systemIndigo
        case .blue:   return .systemBlue
        case .green:  return .systemGreen
        case .orange: return .systemOrange
        case .pink:   return .systemPink
        }
    }

    var title: String {
        switch self {
        case .indigo: return "Indigo"
        case .blue:   return "Blue"
        case .green:  return "Green"
        case .orange: return "Orange"
        case .pink:   return "Pink"
        }
    }
}

enum ThemeManager {
    private static let appearanceKey = "AppearancePreference"
    private static let tintKey = "TintPreference"

    // MARK: - Read current
    static var currentAppearance: AppAppearance {
        AppAppearance(rawValue: UserDefaults.standard.integer(forKey: appearanceKey)) ?? .system
    }

    static var currentTint: AppTint {
        AppTint(rawValue: UserDefaults.standard.integer(forKey: tintKey)) ?? .indigo
    }

    // MARK: - Apply / Persist
    static func setAppearance(_ appearance: AppAppearance) {
        UserDefaults.standard.set(appearance.rawValue, forKey: appearanceKey)
        applyAppearance(appearance)
    }

    static func setTint(_ tint: AppTint) {
        UserDefaults.standard.set(tint.rawValue, forKey: tintKey)
        applyTint(tint)
    }

    static func applyAppearance(_ appearance: AppAppearance = currentAppearance) {
        let style: UIUserInterfaceStyle
        switch appearance {
        case .system: style = .unspecified
        case .light:  style = .light
        case .dark:   style = .dark
        }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.overrideUserInterfaceStyle = style
    }

    static func applyTint(_ tint: AppTint = currentTint) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.tintColor = tint.color
    }

    /// Call this once at app start (optional, but nice if user reopens the app).
    static func bootstrap() {
        applyAppearance()
        applyTint()
    }
}
