//
//  SplashView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//
import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var isActive = false
    @State private var progressValue: Double = 0.0

    var body: some View {
        ZStack {
            // FIX: Restored the original teal background color.
            Color(red: 216 / 255.0, green: 247 / 255.0, blue: 236 / 255.0)
                .ignoresSafeArea()

            Text("NVRSE")
                .font(.system(size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize * 1.25))
                .fontWeight(.bold)
                .foregroundColor(Color.primaryAppColor)
                .scaleEffect(isActive ? 1.0 : 0.8)
                .opacity(isActive ? 1.0 : 0.5)

            VStack {
                Spacer()
                ProgressView(value: progressValue)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryAppColor))
                    .frame(width: 200)
                    .padding(.bottom, 50)
                    .opacity(isActive ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                self.isActive = true
            }

            // Animate Progress Bar using the original Timer logic
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                if self.progressValue < 1.0 {
                    // Ensure progress value doesn't exceed 1.0, fixing the warning.
                    self.progressValue = min(1.0, self.progressValue + 0.025)
                } else {
                    timer.invalidate()
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.showSplash = false
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(showSplash: .constant(true))
    }
}

