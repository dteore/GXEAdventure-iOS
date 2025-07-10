//
//  NotificationManager.swift
//  AdventureApp
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2023 YourCompany. All rights reserved.
//

import Foundation
import UserNotifications // Import UserNotifications framework for managing notifications

// ObservableObject allows this class to be observed by SwiftUI views using @StateObject or @ObservedObject.
class NotificationManager: ObservableObject {
    // @Published properties automatically announce when they change, triggering SwiftUI view updates.
    // This property will store the current authorization status for notifications.
    @Published var authorizationStatus: UNAuthorizationStatus?

    init() {
        // Fetch the current notification authorization status when the manager is initialized.
        fetchNotificationStatus()
    }

    // MARK: - Permission Request

    // This method requests authorization from the user to send notifications.
    func requestNotificationPermission() {
        // UNUserNotificationCenter.current() provides access to the shared notification center.
        // options specify the types of alerts the app wants to use (alert, sound, badge).
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                if granted {
                    self.authorizationStatus = .authorized // User granted permission.
                } else if let error = error {
                    self.authorizationStatus = .denied // Permission denied due to an error.
                } else {
                    self.authorizationStatus = .denied // User denied permission.
                }
            }
        }
    }

    // This method fetches and updates the current notification authorization status.
    func fetchNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                self.authorizationStatus = settings.authorizationStatus // Update the published status.
            }
        }
    }

}

