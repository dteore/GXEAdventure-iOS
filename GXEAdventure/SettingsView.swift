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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryAppColor)
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
    }
}

// MARK: - Child Views
private struct PermissionsSection: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        Section(header: Text("Device Permissions")) {
            PermissionRow(
                title: "Location Services",
                iconName: "location.fill",
                iconColor: .blue,
                status: locationStatusString(for: locationManager.authorizationStatus)
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
            .foregroundColor(.primaryAppColor)
        }
        // Fetch the latest permission statuses when the view appears or returns to the foreground.
        .onAppear {
            notificationManager.fetchNotificationStatus()
            locationManager.fetchLocationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            notificationManager.fetchNotificationStatus()
            locationManager.fetchLocationStatus()
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
        Section(header: Text("General")) {
            Button("Terms of Service") { activeSheet = .terms }
                .foregroundColor(.primary)
            
            Button("Privacy Policy") { activeSheet = .privacy }
                .foregroundColor(.primary)
            
            Button("Send Feedback") { activeSheet = .feedback }
                .foregroundColor(.primary)
        }
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
            Spacer()
            Text(status)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}


// MARK: - Previews
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(NotificationManager())
            .environmentObject(LocationManager())
    }
}

