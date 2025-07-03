//
//  Colors.swift
//  breath
//
//  Created by pc on 24.06.25.
//

import SwiftUI

extension Color {
    // MARK: - App Colors
    static let inAppLabel = Color(red: 0.1, green: 0.1, blue: 0.2)
    static let inAppSecondaryLabel = Color(red: 0.2, green: 0.2, blue: 0.4)
    static let inAppSystemBackground = Color(red: 1, green: 1, blue: 1.0)
    static let inAppSecondarySystemBackground = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let inAppTertiarySystemBackground = Color(red: 0.88, green: 0.88, blue: 0.97)
    
    // MARK: - Accent Colors
    static let inAppBlue = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let inAppGreen = Color(red: 0.2, green: 0.7, blue: 0.4)
    static let inAppOrange = Color(red: 0.9, green: 0.6, blue: 0.2)
    static let inAppPurple = Color(red: 0.6, green: 0.4, blue: 0.9)
    
    // MARK: - Breathing Phase Colors (Rainbow Spectrum)
    static let inhaleColor = inAppBlue
    static let holdInColor = inAppPurple
    static let exhaleColor = inAppGreen
    static let holdOutColor = inAppOrange
}

// MARK: - Balloon Image Names
extension String {
    // Balloon image names for breathing phases
    static let inhaleBalloon = "blue"
    static let holdInBalloon = "purple"
    static let exhaleBalloon = "green"
    static let holdOutBalloon = "orange"
    
    // Additional balloon options for variety
    static let lightBlueBalloon = "lightBlue"
    static let lightGreenBalloon = "lightGreen"
    static let lightPinkBalloon = "lightPink"
    static let lightPurpleBalloon = "lightPurple"
    static let pinkBalloon = "pink"
    static let redBalloon = "red"
    static let whiteBalloon = "white"
    static let yellowBalloon = "yellow"
} 
