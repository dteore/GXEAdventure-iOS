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
    static let primaryAppColor = Color(red: 174/255, green: 255/255, blue: 0/255) // Neon Green
    static let pressedButtonColor = Color(red: 139/255, green: 204/255, blue: 0/255) // Darker Neon Green
    static let appBackground = Color(red: 28/255, green: 28/255, blue: 28/255) // #1C1C1C
    static let headingColor = Color.white
    static let bodyTextColor = Color.white
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
            .foregroundStyle(.black)
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
            .foregroundStyle(isEnabled ? (isSelected ? Color.primaryAppColor : .white) : Color.gray) // Changed to white
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.appBackground) // Changed to appBackground
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isEnabled ? (isSelected ? Color.primaryAppColor : Color.gray.opacity(0.5)) : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}



