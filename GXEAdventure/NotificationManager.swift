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
                    print("Notification permission granted.")
                } else if let error = error {
                    self.authorizationStatus = .denied // Permission denied due to an error.
                    print("Notification permission error: \(error.localizedDescription)")
                } else {
                    self.authorizationStatus = .denied // User denied permission.
                    print("Notification permission denied.")
                }
            }
        }
    }

    // This method fetches and updates the current notification authorization status.
    func fetchNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                self.authorizationStatus = settings.authorizationStatus // Update the published status.
                print("Notification authorization status fetched: \(settings.authorizationStatus.rawValue)")
            }
        }
    }

    // MARK: - Example Notification (Optional)
    // This function demonstrates how to schedule a local notification.
    func scheduleTestNotification() {
        // Check if authorization is granted before scheduling.
        guard authorizationStatus == .authorized else {
            print("Cannot schedule notification: Authorization not granted.")
            return
        }

        let content = UNMutableNotificationContent() // Create notification content.
        content.title = "Adventure Alert!"
        content.body = "A new exclusive adventure drop is happening now! Don't miss out."
        content.sound = .default // Use the default notification sound.

        // Create a trigger (e.g., after 5 seconds).
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Create a request with a unique identifier.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Add the request to the notification center.
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled!")
            }
        }
    }
}

