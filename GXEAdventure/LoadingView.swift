//
//  LoadingView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    @Binding var isLoading: Bool
    let cancelAction: () -> Void

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    // FIX: Button moved to the leading edge (left) with consistent padding.
                    Button(action: {
                        withAnimation {
                            cancelAction()
                            isLoading = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 10)
                    .padding(.top, 15)

                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2.0)
                    .tint(.primaryAppColor)

                Text("Creating adventure...")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.headingColor)
                    .padding(.top, 40)

                Text("We're crafting your personalized adventure now.")
                    .font(.body)
                    .foregroundStyle(Color.bodyTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical, 50)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(isLoading: .constant(true), cancelAction: {})
    }
}

