//
//  CommonButtons.swift
//  GXEAdventure
//
//  Created by Tech Debt Fixer on 2025-07-10.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

// MARK: - Close Button
struct CloseButton: View {
    let action: () -> Void
    var color: Color = .gray
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(color)
        }
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape")
                .font(.title2)
                .foregroundStyle(Color.headingColor)
                .padding(.top, 25)
                .padding(.trailing, 20)
        }
    }
}

// MARK: - Primary Action Button Style
extension View {
    func primaryActionButton() -> some View {
        self.buttonStyle(PressableButtonStyle(
            normalColor: .primaryAppColor,
            pressedColor: .pressedButtonColor
        ))
    }
}

// MARK: - Secondary Button (Skip Button Style)
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .foregroundStyle(.gray)
        .background(.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Section Header View
struct SectionHeaderView: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title.bold())
                .foregroundStyle(Color.headingColor)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.bodyTextColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 25)
    }
}