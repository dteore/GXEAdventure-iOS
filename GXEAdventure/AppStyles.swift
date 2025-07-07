//
//  AppStyles.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

// MARK: - Shared Data Models
/// A specific error type that is Identifiable, for use with SwiftUI alerts.
struct AppError: Identifiable, Error {
    let id = UUID()
    let message: String
}

// MARK: - Centralized Color Definitions
/// This extension holds all the custom colors used throughout the app.
extension Color {
    static let primaryAppColor = Color(red: 18/255, green: 165/255, blue: 144/255) // #12A590
    static let pressedButtonColor = Color(red: 14/255, green: 125/255, blue: 110/255) // Darker shade for pressed state
    static let appBackground = Color(red: 242/255, green: 242/255, blue: 242/255) // #F2F2F2
    static let headingColor = Color(red: 26/255, green: 29/255, blue: 30/255) // #1A1D1E
    static let bodyTextColor = Color(red: 23/255, green: 23/255, blue: 23/255) // #171717
}

// MARK: - Custom Button Styles

/// This is the style for primary action buttons (e.g., "GENERATE ADVENTURE").
struct PressableButtonStyle: ButtonStyle {
    let normalColor: Color
    let pressedColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .background(configuration.isPressed ? pressedColor : normalColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

/// This is the style for selectable options like Type and Theme.
struct SelectableButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundStyle(isSelected ? Color.primaryAppColor : Color.bodyTextColor)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.primaryAppColor.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.primaryAppColor : Color.gray.opacity(0.5), lineWidth: 1)
            )
    }
}

