//
//  AppStyles.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

// MARK: - Centralized Color Definitions
extension Color {
    static let primaryAppColor = Color(red: 18/255, green: 165/255, blue: 144/255) // #12A590
    static let pressedButtonColor = Color(red: 14/255, green: 125/255, blue: 110/255) // Darker shade
    static let appBackground = Color(red: 0xF1 / 255.0, green: 0xF1 / 255.0, blue: 0xF1 / 255.0) // #F1F1F1
    static let headingColor = Color(red: 26/255, green: 29/255, blue: 30/255) // #1A1D1E
    static let bodyTextColor = Color(red: 23/255, green: 23/255, blue: 23/255) // #171717
}

// MARK: - Custom Button Styles
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

struct SelectableButtonStyle: ButtonStyle {
    let isSelected: Bool
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundStyle(isEnabled ? (isSelected ? Color.primaryAppColor : Color.bodyTextColor) : Color.gray)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isEnabled ? (isSelected ? Color.primaryAppColor : Color.gray.opacity(0.5)) : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

