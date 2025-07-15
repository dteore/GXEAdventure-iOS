//
//  FeedbackView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    
    // State for the form fields
    @State private var feedbackMessage: String = ""
    @State private var recommendApp: Bool? = nil // nil for not answered, true for Yes, false for No
    @State private var wantsFollowUp: Bool = false
    @State private var name: String = ""
    @State private var email: String = ""

    // A single state variable to handle validation alerts
    @State private var alertError: ErrorWrapper?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Text
                    Text("SHARE FEEDBACK")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.headingColor)
                        .padding(.top, 25)

                    Text("Share your experience using the app\n—every bit of feedback counts.")
                        .font(.body)
                        .foregroundStyle(Color.bodyTextColor)
                        .multilineTextAlignment(.center)

                    // Recommendation Section
                    HStack(spacing: 10) {
                        Text("WOULD YOU RECOMMEND THIS APP?")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.bodyTextColor)
                        
                        Spacer()

                        RecommendationButtons(selection: $recommendApp)
                    }
                    .padding(.top, 10)
                    
                    // Feedback Message Input
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        
                        if feedbackMessage.isEmpty {
                            Text("TYPE YOUR MESSAGE...")
                                .foregroundStyle(Color.gray.opacity(0.8))
                                .padding(EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0))
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $feedbackMessage)
                            .scrollContentBackground(.hidden)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
                    }
                    .frame(minHeight: 150)
                    
                    // Follow-up Section
                    Toggle(isOn: $wantsFollowUp.animation()) {
                        Text("FOLLOW UP WITH ME REGARDING MY FEEDBACK")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.bodyTextColor)
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .padding(.top, 10)

                    // Conditional fields for follow-up
                    if wantsFollowUp {
                        VStack(spacing: 15) {
                            TextField("NAME", text: $name)
                            TextField("EMAIL", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .textFieldStyle(CustomTextFieldStyle())
                        .transition(.opacity)
                    }

                    // Submit Button
                    Button("SUBMIT") {
                        submitFeedback()
                    }
                    .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .preferredColorScheme(.light)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .alert(item: $alertError) { errorWrapper in
                Alert(title: Text("Validation Error"), message: Text(errorWrapper.error.localizedDescription), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Validation and Submission Logic
    private func submitFeedback() {
        if feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertError = ErrorWrapper(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please type your feedback message."]))
            return
        }

        if wantsFollowUp {
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                alertError = ErrorWrapper(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Name is required if you wish to be followed up."]))
                return
            }
            if !isValidEmail(email) {
                alertError = ErrorWrapper(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please enter a valid email address."]))
                return
            }
        }
        
        print("Feedback Submitted:")
        print("- Message: \(feedbackMessage)")
        print("- Recommends: \(recommendApp.debugDescription)")
        print("- Wants Follow-up: \(wantsFollowUp)")
        if wantsFollowUp {
            print("- Name: \(name)")
            print("- Email: \(email)")
        }
        
        dismiss()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}

// MARK: - Reusable Child Views & Styles
private struct RecommendationButtons: View {
    @Binding var selection: Bool?
    
    var body: some View {
        HStack {
            Button("YES") { selection = true }
                .buttonStyle(RecommendationButtonStyle(isSelected: selection == true))
            
            Button("NO") { selection = false }
                .buttonStyle(RecommendationButtonStyle(isSelected: selection == false))
        }
    }
}

private struct RecommendationButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .foregroundColor(isSelected ? .white : Color.primaryAppColor)
            .padding(.vertical, 8)
            .frame(width: 60)
            .background(isSelected ? Color.primaryAppColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primaryAppColor, lineWidth: 1.5)
            )
    }
}

private struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Button {
                configuration.isOn.toggle()
            } label: {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(configuration.isOn ? Color.primaryAppColor : .gray)
            }
            configuration.label
        }
    }
}

private struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Preview
struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedbackView()
        }
    }
}

