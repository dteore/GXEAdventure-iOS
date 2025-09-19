//
//  SettingsView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI
import CoreLocation
import UserNotifications

struct SettingsView: View {
    // Environment for dismissing the sheet
    @Environment(\.dismiss) private var dismiss

    // State to manage which sheet is being presented
    @State private var activeSheet: ActiveSheet?

    enum ActiveSheet: Identifiable {
        case terms, privacy, feedback
        
        var id: Int {
            hashValue
        }
    }

    var body: some View {
        NavigationView {
            Form {
                PermissionsSection()
                GeneralSection(activeSheet: $activeSheet)
            }
            .scrollContentBackground(.hidden)
            .background(Color.black) // Apply background to the Form
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white) // Ensure text is visible on dark background
                }
            }
            // A single sheet modifier to handle all modal presentations.
            .sheet(item: $activeSheet) { item in
                switch item {
                case .terms:
                    // Assumes SafariView is defined elsewhere in the project.
                    SafariView(url: URL(string: "https://nvrse-gxe.web.app/terms-and-conditions.html")!)
                case .privacy:
                    // Assumes SafariView is defined elsewhere in the project.
                    SafariView(url: URL(string: "https://nvrse-gxe.web.app/privacy-policy.html")!)
                case .feedback:
                    // Assumes FeedbackView is defined elsewhere in the project.
                    FeedbackView()
                }
            }
        }
        .background(Color.black.ignoresSafeArea()) // Apply background to the NavigationView
    }
}

// MARK: - Child Views
private struct PermissionsSection: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject private var adventureViewModel: AdventureViewModel
    
    var body: some View {
        Section(header: Text("Device Permissions").foregroundColor(.white).padding(.top, 25)) {
            PermissionRow(
                title: "Location Services",
                iconName: "location.fill",
                iconColor: .blue,
                status: locationStatusString(for: adventureViewModel.locationManager.authorizationStatus)
            )
            
            PermissionRow(
                title: "Notifications",
                iconName: "bell.fill",
                iconColor: .orange,
                status: notificationStatusString(for: notificationManager.authorizationStatus)
            )

            // A single button to open the device settings for the app
            Button("Manage Permissions in Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .foregroundColor(.blue) // Make it blue to look clickable
        }
        .listRowBackground(Color.black) // Apply background to list rows
        // Fetch the latest permission statuses when the view appears or returns to the foreground.
        .onAppear {
            notificationManager.fetchNotificationStatus()
            adventureViewModel.locationManager.fetchLocationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            notificationManager.fetchNotificationStatus()
            adventureViewModel.locationManager.fetchLocationStatus()
        }
    }
    
    // MARK: - Helper Functions for Status Strings
    private func locationStatusString(for status: CLAuthorizationStatus?) -> String {
        guard let status = status else { return "Unknown" }
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: return "Allowed"
        case .denied, .restricted: return "Denied"
        case .notDetermined: return "Not Asked"
        @unknown default: return "Unknown"
        }
    }

    private func notificationStatusString(for status: UNAuthorizationStatus?) -> String {
        guard let status = status else { return "Unknown" }
        switch status {
        case .authorized: return "Allowed"
        case .denied: return "Denied"
        case .notDetermined: return "Not Asked"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
}

private struct GeneralSection: View {
    @Binding var activeSheet: SettingsView.ActiveSheet?
    
    var body: some View {
        Section(header: Text("General").foregroundColor(.white)) {
            Button("Terms of Service") { activeSheet = .terms }
                .foregroundColor(.white) // Ensure text is visible on dark background
            
            Button("Privacy Policy") { activeSheet = .privacy }
                .foregroundColor(.white) // Ensure text is visible on dark background
            
            Button("Send Feedback") { activeSheet = .feedback }
                .foregroundColor(.white) // Ensure text is visible on dark background
        }
        .listRowBackground(Color.black) // Apply background to list rows
    }
}

// MARK: - Reusable Row Component
private struct PermissionRow: View {
    let title: String
    let iconName: String
    let iconColor: Color
    let status: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 25, alignment: .center)
            Text(title)
                .foregroundColor(.white) // Ensure text is visible on dark background
            Spacer()
            Text(status)
                .font(.subheadline)
                .foregroundColor(.white) // Ensure text is visible on dark background
        }
    }
}


// MARK: - Previews
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(NotificationManager())
            .environmentObject(AdventureViewModel(locationManager: LocationManager()))
    }
}
